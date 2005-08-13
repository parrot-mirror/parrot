#include <parrot/parrot.h>

#if PARROT_GC_GMC


static void gc_gmc_add_free_object(Interp*, struct Small_Object_Pool*, void*);
static void *gc_gmc_get_free_typed_object(Interp*, struct Small_Object_Pool*, INTVAL);
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

    /* We have an IGP basis : only one store. */
    IGP_store = mem_sys_allocate(sizeof(Gc_gmc_hdr_store));
    IGP_store->ptr = &(IGP_store->store[0]);
    IGP_store->next = NULL;
    IGP = mem_sys_allocate(sizeof(Gc_gmc_hdr_list));
    IGP->first = IGP_store;
    IGP->last = IGP_store;
    gen->IGP = IGP;
    
    return gen;
}

/* Inserts the given generation to the right place, keeping all generation 
 * sorted (by insertion sort). */
static void
gc_gmc_insert_gen(Interp *interpreter, struct Small_Object_Pool *pool, Gc_gmc_gen *gen)
{
    Gc_gmc_gen *cur_gen;
    void *ptr;

    cur_gen = pool->gc->old_lst;
    if (cur_gen)
	ptr = (void*)cur_gen->first;
    else
	ptr = NULL;

    /* Find the right place for the address malloc gave us. */
    while ((UINTVAL)ptr > (UINTVAL)gen->first)
    {
      cur_gen = cur_gen->prev;
      ptr = cur_gen->first;
    }
    
    /* Insert the generation. */
    if (cur_gen)
    {
      if (cur_gen->next)
      {
	cur_gen->next->prev = gen;
      }
      cur_gen->next = gen;
      gen->next = cur_gen->next;
    } else {
      gen->next = NULL;
      pool->gc->yng_fst = gen;
      pool->gc->old_lst = gen;
    }
    gen->prev = cur_gen;
    if (pool->gc->old_lst == cur_gen)
      pool->gc->old_lst = gen;
}

static void gc_gmc_pool_deinit(Interp *, struct Small_Object_Pool *);

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
	gc_gmc_insert_gen(interpreter, pool, gen);
    }

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

static void
gc_gmc_pool_deinit(Interp *interpreter, struct Small_Object_Pool *pool)
{
    Gc_gmc *gc;
    Gc_gmc_gen *gen;
    Gc_gmc_hdr_store *store, *st2;
    
    gc = pool->gc;
    for (gen = gc->yng_fst; gen; gen = gen->next)
    {
	if (gen->prev)
	    mem_sys_free(gen->prev);
	mem_sys_free(gen->first);
	for (store = gen->IGP->first; store; st2 = store->next,mem_sys_free(store),
		store = st2);
    }

    for (gen = gc->old_fst; gen; gen = gen->next)
    {
	if (gen->prev)
	    mem_sys_free(gen->prev);
	mem_sys_free(gen->first);
	for (store = gen->IGP->first; store; st2 = store->next,mem_sys_free(store),
		store = st2);
    }
}


static void gc_gmc_deinit(Interp *interpreter)
{
    struct Arenas *arena_base = interpreter->arena_base;
    
    gc_gmc_pool_deinit(interpreter, arena_base->pmc_pool);

}

static void gc_gmc_run(Interp *interpreter, int flags)
{
#ifdef GMC_DEBUG
  fprintf (stderr, "GMC: Trying to run dod_run\n");
#endif /* GMC_DEBUG */
}

void Parrot_gc_gmc_init(Interp *interpreter)
{
  struct Arenas *arena_base;

  arena_base = interpreter->arena_base;

  arena_base->do_dod_run = gc_gmc_run;
  arena_base->de_init_gc_system = gc_gmc_deinit;
  arena_base->init_pool = gc_gmc_pool_init;
}


/******************************* FAKE THINGS ********************************/

static void *
gc_gmc_fake_get_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    return NULL;
}


static void *
gc_gmc_fake_get_free_typed_object(Interp *interpreter,
	struct Small_Object_Pool *pool, INTVAL base_type)
{
    return NULL;
}

static void 
gc_gmc_add_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool, void *to_add)
{
#ifdef GMC_DEBUG
    fprintf (stderr, "GMC: Adding object %p to the free list\n", to_add);
#endif
}

void
gc_gmc_alloc_objects(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
#ifdef GMC_DEBUG
    fprintf (stderr, "GMC: Allocating more objects\n");
#endif
}

static void
gc_gmc_fake_more_objects(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
#ifndef GMC_DEBUG
    fprintf (stderr, "GMC: I want more objects !\n");
#endif
}




/******************************* REAL THINGS ********************************/


static void *
gc_gmc_get_free_object_of_size(Interp *interpreter,
	struct Small_Object_Pool *pool, size_t size, INTVAL aggreg)
{
  void *pmc_body;
  void *pmc;
  Gc_gmc *gc = pool->gc;
  Gc_gmc_gen *gen;

  /* Allocate the pmc_body */
  gen = (aggreg) ? gc->yng_lst : gc->old_lst;

  /* Should we use the next generation ? */
  if (size > gen->remaining)
      gen = gen->next;

  /* Do we need more generations ? */
  if (!gen)
    gc_gmc_more_pmc_bodies (interpreter, pool);

  gc->old_lst = gen;

  pmc_body = gen->fst_free;
  gen->fst_free = (void*)((INTVAL)pmc_body + size);
  gen->remaining -= size;

#ifdef GMC_DEBUG
  fprintf (stderr, "Allocating %s PMC of size %d\n", (aggreg) ? "aggregate" : "non-aggregate", size);
#endif

  /* Allocate the PMC* */

  /* if we don't have any objects */
  if (!pool->free_list)
      (*pool->more_objects) (interpreter, pool);
  
  pmc = pool->free_list;
  fprintf (stderr, "===============\n");
  fprintf (stderr, "PMC found at %p\n", pmc);
  fprintf (stderr, "Next PMC at %p\n", *(void**)pmc);
  fprintf (stderr, "Next Next PMC at %p\n", **(void***)pmc);
  fprintf (stderr, "---------------\n");
  pool->free_list = *(void **)pmc;
  --pool->num_free_objects;
  PMC_body((PMC*)pmc) = Gmc_PMC_hdr_get_BODY(pmc_body);

  Gmc_PMC_hdr_get_PMC((Gc_gmc_hdr*)pmc_body) = pmc;

  fprintf (stderr, "Next PMC at %p\n", pool->free_list);
  fprintf (stderr, "Next Next PMC at %p\n", *(void**)pool->free_list);
  return pmc;
}



/* Here we allocate a PObj, as it is non-typed. */
/* This function should not be called anywhere if possible. */
void *
gc_gmc_get_free_object(Interp *interpreter,
    struct Small_Object_Pool *pool)
{
    size_t size = sizeof(Gc_gmc_hdr) + sizeof(PObj);
    return gc_gmc_get_free_object_of_size(interpreter, pool, size, 0);
}


static void
gc_gmc_real_add_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool, void *to_add)
{
   Gmc_PMC_flag_SET(marking,(PMC*)to_add); 
}


static void *
gc_gmc_get_free_typed_object(Interp *interpreter,
	struct Small_Object_Pool *pool, INTVAL base_type)
{
    Gc_gmc *gc = pool->gc;
    size_t size = sizeof(Gc_gmc_hdr) + gc_gmc_get_PMC_size(interpreter, base_type);
    VTABLE *vtable = Parrot_base_vtables[base_type];
    INTVAL aggreg = vtable->flags & VTABLE_PMC_NEEDS_EXT;
    
    return gc_gmc_get_free_object_of_size (interpreter, pool, size, aggreg);
}


static void
gc_gmc_more_pmc_bodies (Interp *interpreter,
	struct Small_Object_Pool *pool)
{
}


/* Quick and dirty for now, no GC run at all. */
/* XXX: structures must change, because no free is possible with what's here */
static void
gc_gmc_more_objects(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
#define NUM_NEW_OBJ 512
        void *fst = mem_sys_allocate(NUM_NEW_OBJ * pool->object_size);
	int i;
	char *obj;
	for (i = 0, obj = (char*)fst; i < NUM_NEW_OBJ; i++, obj += pool->object_size)
	    *(void**)obj = obj + pool->object_size;
	*(void**)obj = NULL;
	pool->free_list = fst;
	pool->num_free_objects += NUM_NEW_OBJ;
#ifndef GMC_DEBUG
	fprintf(stderr, "Allocating %d more objects of size %d beginning at %p\n", NUM_NEW_OBJ, pool->object_size, fst);
#endif
}


#endif /* PARROT_GC_GMC */
