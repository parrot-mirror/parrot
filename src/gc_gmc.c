/* 
Copyright: 2001-2005 The Perl Foundation.  All Rights Reserved.
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

/*#define BIG_DUMP
#define GMC_DEBUG*/

/* Beware that this is really *huge* output (more than 1Go even on small runs). */
/*#define HUGE_DUMP*/

/*#define GMC_NO_GC_RUN*/


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
    assert(i == gc->nb_gen && j == gc->nb_gen);
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
    gc->hdr_ref = NULL;
    gc->gray = NULL;
    gc->dummy_gc = dummy_gc;
    gc->state = GMC_NORMAL_STATE;
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

    mem_sys_free(pool->gc);
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
gc_gmc_get_size(Gc_gmc_obj *obj)
{
    size_t size;
    /* Align header and body to multiples of GMC_ALIGN. */
    size = sizeof(Gc_gmc_obj);
    if (PObj_is_PMC_TEST(Gmc_OBJ_get_POBJ(obj)))
	size += ((PMC*)(Gmc_OBJ_get_POBJ(obj)))->vtable->size;
    else
	size += sizeof(pobj_body);
    return size;
}




/* Returns the next header in the area, assuming that we have not gone further
 * than gen->first. */
    static Gc_gmc_obj *
gc_gmc_next_obj(Gc_gmc_obj *obj)
{
    size_t size = gc_gmc_get_size(obj);
    return (Gc_gmc_obj*)((char*)obj + size);
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
static Gc_gmc_obj *
gc_gmc_new_body(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size, INTVAL aggreg)
{
    Gc_gmc_obj *obj;
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
    obj = gen->fst_free;
    gen->remaining -= size;
    gen->alloc_obj++;
    memset(obj, 0, size);
    Gmc_OBJ_set_GEN(obj, gen);
    /*assert(!(size % GMC_ALIGN));*/
    /*assert(!((UINTVAL)obj % GMC_ALIGN));*/
    /*fprintf(stderr, "offset: %d\n", offsetof(Gc_gmc_obj, body));*/
    /*assert(!((UINTVAL)Gmc_OBJ_get_BODY(obj,PMC_BODY*) % GMC_ALIGN));*/

    return obj;
}



/* Returns a new object with a body of the required size. */
    static void *
gc_gmc_get_free_object_of_size(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size, INTVAL aggreg)
{
    Gc_gmc_obj *obj;
    PMC *pobj;
    void *ptr, *old_flist;
    struct Small_Object_Arena *arena;
    

#ifdef HUGE_DUMP
    for (ptr = pool->free_list; ptr && *(void**)ptr; ptr = *(void**)ptr)
	assert(ptr != 0x1);
#endif
    obj = gc_gmc_new_body(interpreter, pool, size, aggreg);
    
    if (!pool->free_list)
	(*pool->more_objects)(interpreter, pool);

    pobj = pool->free_list;
    pool->free_list = *(void**)pool->free_list;

    PObj_flags_SETTO(pobj, 0);
    
    pool->num_free_objects--;
    Gmc_POBJ_get_OBJ(pobj) = obj;
    Gmc_OBJ_get_POBJ(obj) = pobj;
    assert(pobj);

#ifdef BIG_DUMP
    fprintf(stderr, "Allocated obj %p -> (%p, %p) (pool %p, new free_list: %p)\n", pobj, obj, Gmc_OBJ_get_BODY(obj,PMC_BODY*), pool, pool->free_list);
#endif
    return pobj;
}


/* Here we allocate a default PObj, as it is non-typed. */
/* This function should not be called anywhere if possible. */
    void *
gc_gmc_get_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    size_t size = sizeof(Gc_gmc_obj) + sizeof(pobj_body);
    PMC *pmc = gc_gmc_get_free_object_of_size(interpreter, pool, size, 0);
    return pmc;
}



/* Returns a PObj of the required size. */
    static void *
gc_gmc_get_free_sized_object(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size)
{
    int i;
    size_t nsize = sizeof(Gc_gmc_obj) + size;
    PMC *pmc = gc_gmc_get_free_object_of_size (interpreter, pool,
	    nsize, 0);
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
    size_t size = sizeof(Gc_gmc_obj) + vtable->size;
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
#ifdef BIG_DUMP
	fprintf(stderr, "Adding ptr %p to the list of freshly allocated objects for pool %p\n", ptr, pool);
#endif
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

#ifdef BIG_DUMP
    fprintf(stderr, "Dumping free_list\n");
    for (ptr = pool->free_list; *(void**)ptr; ptr = *(void**)ptr)
	fprintf(stderr, "%p -> ", ptr);
    fprintf(stderr, "%p -> NULL\n", ptr);
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
    Gc_gmc_obj *obj;
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
    obj = dest->fst_free;
    while ((UINTVAL)obj < (UINTVAL)dest->first)
    {
#ifdef BIG_DUMP
	fprintf(stderr, "copy_gen: ptr %p, ", Gmc_OBJ_get_POBJ(obj));
	fprintf(stderr, "old_body: %p, ", Gmc_POBJ_get_BODY(Gmc_OBJ_get_POBJ(obj),PMC_BODY*));
	fprintf(stderr, "new body: %p, ", Gmc_OBJ_get_BODY(obj,PMC_BODY*));
	fprintf(stderr, "int_val: %ld\n", PMC_int_val(Gmc_OBJ_get_POBJ(obj)));
#endif
	Gmc_OBJ_set_GEN(obj, dest);
	Gmc_POBJ_get_OBJ(Gmc_OBJ_get_POBJ(obj)) = obj;
	obj = gc_gmc_next_obj(obj);
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
gc_gmc_store_hdr_list(Interp *interpreter, Gc_gmc_hdr_list *l, PMC *o)
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
    *(s->ptr)++ = o;
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
gc_gmc_sweep_from_hdr_list(Interp *interpreter, Gc_gmc_obj *o)
{
    Gc_gmc_gen *gen;
    Gc_gmc_hdr_list *list;
    Gc_gmc_hdr_store *store;
    INTVAL i;

    gen = Gmc_OBJ_get_GEN(o);
    list = gen->IGP;
    for (store = list->first; store; store = store->next)
    {
#ifdef GMC_DEBUG
	fprintf (stderr, "store %p\n", store);
#endif
	for (i = 0; &store->store[i] < store->ptr; i++)
	{
#ifdef GMC_DEBUG
	    fprintf (stderr, "looking for %p, got %p\n", o, store->store[i]);
#endif
	    if (Gmc_POBJ_get_OBJ(store->store[i]) == o)
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
    fprintf (stderr, "bad igp: %p -> %p %p\n", Gmc_OBJ_get_POBJ(o), o, Gmc_OBJ_get_BODY(o,PMC_BODY*));
    internal_exception(1, "IGP pointer not found for removal!\n");
}



void gc_gmc_wb(Interp *interpreter, PMC *agg, void *old, void *new)
{
    Gc_gmc_gen *gen;
    gen = Gmc_POBJ_get_GEN((PMC*)agg);
    if (!PObj_igp_TEST(agg))
	gc_gmc_store_hdr_list(interpreter, gen->IGP, agg);
    PObj_igp_SET(agg);
}

void gc_gmc_wb_key(Interp *interpreter, PMC *agg,
	void *old, void *old_key, void *new, void *new_key)
{
    gc_gmc_wb(interpreter, agg, old, new);
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
#ifdef GMC_NO_GC_RUN
#ifdef GMC_DEBUG
	fprintf(stderr, "Skipping GC run\n");
#endif /* GMC_DEBUG */
#else
#ifdef GMC_DEBUG
	fprintf(stderr, "GMC RUN !\n");
#endif
	arena_base->dod_runs++;
	arena_base->lazy_dod = (flags & DOD_lazy_FLAG);
	gc_gmc_mark(interpreter, arena_base->pmc_pool, !arena_base->lazy_dod);
	gc_gmc_compact(interpreter, arena_base->pmc_pool);
	if (arena_base->lazy_dod)
	    arena_base->lazy_dod_runs++;

#ifdef GMC_DEBUG
	fprintf (stderr, "\nGMC: Trying to run dod_run for normal allocation\n\n");
#endif /* GMC_DEBUG */
#endif /* GMC_NO_GC_RUN */
	--arena_base->DOD_block_level;
    }

}



/* Calls finalizers of all PMC in pool that are marked as dead. */
static int sweep_pmc (Interp *interpreter, struct Small_Object_Pool *pool,
	int flag, void *arg)
{

    Gc_gmc_obj *obj;
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
	for (obj = gen->fst_free; (UINTVAL)obj < (UINTVAL)gen->first; obj = gc_gmc_next_obj(obj))
	{
	    pmc = Gmc_OBJ_get_POBJ(obj);
	    /* We can do it only now, or we don't know how to go to the next
	     * body. */
	    if (old_pmc)
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "From sweep_pmc\n");
#endif
		(*pool->add_free_object)(interpreter, pool, old_pmc);
	    }
	    old_pmc = NULL;

	    if (!PObj_live_TEST(pmc))
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "sweep_pmc: %p -> (%p, %p)\n", pmc, obj, Gmc_OBJ_get_BODY(obj,PMC_BODY*));
#endif
		if (PObj_needs_early_DOD_TEST(pmc))
		    --interpreter->arena_base->num_early_DOD_PMCs;
		if (PObj_active_destroy_TEST(pmc)) {
		    VTABLE_destroy(interpreter, pmc);
		}
		if (PObj_igp_TEST(pmc))
		{
		    gc_gmc_sweep_from_hdr_list(interpreter, obj);
		}
		old_pmc = pmc;
		sweep++;
		(Gmc_OBJ_get_GEN(obj))->alloc_obj--;
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
    Gc_gmc_obj *obj;
    Gc_gmc_gen *gen;
    INTVAL pass = 0;
    PObj *pobj, *old_pobj;
    
    old_pobj = NULL;

    for (gen = pool->gc->old_fst; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass)
	{
	    pass++;
	    gen = pool->gc->yng_fst;
	}
	for (obj = gen->fst_free; (UINTVAL)obj < (UINTVAL)gen->first; obj = gc_gmc_next_obj(obj))
	{
	    pobj = (PObj*)Gmc_OBJ_get_POBJ(obj);
	    if (old_pobj)
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "From sweep buf\n");
#endif
		(*pool->add_free_object)(interpreter, pool, old_pobj);
	    }
	    old_pobj = NULL;

	    /* Go through all the headers of the pool. */
	    if (!PObj_live_TEST(pobj))
	    {
		if (PObj_sysmem_TEST(pobj) && PObj_bufstart(pobj)) {
		    /* has sysmem allocated, e.g. string_pin */
		    mem_sys_free(PObj_bufstart(pobj));
		    PObj_bufstart(pobj) = NULL;
		    PObj_buflen(pobj) = 0;
		} else {
		    /*
		     * XXX Jarkko did report that on irix pool->mem_pool
		     *     was NULL, which really shouldn't happen
		     */
		    if (pool->mem_pool) {
			if (!PObj_COW_TEST(pobj)) {
			    ((struct Memory_Pool *)
			     pool->mem_pool)->guaranteed_reclaimable +=
				PObj_buflen(pobj);
			}
			((struct Memory_Pool *)
			 pool->mem_pool)->possibly_reclaimable +=
			    PObj_buflen(pobj);
		    }
		    PObj_buflen(pobj) = 0;
		}
		old_pobj = pobj;
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
    Gc_gmc_obj *obj;
    Gc_gmc_gen *gen;
    INTVAL pass = 0;

    for (gen = pool->gc->old_fst; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass)
	{
	    pass++;
	    gen = pool->gc->yng_fst;
	}
	for (obj = gen->fst_free; (UINTVAL)obj < (UINTVAL)gen->first; obj = gc_gmc_next_obj(obj))
	    PObj_live_CLEAR(Gmc_OBJ_get_POBJ(obj));
    }
    return 0;
}


/* Initializes the pool for M&S. Basically, mark everyone dead. */
static void
gc_gmc_init_pool_for_ms(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc_gen *gen;
    Gc_gmc_obj *obj;
    int pass;
    for (gen = pool->gc->old_fst, pass = 0; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass) {
	    gen = pool->gc->yng_fst;
	    pass++;
	}
	gen->marked = 0;
	/* If we are searching timely destruction objects, we are going
	 * to make a full run anyway, so we can afford to mark everyone
	 * as dead first (this will remove false negatives and thus avoid
	 * us to have to run two times the GC). */
	if (interpreter->arena_base->lazy_dod)
	{
	    for (obj = gen->fst_free; (UINTVAL)obj < (UINTVAL)gen->first; obj = gc_gmc_next_obj(obj))
		PObj_live_CLEAR(Gmc_OBJ_get_POBJ(obj));
	}
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
gc_gmc_trace_children(Interp *interpreter, Gc_gmc_obj *o)
{
    UINTVAL mask = PObj_data_is_PMC_array_FLAG | PObj_custom_mark_FLAG;
    UINTVAL bits;
    PMC *pmc;
    INTVAL i;

    pmc = Gmc_OBJ_get_POBJ(o);
    Gmc_OBJ_get_GEN(o)->pool->gc->hdr_ref = o;

    bits = PObj_get_FLAGS(pmc) & mask;
    if (bits)
    {
	if (bits == PObj_data_is_PMC_array_FLAG) {
	    PMC** data = PMC_data(pmc);
	    if (data)
	    {
		for (i = 0; i < PMC_int_val(pmc); i++)
		{
		    if (data[i])
		    /*if (data[i] && Gmc_PMC_get_HDR(data[i]) > h)*/
			pobject_lives(interpreter, (PObj*)data[i]);
		}
	    }
	} else {
	    VTABLE_mark(interpreter, pmc);
	}
    }
}

static void
gc_gmc_trace_igp_sons(Interp *interpreter, Gc_gmc_obj *o)
{
    UINTVAL mask = PObj_data_is_PMC_array_FLAG | PObj_custom_mark_FLAG;
    UINTVAL bits;
    PMC *pmc;
    INTVAL i;
    INTVAL sav_state;
    struct Small_Object_Pool *pool;

    pmc = Gmc_OBJ_get_POBJ(o);

    pool = Gmc_OBJ_get_GEN(o)->pool;
    sav_state = pool->gc->state;
    pool->gc->state = GMC_SON_OF_IGP_STATE;

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
	    gc_gmc_trace_igp_sons(interpreter, Gmc_POBJ_get_OBJ(s->store[i]));
	}
    }
}



/* Marks the object whose body is at h as alive. */
void
parrot_gc_gmc_pobject_lives(Interp *interpreter, PObj *o)
{
    Gc_gmc *gc;
    Gc_gmc_obj *obj;

    obj = Gmc_POBJ_get_OBJ(o);
#ifdef GMC_DEBUG
    fprintf (stderr, "PObject %p, body at %p lives !\n", o, obj);
#endif
    gc = Gmc_OBJ_get_GEN(obj)->pool->gc;
    switch (gc->state)
    {
	/* This object was precedently dead and has been marked alive as a
	 * consequence of IGP. */
	case GMC_SON_OF_IGP_STATE:
	    if (!PObj_live_TEST(o) && Gmc_OBJ_get_GEN(obj)->marked)
	    {
		PObj_live_SET(o);
		gc_gmc_trace_igp_sons(interpreter, obj);
	    }
	    break;
	case GMC_NORMAL_STATE:
	    /*if ((UINTVAL)h > (UINTVAL)gc->hdr_ref)*/
		PObj_live_SET(o);
	    break;
	default:
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
    Gc_gmc_obj *obj, *o2;
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

    gen = pool->gc->yng_lst;
    pool->gc->hdr_ref = NULL;
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
	    for (obj = gen->fst_free; (UINTVAL)obj < (UINTVAL)gen->first; obj = gc_gmc_next_obj(obj))
	    {
		pool->gc->gray = obj;

		/* If we have found enough objects, change our state and
		 * consider only IGP from now on. */
		/* If this is a timely destruction triggered run, make a full
		 * run. */
		if (!state && dopr <= 0 && !interpreter->arena_base->lazy_dod)
		    state = 1;

		/* PObj is alive, trace its children */
		if (PObj_live_TEST(Gmc_OBJ_get_POBJ(obj)))
		{
		    if (PObj_igp_TEST(Gmc_OBJ_get_POBJ(obj)))
			gc_gmc_trace_igp_sons(interpreter, obj);
		    gc_gmc_trace_children(interpreter, obj);
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

    return (DEAD_OBJECTS_PER_RUN - dopr);
}


/* Copies a header and its pmc_body, then updates the pointers. */
/* We are sure that there is enough room in to. from and to may overlap. */
/* Also clear the live bit of the new object. */
static Gc_gmc_obj *
gc_gmc_copy_hdr(Interp *interpreter, Gc_gmc_obj *from, Gc_gmc_obj *to)
{
    Gc_gmc_gen *gen;
    size_t size;

    PObj_live_CLEAR(Gmc_OBJ_get_POBJ(to));
    if (from == to)
	return gc_gmc_next_obj(to);
    size = gc_gmc_get_size(from);
    gen = Gmc_OBJ_get_GEN(from);
    memmove(to, from, size);
    Gmc_OBJ_set_GEN(to, gen);
    Gmc_POBJ_get_OBJ(Gmc_OBJ_get_POBJ(to)) = to;
    return gc_gmc_next_obj(to);
}



/* Compacts a generation. */

/*

Our generation looks like :
    
    [ ________OOXOXXOOXXXXOOOXXXOO ]
	      ^                    ^
	      |                    |
           fst_free              first

where C<_> is unused memory, C<O> is a live object and C<X> is a dead object.

We use two pointers, C<orig> and C<dest>. C<orig> represents the object that we
are currently examining while dest is the place where the next object will be
copied. So C<orig> is always >= to C<dest> and there are only live objects to
the left of C<dest>.

During the compacting, a gen looks like :

    [ _________OOOOOOOXOXOOXOXXXXOO ]
                      ^       ^    
		      |       |
		    dest     orig

If the object at C<orig> is alive, then copy it to dest, clear its live flag
(for next run) and move both pointers forward. If not, call finalizers methods
on him and move only orig.

When C<orig> has walked all the objects, we are done with the first phase of
compaction and memory looks like :

    [ _________0000000000000XX00X0 ]
               ^          ^        ^
               |          |        |
	    fst_free	dest     orig
	                         first

The area between dest and orig is junk (live objects have already been copied).
As we need the generation to be aligned to the right, we'll simply shift
the area between fst_free and dest to first - dest + fst_free.

			
=cut

*/
static INTVAL
gc_gmc_compact_gen(Interp *interpreter, Gc_gmc_gen *gen)
{
    Gc_gmc_obj *orig;
    Gc_gmc_obj *dest;
    PMC *to_destroy;
    size_t remaining;
    size_t size;
    INTVAL leave = 0;
    INTVAL destroyed = 0;

    /* Begin by aligning them on the left, we'll shift everything in the end. */
    orig = dest = gen->fst_free;
    remaining = (char*)gen->first - (char*)gen->fst_free + gen->remaining;

    to_destroy = NULL;
    /* We are sure that orig will be the first to hit the barrier. */
    while ((UINTVAL)orig < (UINTVAL)gen->first)
    {
	/*assert(!((UINTVAL)orig % GMC_ALIGN));*/
	/* Free any object that has the live flag clear. */
	while (((UINTVAL)orig < (UINTVAL)gen->first || !(leave = 1)) && !PObj_live_TEST(Gmc_OBJ_get_POBJ(orig)))
	{
	    /*assert(!((UINTVAL)orig % GMC_ALIGN));*/
	    if (to_destroy)
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "From compact_gen\n");
#endif
		(*gen->pool->add_free_object)(interpreter, gen->pool, to_destroy);
	    }
	    to_destroy = NULL;

	    if (PObj_needs_early_DOD_TEST(Gmc_OBJ_get_POBJ(orig)))
		--interpreter->arena_base->num_early_DOD_PMCs;
	    if (PObj_active_destroy_TEST(Gmc_OBJ_get_POBJ(orig)))
		VTABLE_destroy(interpreter, Gmc_OBJ_get_POBJ(orig));
	    if (PObj_igp_TEST(Gmc_OBJ_get_POBJ(orig)))
		gc_gmc_sweep_from_hdr_list(interpreter, orig);
	    to_destroy = Gmc_OBJ_get_POBJ(orig);
	    orig = gc_gmc_next_obj(orig);
	    gen->alloc_obj--;
	    destroyed++;
	    assert(Gmc_OBJ_get_POBJ(orig));
	}
	if (!leave)
	{
	    if (to_destroy)
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "From compact_gen 2\n");
#endif
		(*gen->pool->add_free_object)(interpreter, gen->pool, to_destroy);
	    }
	    to_destroy = NULL;
	    /* Copy from orig to dest and update pointers. */	
	    size = gc_gmc_get_size(orig);
	    remaining -= size;
	    dest = gc_gmc_copy_hdr(interpreter, orig, dest);
	    orig = (Gc_gmc_obj*)((char*)orig + size);
	}
    }

    /* Shift everything to align them to the higher memory */
    size = (char*)dest - (char*)gen->fst_free;
#ifdef BIG_dump
    fprintf(stderr, "Moving %p - %p to %p - %p in gen %p (%p - %p)\n", gen->fst_free, dest, (char*)gen->first - size, (char*)gen->first, gen, (char*)gen->fst_free - gen->remaining, gen->first);
#endif
    memmove((char*)gen->first - size, gen->fst_free, size);
    gen->fst_free = (char*)gen->first - size;
    for (orig = gen->fst_free; (UINTVAL)orig < (UINTVAL)gen->first; orig = gc_gmc_next_obj(orig))
    {
	Gmc_POBJ_get_OBJ(Gmc_OBJ_get_POBJ(orig)) = orig;
    }
    
    gen->remaining = remaining;
#ifdef GMC_DEBUG
    fprintf(stderr, "gen %p, destroyed %ld, remaining %ld\n", gen, destroyed, gen->alloc_obj);
#endif
    return destroyed;
}



/* Appends all objects of yng just after those of old. */
static void
gc_gmc_merge_gen(Interp *interpreter, Gc_gmc_gen *old, Gc_gmc_gen *yng)
{
    size_t size;
    Gc_gmc_obj *o;
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
    o = (Gc_gmc_obj*)((char*)old->fst_free - size);
    old->remaining -= size;
    /* And update all pointers. */
    for (; (UINTVAL)o < (UINTVAL)old->fst_free; o = gc_gmc_next_obj(o))
    {
	Gmc_OBJ_set_GEN(o,old);
	Gmc_POBJ_get_OBJ(Gmc_OBJ_get_POBJ(o)) = o;
    }
    old->fst_free = (void*)((char*)old->fst_free - size);


    /* Merge IGP sets */
    for (store = yng->IGP->first; store; store = store->next)
    {
	for (i = 0; &store->store[i] < store->ptr; i++)
	{
	    if (!gc_gmc_find_igp(old->IGP, (PMC*)store->store[i]))
		gc_gmc_store_hdr_list(interpreter, old->IGP, store->store[i]);
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
#ifdef BIG_DUMP
    void *ptr;
    fprintf(stderr, "Dumping free_list\n");
    for (ptr = pool->free_list; *(void**)ptr; ptr = *(void**)ptr)
	fprintf(stderr, "%p -> ", ptr);
    fprintf(stderr, "%p -> NULL\n", ptr);
#endif

}




#endif /* PARROT_GC_GMC */
