/* 
Copyright: 2001-2005 The Perl Foundation.  All Right Reserved.
$Id: $

=head1 NAME

src/gc_gmc.c - Generational Mark & Compact Garbage Collection


=head1 OVERVIEW

This is a generational GC scheme that introduces copying and compaction to Parrot.
Keywords:
- copying, compacting
- mark and sweep
- generational


=head1 DESCRIPTION

TODO

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

    cur_gen = gc->yng_lst;
    if (cur_gen)
	ptr = (void*)cur_gen->first;
    else
	ptr = NULL;

    /* Find the right place for the address malloc gave us. */
    while ((UINTVAL)ptr > (UINTVAL)gen->first)
    {
	cur_gen = cur_gen->prev;
	if (cur_gen)
	    ptr = cur_gen->first;
	else
	    ptr = NULL;
    }

    /* Insert the generation. */
    if (cur_gen)
    {
	if (cur_gen->next)
	{
	    cur_gen->next->prev = gen;
	}
	gen->next = cur_gen->next;
	cur_gen->next = gen;
    } else {
	if (gc->old_fst)
	{
	    gen->next = gc->old_fst;
	    gc->old_fst->prev = gen;
	    gc->old_fst = gen;
	} else {
	    gen->next = NULL;
	    gc->old_fst = gen;
	    gc->yng_lst = gen;
	}
    }
    gen->prev = cur_gen;
    if (gc->yng_lst == cur_gen)
	gc->yng_lst = gen;
}



/* Initializes a pool with some empty generations. */
    static void 
gc_gmc_pool_init(Interp *interpreter, struct Small_Object_Pool *pool) 
{
    struct Arenas *arena_base;
    Gc_gmc *gc;
    Gc_gmc_gen *gen;
    int i;

    pool->add_free_object = gc_gmc_add_free_object;
    pool->get_free_object = gc_gmc_get_free_object;
    pool->get_free_typed_object = gc_gmc_get_free_typed_object;
    pool->get_free_sized_object = gc_gmc_get_free_sized_object;
    pool->alloc_objects   = gc_gmc_alloc_objects;
    pool->more_objects    = gc_gmc_more_objects;

    gc = mem_sys_allocate(sizeof(Gc_gmc));

    gc->nb_gen = GMC_GEN_INIT_NUMBER;
    gc->nb_empty_gen = GMC_GEN_INIT_NUMBER;
    gc->alloc_obj = 0;
    gc->yng_fst = NULL;
    gc->yng_lst = NULL;
    gc->old_fst = NULL;
    gc->old_lst = NULL;
    gc->igp_ref = NULL;
    gc->gray = NULL;
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
	mem_sys_free(gen->first);
	mem_sys_free(gen);
	gen = gen_nxt;
    }

    for (gen = gc->old_fst; gen;)
    {
	gen_nxt = gen->next;
	mem_sys_free(gen->first);
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
    internal_exception(1, "add_free should not be called in GMC!\n");
}



/* Returns a new object with a body of the required size. */
    static void *
gc_gmc_get_free_object_of_size(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size, INTVAL aggreg)
{
    void *pmc_body;
    void *pmc;
    void *ptr;
    UINTVAL i;
    Gc_gmc *gc = pool->gc;
    Gc_gmc_gen *gen, *gen_ref;
    struct Small_Object_Arena *arena;

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

    pmc_body = gen->fst_free;
    gen->fst_free = (void*)((char*)gen->fst_free + size);
    gen->remaining -= size;
    gen->alloc_obj++;
    memset(pmc_body, 0, size);
#ifdef GMC_DEBUG
    fprintf (stderr,"Allocated size %d in gen %p, first: %p,"
	    "remaining %d, next_gen: %p, fst_free: %p, lim: %p\n", 
	    size, gen, gen->first, gen->remaining, gen->next, gen->fst_free, 
	    (char*)gen->fst_free + gen->remaining);
#endif

    /* Allocate the PMC* */

    /* If we don't have any objects left, find more. */
    if (!pool->num_free_objects)
	(*pool->more_objects) (interpreter, pool);

    /* Find an arena with a free object. */
    for (arena = pool->free_list; arena->total_objects == arena->used;
	    arena = (arena->prev) ? arena->prev : pool->last_Arena);

    /* Now find this object. */
    for (pmc = arena->start_objects, i = 0;
	    gc_gmc_bitmap_test(arena->bitmap, i);
	    pmc = (PMC*)((char*)pmc + pool->object_size), i++);

    pool->free_list = arena;
    gc_gmc_bitmap_set(arena->bitmap, i);
    ++arena->used;
    --pool->num_free_objects;
    PMC_body((PMC*)pmc) = Gmc_PMC_hdr_get_BODY((Gc_gmc_hdr*)pmc_body);
    Gmc_PMC_hdr_get_GEN((Gc_gmc_hdr*)pmc_body) = gen;

    Gmc_PMC_hdr_get_PMC((Gc_gmc_hdr*)pmc_body) = pmc;
    PObj_get_FLAGS((PObj*)pmc) = 0;
    Gmc_PMC_hdr_get_FLAGS((Gc_gmc_hdr*)pmc_body) = 0;

#ifdef BIG_DUMP
    fprintf(stderr, "Allocated ptr %p with body at %p from gen %p\n", pmc, Gmc_PMC_hdr_get_BODY(pmc_body), gen);
#endif
    return pmc;
}


/* Here we allocate a default PObj, as it is non-typed. */
/* This function should not be called anywhere if possible. */
    void *
gc_gmc_get_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    size_t size = sizeof(Gc_gmc_hdr) + sizeof(pobj_body);
    PMC *pmc = gc_gmc_get_free_object_of_size(interpreter, pool, size, 0);
    Gmc_PMC_flag_CLEAR(is_pmc,pmc);
    return pmc;
}



/* Returns a PObj of the required size. */
    static void *
gc_gmc_get_free_sized_object(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size)
{
    PMC *pmc = gc_gmc_get_free_object_of_size (interpreter, pool,
	    sizeof(Gc_gmc_hdr) + size, 0);
    if (size == sizeof(pobj_body))
	Gmc_PMC_flag_CLEAR(is_pmc, pmc);
    else
	Gmc_PMC_flag_SET(is_pmc, pmc);
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
    Gmc_PMC_flag_SET(is_pmc, pmc);
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
    new_arena->start_looking = new_arena->start_objects;
    new_arena->bitmap = gc_gmc_new_bitmap(pool->objects_per_alloc);
    pool->num_free_objects += pool->objects_per_alloc;
    pool->total_objects += pool->objects_per_alloc;

    /* Allocate more next time. */
    pool->objects_per_alloc = 
	(UINTVAL) pool->objects_per_alloc * UNITS_PER_ALLOC_GROWTH_FACTOR;
    if (pool->object_size * pool->objects_per_alloc > POOL_MAX_BYTES)
	pool->objects_per_alloc = POOL_MAX_BYTES / pool->object_size;

    /* Tell alloc to begin looking in this arena */
    pool->free_list = new_arena;

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
    INTVAL offset = (char*)from->fst_free - (char*)from->first;
    Gc_gmc_hdr *ptr;
    dest->fst_free = (void*)((char*)dest->first + offset);
    dest->remaining = from->remaining;
    dest->IGP = from->IGP;
    dest->alloc_obj = from->alloc_obj;
#ifdef GMC_DEBUG
    fprintf (stderr, "Copying gen (%p,%p) to gen (%p,%p)\n",
	    from, from->first, dest, dest->first);
#endif
    memcpy(dest->first, from->first, GMC_GEN_SIZE);
    ptr = dest->first;
    while ((UINTVAL)ptr < (UINTVAL)dest->fst_free)
    {
#ifdef BIG_DUMP
	fprintf(stderr, "copy_gen: ptr %p, old_body %p, new_body %p\n", Gmc_PMC_hdr_get_PMC(ptr), PMC_body(Gmc_PMC_hdr_get_PMC(ptr)), Gmc_PMC_hdr_get_BODY(ptr));
#endif
	Gmc_PMC_hdr_get_GEN(ptr) = dest;
	PMC_body(Gmc_PMC_hdr_get_PMC(ptr)) = Gmc_PMC_hdr_get_BODY(ptr);
	ptr = gc_gmc_next_hdr(ptr);
    }
}



/* Frees a generation. */
    static void
gc_gmc_gen_free(Gc_gmc_gen *gen)
{
    mem_sys_free(gen->first);
    mem_sys_free(gen);
}



/* Allocates twice as much generations as before, copies everything */
/* TODO: double only the half that needs it. */
    static void
gc_gmc_more_bodies (Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    Gc_gmc *gc = pool->gc;
    Gc_gmc *dummy_gc = mem_sys_allocate (sizeof(Gc_gmc));
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

    mem_sys_free(dummy_gc);

#ifdef GMC_DEBUG
    fprintf(stderr, "Done with allocation\n");
#endif
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
gc_gmc_find_igp(Interp *interpreter, Gc_gmc_hdr *h)
{
    Gc_gmc_gen *gen;
    Gc_gmc_hdr_list *list;
    Gc_gmc_hdr_store *store;
    INTVAL i;

    gen = Gmc_PMC_hdr_get_GEN(h);
    list = gen->IGP;
    for (store = list->first; store; store = store->next)
    {
	for (i = 0; &store->store[i] < store->ptr; i++)
	{
	    if (Gmc_PMC_get_HDR(store->store[i]) == h)
		return 1;
	}
    }
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
    /*fprintf (stderr, "bad igp: %p\n", h);*/
    /*internal_exception(1, "IGP pointer not found for removal!\n");*/
}



void gc_gmc_wb(Interp *interpreter, PMC *agg, void *old, void *new)
{
    Gc_gmc_gen *gen;
    if (PObj_is_PMC_TEST((PObj*)new) && Gmc_has_PMC_EXT_TEST((PMC*)new))
    {
	gen = Gmc_PMC_get_GEN((PMC*)agg);
	if (!gc_gmc_find_igp(interpreter, Gmc_PMC_get_HDR(agg)))
	    gc_gmc_store_hdr_list(interpreter, gen->IGP, Gmc_PMC_get_HDR(agg));
	Gmc_PMC_flag_SET(is_igp, agg);
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
    struct Arenas *arena_base = interpreter->arena_base;
    PMC *ptr;
    struct Small_Object_Arena *arena;
    int sweep = 0;
    UINTVAL i;

    /* Go through all the headers of the pool. */
    for (arena = pool->last_Arena; arena; arena = arena->prev)
    {
	for (i = 0, ptr = (PMC*)arena->start_objects; (UINTVAL)ptr < 
		(UINTVAL)((char*)arena->start_objects +
			  pool->object_size * arena->total_objects);
		ptr = (PMC*)((char*)ptr + pool->object_size), i++)
	{
	    if (gc_gmc_bitmap_test(arena->bitmap,i) && !PObj_live_TEST(ptr))
	    {
#ifdef BIG_DUMP
		fprintf(stderr, "ptr: %p, body at %p\n", ptr, PMC_body(ptr));
#endif
		/* This shouldn't be necessary. */
		if (PObj_needs_early_DOD_TEST(ptr))
		    --arena_base->num_early_DOD_PMCs;
		if (PObj_active_destroy_TEST(ptr)) {
		    VTABLE_destroy(interpreter, ptr);
		}
		/*fprintf (stderr, "Testing for igp: %p\n", Gmc_PMC_get_HDR(ptr));*/
		if (Gmc_PMC_flag_TEST(is_igp, ptr))
		{
#ifdef GMC_DEBUG
		    fprintf(stderr, "%p: is_igp: %s\n", Gmc_PMC_get_HDR(ptr), (Gmc_PMC_hdr_flag_TEST(is_igp,Gmc_PMC_get_HDR(ptr))) ? "set" : "clear");
#endif
		    gc_gmc_sweep_from_hdr_list(interpreter, Gmc_PMC_get_HDR(ptr));
		}
		gc_gmc_bitmap_clear(arena->bitmap, i);
		sweep++;
		(Gmc_PMC_get_GEN(ptr))->alloc_obj--;
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
    struct Arenas *arena_base = interpreter->arena_base;
    PObj *obj;
    struct Small_Object_Arena *arena;
    UINTVAL i;

    /* Go through all the headers of the pool. */
    for (arena = pool->last_Arena; arena; arena = arena->prev)
    {
	for (i = 0, obj = (PObj*)arena->start_objects; (UINTVAL)obj < 
		(UINTVAL)((char*)arena->start_objects +
			  pool->object_size * arena->total_objects);
		obj = (PObj*)((char*)obj + pool->object_size), i++)
	{

	    if (gc_gmc_bitmap_test(arena->bitmap, i) && !PObj_live_TEST(obj) && PMC_body(obj))
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
		gc_gmc_bitmap_clear(arena->bitmap, i);
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
    PObj *obj;
    struct Small_Object_Arena *arena;
    UINTVAL i;

    for (arena = pool->last_Arena; arena; arena = arena->prev)
    {
	for (i = 0, obj = (PObj*)arena->start_objects; (UINTVAL)obj < 
		(UINTVAL)((char*)arena->start_objects +
			  pool->object_size * arena->total_objects);
		obj = (PObj*)((char*)obj + pool->object_size), i++)
	{
	    if (gc_gmc_bitmap_test(arena->bitmap, i))
		PObj_live_CLEAR(obj);
	}
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
    /* Find the most recent object ever allocated and prepare for M&S. */
    hdr = pool->gc->yng_lst->first;
    while (1) {
	h2 = gc_gmc_next_hdr(hdr);
	if ((UINTVAL)h2 >= (UINTVAL)pool->gc->yng_lst->fst_free)
	    break;
	hdr = h2;
    }
    pool->gc->gray = hdr;
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
		    if (data[i] && Gmc_PMC_get_HDR(data[i]) < h)
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

    if (!Gmc_PMC_hdr_flag_TEST(is_igp, h))
	return;

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
	    pool = Gmc_PMC_hdr_get_GEN(h)->pool;
	    sav_state = pool->gc->state;
	    pool->gc->state = GMC_SON_OF_IGP_STATE;
	    VTABLE_mark(interpreter, pmc);
	    pool->gc->state = sav_state;
	}
    }
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
	/* This just comes from an IGP. */
	case GMC_IGP_STATE:
	    if ((UINTVAL)h > (UINTVAL)gc->igp_ref && !PObj_live_TEST(o))
	    {
		PObj_live_SET(o);
		gc->state = GMC_SON_OF_IGP_STATE;
		gc_gmc_trace_igp_sons(interpreter, h);
		gc->state = GMC_IGP_STATE;
	    }
	    break;
	/* This object was precedently dead and has been marked alive as a
	 * consequence of IGP. */
	case GMC_SON_OF_IGP_STATE:
	    if (!PObj_live_TEST(o) && (UINTVAL)h > (UINTVAL)gc->white)
	    {
		PObj_live_SET(o);
		gc_gmc_trace_igp_sons(interpreter, h);
	    }
	    break;
	case GMC_NORMAL_STATE:
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

/* Find the max number of objects allocated in a single gen. */
static INTVAL
gc_gmc_max_objects_per_gen(Interp *interpreter, struct Small_Object_Pool *pool)
{
    UINTVAL max = 0;
    Gc_gmc_gen *gen;
    INTVAL pass = 0;
    for (gen = pool->gc->old_fst; gen || !pass; gen = gen->next)
    {
	if (!gen && !pass)
	{
	    gen = pool->gc->yng_fst;
	    pass++;
	}
	if (gen->alloc_obj > max)
	{
	    max = gen->alloc_obj;
	}
    }
    return max;
}


/* Wraps everything nicely. */
static INTVAL
gc_gmc_mark(Interp *interpreter, struct Small_Object_Pool *pool, int flags)
{
    INTVAL dopr = DEAD_OBJECTS_PER_RUN; /* Number of objects we want to find in a run. */
    Gc_gmc_hdr *hdr, *h2;
    Gc_gmc_gen *gen;
    Gc_gmc_hdr **rev;
    INTVAL index;
    INTVAL max_obj;
    INTVAL pass = 0;
    /* State 0 : normal run, we free every dead object.
     * State 1 : we've found enough objects, simply consider IGP and mark
     * everyone alive. */
    INTVAL state = 0;

    rev = mem_sys_allocate_zeroed(gc_gmc_max_objects_per_gen(interpreter, pool) * sizeof(Gc_gmc_hdr*));

#ifdef GMC_DEBUG
    fprintf (stderr, "\nMarking pass\n\n");
    fprintf (stderr, "max objects: %d\n", gc_gmc_max_objects_per_gen(interpreter, pool));
#endif

    gc_gmc_init_pool_for_ms(interpreter, pool);
    gc_gmc_trace_root(interpreter, flags);

    hdr = pool->gc->gray; 
    gen = pool->gc->yng_lst;
    pool->gc->state = GMC_NORMAL_STATE;
    for (gen = pool->gc->yng_lst; gen || !pass; gen = gen->prev)
    {
	/* We've run through all the young objects, jump to the old ones. */
	if (!gen && !pass)
	{
	    gen = pool->gc->old_lst;
	    pass++;
	}
	
	/* Build the reverse pointers structure. */
	max_obj = gen->alloc_obj - 1;
	for (hdr = gen->first, index = 1; (UINTVAL)hdr < (UINTVAL)gen->fst_free && (UINTVAL)(h2 = gc_gmc_next_hdr(hdr)) < (UINTVAL)gen->fst_free && index <= max_obj; hdr = h2, index++)
	    rev[max_obj-index] = hdr; 


	if (!state)
	{
	    gen->marked = 1;

	    /* And go through it. */	
	    for (index = 0; index < max_obj; index++)
	    {
		hdr =rev[index]; 
		pool->gc->gray = hdr;

		/* If we have found enough objects, change our state and
		 * consider only IGP from now on. */
		if (dopr <= 0)
		{
		    pool->gc->white = hdr;
		    state = 1;
		}

		/* PObj is alive, trace its children */
		if (PObj_live_TEST((PObj*)Gmc_PMC_hdr_get_PMC(hdr)))
		{
		    gc_gmc_trace_children(interpreter, hdr);
		    if (Gmc_PMC_hdr_flag_TEST(is_igp, hdr))
			gc_gmc_trace_igp_sons(interpreter, hdr);
		}
		else
		    dopr--;
	    }
	} else
	    gc_gmc_trace_igp(interpreter, gen);
    }
    mem_sys_free(rev);
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

    if (from == to)
	return gc_gmc_next_hdr(to);
    size = gc_gmc_get_size(interpreter, from);
    gen = Gmc_PMC_hdr_get_GEN(from);
    memmove(to, from, size);
#ifdef BIG_DUMP
    fprintf(stderr, "copy_hdr: ptr %p, old_body %p, new_body %p\n", Gmc_PMC_hdr_get_PMC(from), PMC_body(Gmc_PMC_hdr_get_PMC(from)), Gmc_PMC_hdr_get_BODY(to));
#endif
    Gmc_PMC_hdr_get_GEN(to) = gen;
    PMC_body(Gmc_PMC_hdr_get_PMC(to)) = Gmc_PMC_hdr_get_BODY(to);
    PObj_live_CLEAR(Gmc_PMC_hdr_get_PMC(to));
    return gc_gmc_next_hdr(to);
}



/* Compacts a generation. */
static void
gc_gmc_compact_gen(Interp *interpreter, Gc_gmc_gen *gen)
{
    Gc_gmc_hdr *orig;
    Gc_gmc_hdr *dest;
    size_t remaining;
    size_t size;
    INTVAL leave = 0;
    INTVAL destroyed = 0;

    orig = dest = gen->first;
    remaining = (char*)gen->fst_free - (char*)gen->first + gen->remaining;

    /* We are sure that orig will be the first to hit the barrier. */
    while ((UINTVAL)orig < (UINTVAL)gen->fst_free)
    {
	/* Free any object that has the live flag clear. */
	while (((UINTVAL)orig < (UINTVAL)gen->fst_free || !(leave = 1)) && !PObj_live_TEST(Gmc_PMC_hdr_get_PMC(orig)))
	{
	    if (PObj_active_destroy_TEST(Gmc_PMC_hdr_get_PMC(orig)))
		VTABLE_destroy(interpreter, Gmc_PMC_hdr_get_PMC(orig));
	    if (Gmc_PMC_hdr_flag_TEST(is_igp, orig))
		gc_gmc_sweep_from_hdr_list(interpreter, orig);
	    gc_gmc_bitmap_clear_from_hdr((PObj*)Gmc_PMC_hdr_get_PMC(orig), gen->pool);
	    orig = gc_gmc_next_hdr(orig);
	    gen->alloc_obj--;
	    destroyed++;
	}
	if (!leave)
	{
	    /* Copy from orig to dest and update pointers. */	
	    size = gc_gmc_get_size(interpreter, orig);
	    remaining -= size;
	    dest = gc_gmc_copy_hdr(interpreter, orig, dest);
	    orig = (Gc_gmc_hdr*)((char*)orig + size);
	}
    }
    gen->fst_free = dest;
    gen->remaining = remaining;
#ifdef GMC_DEBUG
    fprintf(stderr, "gen %p, destroyed %d, remaining %d\n", gen, destroyed, gen->alloc_obj);
#endif
}



/* Appends all objects of yng just after those of old. */
static void
gc_gmc_merge_gen(Interp *interpreter, Gc_gmc_gen *old, Gc_gmc_gen *yng)
{
    size_t size;
    Gc_gmc_hdr *h;
    struct Small_Object_Pool *pool;


    pool = yng->pool;
    size = (UINTVAL)yng->fst_free - (UINTVAL)yng->first;

    /* Check we have enough space for this. */
    if (size >= (UINTVAL)old->remaining)
	return;

    /* Copy the data. */
    memcpy(old->fst_free, yng->first, size);
    h = old->fst_free;
    old->fst_free = (void*)((char*)old->fst_free + size);
    old->remaining -= size;
    /* And update all pointers. */
    for (; (UINTVAL)h < (UINTVAL)old->fst_free; h = gc_gmc_next_hdr(h))
    {
#ifdef BIG_DUMP
	fprintf(stderr, "merge_gen: h %p, ptr %p, old_body at %p, new body at %p\n", h, Gmc_PMC_hdr_get_PMC(h), PMC_body(Gmc_PMC_hdr_get_PMC(h)), Gmc_PMC_hdr_get_BODY(h));
#endif
	Gmc_PMC_hdr_get_GEN(h) = old;
	PMC_body(Gmc_PMC_hdr_get_PMC(h)) = Gmc_PMC_hdr_get_BODY(h);
    }
    old->next = yng->next;
    if (old->next)
	old->next->prev = old;
    if (pool->gc->yng_lst == yng)
	pool->gc->yng_lst = old;
    if (pool->gc->old_lst == yng)
	pool->gc->old_lst = old;
    
    gc_gmc_gen_free(yng);
}



static void
gc_gmc_compact(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc_gen *gen;
    Gc_gmc_gen *ogen;
    /* We want to treat the last_gen */
    INTVAL last_gen = 0;
    
    gen = pool->gc->yng_lst;
    ogen = NULL;
    /* Compact only the gen that were examined. */
    while ((UINTVAL)gen > (UINTVAL)pool->gc->white || !last_gen++)
    {
	gc_gmc_compact_gen(interpreter, gen);
	if (ogen)
	    gc_gmc_merge_gen(interpreter, gen, ogen);
	ogen = gen;
	gen = gen->prev;
	if (!gen)
	{
	    ogen = NULL;
	    gen = pool->gc->old_lst;
	}
    }
}


/* Old code. */
#if 0
/* Compacts every gen so they are all filled, except the last one. */
static void
gc_gmc_compact(Interp *interpreter, struct Small_Object_Pool *pool)
{
    /* The generation that we are currently filling. */
    Gc_gmc_gen *filled_gen;
    /* The generation of origin of the objects being moved. */
    Gc_gmc_gen *filling_gen;
    /* Place where the next object will be moved. */
    Gc_gmc_hdr *gray;
    /* Origin of the current object being moved. */
    Gc_gmc_hdr *white;

    INTVAL pass = 0;
    INTVAL copying = 0;
    size_t size;
    size_t remaining;
    
    filled_gen = filling_gen = pool->gc->old_fst;
    gray = white = filling_gen->first;
    remaining = (UINTVAL)filled_gen->fst_free - (UINTVAL)filled_gen->first + filled_gen->remaining;
    
    while (1)
    {
	while ((UINTVAL)gray < (UINTVAL)filling_gen->fst_free)
	{
	    /* Jump over any dead object. */
	    while (!PObj_live_TEST(Gmc_PMC_hdr_get_PMC(gray)) && filling_gen->marked)
	    {
		if (PObj_active_destroy_TEST(Gmc_PMC_hdr_get_PMC(gray)))
		    VTABLE_destroy(interpreter, Gmc_PMC_hdr_get_PMC(gray));
		if (Gmc_PMC_hdr_flag_TEST(is_igp, gray))
		{
		    /*fprintf(stderr, "Sweeping from mark\n");*/
		    gc_gmc_sweep_from_hdr_list(interpreter, gray);
		}
		/* XXX: find a way to mark the header dead as well! */
		gray = gc_gmc_next_hdr(gray);
		filling_gen->alloc_obj--;
		if ((UINTVAL)gray >= (UINTVAL)filling_gen->fst_free)
		    goto switch_gen;
	    }
	    /* If we are done with the current filled generation. */
	    if ((size = gc_gmc_get_size(interpreter, gray)) >= remaining)
	    {
		filled_gen->remaining = remaining;
		filled_gen->fst_free = white;
		assert(filled_gen->next);
		filled_gen = filled_gen->next;
		white = filled_gen->first;
		remaining = (UINTVAL)filled_gen->fst_free - (UINTVAL)filled_gen->first + filled_gen->remaining;
	    }
	    /* Then copy data and move both pointers. */
	    /*fprintf (stderr, "Copying %p to %p\n", gray, white);*/
	    remaining -= size;
	    white = gc_gmc_copy_hdr (interpreter, gray, white);
	    gray = (Gc_gmc_hdr*)((char*)gray + size);
	    filling_gen->alloc_obj--;
	    filled_gen->alloc_obj++;
	}
switch_gen:
	filling_gen = filling_gen->next;
	if (!filling_gen)
	{
	    if (pass)
		return;
	    filling_gen = pool->gc->yng_fst;
	    filled_gen = pool->gc->yng_fst;
	    white = filled_gen->first;
	    remaining = (UINTVAL)filled_gen->fst_free - (UINTVAL)filled_gen->first + filled_gen->remaining;
	    pass++;
	}
	gray = filling_gen->first;	
	if (gray > pool->gc->gray)
	{
	    filled_gen->fst_free = white;
	    filled_gen->remaining = remaining;
	    return;
	}
    }
}
#endif



#endif /* PARROT_GC_GMC */
