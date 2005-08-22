#include <parrot/parrot.h>

#if PARROT_GC_GMC


#define UNITS_PER_ALLOC_GROWTH_FACTOR 1.75
#define POOL_MAX_BYTES 65536*128

static void gc_gmc_add_free_object(Interp*, struct Small_Object_Pool*, void*);
static void *gc_gmc_get_free_typed_object(Interp*, struct Small_Object_Pool*, INTVAL);
static void *gc_gmc_get_free_sized_object(Interp*, struct Small_Object_Pool*, size_t);
static void *gc_gmc_get_free_object(Interp*, struct Small_Object_Pool*);
static void gc_gmc_alloc_objects(Interp*, struct Small_Object_Pool*);
static void gc_gmc_more_objects(Interp*, struct Small_Object_Pool*);
static void gc_gmc_more_pmc_bodies(Interp *, struct Small_Object_Pool*);


/* Determines the size of a PMC according to its base_type. */
    static size_t
gc_gmc_get_PMC_size(Interp *interpreter, INTVAL base_type)
{
    VTABLE *vtable = Parrot_base_vtables[base_type];
    if (!vtable)
	return (UINTVAL)0;
    return vtable->size;
}

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



/* Allocates and initializes a generation, but does not plug it to the pool yet. */
    static Gc_gmc_gen *
gc_gmc_gen_init(Interp *interpreter)
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

    /* We have an IGP basis : only one store. */
    IGP_store = mem_sys_allocate(sizeof(Gc_gmc_hdr_store));
    IGP_store->ptr = &(IGP_store->store[0]);
    IGP_store->next = NULL;
    IGP = mem_sys_allocate(sizeof(Gc_gmc_hdr_list));
    IGP->first = IGP_store;
    IGP->last = IGP_store;
    gen->IGP = IGP;

#ifdef GMC_DEBUG
    fprintf(stderr, "Allocating gen at %p, first at %p, limit at %p\n", gen, gen->first, (char*)gen->first + gen->remaining);
#endif

    return gen;
}

/* Inserts the given generation to the right place, keeping all generation 
 * sorted (by insertion sort). */
    static void
gc_gmc_insert_gen(Interp *interpreter, Gc_gmc *gc, Gc_gmc_gen *gen)
{
    Gc_gmc_gen *cur_gen;
    void *ptr;

    cur_gen = gc->old_lst;
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
	if (gc->yng_fst)
	{
	    gen->next = gc->yng_fst;
	    gc->yng_fst->prev = gen;
	    gc->yng_fst = gen;
	} else {
	    gen->next = NULL;
	    gc->yng_fst = gen;
	    gc->old_lst = gen;
	}
    }
    gen->prev = cur_gen;
    if (gc->old_lst == cur_gen)
	gc->old_lst = gen;
}


/* Checks if the linked list of generations is valid. Can be removed safely,
 * useful only for tests. */
    static void
gc_gmc_test_linked_list_gen(Interp *interpreter, Gc_gmc *gc)
{
    Gc_gmc_gen *gen;
    UINTVAL i,j;
    for (i = 0, gen = gc->yng_fst; gen; i++, gen = gen->next);
    for (j = 0, gen = gc->old_lst; gen; j++, gen = gen->prev);
    if (i != gc->nb_gen || j != gc->nb_gen)
    {
#ifdef GMC_DEBUG
	fprintf(stderr, "Invalid linked list\n");
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

static void gc_gmc_pool_deinit(Interp *, struct Small_Object_Pool *);


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
    gc->timely = gc_gmc_gen_init(interpreter);
    gc->constant = gc_gmc_gen_init(interpreter);
    pool->gc = gc;

    for (i = 0; i < GMC_GEN_INIT_NUMBER; i++)
    {
	gen = gc_gmc_gen_init(interpreter);
	gc_gmc_insert_gen(interpreter, gc, gen);
    }

    gc_gmc_test_linked_list_gen(interpreter, gc);

    /* Separate the generations in two halves : one is young (= aggregate
     * objects), the other is old (non-aggregate objects). */
    for (i = 0, gen = gc->yng_fst; i < (GMC_GEN_INIT_NUMBER/2); i++, gen = gen->next);
    gc->old_fst = gen;
    gc->old_lst = gen;
    /* Now cut the bridges between these two parts. */
    gen->prev->next = NULL;
    gen->prev = NULL;
    gc->yng_lst = gc->yng_fst;
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
	for (store = gen->IGP->first; store; st2 = store->next,mem_sys_free(store),
		store = st2);
	mem_sys_free(gen->first);
	mem_sys_free(gen);
	gen = gen_nxt;
    }

    for (gen = gc->old_fst; gen;)
    {
	gen_nxt = gen->next;
	for (store = gen->IGP->first; store; st2 = store->next,mem_sys_free(store),
		store = st2);
	mem_sys_free(gen->first);
	mem_sys_free(gen);
	gen = gen_nxt;
    }
}


static void gc_gmc_deinit(Interp *interpreter)
{
    struct Arenas *arena_base = interpreter->arena_base;

    /* This is done in gc_gmc_do_dod_run when given the right flag. */
    /*gc_gmc_pool_deinit(interpreter, arena_base->pmc_pool);*/

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
		(UINTVAL)((char*)arena->start_objects + pool->object_size * arena->total_objects);
		ptr = (PMC*)((char*)ptr + pool->object_size), i++)
	{
	    if (gc_gmc_bitmap_test(arena->bitmap,i) && !PObj_live_TEST(ptr))
	    {
		/* This shouldn't be necessary. */
		if (PObj_needs_early_DOD_TEST(ptr))
		    --arena_base->num_early_DOD_PMCs;
		if (PObj_active_destroy_TEST(ptr)) {
		    VTABLE_destroy(interpreter, ptr);
		}
		gc_gmc_bitmap_clear(arena->bitmap, i);
		sweep++;
		/* This is the work of the VTABLE_destroy function. */
		/*
		   if ((Gmc_has_PMC_EXT_TEST(ptr) || PObj_is_PMC_EXT_TEST(ptr)) && PMC_data(ptr))
		   {
		   mem_sys_free(PMC_data(ptr));
		   PMC_data(ptr) = NULL;
		   } */
	    }
	}
    }
#ifdef GMC_DEBUG
    fprintf (stderr, "Sweeped %d PMC in pool %s (%d/%d)\n", sweep, pool->name, pool->total_objects - pool->num_free_objects, pool->total_objects);
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
		(UINTVAL)((char*)arena->start_objects + pool->object_size * arena->total_objects);
		obj = (PObj*)((char*)obj + pool->object_size), i++)
	{

	    if (gc_gmc_bitmap_test(arena->bitmap, i))
	    {
		if (PObj_sysmem_TEST(obj) && PObj_bufstart(obj)) {
		    /* has sysmem allocated, e.g. string_pin */
		    mem_sys_free(PObj_bufstart(obj));
		    PObj_bufstart(obj) = NULL;
		    PObj_buflen(obj) = 0;
		}
		else {
#ifdef GC_IS_MALLOC
		    /* free allocated space at (int*)bufstart - 1,
		     * but not if it is used COW or external
		     */
		    if (PObj_bufstart(obj) &&
			    !PObj_is_external_or_free_TESTALL(obj)) {
			if (PObj_COW_TEST(obj)) {
			    INTVAL *refcount = ((INTVAL *)PObj_bufstart(obj) - 1);

			    if (!--(*refcount))
				free(refcount); /* the actual bufstart */
			}
			else
			    free((INTVAL*)PObj_bufstart(obj) - 1);
		    }
#else
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
#endif
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
		(UINTVAL)((char*)arena->start_objects + pool->object_size * arena->total_objects);
		obj = (PObj*)((char*)obj + pool->object_size), i++)
	{
	    if (gc_gmc_bitmap_test(arena->bitmap, i))
		gc_gmc_bitmap_clear(arena->bitmap, i);
	}
    }
    return 0;
}



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
	/*Parrot_forall_header_pools(interpreter, POOL_BUFFER, 0, sweep_buf);*/

	/* Then the pmc_bodies. */
	gc_gmc_pool_deinit(interpreter, arena_base->pmc_pool);

#ifdef GMC_DEBUG
	fprintf (stderr, "GMC: Trying to run dod_run for final sweeping\n");
#endif /* GMC_DEBUG */
	--arena_base->DOD_block_level;
	return;
    } else {
#ifdef GMC_DEBUG
	fprintf (stderr, "GMC: Trying to run dod_run for normal allocation\n");
#endif /* GMC_DEBUG */
	--arena_base->DOD_block_level;
    }

}

void Parrot_gc_gmc_init(Interp *interpreter)
{
    struct Arenas *arena_base;

    arena_base = interpreter->arena_base;

    arena_base->do_dod_run = gc_gmc_run;
    arena_base->de_init_gc_system = gc_gmc_deinit;
    arena_base->init_pool = gc_gmc_pool_init;
}


/* Write Barrier Functions */

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
    *(s->ptr)++ = h;
}



void gc_gmc_wb(Interp *interpreter, PMC *agg, void *old, void *new)
{

}

void gc_gmc_wb_key(Interp *interpreter, PMC *agg,
	void *old, void *old_key, void *new, void *new_key)
{
    }




/******************************* REAL THINGS ********************************/


/* Allocates a new Small_Object_Arena and links it to the current pool. */
    static void 
gc_gmc_alloc_objects(Interp *interpreter, struct Small_Object_Pool *pool)
{
    struct Small_Object_Arena *new_arena;
    char *ptr;
    void *lim;
    new_arena = mem_sys_allocate(sizeof(struct Small_Object_Arena));

    new_arena->start_objects = mem_sys_allocate_zeroed(pool->objects_per_alloc * pool->object_size);
    new_arena->total_objects = pool->objects_per_alloc;
    new_arena->used = 0;
    new_arena->start_looking = new_arena->start_objects;
    new_arena->bitmap = gc_gmc_new_bitmap(pool->objects_per_alloc);
    pool->num_free_objects += pool->objects_per_alloc;
    pool->total_objects += pool->objects_per_alloc;
    new_arena->next = NULL;
    new_arena->prev = pool->last_Arena;
    lim = (void*)((char*)new_arena->start_objects + pool->objects_per_alloc * pool->object_size);

    if (pool->last_Arena)
	pool->last_Arena->next = new_arena;
    pool->last_Arena = new_arena;

    /* Allocate more next time. */
    pool->objects_per_alloc = (UINTVAL) pool->objects_per_alloc * UNITS_PER_ALLOC_GROWTH_FACTOR;
    if (pool->object_size * pool->objects_per_alloc > POOL_MAX_BYTES)
	pool->objects_per_alloc = POOL_MAX_BYTES / pool->object_size;

    /* Tell alloc to begin looking in this arena */
    pool->free_list = new_arena;

#ifdef GMC_DEBUG
    fprintf(stderr, "Allocated new objects at arena %p, %p\n", new_arena, new_arena->start_objects);
#endif
}



/* Returns a new PObj with a body of the required size. */
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
	gc_gmc_more_pmc_bodies (interpreter, pool);

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
    fprintf (stderr,"Allocated size %d in gen %p, first: %p, remaining %d, next_gen: %p, fst_free: %p, lim: %p\n", size, gen, gen->first, gen->remaining, gen->next, gen->fst_free, (char*)gen->fst_free + gen->remaining);
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
	    pmc = (PMC*)((char*)pmc + pool->object_size), i++)

    pool->free_list = arena;
    gc_gmc_bitmap_set(arena->bitmap, i);
    ++arena->used;
    --pool->num_free_objects;
    PMC_body((PMC*)pmc) = Gmc_PMC_hdr_get_BODY((Gc_gmc_hdr*)pmc_body);
    Gmc_PMC_hdr_get_GEN((Gc_gmc_hdr*)pmc_body) = gen;

    Gmc_PMC_hdr_get_PMC((Gc_gmc_hdr*)pmc_body) = pmc;
    PObj_get_FLAGS((PObj*)pmc) = 0;

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


/* Should not be called anywhere. */
    static void
gc_gmc_add_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool, void *to_add)
{
    Gmc_PMC_flag_SET(marking,(PMC*)to_add); 
}



/* Returns a PMC of type base_type (which is an index into Parrot_base_vtables). */
    static void *
gc_gmc_get_free_typed_object(Interp *interpreter,
	struct Small_Object_Pool *pool, INTVAL base_type)
{
    Gc_gmc *gc = pool->gc;
    size_t size = sizeof(Gc_gmc_hdr) + gc_gmc_get_PMC_size(interpreter, base_type);
    VTABLE *vtable = Parrot_base_vtables[base_type];
    INTVAL aggreg = vtable->flags & VTABLE_PMC_NEEDS_EXT;
    PMC *pmc = gc_gmc_get_free_object_of_size (interpreter, pool, size, aggreg);
    Gmc_PMC_flag_SET(is_pmc, pmc);
    return pmc;
}


/* Returns a PObj of the required size. */
    static void *
gc_gmc_get_free_sized_object(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size)
{
    PMC *pmc = gc_gmc_get_free_object_of_size (interpreter, pool, sizeof(Gc_gmc_hdr) + size, 0);
    if (size == sizeof(pobj_body))
	Gmc_PMC_flag_CLEAR(is_pmc, pmc);
    else
	Gmc_PMC_flag_SET(is_pmc, pmc);
    return pmc;
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
#ifdef GMC_DEBUG
    fprintf (stderr, "Copying gen (%p,%p) to gen (%p,%p)\n", from, from->first, dest, dest->first);
#endif
    memcpy(dest->first, from->first, GMC_GEN_SIZE);
    ptr = dest->first;
    while ((UINTVAL)ptr < (UINTVAL)dest->fst_free)
    {
	PMC_body(Gmc_PMC_hdr_get_PMC(ptr)) = Gmc_PMC_hdr_get_BODY(ptr);
	Gmc_PMC_hdr_get_GEN(ptr) = dest;
	if (PObj_is_PMC_TEST(Gmc_PMC_hdr_get_PMC(ptr)))
	    ptr = (Gc_gmc_hdr*)((char*)ptr + Gmc_PMC_hdr_get_PMC(ptr)->vtable->size + sizeof(Gc_gmc_hdr));
	else
	    ptr = (Gc_gmc_hdr*)((char*)ptr + sizeof(Gc_gmc_hdr) + sizeof(pobj_body));
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
gc_gmc_more_pmc_bodies (Interp *interpreter,
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
	gen = gc_gmc_gen_init (interpreter);
	gc_gmc_insert_gen (interpreter, dummy_gc, gen);
    }

    gc_gmc_test_linked_list_gen(interpreter, dummy_gc);

    for (gen = dummy_gc->yng_fst, ogen = gc->yng_fst; ogen; gen = gen->next)
    {
	ogen_nxt = ogen->next;
	gc_gmc_copy_gen(ogen,gen);
	gc_gmc_gen_free(ogen);
	ogen = ogen_nxt;
    }
    dummy_gc->yng_lst = gen;

    for (gen = dummy_gc->yng_fst, i = 0; i < (nb_gen/2); i++, gen = gen->next);
    dummy_gc->old_fst = gen;
    gen->prev->next = NULL;
    gen->prev = NULL;

    for (gen = dummy_gc->old_fst, ogen = gc->old_fst; ogen; gen = gen->next)
    {
	ogen_nxt = ogen->next;
	gc_gmc_copy_gen(ogen,gen);
	gc_gmc_gen_free(ogen);
	ogen = ogen_nxt;
    }
    dummy_gc->old_lst = gen;

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



/* Obtains more free objects from the pool. */
    static void
gc_gmc_more_objects(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    /* For now only alloc more objects. There will be a GC run in the future. */
    (*pool->alloc_objects) (interpreter, pool);
}


#endif /* PARROT_GC_GMC */
