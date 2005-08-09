#include <parrot/parrot.h>

#if PARROT_GC_GMC


static void gc_gmc_add_free_object(Interp*, struct Small_Object_Pool*, void*);
static void *gc_gmc_get_free_object(Interp*, struct Small_Object_Pool*);
static void gc_gmc_alloc_objects(Interp*, struct Small_Object_Pool*);
static void gc_gmc_more_objects(Interp*, struct Small_Object_Pool*);


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
    gen->last = NULL;

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

    cur_gen = pool->gc->last;
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
      pool->gc->first = gen;
      pool->gc->last = gen;
    }
    gen->prev = cur_gen;
    if (pool->gc->last == cur_gen)
      pool->gc->last = gen;
}


static void 
gc_gmc_pool_init(Interp *interpreter, struct Small_Object_Pool *pool) 
{
    struct Arenas *arena_base;
    Gc_gmc *gc;
    Gc_gmc_gen *gen;
    int i;
    
    pool->add_free_object = gc_gmc_add_free_object;
    pool->get_free_object = gc_gmc_get_free_object;
    pool->alloc_objects   = gc_gmc_alloc_objects;
    pool->more_objects    = gc_gmc_more_objects;

    gc = mem_sys_allocate(sizeof(Gc_gmc));
    
    gc->nb_gen = GMC_GEN_INIT_NUMBER;
    gc->nb_empty_gen = GMC_GEN_INIT_NUMBER;
    gc->alloc_obj = 0;
    gc->first = NULL;
    gc->fst_free = NULL;
    gc->lst_free = NULL;
    gc->last = NULL;
    gc->timely = gc_gmc_gen_init(interpreter);
    gc->constant = gc_gmc_gen_init(interpreter);
    pool->gc = gc;
    
    for (i = 0; i < GMC_GEN_INIT_NUMBER; i++)
    {
	gen = gc_gmc_gen_init(interpreter);
	gc_gmc_insert_gen(interpreter, pool, gen);
    }
}


void gc_gmc_deinit(Interp *interpreter)
{

}

void gc_gmc_run(Interp *interpreter, int flags)
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

void *
gc_gmc_get_free_object(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
    return NULL;
}

void 
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

void
gc_gmc_more_objects(Interp *interpreter,
	struct Small_Object_Pool *pool)
{
#ifdef GMC_DEBUG
    fprintf (stderr, "GMC: I want more objects !\n");
#endif
}




/******************************* REAL THINGS ********************************/



/* The real thing, but not plugged yet */
void *
gc_gmc_real_get_free_object(Interp *interpreter,
    struct Small_Object_Pool *pool)
{
  void *ptr;
  Gc_gmc *gc = pool->gc;

  /* Is this the real test we want ? */
  if (gc->fst_free == gc->lst_free)
    (*pool->more_objects) (interpreter, pool);

  /* TODO: find a way to know if we want an aggregate allocation or not.
   * For now, let's say that everything is non-aggregate. */
  
  return ptr;
}


#endif /* PARROT_GC_GMC */
