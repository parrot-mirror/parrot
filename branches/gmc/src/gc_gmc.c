#include <parrot/parrot.h>

#if PARROT_GC_GMC

static void gc_gmc_pool_init(Interp *interpreter, struct Small_Object_Pool *pool) 
{

}

static void gc_gmc_deinit(Interp *interpreter)
{

}

static void gc_gmc_run(Interp *interpreter, int flags)
{

}

void Parrot_gc_gmc_init(Interp *interpreter)
{
  struct Arenas *arena_base;

  arena_base = interpreter->arena_base;

  arena_base->do_dod_run = gc_gmc_run;
  arena_base->de_init_gc_system = gc_gmc_deinit;
  arena_base->init_pool = gc_gmc_pool_init;
}

void gc_pmc_body_pool_init(Interp *interpreter, struct Small_Object_Pool *pool)
{

}

#endif /* PARROT_GC_GMC */
