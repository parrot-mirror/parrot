/* atomic/sparc.h
 *  Copyright (C) 2006, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This header provides an implementation of atomic
 *     operations on Sparc V8plus and better platforms.
 *     It relies on an assembler file.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(ATOMIC_SPARC_H_GAURD)

extern int parrot_sparc_cas32(Parrot_UInt4 *value, Parrot_UInt4 old, Parrot_UInt4 new);
/* NB cas64 _will_ be broken when PTR_SIZE == 4 */
#if PTR_SIZE == 8
extern int parrot_sparc_cas64(Parrot_UInt8 *value, Parrot_UInt8 old, Parrot_UInt8 new);
#endif

typedef struct {
    volatile void *val;
} Parrot_atomic_pointer;

#define ATOMIC_PTR_GET(result, a) result = (a).val

#define ATOMIC_PTR_SET(a, b) (a).val = b

#if PTR_SIZE == 8
#  define ATOMIC_PTR_CAS(result, a, expect, update) \
    do { \
        result = parrot_sparc_cas64((Parrot_UInt8 *) &(a).val, \
            (Parrot_UInt8) expect, (Parrot_UInt8) update); \
    } while (0)
#else
#  define ATOMIC_PTR_CAS(result, a, expect, update) \
    do { \
        result = parrot_sparc_cas32((Parrot_UInt4 *) &(a).val, \
            (Parrot_UInt4) expect, (Parrot_UInt4) update); \
    } while (0)
#endif

#define ATOMIC_PTR_INIT(a)

#define ATOMIC_PTR_DESTROY(a)

typedef struct {
    volatile Parrot_Int4 val;
} Parrot_atomic_int;

#define ATOMIC_INT_INIT(a)

#define ATOMIC_INT_DESTROY(a)

#define ATOMIC_INT_GET(result, a) result = (a).val

#define ATOMIC_INT_SET(a, b) (a).val = b

#define ATOMIC_INT_CAS(result, a, expect, update) \
    do { \
        result = parrot_sparc_cas32((Parrot_UInt4*) &(a).val, \
            (Parrot_UInt4) (expect), (Parrot_UInt4) (update)); \
    } while (0)

#define parrot_sparc_atomic_int_add(result, a, what) \
    do { \
        int successp; \
        Parrot_Int4 old; \
        do { \
            old = (a).val; \
            ATOMIC_INT_CAS(successp, a, old, old + what); \
        } while (!successp); \
        result = old + what; \
    } while (0)


#define ATOMIC_INT_DEC(result, a) parrot_sparc_atomic_int_add(result, a, -1)
#define ATOMIC_INT_INC(result, a) parrot_sparc_atomic_int_add(result, a,  1)

#endif
/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
