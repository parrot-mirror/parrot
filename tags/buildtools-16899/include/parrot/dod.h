/* dod.h
 *  Copyright (C) 2001-2003, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     Handles dead object destruction of the various headers
 *  Data Structure and Algorithms:
 *
 *  History:
 *     Initial version by Mike Lambert on 2002.05.27
 *  Notes:
 *  References:
 */

#if !defined(PARROT_DOD_H_GUARD)
#define PARROT_DOD_H_GUARD

#include "parrot/parrot.h"

/* Macros for recursively blocking and unblocking DOD */
#define Parrot_block_DOD(interp) \
        do { \
            (interp)->arena_base->DOD_block_level++; \
            Parrot_shared_DOD_block(interp); \
        } while (0)

#define Parrot_unblock_DOD(interp) \
        if ((interp)->arena_base->DOD_block_level) { \
            (interp)->arena_base->DOD_block_level--; \
            Parrot_shared_DOD_unblock(interp); \
        }

/* Macros for recursively blocking and unblocking GC */
#define Parrot_block_GC(interp) \
        (interp)->arena_base->GC_block_level++

#define Parrot_unblock_GC(interp) \
        if ((interp)->arena_base->GC_block_level) \
            (interp)->arena_base->GC_block_level--

/* Macros for testing if the DOD and GC are blocked */
#define Parrot_is_blocked_DOD(interp) \
        ((interp)->arena_base->DOD_block_level)

#define Parrot_is_blocked_GC(interp) \
        ((interp)->arena_base->GC_block_level)

enum {
    DOD_trace_stack_FLAG = 1 << 0,      /* trace system areads and stack */
    DOD_trace_normal     = 1 << 0,      /* the same */
    DOD_lazy_FLAG        = 1 << 1,      /* timely destruction run */
    DOD_finish_FLAG      = 1 << 2,      /* run async past sweep */
    DOD_no_trace_volatile_roots = 1 << 3  /* trace all but volatile root
                                             set, i.e. registers */
};

PARROT_API void Parrot_do_dod_run(Interp *, UINTVAL flags);
void trace_system_areas(Interp *);
void trace_mem_block(Interp *, size_t, size_t);

void free_unused_pobjects(Interp *interp,
                    struct Small_Object_Pool *pool);

void used_cow(Interp *interp,
        struct Small_Object_Pool *pool, int cleanup);
void clear_cow(Interp *interp,
        struct Small_Object_Pool *pool, int cleanup);

/* mark a PObj live during DOD */

#if PARROT_GC_GMS
#  define pobject_lives(i, o) do { \
    if (!PObj_live_TEST(o) && \
            PObj_to_GMSH(o)->gen->gen_no >= i->gc_generation) \
        parrot_gc_gms_pobject_lives(i, o); \
  } while (0)

PARROT_API void parrot_gc_gms_pobject_lives(Interp *interp, PObj *obj);

#else
PARROT_API void pobject_lives(Interp *interp, PObj *buffer);
#endif

#if ! DISABLE_GC_DEBUG
/* Set when walking the system stack */
extern int CONSERVATIVE_POINTER_CHASING;
#endif

PARROT_API int Parrot_dod_trace_root(Interp *, int trace_stack);
PARROT_API int Parrot_dod_trace_children(Interp *, size_t how_many);
PARROT_API void Parrot_dod_sweep(Interp *, struct Small_Object_Pool *pool);
PARROT_API void Parrot_dod_ms_run_init(Interp *interp);
PARROT_API void Parrot_dod_clear_live_bits(Interp*);

PARROT_API void Parrot_dod_profile_start(Parrot_Interp interp);
PARROT_API void Parrot_dod_profile_end(Parrot_Interp interp, int what);

/* GC subsystem init functions */
PARROT_API void Parrot_gc_ms_init(Interp *interp);
PARROT_API void Parrot_gc_ims_init(Interp *interp);
PARROT_API void Parrot_gc_gms_init(Interp *interp);
/* do_dod_run function for MS */
PARROT_API void Parrot_dod_ms_run(Interp *interp, int flags);

PARROT_API void Parrot_dod_ims_wb(Interp*, PMC *, PMC *);
/*
 * write barrier
 */
#if PARROT_GC_IMS
#  define DOD_WRITE_BARRIER(interp, agg, old, new) \
    do { \
        if (!PMC_IS_NULL(new)   && \
                PObj_live_TEST(agg) && \
                (PObj_get_FLAGS(agg) & PObj_custom_GC_FLAG) && \
                !PObj_live_TEST(new)) { \
            Parrot_dod_ims_wb(interp, agg, new); \
        } \
    } while (0)

#  define DOD_WRITE_BARRIER_KEY(interp, agg, old, old_key, new, new_key) \
          DOD_WRITE_BARRIER(interp, agg, old, new)
#endif

#if PARROT_GC_MS
#  define DOD_WRITE_BARRIER(interp, agg, old, new)
#  define DOD_WRITE_BARRIER_KEY(interp, agg, old, old_key, new, new_key)
#endif

#if PARROT_GC_GMS
#  define DOD_WRITE_BARRIER(interp, agg, old, new) do { \
    UINTVAL gen_agg, gen_new; \
    if (!(new) || (new) == (void*)PMCNULL) \
        break; \
    gen_agg = PObj_to_GMSH(agg)->gen->gen_no; \
    gen_new = PObj_to_GMSH(new)->gen->gen_no; \
    if (gen_agg < gen_new) \
        parrot_gc_gms_wb(interp, agg, old, new); \
} while (0)

#  define DOD_WRITE_BARRIER_KEY(interp, agg, old, old_key, new, new_key) do { \
    UINTVAL gen_agg, gen_new, gen_key; \
    if (!(new) || (new) == (void*)PMCNULL) \
        break; \
    gen_agg = PObj_to_GMSH(agg)->gen->gen_no; \
    gen_new = PObj_to_GMSH(new)->gen->gen_no; \
    gen_key = PObj_to_GMSH(new_key)->gen->gen_no; \
    if (gen_agg < gen_new || gen_agg < gen_key) \
        parrot_gc_gms_wb_key(interp, agg, old, old_key, new, new_key); \
} while (0)

void parrot_gc_gms_wb(Interp *, PMC *agg, void *old, void *new);
void parrot_gc_gms_wb_key(Interp *, PMC *agg,
        void *old, void *old_key, void *new, void *new_key);

#endif

#endif /* PARROT_DOD_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
