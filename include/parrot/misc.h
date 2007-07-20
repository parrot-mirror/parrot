/* misc.h
 *  Copyright (C) 2001-2007, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     Miscellaneous functions, mainly the Parrot_sprintf family
 *  Data Structure and Algorithms:
 *     Uses a generalized formatting algorithm (spf_render.c) with
 *     a specialized vtable (spf_vtable.c) to handle argument extraction.
 *  History:
 *     This file used to be a simple one, with just a few function prototypes
 *     in it.  When misc.c was split in three, this file took on the job of
 *     being the internal header as well.
 *     To expose the guts of Parrot_sprintf, define IN_SPF_SYSTEM before
 *     including this file.
 *  Notes:
 *  References: misc.c, spf_vtable.c, spf_render.c
 */

#ifndef PARROT_MISC_H_GUARD
#define PARROT_MISC_H_GUARD

#include "parrot/parrot.h"

/*
 * utils.c
 */
typedef int (*reg_move_func)(Interp*, unsigned char d, unsigned char s, void *);

/* HEADERIZER BEGIN: src/utils.c */

PARROT_API
INTVAL Parrot_byte_index( SHIM_INTERP,
    NOTNULL(const STRING *base),
    NOTNULL(const STRING *search),
    UINTVAL start_offset )
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
PARROT_WARN_UNUSED_RESULT
INTVAL Parrot_byte_rindex( SHIM_INTERP,
    NOTNULL(const STRING *base),
    NOTNULL(const STRING *search),
    UINTVAL start_offset )
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
void Parrot_destroy_cpa( NOTNULL(char **array) )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_destroy_la( NULLOK(long *array) );

PARROT_API
FLOATVAL Parrot_float_rand( INTVAL how_random );

PARROT_API
INTVAL Parrot_int_rand( INTVAL how_random );

PARROT_API
PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
void * Parrot_make_cpa( PARROT_INTERP, NOTNULL(PMC *array) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
void * Parrot_make_la( PARROT_INTERP, NOTNULL(PMC *array) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
INTVAL Parrot_range_rand( INTVAL from, INTVAL to, INTVAL how_random );

PARROT_API
void Parrot_register_move( PARROT_INTERP,
    int n_regs,
    NOTNULL(unsigned char *dest_regs),
    NOTNULL(unsigned char *src_regs),
    unsigned char temp_reg,
    reg_move_func mov,
    reg_move_func mov_alt,
    NOTNULL(void *info) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4)
        __attribute__nonnull__(8);

PARROT_API
void Parrot_srand( INTVAL seed );

PARROT_API
INTVAL Parrot_uint_rand( INTVAL how_random );

PARROT_API
PARROT_CANNOT_RETURN_NULL
PMC* tm_to_array( PARROT_INTERP, NOTNULL(const struct tm *tm) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CONST_FUNCTION
FLOATVAL floatval_mod( FLOATVAL n2, FLOATVAL n3 );

PARROT_CONST_FUNCTION
INTVAL intval_mod( INTVAL i2, INTVAL i3 );

/* HEADERIZER END: src/utils.c */


/*
 * IMCC API
 * XXX These should go into another file, not seen by libparrot
 */
void *IMCC_compile_file_s(Parrot_Interp interp, const char *s,
        STRING **error_message);
void * IMCC_compile_file(Parrot_Interp interp, const char *s);
PMC * IMCC_compile_pir_s(Parrot_Interp interp, const char *s,
        STRING **error_message);
PMC * IMCC_compile_pasm_s(Parrot_Interp interp, const char *s,
        STRING **error_message);


/* HEADERIZER BEGIN: src/misc.c */

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING * Parrot_psprintf( PARROT_INTERP,
    NOTNULL(STRING *pat),
    NOTNULL(PMC *ary) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
void Parrot_snprintf( PARROT_INTERP,
    NOTNULL(char *targ),
    size_t len,
    NOTNULL(const char *pat),
    ... )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(4);

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING * Parrot_sprintf_c( PARROT_INTERP, NOTNULL(const char *pat), ... )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING * Parrot_sprintf_s( PARROT_INTERP, NOTNULL(STRING *pat), ... )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
void Parrot_vsnprintf( PARROT_INTERP,
    NOTNULL(char *targ),
    size_t len,
    NOTNULL(const char *pat),
    va_list args )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(4);

PARROT_API
PARROT_CANNOT_RETURN_NULL
STRING * Parrot_vsprintf_c( PARROT_INTERP,
    NOTNULL(const char *pat),
    va_list args )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING * Parrot_vsprintf_s( PARROT_INTERP,
    NOTNULL(STRING *pat),
    va_list args )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* HEADERIZER END: src/misc.c */


#ifdef IN_SPF_SYSTEM

    /* The size of all our buffers (and the maximum width of a float
     * field).
     */
#  define PARROT_SPRINTF_BUFFER_SIZE 4096

    /* The maximum floating-point precision--hopefully this and the
     * width cap will help head off buffer overruns.
     */
#  define PARROT_SPRINTF_MAX_PREC 3 * PARROT_SPRINTF_BUFFER_SIZE / 4

#  define cstr2pstr(cstr) string_make(interp, cstr, strlen(cstr), "ascii", 0)
#  define char2pstr(ch)   string_make(interp, &ch , 1, "ascii", 0)

    /* SPRINTF DATA STRUCTURE AND FLAGS */

    typedef enum {
        SIZE_REG = 0,
        SIZE_SHORT,
        SIZE_LONG,
        SIZE_HUGE,
        SIZE_XVAL,
        SIZE_OPCODE,
        SIZE_PMC,
        SIZE_PSTR
    } spf_type_t;

    /* SPRINTF ARGUMENT OBJECT */

    typedef struct sprintf_obj SPRINTF_OBJ;

    typedef STRING *(*sprintf_getchar_t) (Interp *, INTVAL,
                                          SPRINTF_OBJ *);
    typedef HUGEINTVAL(*sprintf_getint_t) (Interp *, INTVAL,
                                           SPRINTF_OBJ *);
    typedef UHUGEINTVAL(*sprintf_getuint_t) (Interp *, INTVAL,
                                             SPRINTF_OBJ *);
    typedef HUGEFLOATVAL(*sprintf_getfloat_t) (Interp *, INTVAL,
                                               SPRINTF_OBJ *);
    typedef STRING *(*sprintf_getstring_t) (Interp *, INTVAL,
                                            SPRINTF_OBJ *);
    typedef void *(*sprintf_getptr_t) (Interp *, INTVAL,
                                       SPRINTF_OBJ *);

    struct sprintf_obj {
        void *data;
        INTVAL index;

        sprintf_getchar_t getchr;
        sprintf_getint_t getint;
        sprintf_getuint_t getuint;
        sprintf_getfloat_t getfloat;
        sprintf_getstring_t getstring;
        sprintf_getptr_t getptr;
    };

    extern SPRINTF_OBJ pmc_core;
    extern SPRINTF_OBJ va_core;

/* HEADERIZER BEGIN: src/spf_render.c */

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
STRING * Parrot_sprintf_format( PARROT_INTERP,
    NOTNULL(STRING *pat),
    NOTNULL(SPRINTF_OBJ *obj) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

/* HEADERIZER END: src/spf_render.c */

#endif /* IN_SPF_SYSTEM */


/*
 * generated src/revision.c
 */
PARROT_API int Parrot_config_revision(void);

#endif /* PARROT_MISC_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
