/*
 * Copyright (C) 2003-2007, The Perl Foundation
 */

/*
 * exec.h
 *
 * SVN Info
 *    $Id$
 * Overview:
 *    Exec header file.
 * History:
 *      Initial version by Daniel Grunblatt on 2003.6.9
 * Notes:
 * References:
 */

#ifndef PARROT_EXEC_H_GUARD
#define PARROT_EXEC_H_GUARD

#if EXEC_CAPABLE

#  ifdef PARROT_EXEC_OS_OPENBSD
#    ifdef PARROT_OPENBSD_ELF
#      define EXEC_ELF
#    else
#      define EXEC_A_OUT
#    endif
#  endif
#  ifdef PARROT_EXEC_OS_DARWIN
#    define EXEC_MACH_O
#  endif
#  if defined(PARROT_EXEC_OS_FREEBSD) || defined(PARROT_EXEC_OS_NETBSD) || defined(PARROT_EXEC_OS_LINUX)
#    define EXEC_ELF
#  endif
#  ifdef PARROT_EXEC_OS_MSWIN32
#    define EXEC_COFF
#  endif

#  ifdef EXEC_A_OUT
#    define EXEC_CALLDISP jit_info->arena.start - jit_info->native_ptr - 4
#  elif defined(EXEC_COFF)
#    define EXEC_CALLDISP 0
#  else
#    define EXEC_CALLDISP 0xfffffffc
#  endif

/* Symbol types */
#  define STYPE_UND   1     /* Undefined */
#  define STYPE_GCC   2     /* GCC */
#  ifdef I386
#    define STYPE_GDATA 3   /* Global data */
#    define STYPE_FUNC  4   /* Function */
#  else
#    define STYPE_GDATA 0x0F020000   /* Global data */
#    define STYPE_FUNC  0x0F010000  /* Function */
#  endif
#  define STYPE_COM   5   /* Variable */

/* Rellocation types */
#  define RTYPE_DATA  1   /* Data */
#  define RTYPE_COM   2   /* Variable */
#  define RTYPE_FUNC  3   /* Function */
#  define RTYPE_DATA1 4   /* 2nd. rellocation for RISC machines */

typedef struct Parrot_exec_symbol_t {
    int                                                 offset_list;
    int                                                 type;
    int                                                 value;
    const char                                         *symbol;
} Parrot_exec_symbol_t;

typedef struct Parrot_exec_rellocation_t {
    int                                                 offset;
    short                                               symbol_number;
    int                                                 type;
} Parrot_exec_rellocation_t;

typedef struct Parrot_exec_section_t {
    char                                               *code;
    int                                                 size;
} Parrot_exec_section_t;

typedef struct Parrot_exec_objfile_t {
    Parrot_exec_section_t                               text;
    Parrot_exec_section_t                               data;
    Parrot_exec_section_t                               bss;
    int                                                *data_size;
    int                                                 data_count;
    Parrot_exec_rellocation_t                          *text_rellocation_table;
    int                                                 text_rellocation_count;
    Parrot_exec_rellocation_t                          *data_rellocation_table;
    int                                                 data_rellocation_count;
    Parrot_exec_symbol_t                               *symbol_table;
    int                                                 symbol_count;
    int                                                 symbol_list_size;
    int                                                 bytecode_header_size;
} Parrot_exec_objfile_t;

/* HEADERIZER BEGIN: src/exec.c */

PARROT_API
void Parrot_exec_add_text_rellocation(
    NOTNULL(Parrot_exec_objfile_t *obj),
    NOTNULL(char *nptr),
    int type,
    NOTNULL(const char *symbol),
    int disp)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(4);

PARROT_API
void Parrot_exec_add_text_rellocation_func(
    NOTNULL(Parrot_exec_objfile_t *obj),
    NOTNULL(char *nptr),
    NOTNULL(const char *func_name))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_API
PARROT_CAN_RETURN_NULL
int * Parrot_exec_add_text_rellocation_reg(
    NOTNULL(Parrot_exec_objfile_t *obj),
    NOTNULL(char *nptr),
    NOTNULL(const char *var),
    int offset,
    int disp)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

void Parrot_exec(PARROT_INTERP,
    NOTNULL(opcode_t *pc),
    NOTNULL(opcode_t *code_start),
    NOTNULL(opcode_t *code_end))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        __attribute__nonnull__(4);

int Parrot_exec_add_symbol(
    NOTNULL(Parrot_exec_objfile_t *obj),
    NOTNULL(const char *symbol),
    int stype)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* HEADERIZER END: src/exec.c */

#endif /* EXEC_CAPABLE */

#endif /* PARROT_EXEC_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
