/*
 * $Id$
 * Copyright (C) 2002-2007, The Perl Foundation.
 */

#ifndef PARROT_WARNINGS_H_GUARD
#define PARROT_WARNINGS_H_GUARD

/* These should be visible to embedders. */

/* Warning flags */
/* &gen_from_enum(warnings.pasm)  */
typedef enum {
    PARROT_WARNINGS_ALL_FLAG        = 0xFF,
    PARROT_WARNINGS_NONE_FLAG       = 0x00,
    PARROT_WARNINGS_UNDEF_FLAG      = 0x01,
    PARROT_WARNINGS_IO_FLAG         = 0x02,
    PARROT_WARNINGS_PLATFORM_FLAG   = 0x04,
    PARROT_WARNINGS_DYNEXT_FLAG     = 0x08,
    PARROT_WARNINGS_DEPRECATED_FLAG = 0x10
} Warnings_classes;

/* &end_gen */

/* error flags */
/* &gen_from_enum(errors.pasm)  */
typedef enum {
    PARROT_ERRORS_NONE_FLAG         = 0x00,
    PARROT_ERRORS_GLOBALS_FLAG      = 0x01,
    PARROT_ERRORS_OVERFLOW_FLAG     = 0x02,
    PARROT_ERRORS_PARAM_COUNT_FLAG  = 0x04,
    PARROT_ERRORS_RESULT_COUNT_FLAG = 0x08,
    PARROT_ERRORS_ALL_FLAG          = 0xFF
} Errors_classes;

/* &end_gen */

#define PARROT_WARNINGS_on(interp, flag) do { \
    CONTEXT((interp))->warns |= (flag); } while (0)
#define PARROT_WARNINGS_off(interp, flag) do { \
    CONTEXT((interp))->warns &= ~(flag); } while (0)
#define PARROT_WARNINGS_test(interp, flag)  \
    (CONTEXT((interp))->warns & (flag))

#define PARROT_ERRORS_on(interp, flag) do { \
    CONTEXT((interp))->errors |= (flag); } while (0)
#define PARROT_ERRORS_off(interp, flag) do { \
    CONTEXT((interp))->errors &= ~(flag); } while (0)
#define PARROT_ERRORS_test(interp, flag)  \
    (CONTEXT((interp))->errors & (flag))

#if defined(PARROT_IN_CORE)

#include "parrot/parrot.h"

/* HEADERIZER BEGIN: src/warnings.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
INTVAL Parrot_warn(PARROT_INTERP,
    INTVAL warnclass,
    ARGIN(const char *message),
    ...)
        __attribute__nonnull__(1)
        __attribute__nonnull__(3);

PARROT_EXPORT
void print_pbc_location(PARROT_INTERP)
        __attribute__nonnull__(1);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/warnings.c */

#endif /* PARROT_IN_CORE */
#endif /* PARROT_WARNINGS_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
