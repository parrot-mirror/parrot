#include <parrot/parrot.h>

#if PARROT_GC_GMC

/*static void gc_gmc_pool_init(Interp *interpreter, struct Small_Object_Pool *pool) 
{

}*/

void gc_gmc_deinit(Interp *interpreter)
{

}

void gc_gmc_run(Interp *interpreter, int flags)
{
#ifdef GMC_DEBUG
  fprintf (stderr, "Trying to run dod_run\n");
#endif /* GMC_DEBUG */
}

/*void Parrot_gc_gmc_init(Interp *interpreter)
{
  struct Arenas *arena_base;

  arena_base = interpreter->arena_base;

  arena_base->do_dod_run = gc_gmc_run;
  arena_base->de_init_gc_system = gc_gmc_deinit;
  arena_base->init_pool = gc_gmc_pool_init;
}*/


/* Small adaptation of gc_ms_free_object. Does not yet use GMC at all. */

void *
gc_gmc_get_free_object(Interp *interpreter,
    struct Small_Object_Pool *pool)
{
    void *ptr;

    /* if we don't have any objects */
    if (!pool->free_list)
        (*pool->more_objects) (interpreter, pool);
    ptr = pool->free_list;
    pool->free_list = *(void **)ptr;
    --pool->num_free_objects;
#if ! DISABLE_GC_DEBUG
    if (GC_DEBUG(interpreter))
        PObj_version((Buffer*)ptr) = interpreter->arena_base->dod_runs;
#endif
    return ptr;
}


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
