/* 
Copyright: 2001-2005 The Perl Foundation.  All Right Reserved.
$Id: $

=head1 NAME

src/gc_gmc.c - Generational Mark & Compact Garbage Collection


=head1 OVERVIEW

This is a generational GC scheme that introduces copying and compaction to 
Parrot.
Keywords:
- copying, compacting
- mark and sweep
- generational


=head1 DESCRIPTION

=head2 Object structure

In GMC, we add a new indirection level to objects, which will allow us to move
objects without invalidating external references.
In the old scheme, a PMC is basically :

    ...[ Flags ][ UnionVal ][ VTABLE* ][ PMC_Ext* ]...

The data of the PMC is stored in UnionVal. To be more flexible, it can have a
pointer to a PMC_Ext structure where anything can be stored (including pointers 
to other PMCs, which is of great interest to us). The various flags used by the 
PMC itself, DOD system and other bits of parrot are in the header.

In GMC, a PMC will become the following :

    ...[ Flags ][ PMC_Body* ][ VTABLE* ]...      <---- Fixed Header
       ^           |
       |	   +---> [ Gmc_Flags ][ PMC* ][ Gen* ][ UnionVal ][ PMC_Ext ]...
       |	                         |
       +---------------------------------+      ^   
						+---- Moveable Body

The PObj_Flags are still in the header, as well as the pointer to the VTable,
but everything else is moved in the pmc_body. We have there special Gmc_flags
(because there is no room left in the PObj_flags...), a pointer to the fixed
header, a pointer to the generation it belongs to (more on generations later),
the header that was previously in the PMC_Ext structure and the pointer to
additional data.

This scheme can be changed, as long as the Gc_gmc_hdr (Gmc_Flags + PMC* + Gen*)
remains in front of the body. To do this, the PMC must undef PMC_BODY and
redefine it to its conveniance. The size field of the VTable must be updated
too.

Thus, we can move the body anywhere as long as we update the PMC_body* pointer 
of the fixed header. The wild world will only see the PMC*, and adding the 
indirection is handled in the macros of include/parrot/pobj.h


PObj (buffers) are handled in the same way except that they have less fields 
(no VTABLE, no PMC_Ext related structure).


=head2 Object Allocation

We have to separate the allocation in two phases : one for fixed header, the 
other for the body.

Fixed headers are allocated from Small_Object_Arenas which are organized in a 
linked list (from pool->last_Arena). As we can have "holes" in these arenas, 
when objects are destroyed, we need to keep track of who is allocated and who 
isn't. We currently use a bitmap for this but it is non-optimal as finding the 
bitmap from the mere address of an object is in O(#{Arenas}). Another solution 
would be to use a PObj flag for that (it would then become O(1)) but the flag 
seemed to get corrupted somehow, so this is not implemented yet.

As headers have all the same size (pool->object_size), finding a new place to al
locate a header is just a matter of finding a hole in any arena. Alternatively,
if none is available, we can just allocate a new arena and append it to the 
list.


On the other hand, bodies are variable-sized. To be able to run the GC, we need 
them to be allocated with an invariant : an object A is older than an object B 
if and only if the address of the body of A is higher than the one of B. And we 
add another rule : an aggregate object (i.e. contains pointers to other objects)
is always younger than a non-aggregate one.

We store bodies in structures called generations. A generation looks like :

    ...[ Stats ][ Gen *prev ][ Gen *next ][ first ][ fst_free ][ remaining ]...
					     |          |            |
       +-------------------------------------+          | ___________|_
       v			   +--------------------+{             }
    ...[ XXXXX Used memory XXXXXX ][ 000000 Not used yet memory 000000 ]...

    ...[ Stats ][ Gen *prev ][ Gen *next ][ remaining ][ fst_free ][ first ]...
                      +-------------------------+           |          |
        ______________|__________________ +-----------------+          +---+
       {                                 }v                                v
    ...[ 0000000 Unused memory 000000000 ][ XXXXXXXXX Used memory XXXXXXXXX]...

    
The area between C<fst_free - remaining> and C<first> has been allocated at the
time of the generation initialization and is fixed. We allocate objects at
fst_free, moving accordingly the fst_free pointer and the remaining indicator.
When remaining is not high enough for allocating the object, we switch to gen->next
which, by construction, has a memory address higher than the current gen.

Generations are organized in the following way :
      
          free            allocated            free          allocated
        _________  _____________________     ________  ______________________
       {         }{                     }   {        }{                      }

    ...[...]<-[yng_lst]<-[...]<-[yng_fst] | [...]<-[old_lst]<-[...]<-[old_fst]..
    
       {________________________________}   {________________________________}
              aggregate objects                   non- aggregate objects


Thus the allocation is pretty straightforward : start at old_lst or yng_lst
depending on whether you are an aggregate or not, return fst_free - size if
there is enough space or switch to the next gen.

When no more generations are available, we have to reallocate a whole new set
of generations, copy the whole content of the current set to the new one,
update pointers and free the now unused set.


=head2 GC run

The main idea behind the GC is that we are using a functional language. And, as
such, once created, objects can't be modified. This means that they can have
pointers only to objects that already existed when they were created, thus 
older.
(see src/gc_gms.c for a more detailed description of this).

We can then mark all the objects in a single pass by walking the memory from
higher addresses (youngest objects) to lower memory (oldest objects). If an 
object has not been marked alive by younger objects or the root set, then it
is dead and can be safely removed.

Another important thing is that we can stop the marking pass at any point and
still be sure about the status of all the objects we have examined. This leads
the way to our generational GC.

But of course, things are not so simple, as imperative instructions 
(modification of an already existing object) can set pointers in the other way 
(from old objects to young ones). We need to track these I<inter-generational 
pointers> (IGP). For this, we use a write barrier that is called each time such 
an imperative instruction is executed.

An IGP is a pointer from a PMC p0 to a PMC p1. It is marked as such in two 
ways : p0 has a Gmc_flag (is_igp) that is set, and p0 is added to the list of 
igp headers in its generation.

We adopt the following convention in our pseudo code : a children of an object 
is an older object pointed by this object, while a son is a younger object 
pointed by the object. Thus p0 -> p1 is an IGP iff p1 is a son of p0.

Then the marking pass is :

    mark root set;
    start from yng_lst;
    while (objects_scavenged < dead_objects_wanted) {
	if (current_object is alive) {
	    mark its children as alive;
	    if (current_object has Gmc_is_igp_flag) {
		mark_igp_sons(current_object);
	    }
	} else {
	    objects_scavenged++;
	}
    }
    forall(igp of non-examined_gen) {
	mark_igp_sons(igp);
    }


where the function mark_igp_sons is the following :
    
    forall(children(object)) {
	if (child is *not* alive) {
	    mark_alive(child);
	    mark_igp_sons(child);
	    if (child has Gmc_is_igp_flag) {
		forall(sons(child)) {
		    mark_igp_sons(grandson);
		}
	    }
	}


This allows us to collect dead cycles and to be generational, as once we have 
found enough dead objects, only igp related will be examined.


The second phase of the gc run is compaction. As running the marking pass will 
find dead objects, simply removing them will result in a waste of memory due to 
our allocation scheme. We thus have to recompact every generation that suffered 
losses, in order to be able to reuse this memory without violating our 
invariant.

Compacting is done separately for each generation, destroying dead objects when
encountered and moving live objects to cover each gap so created. Live objects 
are then marked as dead in prevision of the next GC run.

Generations will then be half (or less)-filled. If there is enough space in a
generation to copy the contents of the one just younger, then we merge the two
of them. If not, we don't touch anything.


=cut

*/
#include <parrot/parrot.h>

#if PARROT_GC_GMC



/* How many more objects do we want allocated next time ? */
#define UNITS_PER_ALLOC_GROWTH_FACTOR 1.75
/* Hard limit for a single header allocation. */
#define POOL_MAX_BYTES 65536*128


/* Uncomment for *heavy* debug information. */
/* #define GMC_DEBUG */

/*
 * Static forward definitions.
 */

static void gc_gmc_add_free_object(Interp*, struct Small_Object_Pool*, void*);
static void *gc_gmc_get_free_typed_object(Interp*, struct Small_Object_Pool*,
	INTVAL);
static void *gc_gmc_get_free_sized_object(Interp*, struct Small_Object_Pool*,
	size_t);
static void *gc_gmc_get_free_object(Interp*, struct Small_Object_Pool*);
static void gc_gmc_alloc_objects(Interp*, struct Small_Object_Pool*);
static void gc_gmc_more_objects(Interp*, struct Small_Object_Pool*);
static void gc_gmc_more_bodies(Interp *, struct Small_Object_Pool*);
static void gc_gmc_compact(Interp *, struct Small_Object_Pool *);
static INTVAL gc_gmc_mark(Interp *, struct Small_Object_Pool *, int);
static int gc_gmc_clear_live(Interp *, struct Small_Object_Pool *, int, void *);
static int sweep_pmc(Interp *, struct Small_Object_Pool *, int, void *);
static int sweep_buf(Interp *, struct Small_Object_Pool *, int, void *);
static void gc_gmc_run(Interp *, int);



/*


=head2 Initialisation functions

=over 4

=item C<static Gc_gmc_gen *gc_gmc_gen_init(Interp *, struct Small_Object_Pool *)>

Allocate a new generation of size GMC_GEN_SIZE and fill its fields but do not plus it in the pool yet.


=item C<static void gc_gmc_insert_gen(Interp *, Gc_gmc *, Gc_gmc_gen *)>

Insertion sort function. Generations must be keeped sorted by memory address, so insert this one in the right place in the gc structure.


=item C<static void gc_gmc_pool_init(Interp *, struct Small_Object_Pool *)>

Initialize the pool and create GMC_GEN_INIT_NUMBER generation. Organize these generations in 'young' and 'old' sets.


=item C<static void gc_gmc_pool_deinit(Interp *, struct Small_Object_Pool *)>

Frees all gc related resources in a pool.


=item C<static void gc_gmc_deinit(Interp *)>

Frees all global resources (i.e. not related to a specific pool).


=item C<void Parrot_gc_gmc_init(Interp *)>

Initialize the whole GC system.


=back

=cut

*/

#if 0

/* Allocates a new empty bitmap of the requested size. */
static gmc_bitmap
gc_gmc_new_bitmap(UINTVAL nb_elem)
{
    gmc_bitmap bitmap;
    UINTVAL size = (nb_elem/8) + 1;
    bitmap = mem_sys_allocate_zeroed(size * sizeof(gmc_bmp_elem));
    return bitmap;
}

/* Tests if the nth bit is set. */
UINTVAL
gc_gmc_bitmap_test(gmc_bitmap bitmap, UINTVAL bit)
{
    UINTVAL cell = bit / 8;
    UINTVAL offs = bit % 8;
    gmc_bmp_elem elem = bitmap[cell];
    return (elem & (1 << offs));
}

/* Sets the nth bit. */
void
gc_gmc_bitmap_set(gmc_bitmap bitmap, UINTVAL bit)
{
    UINTVAL cell = bit / 8;
    UINTVAL offs = bit % 8;
    bitmap[cell] |= 1 << offs;
}


/* Clears the nth bit. */
void
gc_gmc_bitmap_clear(gmc_bitmap bitmap, UINTVAL bit)
{
    UINTVAL cell = bit / 8;
    UINTVAL offs = bit % 8;
    bitmap[cell] &= ~(1 << offs);
}

/* Find the header in the arenas and clear its bit. */
static void
gc_gmc_bitmap_clear_from_hdr(PObj *obj, struct Small_Object_Pool *pool)
{
    struct Small_Object_Arena *arena;
    INTVAL index;

    for (arena = pool->last_Arena; arena && ((UINTVAL)obj < (UINTVAL)arena->start_objects || (UINTVAL)obj >= (UINTVAL)arena->start_objects + arena->total_objects * pool->object_size); arena = arena->prev);
    if (!arena)
    {
	*(int*)NULL = 54;
	internal_exception(1, "PObj not found in any arena\n");
	return;
    }
    index = ((UINTVAL)obj - (UINTVAL)arena->start_objects) / pool->object_size;
    gc_gmc_bitmap_clear(arena->bitmap, index);
}

#endif


/* Allocates and initializes a generation, but does not plug it 
 * to the pool yet. */
    static Gc_gmc_gen *
gc_gmc_gen_init(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc_gen *gen;
    Gc_gmc_hdr_list *IGP;
    Gc_gmc_hdr_store *IGP_store;

    gen = mem_sys_allocate(sizeof(Gc_gmc_gen));
    gen->first = mem_sys_allocate(GMC_GEN_SIZE);
    /* Move gen->first to the END of the allocated zone. */
    gen->first = (void*)((char*)gen->first + GMC_GEN_SIZE);

    /* And fill the blanks. */
    gen->fst_free = gen->first;
    gen->remaining = GMC_GEN_SIZE;
    gen->alloc_obj = 0;
    gen->pool = pool;

    /* We have an IGP basis : only one store. */
    IGP_store = mem_sys_allocate(sizeof(Gc_gmc_hdr_store));
    IGP_store->ptr = &(IGP_store->store[0]);
    IGP_store->next = NULL;
    IGP = mem_sys_allocate(sizeof(Gc_gmc_hdr_list));
    IGP->first = IGP_store;
    IGP->last = IGP_store;
    gen->IGP = IGP;

#ifdef GMC_DEBUG
    fprintf(stderr, "Allocating gen at %p, first at %p, limit at %p\n",
	    gen, gen->first, (char*)gen->first + gen->remaining);
#endif

    return gen;
}


/* Checks if the linked list of generations is valid. Can be removed safely,
 * useful only for tests. */
    static void
gc_gmc_test_linked_list_gen(Interp *interpreter, Gc_gmc *gc)
{
    Gc_gmc_gen *gen;
    UINTVAL i,j;
    for (i = 0, gen = gc->old_fst; gen; i++, gen = gen->next);
    for (j = 0, gen = gc->yng_lst; gen; j++, gen = gen->prev);
    if (i != gc->nb_gen || j != gc->nb_gen)
    {
#ifdef GMC_DEBUG
	fprintf(stderr, "Invalid linked list\n");
#endif
	gen = NULL;
	*(int*)gen = 54;
    } 
#ifdef GMC_DEBUG
    else
	fprintf(stderr, "Linked list is OK !\n");
#endif
}

/* Inserts the given generation to the right place, keeping all generation 
 * sorted (by insertion sort). */
    static void
gc_gmc_insert_gen(Interp *interpreter, Gc_gmc *gc, Gc_gmc_gen *gen)
{
    Gc_gmc_gen *cur_gen;
    void *ptr;

    cur_gen = gc->old_fst;
    if (cur_gen)
	ptr = (void*)cur_gen->first;
    else
	ptr = NULL;

    /* Find the right place for the address malloc gave us. */
    while ((UINTVAL)ptr > (UINTVAL)gen->first)
    {
	cur_gen = cur_gen->next;
	if (cur_gen)
	    ptr = cur_gen->first;
	else
	    ptr = NULL;
    }

    /* Insert the generation. */
    if (cur_gen)
    {
	if (cur_gen->prev)
	{
	    cur_gen->prev->next = gen;
	}
	gen->prev = cur_gen->prev;
	cur_gen->prev = gen;
    } else {
	if (gc->yng_lst)
	{
	    gen->prev = gc->yng_lst;
	    gc->yng_lst->next = gen;
	    gc->yng_lst = gen;
	} else {
	    gen->prev = NULL;
	    gc->old_fst = gen;
	    gc->yng_lst = gen;
	}
    }
    gen->next = cur_gen;
    if (gc->old_fst == cur_gen)
	gc->old_fst = gen;
}



/* Initializes a pool with some empty generations. */
    static void 
gc_gmc_pool_init(Interp *interpreter, struct Small_Object_Pool *pool) 
{
    struct Arenas *arena_base;
    Gc_gmc *gc, *dummy_gc;
    Gc_gmc_gen *gen;
    int i;

    pool->add_free_object = gc_gmc_add_free_object;
    pool->get_free_object = gc_gmc_get_free_object;
    pool->get_free_typed_object = gc_gmc_get_free_typed_object;
    pool->get_free_sized_object = gc_gmc_get_free_sized_object;
    pool->alloc_objects   = gc_gmc_alloc_objects;
    pool->more_objects    = gc_gmc_more_objects;

    gc = mem_sys_allocate(sizeof(Gc_gmc));
    dummy_gc = mem_sys_allocate_zeroed(sizeof(Gc_gmc));

    gc->nb_gen = GMC_GEN_INIT_NUMBER;
    gc->nb_empty_gen = GMC_GEN_INIT_NUMBER;
    gc->alloc_obj = 0;
    gc->yng_fst = NULL;
    gc->yng_lst = NULL;
    gc->old_fst = NULL;
    gc->old_lst = NULL;
    gc->igp_ref = NULL;
    gc->gray = NULL;
    gc->dummy_gc = dummy_gc;
    gc->state = GMC_NORMAL_STATE;
    gc->timely = gc_gmc_gen_init(interpreter, pool);
    gc->constant = gc_gmc_gen_init(interpreter, pool);
    pool->gc = gc;

    for (i = 0; i < GMC_GEN_INIT_NUMBER; i++)
    {
	gen = gc_gmc_gen_init(interpreter, pool);
	gc_gmc_insert_gen(interpreter, gc, gen);
    }

    gc_gmc_test_linked_list_gen(interpreter, gc);

    /* Separate the generations in two halves : one is young (= aggregate
     * objects), the other is old (non-aggregate objects). */
    for (i = 0, gen = gc->old_fst; i < (GMC_GEN_INIT_NUMBER/2);
	    i++, gen = gen->next);
    gc->yng_fst = gen;
    gc->yng_lst = gen;
    /* Now cut the bridges between these two parts. */
    gen->prev->next = NULL;
    gen->prev = NULL;
    gc->old_lst = gc->old_fst;
    gc->white = gc->old_fst->first;
#ifdef GMC_DEBUG
    for (i = 0, gen = gc->old_fst; ; gen = gen->next)
    {
	if (!gen)
	{
	    if (i++)
		return;
	    gen = gc->yng_fst;
	}
	fprintf(stderr, "pool_init: gen: %p : %p -> %p\n", gen, (char*)gen->fst_free - gen->remaining, gen->first);
    }
#endif
}



/* Frees all the generations and GC related objects in a pool. */
    static void
gc_gmc_pool_deinit(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc *gc;
    Gc_gmc_gen *gen, *gen_nxt;
    Gc_gmc_hdr_store *store, *st2;

    gc = pool->gc;
    for (gen = gc->yng_fst; gen;)
    {
	gen_nxt = gen->next;
	for (store = gen->IGP->first; store; st2 = store->next, mem_sys_free(store), store = st2);
	mem_sys_free((char*)gen->fst_free - gen->remaining);
	mem_sys_free(gen);
	gen = gen_nxt;
    }

    for (gen = gc->old_fst; gen;)
    {
	gen_nxt = gen->next;
	for (store = gen->IGP->first; store; st2 = store->next, mem_sys_free(store), store = st2);
	mem_sys_free((char*)gen->fst_free - gen->remaining);
	mem_sys_free(gen);
	gen = gen_nxt;
    }
}


static void gc_gmc_deinit(Interp *interpreter)
{
    /* There's nothing to do... */
}


void Parrot_gc_gmc_init(Interp *interpreter)
{
    struct Arenas *arena_base;

    arena_base = interpreter->arena_base;

    arena_base->do_dod_run = gc_gmc_run;
    arena_base->de_init_gc_system = gc_gmc_deinit;
    arena_base->init_pool = gc_gmc_pool_init;
}



/*


=head2 Interface functions

=over 4

=item C<static void gc_gmc_add_free_object(Interp *, void *)>

Unused. Raises internal exception.


=item C<static void *gc_gmc_get_free_object(Interp *, struct Small_Object_Pool *)>

Returns a pointer to a PObj (buffer) freshly allocated.


=item C<static void *gc_gmc_get_free_typed_object(Interp *, struct Small_Object_Pool *, INTVAL)>

Returns a pointer to a new PMC of type C<base_type>, which is an index in C<Parrot_base_vtables>.


=item C<static void *gc_gmc_get_free_sized_object(Interp *, struct Small_Object_Pool *, size_t)>

Returns a pointer to a new non-aggregative PMC (unless C<size == sizeof(pobj_body)>) whose body has exactly the required size. 


=item C<static void gc_gmc_alloc_objects(Interp *, struct Small_Object_Pool *)>

Allocates new object headers (not bodies) for the pool.


=item C<static void gc_gmc_more_objects(Interp *, struct Small_Object_Pool *)>

Makes more object headers available.


=item C<static void gc_gmc_more_bodies(Interp *, struct Small_Object_Pool *)>

Makes more object bodies available.

I<NB> : this function has no hook in the C<Small_Object_Pool> structure.

=back

=cut

*/




/* Determines the size of a PMC according to its header. */
    static size_t
gc_gmc_get_size(Interp *interpreter, Gc_gmc_hdr *hdr)
{
    if (PObj_is_PMC_TEST(Gmc_PMC_hdr_get_PMC(hdr)))
	return (Gmc_PMC_hdr_get_PMC(hdr)->vtable->size 
		+ sizeof(Gc_gmc_hdr));
    else
	return (sizeof(Gc_gmc_hdr) + sizeof(pobj_body));
}




/* Returns the next header in the area, assuming that we have not gone further
 * than gen->fst_free. */
static Gc_gmc_hdr *
gc_gmc_next_hdr(Gc_gmc_hdr *hdr)
{
    if (PObj_is_PMC_TEST(Gmc_PMC_hdr_get_PMC(hdr)))
	return (Gc_gmc_hdr*)((char*)hdr + 
		Gmc_PMC_hdr_get_PMC(hdr)->vtable->size 
		+ sizeof(Gc_gmc_hdr));
    else
	return (Gc_gmc_hdr*)((char*)hdr 
		+ sizeof(Gc_gmc_hdr) + sizeof(pobj_body));
}


/* Should not be called anywhere. */
    static void
gc_gmc_add_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool, void *to_add)
{
    *(void**)to_add = pool->free_list;
    pool->free_list = to_add;
}


/* Allocate a body of the required size. */
static Gc_gmc_hdr *
gc_gmc_new_body(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size, INTVAL aggreg)
{
    Gc_gmc_hdr *hdr;
    void *ptr;
    UINTVAL i;
    Gc_gmc *gc = pool->gc;
    Gc_gmc_gen *gen, *gen_ref;

    /* Allocate the pmc_body */
    gen = (aggreg) ? gc->yng_lst : gc->old_lst;

    /* Should we use the next generation ? */
    if (size >= gen->remaining)
    {
	if (aggreg)
	    gc->yng_lst = gen->next;
	else
	    gc->old_lst = gen->next;
	gen = gen->next;
    }

    /* Do we need more generations ? */
    if (!gen)
	gc_gmc_more_bodies (interpreter, pool);

    gen = (aggreg) ? gc->yng_lst : gc->old_lst;

    /* Should we use the next generation ? */
    if (size >= gen->remaining)
    {
	if (aggreg)
	    gc->yng_lst = gen->next;
	else
	    gc->old_lst = gen->next;
	gen = gen->next;
    }

    gen->fst_free = (void*)((char*)gen->fst_free - size);
    hdr = gen->fst_free;
    gen->remaining -= size;
    gen->alloc_obj++;
    memset(hdr, 0, size);
    Gmc_PMC_hdr_set_GEN(hdr, gen);
	
    return hdr;
}



/* Returns a new object with a body of the required size. */
    static void *
gc_gmc_get_free_object_of_size(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size, INTVAL aggreg)
{
    Gc_gmc_hdr *hdr;
    void *obj;
    void *ptr;
    struct Small_Object_Arena *arena;
    
    hdr = gc_gmc_new_body(interpreter, pool, size, aggreg);
    
    if (!pool->free_list)
	(*pool->more_objects)(interpreter, pool);

    obj = pool->free_list;
    pool->free_list = *(void**)pool->free_list;

    PObj_flags_SETTO((PObj*)obj, 0);
    
    pool->num_free_objects--;
    PMC_body((PMC*)obj) = Gmc_PMC_hdr_get_BODY(hdr);
    Gmc_PMC_hdr_get_PMC(hdr) = obj;
    assert(obj);

#ifdef BIG_DUMP
    fprintf(stderr, "Allocated obj %p -> (%p, %p) (pool %p, new free_list: %p)\n", obj, hdr, Gmc_PMC_hdr_get_BODY(hdr), pool, pool->free_list);
#endif
    return obj;
}


/* Here we allocate a default PObj, as it is non-typed. */
/* This function should not be called anywhere if possible. */
    void *
gc_gmc_get_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    size_t size = sizeof(Gc_gmc_hdr) + sizeof(pobj_body);
    PMC *pmc = gc_gmc_get_free_object_of_size(interpreter, pool, size, 0);
    return pmc;
}



/* Returns a PObj of the required size. */
    static void *
gc_gmc_get_free_sized_object(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size)
{
    PMC *pmc = gc_gmc_get_free_object_of_size (interpreter, pool,
	    sizeof(Gc_gmc_hdr) + size, 0);
    return pmc;
}

/* Returns a PMC of type base_type (which is an index into 
 * Parrot_base_vtables). */
    static void *
gc_gmc_get_free_typed_object(Interp *interpreter,
	struct Small_Object_Pool *pool, INTVAL base_type)
{
    Gc_gmc *gc = pool->gc;
    VTABLE *vtable = Parrot_base_vtables[base_type];
    INTVAL aggreg = vtable->flags & VTABLE_PMC_NEEDS_EXT;
    size_t size = sizeof(Gc_gmc_hdr) + vtable->size;
    PMC *pmc = gc_gmc_get_free_object_of_size (interpreter, pool, size, aggreg);
    return pmc;
}



/* Allocates a new Small_Object_Arena and links it to the current pool. */
    static void 
gc_gmc_alloc_objects(Interp *interpreter, struct Small_Object_Pool *pool)
{
    struct Small_Object_Arena *new_arena;
    char *ptr;
    new_arena = mem_sys_allocate(sizeof(struct Small_Object_Arena));

    new_arena->start_objects =
	mem_sys_allocate_zeroed(pool->objects_per_alloc * pool->object_size);
    Parrot_append_arena_in_pool(interpreter, pool, new_arena, pool->object_size * pool->objects_per_alloc);
    new_arena->used = 0;
    pool->num_free_objects += pool->objects_per_alloc;
    pool->total_objects += pool->objects_per_alloc;

    /* Update linked list */
    for (ptr = new_arena->start_objects;
	    (UINTVAL)ptr < (UINTVAL)new_arena->start_objects + 
	    pool->object_size * pool->objects_per_alloc;
	    ptr += pool->object_size)
    {
	(*pool->add_free_object)(interpreter,pool,ptr);
    }

    /* Allocate more next time. */
    pool->objects_per_alloc = 
	(UINTVAL) pool->objects_per_alloc * UNITS_PER_ALLOC_GROWTH_FACTOR;
    if (pool->object_size * pool->objects_per_alloc > POOL_MAX_BYTES)
	pool->objects_per_alloc = POOL_MAX_BYTES / pool->object_size;

#ifdef GMC_DEBUG
    fprintf(stderr, "Allocated new objects at arena %p, %p\n",
	    new_arena, new_arena->start_objects);
#endif
}




/* Obtains more free objects from the pool. */
    static void
gc_gmc_more_objects(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    /* For now only alloc more objects. There will be a GC run in the future. */
    (*pool->alloc_objects) (interpreter, pool);
}



/* Copies the content of a generation into a new one and updates the pointers of
 * objects to refer to the new location. */
    static void
gc_gmc_copy_gen (Gc_gmc_gen *from, Gc_gmc_gen *dest)
{
    INTVAL offset = (char*)from->first - (char*)from->fst_free;
    Gc_gmc_hdr *ptr;
    void *start1, *start2;
    
    start1 = (char*)dest->fst_free - dest->remaining;
    start2 = (char*)from->fst_free - from->remaining;
    dest->fst_free = (void*)((char*)dest->first - offset);
    dest->remaining = from->remaining;
    dest->IGP = from->IGP;
    dest->alloc_obj = from->alloc_obj;
#ifdef GMC_DEBUG
    fprintf (stderr, "Copying gen (%p,%p) to gen (%p,%p)\n",
	    from, from->first, dest, dest->first);
#endif
    memcpy(start1, start2, GMC_GEN_SIZE);
    ptr = dest->fst_free;
    while ((UINTVAL)ptr < (UINTVAL)dest->first)
    {
#ifdef BIG_DUMP
	fprintf(stderr, "copy_gen: ptr %p, old_body %p, new_body %p\n", Gmc_PMC_hdr_get_PMC(ptr), PMC_body(Gmc_PMC_hdr_get_PMC(ptr)), Gmc_PMC_hdr_get_BODY(ptr));
#endif
	Gmc_PMC_hdr_set_GEN(ptr, dest);
	PMC_body(Gmc_PMC_hdr_get_PMC(ptr)) = Gmc_PMC_hdr_get_BODY(ptr);
	ptr = gc_gmc_next_hdr(ptr);
    }
}



/* Frees a generation. */
    static void
gc_gmc_gen_free(Gc_gmc_gen *gen)
{
    void *start;

    start = (char*)gen->fst_free - gen->remaining;
    mem_sys_free(start);
    mem_sys_free(gen);
}



/* Allocates twice as much generations as before, copies everything */
/* TODO: double only the half that needs it. */
    static void
gc_gmc_more_bodies (Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    Gc_gmc *gc = pool->gc;
    /* XXX: allocate dummy_gc at init time as a field of Gc_gmc */
    Gc_gmc *dummy_gc = pool->gc->dummy_gc;
    Gc_gmc_gen *gen, *ogen, *ogen_nxt;
    INTVAL nb_gen = 2 * gc->nb_gen;
    int i;
#ifdef GMC_DEBUG
    fprintf(stderr, "Allocating more pmc_bodies\n");
#endif

    /* We use a dummy_gc before copying all the data. */
    dummy_gc->yng_fst = NULL;
    dummy_gc->yng_lst = NULL;
    dummy_gc->old_fst = NULL;
    dummy_gc->old_lst = NULL;
    dummy_gc->nb_gen = nb_gen;

    for (i = 0; i < nb_gen; i++)
    {
	gen = gc_gmc_gen_init (interpreter, pool);
	gc_gmc_insert_gen (interpreter, dummy_gc, gen);
    }

    gc_gmc_test_linked_list_gen(interpreter, dummy_gc);

    for (gen = dummy_gc->old_fst, ogen = gc->old_fst; ogen; gen = gen->next)
    {
	ogen_nxt = ogen->next;
	gc_gmc_copy_gen(ogen,gen);
	gc_gmc_gen_free(ogen);
	ogen = ogen_nxt;
    }
    dummy_gc->old_lst = gen;

    for (gen = dummy_gc->old_fst, i = 0; i < (nb_gen/2); i++, gen = gen->next);
    dummy_gc->yng_fst = gen;
    gen->prev->next = NULL;
    gen->prev = NULL;

    for (gen = dummy_gc->yng_fst, ogen = gc->yng_fst; ogen; gen = gen->next)
    {
	ogen_nxt = ogen->next;
	gc_gmc_copy_gen(ogen,gen);
	gc_gmc_gen_free(ogen);
	ogen = ogen_nxt;
    }
    dummy_gc->yng_lst = gen;

    gc->yng_fst = dummy_gc->yng_fst;
    gc->yng_lst = dummy_gc->yng_lst;
    gc->old_fst = dummy_gc->old_fst;
    gc->old_lst = dummy_gc->old_lst;
    gc->nb_gen = nb_gen;

#ifdef GMC_DEBUG
    fprintf(stderr, "Done with allocation\n");
#endif
}


/* If there are any objects needing timely destruction, change state accordingly
 * and trigger a GC run. */
void
Parrot_exit_scope(Interp *interpreter)
{
    if (interpreter->arena_base->num_early_DOD_PMCs)
	gc_gmc_run(interpreter, 0);
}


/*

=head2 Write Barrier functions

=over 4

=item C<void gc_gmc_wb(Interp *, PMC *, void *, void *)>

=item C<void gc_gmc_wb_key(Interp *, PMC *, void *, void *, void *, void *)>

An IGP is being created, record it.


=back

=cut

*/



/* Add a header to a header list. */
static void
gc_gmc_store_hdr_list(Interp *interpreter, Gc_gmc_hdr_list *l, Gc_gmc_hdr *h)
{
    Gc_gmc_hdr_store *s = l->last;

    /* if it's not created or if it's full allocate new store */
    if (!s || s->ptr == &s->store[GC_GMC_STORE_SIZE]) {
        s = mem_sys_allocate(sizeof(Gc_gmc_hdr_store));
        s->ptr = &s->store[0];
        s->next = NULL;
        /* chain new store to old one */
        if (l->first) {
            assert(l->last);
            l->last->next = s;
        }
        else {
            l->first = s;
        }
        l->last = s;
    }
    *(s->ptr)++ = Gmc_PMC_hdr_get_PMC(h);
#ifdef GMC_DEBUG
    fprintf(stderr, "Adding IGP %p to store %p\n", Gmc_PMC_hdr_get_BODY(h), s);
#endif
}


/* Returns 1 iff the header is already in the IGP list. */
static INTVAL
gc_gmc_find_igp(Gc_gmc_hdr_list *list, PMC *p)
{
    Gc_gmc_hdr_store *store;
    INTVAL i;

    for (store = list->first; store; store = store->next)
	for (i = 0; (UINTVAL)&store->store[i] < (UINTVAL)store->ptr; i++)
	    if (store->store[i] == p)
		return 1;
    return 0;
}




/* Removes a header from the IGP list. Raises an exception if the header was not
 * in the list.*/
static void 
gc_gmc_sweep_from_hdr_list(Interp *interpreter, Gc_gmc_hdr *h)
{
    Gc_gmc_gen *gen;
    Gc_gmc_hdr_list *list;
    Gc_gmc_hdr_store *store;
    INTVAL i;

    gen = Gmc_PMC_hdr_get_GEN(h);
    list = gen->IGP;
    for (store = list->first; store; store = store->next)
    {
#ifdef GMC_DEBUG
	fprintf (stderr, "store %p\n", store);
#endif
	for (i = 0; &store->store[i] < store->ptr; i++)
	{
#ifdef GMC_DEBUG
	    fprintf (stderr, "looking for %p, got %p\n", h, store->store[i]);
#endif
	    if (Gmc_PMC_get_HDR(store->store[i]) == h)
	    {
		for (i++; &store->store[i] < store->ptr; i++)
		{
		    store->store[i-1] = store->store[i];
		}
		store->ptr--;
		return;
	    }
	}
    }
    fprintf (stderr, "bad igp: %p -> %p %p\n", Gmc_PMC_hdr_get_PMC(h), h, Gmc_PMC_hdr_get_BODY(h));
    internal_exception(1, "IGP pointer not found for removal!\n");
}



void gc_gmc_wb(Interp *interpreter, PMC *agg, void *old, void *new)
{
    Gc_gmc_gen *gen;
    if (PObj_is_PMC_TEST((PObj*)new) && PObj_exists_PMC_EXT_TEST((PMC*)new))
    {
	gen = Gmc_PMC_get_GEN((PMC*)agg);
	if (!PObj_igp_TEST(agg))
	    gc_gmc_store_hdr_list(interpreter, gen->IGP, Gmc_PMC_get_HDR(agg));
	PObj_igp_SET(agg);
    }
    /* XXX: Do we need to move it one way or another for invariant ? */
}

void gc_gmc_wb_key(Interp *interpreter, PMC *agg,
	void *old, void *old_key, void *new, void *new_key)
{
    gc_gmc_wb(interpreter, agg, old, new);
    
    /* TODO: Deal with key too. */
}



/*

=head2 GC Run

=over 4

=item C<static void gc_gmc_run(Interp *, int)>

DOD run. Can either sweep all the remaining objects for a Parrot destruction or run a M&S GC pass.


=item C<static int sweep_pmc(Interp *, struct Small_Object_Pool *, int, void *)>

Removes any dead pmc (must have the PObj_live_FLAG cleared), possibly calling their finalizers.


=item C<static int sweep_buf(Interp *, struct Small_Object_Pool *, int, void *)>

Same things for buffers.


=item C<static int gc_gmc_clear_live(Interp *, struct Small_Object_Pool *, int, void *)>

Clears all PObj_live_FLAG of objects in the pool.


=item C< static void gc_gmc_init_pool_for_ms(Interp *, struct Small_Object_Pool *)>

Initializes the pool for a mark&sweep pass.


=item C<static void gc_gmc_trace_children(Interp *, Gc_gmc_hdr *)>

Finds all objects pointed by the header and mark them as alive.


=item C<static void gc_gmc_trace_igp(Interp *, Gc_gmc_hdr *)>

Find all IGP starting from this object and initiate NLDGC (Night of the Living-Dead GC) on them.


=item C<void parrot_gc_gmc_pobject_lives(Interp *, PObj *)>

Marks the considered object as alive and possibly recurse this marking (if we are following an IGP thread).


=item C<static INTVAL gc_gmc_mark(Interp *, struct Small_Object_Pool *, int)>

Marking pass. Returns the number of objects having been marked dead. Stops if at least DEAD_OBJECTS_PER_RUN have been marked.


=item C<static void gc_gmc_compact(Interp *, struct Small_Object_Pool *)>

Compaction pass: generations are back in the state where all objects are contiguous.

=back 

=cut 

*/


/* If given the flag DOD_finish_FLAG, call finalizers on all objects. If not,
 * runs the GC until enough objects have been found. */
    static void 
gc_gmc_run(Interp *interpreter, int flags)
{
    struct Arenas *arena_base = interpreter->arena_base;

    if (arena_base->DOD_block_level)
	return;
    ++arena_base->DOD_block_level;

    /* This interpreter will be destroyed, free everything. */
    if (flags & DOD_finish_FLAG) {

	/* First the pmc headers */
	Parrot_forall_header_pools(interpreter, POOL_ALL, 0, gc_gmc_clear_live);
	Parrot_forall_header_pools(interpreter, POOL_PMC, 0, sweep_pmc);
	Parrot_forall_header_pools(interpreter, POOL_BUFFER, 0, sweep_buf);

	/* Then the pmc_bodies. */
	gc_gmc_pool_deinit(interpreter, arena_base->pmc_pool);

#ifdef GMC_DEBUG
	fprintf (stderr, "GMC: Trying to run dod_run for final sweeping\n");
#endif /* GMC_DEBUG */
	--arena_base->DOD_block_level;
	return;
    } else {
#ifdef GMC_DEBUG
	fprintf(stderr, "GMC RUN !\n");
#endif
	arena_base->dod_runs++;
	arena_base->lazy_dod = (flags & DOD_lazy_FLAG);
	gc_gmc_mark(interpreter, arena_base->pmc_pool, !arena_base->lazy_dod);
	gc_gmc_compact(interpreter, arena_base->pmc_pool);
#ifdef GMC_DEBUG
	fprintf (stderr, "\nGMC: Trying to run dod_run for normal allocation\n\n");
#endif /* GMC_DEBUG */
	--arena_base->DOD_block_level;
    }

}



/* Calls finalizers of all PMC in pool that are marked as dead. */
static int sweep_pmc (Interp *interpreter, struct Small_Object_Pool *pool,
	int flag, void *arg)
{

    Gc_gmc_hdr *hdr;
    Gc_gmc_gen *gen;
    INTVAL pass = 0;
    PMC *pmc, *old_pmc;
    int sweep = 0;

    old_pmc = NULL;
    for (gen = pool->gc->old_fst; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass)
	{
	    pass++;
	    gen = pool->gc->yng_fst;
	}
	for (hdr = gen->fst_free; (UINTVAL)hdr < (UINTVAL)gen->first; hdr = gc_gmc_next_hdr(hdr))
	{
	    pmc = Gmc_PMC_hdr_get_PMC(hdr);
	    /* We can do it only now, or we don't know how to go to the next
	     * body. */
	    if (old_pmc)
		(*pool->add_free_object)(interpreter, pool, old_pmc);
	    old_pmc = NULL;

	    if (!PObj_live_TEST(pmc))
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "sweep_pmc: %p -> (%p, %p)\n", pmc, hdr, Gmc_PMC_hdr_get_BODY(hdr));
#endif
		if (PObj_needs_early_DOD_TEST(pmc))
		    --interpreter->arena_base->num_early_DOD_PMCs;
		if (PObj_active_destroy_TEST(pmc)) {
		    VTABLE_destroy(interpreter, pmc);
		}
		if (PObj_igp_TEST(pmc))
		{
		    gc_gmc_sweep_from_hdr_list(interpreter, hdr);
		}
		old_pmc = pmc;
		sweep++;
		(Gmc_PMC_hdr_get_GEN(hdr))->alloc_obj--;
	    }
	}
    }
#ifdef GMC_DEBUG
    fprintf (stderr, "Sweeped %d PMC in pool %s (%d/%d)\n",
	    sweep, pool->name, pool->total_objects - pool->num_free_objects,
	    pool->total_objects);
#endif
    return 0;
}





/* Deinit all buffers in a given pool. */
static int sweep_buf (Interp *interpreter, struct Small_Object_Pool *pool,
	int flag, void *arg)
{
    Gc_gmc_hdr *hdr;
    Gc_gmc_gen *gen;
    INTVAL pass = 0;
    PObj *obj, *old_obj;
    
    old_obj = NULL;

    for (gen = pool->gc->old_fst; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass)
	{
	    pass++;
	    gen = pool->gc->yng_fst;
	}
	for (hdr = gen->fst_free; (UINTVAL)hdr < (UINTVAL)gen->first; hdr = gc_gmc_next_hdr(hdr))
	{
	    obj = (PObj*)Gmc_PMC_hdr_get_PMC(hdr);
	    if (old_obj)
		(*pool->add_free_object)(interpreter, pool, old_obj);
	    old_obj = NULL;

	    /* Go through all the headers of the pool. */
	    if (!PObj_live_TEST(obj))
	    {
		if (PObj_sysmem_TEST(obj) && PObj_bufstart(obj)) {
		    /* has sysmem allocated, e.g. string_pin */
		    mem_sys_free(PObj_bufstart(obj));
		    PObj_bufstart(obj) = NULL;
		    PObj_buflen(obj) = 0;
		} else {
		    /*
		     * XXX Jarkko did report that on irix pool->mem_pool
		     *     was NULL, which really shouldn't happen
		     */
		    if (pool->mem_pool) {
			if (!PObj_COW_TEST(obj)) {
			    ((struct Memory_Pool *)
			     pool->mem_pool)->guaranteed_reclaimable +=
				PObj_buflen(obj);
			}
			((struct Memory_Pool *)
			 pool->mem_pool)->possibly_reclaimable +=
			    PObj_buflen(obj);
		    }
		    PObj_buflen(obj) = 0;
		}
		old_obj = obj;
	    }
	}
    }
    return 0;
}


/* Clear all live bits of the objects in pool. */
    static int
gc_gmc_clear_live(Interp *interpreter, struct Small_Object_Pool *pool,
	int flags, void *arg)
{
    Gc_gmc_hdr *hdr;
    Gc_gmc_gen *gen;
    INTVAL pass = 0;

    for (gen = pool->gc->old_fst; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass)
	{
	    pass++;
	    gen = pool->gc->yng_fst;
	}
	for (hdr = gen->fst_free; (UINTVAL)hdr < (UINTVAL)gen->first; hdr = gc_gmc_next_hdr(hdr))
	    PObj_live_CLEAR(Gmc_PMC_hdr_get_PMC(hdr));
    }
    return 0;
}


/* Initializes the pool for M&S. Basically, mark everyone dead. */
static void
gc_gmc_init_pool_for_ms(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc_gen *gen;
    Gc_gmc_hdr *hdr, *h2;
    int pass;
    for (gen = pool->gc->old_fst, pass = 0; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass) {
	    gen = pool->gc->yng_fst;
	    pass++;
	}
	gen->marked = 0;
    }
}


/* Marks the contents of the root set as alive. */
static int
gc_gmc_trace_root(Interp *interpreter, int trace_stack)
{
    return Parrot_dod_trace_root (interpreter, trace_stack);
}


/* If the object is alive and has pointers to older PMC, mark them alive. */
static void
gc_gmc_trace_children(Interp *interpreter, Gc_gmc_hdr *h)
{
    UINTVAL mask = PObj_data_is_PMC_array_FLAG | PObj_custom_mark_FLAG;
    UINTVAL bits;
    PMC *pmc;
    INTVAL i;

    pmc = Gmc_PMC_hdr_get_PMC(h);

    bits = PObj_get_FLAGS(pmc) & mask;
    if (bits)
    {
	if (bits == PObj_data_is_PMC_array_FLAG) {
	    PMC** data = PMC_data(pmc);
	    if (data)
	    {
		for (i = 0; i < PMC_int_val(pmc); i++)
		{
		    /*if (data[i] && Gmc_PMC_get_HDR(data[i]) < h)*/
		    if (data[i])
			pobject_lives(interpreter, (PObj*)data[i]);
		}
	    }
	} else {
	    VTABLE_mark(interpreter, pmc);
	}
    }
}

static void
gc_gmc_trace_igp_sons(Interp *interpreter, Gc_gmc_hdr *h)
{
    UINTVAL mask = PObj_data_is_PMC_array_FLAG | PObj_custom_mark_FLAG;
    UINTVAL bits;
    PMC *pmc;
    INTVAL i;
    INTVAL sav_state;
    struct Small_Object_Pool *pool;

    pmc = Gmc_PMC_hdr_get_PMC(h);

    pool = Gmc_PMC_hdr_get_GEN(h)->pool;
    sav_state = pool->gc->state;
    pool->gc->state = (sav_state < GMC_TIMELY_NORMAL_STATE) ? GMC_SON_OF_IGP_STATE : GMC_TIMELY_SON_OF_IGP_STATE;

    bits = PObj_get_FLAGS(pmc) & mask;
    if (bits)
    {
	if (bits == PObj_data_is_PMC_array_FLAG) {
	    PMC** data = PMC_data(pmc);
	    if (data)
	    {
		for (i = 0; i < PMC_int_val(pmc); i++)
		{
		    if (data[i] && !PObj_live_TEST((PObj*)data[i]))
			pobject_lives(interpreter, (PObj*)data[i]);
		}
	    }
	} else {
	    VTABLE_mark(interpreter, pmc);
	}
    }
    pool->gc->state = sav_state;
}

static void 
gc_gmc_trace_igp(Interp *interpreter, Gc_gmc_gen *gen)
{
    Gc_gmc_hdr_list *l;
    Gc_gmc_hdr_store *s;
    INTVAL i;

    l = gen->IGP;
    for (s = l->first; s; s = s->next)
    {
	for (i = 0; &s->store[i] < s->ptr; i++)
	{
	    gc_gmc_trace_igp_sons(interpreter, Gmc_PMC_get_HDR(s->store[i]));
	}
    }
}



/* Marks the object whose body is at h as alive. */
void
parrot_gc_gmc_pobject_lives(Interp *interpreter, PObj *o)
{
    Gc_gmc *gc;
    Gc_gmc_hdr *h;

    h = Gmc_PMC_get_HDR(o);
#ifdef GMC_DEBUG
    fprintf (stderr, "PObject %p, body at %p lives !\n", o, h);
#endif
    gc = Gmc_PMC_body_get_GEN(PMC_body(o))->pool->gc;
    switch (gc->state)
    {
	/* This object was precedently dead and has been marked alive as a
	 * consequence of IGP. */
	case GMC_SON_OF_IGP_STATE:
	case GMC_TIMELY_SON_OF_IGP_STATE:
	    if (!PObj_live_TEST(o) && Gmc_PMC_get_GEN(o)->marked)
	    {
		PObj_live_SET(o);
		gc_gmc_trace_igp_sons(interpreter, h);
	    }
	    break;
	case GMC_NORMAL_STATE:
	case GMC_TIMELY_NORMAL_STATE:
	    PObj_live_SET(o);
	    break;
	default:
	    *(int*)NULL = 0;
	    internal_exception(1, "GMC: undefined state");
    }
}



/* Implement NLDGC (Night of the Living-Dead GC). When all a generation is
 * scanned, follow IGP pointers that *start* from that generation and trace its
 * children, but only if they were marked dead before (if not, they were already
 * traced). */


/* Wraps everything nicely. */
static INTVAL
gc_gmc_mark(Interp *interpreter, struct Small_Object_Pool *pool, int flags)
{
    INTVAL dopr = DEAD_OBJECTS_PER_RUN; /* Number of objects we want to find in a run. */
    Gc_gmc_hdr *hdr, *h2;
    Gc_gmc_gen *gen;
    INTVAL index;
    INTVAL pass = 0;
    /* State 0 : normal run, we free every dead object.
     * State 1 : we've found enough objects, simply consider IGP and mark
     * everyone alive. */
    INTVAL state = 0;


#ifdef GMC_DEBUG
    fprintf (stderr, "\nMarking pass\n\n");
#endif

    gc_gmc_init_pool_for_ms(interpreter, pool);
    gc_gmc_trace_root(interpreter, flags);

    hdr = pool->gc->gray; 
    gen = pool->gc->yng_lst;
    if (interpreter->arena_base->num_early_DOD_PMCs)
	pool->gc->state = GMC_TIMELY_NORMAL_STATE;
    else
	pool->gc->state = GMC_NORMAL_STATE;
    for (gen = pool->gc->yng_lst; ; gen = gen->prev)
    {
	/* We've run through all the young objects, jump to the old ones. */
	if (!gen)
	{
	    if (pass++)
		break;
	    gen = pool->gc->yng_lst;
	}
	

	if (!state)
	{
	    gen->marked = 1;
#ifdef GMC_DEBUG
	    fprintf(stderr, "GC state: %ld, dopr: %ld, gen %p\n",pool->gc->state, dopr, gen);
#endif

	    /* And go through it. */	
	    for (hdr = gen->fst_free; (UINTVAL)hdr < (UINTVAL)gen->first; hdr = gc_gmc_next_hdr(hdr))
	    {
		pool->gc->gray = hdr;

		/* If we have found enough objects, change our state and
		 * consider only IGP from now on. */
		/* If this is a timely destruction triggered run, make a full
		 * run. */
		if (!state && dopr <= 0 && pool->gc->state < GMC_TIMELY_NORMAL_STATE)
		{
		    pool->gc->white = hdr;
		    state = 1;
		}

		/* PObj is alive, trace its children */
		if (PObj_live_TEST((PObj*)Gmc_PMC_hdr_get_PMC(hdr)))
		{
		    gc_gmc_trace_children(interpreter, hdr);
		    if (PObj_igp_TEST(Gmc_PMC_hdr_get_PMC(hdr)))
			gc_gmc_trace_igp_sons(interpreter, hdr);
		}
		else
		    dopr--;
	    }
	} else {
	    gc_gmc_trace_igp(interpreter, gen);
#ifdef GMC_DEBUG
	    fprintf(stderr, "Finishing run\n");
#endif
	}
    }
    if (!gen)
	pool->gc->white = hdr;

    return (DEAD_OBJECTS_PER_RUN - dopr);
}


/* Copies a header and its pmc_body, then updates the pointers. */
/* We are sure that there is enough room in to. from and to may overlap. */
/* Also clear the live bit of the new object. */
static Gc_gmc_hdr *
gc_gmc_copy_hdr(Interp *interpreter, Gc_gmc_hdr *from, Gc_gmc_hdr *to)
{
    Gc_gmc_gen *gen;
    size_t size;

    PObj_live_CLEAR(Gmc_PMC_hdr_get_PMC(to));
    if (from == to)
	return gc_gmc_next_hdr(to);
    size = gc_gmc_get_size(interpreter, from);
    gen = Gmc_PMC_hdr_get_GEN(from);
    memmove(to, from, size);
    Gmc_PMC_hdr_set_GEN(to, gen);
    PMC_body(Gmc_PMC_hdr_get_PMC(to)) = Gmc_PMC_hdr_get_BODY(to);
    return gc_gmc_next_hdr(to);
}



/* Compacts a generation. */
static INTVAL
gc_gmc_compact_gen(Interp *interpreter, Gc_gmc_gen *gen)
{
    Gc_gmc_hdr *orig, *old_orig;
    Gc_gmc_hdr *dest;
    size_t remaining;
    size_t size;
    INTVAL leave = 0;
    INTVAL destroyed = 0;

    /* Begin by aligning them on the left, we'll shift everything in the end. */
    orig = dest = gen->fst_free;
    remaining = (char*)gen->first - (char*)gen->fst_free + gen->remaining;

    old_orig = NULL;
    /* We are sure that orig will be the first to hit the barrier. */
    while ((UINTVAL)orig < (UINTVAL)gen->first)
    {
	/*old_orig = NULL;*/
	/* Free any object that has the live flag clear. */
	while (((UINTVAL)orig < (UINTVAL)gen->first || !(leave = 1)) && !PObj_live_TEST(Gmc_PMC_hdr_get_PMC(orig)))
	{
	    if (old_orig)
		(*gen->pool->add_free_object)(interpreter, gen->pool, Gmc_PMC_hdr_get_PMC(old_orig));
	    old_orig = NULL;

	    if (PObj_needs_early_DOD_TEST(Gmc_PMC_hdr_get_PMC(orig)))
		--interpreter->arena_base->num_early_DOD_PMCs;
	    if (PObj_active_destroy_TEST(Gmc_PMC_hdr_get_PMC(orig)))
		VTABLE_destroy(interpreter, Gmc_PMC_hdr_get_PMC(orig));
	    if (PObj_igp_TEST(Gmc_PMC_hdr_get_PMC(orig)))
		gc_gmc_sweep_from_hdr_list(interpreter, orig);
	    old_orig = orig;
	    orig = gc_gmc_next_hdr(orig);
	    gen->alloc_obj--;
	    destroyed++;
	}
	if (!leave)
	{
	    if (old_orig)
		(*gen->pool->add_free_object)(interpreter, gen->pool, Gmc_PMC_hdr_get_PMC(old_orig));
	    old_orig = NULL;
	    /* Copy from orig to dest and update pointers. */	
	    size = gc_gmc_get_size(interpreter, orig);
	    remaining -= size;
	    dest = gc_gmc_copy_hdr(interpreter, orig, dest);
	    orig = (Gc_gmc_hdr*)((char*)orig + size);
	}
    }

    /* Shift everything to align them to the higher memory */
    size = (char*)dest - (char*)gen->fst_free;
    memmove((char*)gen->first - size, gen->fst_free, size);
    gen->fst_free = (char*)gen->first - size;
    for (orig = gen->fst_free; (UINTVAL)orig < (UINTVAL)gen->first; orig = gc_gmc_next_hdr(orig))
    {
#ifdef BIG_DUMP
	fprintf(stderr, "copy_hdr: ptr %p, old_body %p, new_body %p\n", Gmc_PMC_hdr_get_PMC(orig), PMC_body(Gmc_PMC_hdr_get_PMC(orig)), Gmc_PMC_hdr_get_BODY(orig));
#endif
	PMC_body(Gmc_PMC_hdr_get_PMC(orig)) = Gmc_PMC_hdr_get_BODY(orig);
    }
    
    gen->remaining = remaining;
#ifdef GMC_DEBUG
    fprintf(stderr, "gen %p, destroyed %d, remaining %d\n", gen, destroyed, gen->alloc_obj);
#endif
    return destroyed;
}



/* Appends all objects of yng just after those of old. */
static void
gc_gmc_merge_gen(Interp *interpreter, Gc_gmc_gen *old, Gc_gmc_gen *yng)
{
    size_t size;
    Gc_gmc_hdr *h;
    struct Small_Object_Pool *pool;
    Gc_gmc_hdr_store *store, *st2;
    INTVAL i;

    pool = yng->pool;
    size = (UINTVAL)yng->first - (UINTVAL)yng->fst_free;

    /* Check we have enough space for this. */
    if (size >= (UINTVAL)old->remaining)
	return;

    /* Copy the data. */
    memcpy((char*)old->fst_free - size, yng->fst_free, size);
    h = (Gc_gmc_hdr*)((char*)old->fst_free - size);
    old->remaining -= size;
    /* And update all pointers. */
    for (; (UINTVAL)h < (UINTVAL)old->fst_free; h = gc_gmc_next_hdr(h))
    {
#ifdef BIG_DUMP
	fprintf(stderr, "merge_gen: h %p, ptr %p, old_body at %p, new body at %p\n", h, Gmc_PMC_hdr_get_PMC(h), PMC_body(Gmc_PMC_hdr_get_PMC(h)), Gmc_PMC_hdr_get_BODY(h));
#endif
	Gmc_PMC_hdr_set_GEN(h,old);
	PMC_body(Gmc_PMC_hdr_get_PMC(h)) = Gmc_PMC_hdr_get_BODY(h);
    }
    old->fst_free = (void*)((char*)old->fst_free - size);


    for (store = yng->IGP->first; store; store = store->next)
    {
	for (i = 0; &store->store[i] < store->ptr; i++)
	{
	    if (!gc_gmc_find_igp(old->IGP, (PMC*)store->store[i]))
		gc_gmc_store_hdr_list(interpreter, old->IGP, Gmc_PMC_get_HDR(store->store[i]));
	}
    }
    
    old->next = yng->next;
    if (old->next)
	old->next->prev = old;
    if (pool->gc->yng_lst == yng)
	pool->gc->yng_lst = old;
    if (pool->gc->old_lst == yng)
	pool->gc->old_lst = old;
    
    for (store = yng->IGP->first; store; st2 = store->next, mem_sys_free(store), store = st2);
    gc_gmc_gen_free(yng);
}



static void
gc_gmc_compact(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc_gen *gen;
    Gc_gmc_gen *ogen;
    INTVAL pass = 0;
    INTVAL destroyed = 0;
    Gc_gmc_hdr *h;
    
    gen = pool->gc->yng_lst;
    ogen = NULL;


    /* Compact only the gen that were examined. */
    while (gen->marked)
    {
	destroyed += gc_gmc_compact_gen(interpreter, gen);
	if (ogen)
	    gc_gmc_merge_gen(interpreter, gen, ogen);
	ogen = gen;
	gen = gen->prev;
	if (!gen)
	{
	    if (pass++)
		break;
	    ogen = NULL;
	    gen = pool->gc->old_lst;
	}
    }
#ifdef GMC_DEBUG
    fprintf(stderr, "Sweeped %ld objects\n", destroyed);
#endif
}




#endif /* PARROT_GC_GMC */
