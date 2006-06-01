/* atomic.h
 *  Copyright (C) 2006, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This header implements portable atomic operations. 
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */


#if !defined(PARROT_ATOMIC_H_GAURD)
#define PARROT_ATOMIC_H_GAURD

#include "parrot/has_header.h"
#include "parrot/thread.h"

#define PARROT_HAS_NATIVE_ATOMIC 1      /* we'll redefine later if need be */

#if (PARROT_HAS_THREADS)
#  if defined(PARROT_HAS_I386_GCC_CMPXCHG)
#    include "parrot/atomic/gcc_x86.h"
#  elif defined(PARROT_HAS_PPC_GCC_CMPSET)
#    include "parrot/atomic/gcc_pcc.h"
#  else
#    undef PARROT_HAS_NATIVE_ATOMIC
#    define PARROT_HAS_NATIVE_ATOMIC 0
#    include "parrot/atomic/fallback.h"
#  endif
#else
typedef struct {
    void *val;
} Parrot_atomic_pointer;

typedef struct {
    INTVAL val;
} Parrot_atomic_int;

#   define ATOMIC_PTR_INIT(a)
#   define ATOMIC_PTR_GET(result,a) result = (a).val
#   define ATOMIC_PTR_SET(a,b) (a).val = b

/* a is the Parrot_atomic.
 * expect is the value we expect the atomic to be holding,
 * update is the new value for the atomic
 * result will be 1 if the value was as expected (and thus
 * the update was performed) and 0 otherwise
 */
#   define ATOMIC_PTR_COMPARE_AND_SET(result, a, expect, update) \
        do { \
            void * orig; \
            ATOMIC_PTR_GET(a, orig); \
            if (expect == orig) { \
                ATOMIC_SET(a, update); \
                result = 1; \
            } else { \
                result = 0; \
            } \
        } while (0)
#   define ATOMIC_PTR_DESTROY(a)
#   define ATOMIC_INT_INIT(a)
#   define ATOMIC_INT_DESTROY(a)
#   define ATOMIC_INT_GET(result, a) result = (a).val
#   define ATOMIC_INT_COMPARE_AND_SET(result, a, expect, update) \
        do { \
            INTVAL orig; \
            ATOMIC_PTR_GET(a, orig); \
            if (expect == orig) { \
                ATOMIC_SET(a, update); \
                result = 1; \
            } else { \
                result = 0; \
            } \
        } while (0)
#   define ATOMIC_INT_INC(result, a) result = ++(a).val
#   define ATOMIC_INT_DEC(result, a) result = --(a).val


#endif /* PARROT_HAS_THREADS */

#endif /* PARROT_ATOMIC_H_GAURD */
/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
