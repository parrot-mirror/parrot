/* embed.h
 *  Copyright (C) 2001-2003, The Perl Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     This is the Parrot embedding system--the only part of Parrot that
 *     the outside world should see.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 *      embed.c, docs/embed.pod.
 */

#ifndef PARROT_EMBED_H_GUARD
#define PARROT_EMBED_H_GUARD

#include "parrot/compiler.h"    /* compiler capabilities */
#include "parrot/config.h"      /* PARROT_VERSION, PARROT_JIT_CAPABLE... */
#include "parrot/interpreter.h" /* give us the interpreter flags */
#include "parrot/warnings.h"    /* give us the warnings flags    */

typedef int Parrot_warnclass;

/* HEADERIZER BEGIN: src/embed.c */

PARROT_API
void Parrot_clear_debug( PARROT_INTERP, UINTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_clear_flag( PARROT_INTERP, INTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_clear_trace( PARROT_INTERP, UINTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
opcode_t * Parrot_debug( NOTNULL(Parrot_Interp debugger), opcode_t * pc )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_disassemble( PARROT_INTERP )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_init( PARROT_INTERP )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_init_stacktop( PARROT_INTERP, void *stack_top )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_loadbc( PARROT_INTERP, NOTNULL(PackFile *pf) )
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_API
Parrot_Interp Parrot_new( Parrot_Interp parent );

PARROT_API
PackFile * Parrot_readbc( PARROT_INTERP, NULLOK(const char *fullname) )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_run_native( PARROT_INTERP, native_func_t func )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_runcode( PARROT_INTERP, int argc, char *argv[] )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_set_debug( PARROT_INTERP, UINTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_set_flag( PARROT_INTERP, INTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_set_run_core( PARROT_INTERP, Parrot_Run_core_t core )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_set_trace( PARROT_INTERP, UINTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
void Parrot_setwarnings( PARROT_INTERP, Parrot_warnclass wc )
        __attribute__nonnull__(1);

PARROT_API
UINTVAL Parrot_test_debug( PARROT_INTERP, UINTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
Parrot_Int Parrot_test_flag( PARROT_INTERP, INTVAL flag )
        __attribute__nonnull__(1);

PARROT_API
UINTVAL Parrot_test_trace( PARROT_INTERP, UINTVAL flag )
        __attribute__nonnull__(1);

/* HEADERIZER END: src/embed.c */

PARROT_API Parrot_Interp Parrot_new(Parrot_Interp parent);

/* XXX Parrot_init() should be removed, no longer required for embedders */
PARROT_API void Parrot_init(Parrot_Interp);
PARROT_API void Parrot_init_stacktop(Parrot_Interp, void *);

PARROT_API void Parrot_set_flag(Parrot_Interp, Parrot_Int);
PARROT_API void Parrot_clear_flag(Parrot_Interp, Parrot_Int);
PARROT_API Parrot_Int Parrot_test_flag(Parrot_Interp, Parrot_Int);

PARROT_API void Parrot_set_trace(Parrot_Interp, Parrot_UInt);
PARROT_API void Parrot_clear_trace(Parrot_Interp, Parrot_UInt);
PARROT_API Parrot_UInt Parrot_test_trace(Parrot_Interp, Parrot_UInt);

PARROT_API void Parrot_set_debug(Parrot_Interp, Parrot_UInt);
PARROT_API void Parrot_clear_debug(Parrot_Interp, Parrot_UInt);
PARROT_API Parrot_UInt Parrot_test_debug(Parrot_Interp, Parrot_UInt);

PARROT_API void Parrot_set_run_core(Parrot_Interp, Parrot_Run_core_t core);

PARROT_API void Parrot_setwarnings(Parrot_Interp, Parrot_warnclass);

PARROT_API Parrot_PackFile Parrot_readbc(Parrot_Interp, const char *);

PARROT_API void Parrot_loadbc(Parrot_Interp, Parrot_PackFile);

PARROT_API void Parrot_setup_argv(Parrot_Interp, int argc, char ** argv);

PARROT_API void Parrot_setup_opt(Parrot_Interp, int n, char *argv);

PARROT_API void Parrot_runcode(Parrot_Interp, int argc, char *argv[]);

PARROT_API void Parrot_destroy(Parrot_Interp);

PARROT_API Parrot_Opcode * Parrot_debug(Parrot_Interp, Parrot_Opcode *pc);

PARROT_API void Parrot_disassemble(Parrot_Interp);

PARROT_API void Parrot_exit(Parrot_Interp, int status)
                __attribute__noreturn__;

PARROT_API void Parrot_run_native(Parrot_Interp interp, native_func_t func);

/* Parrot_set_config_hash exists in *_config.o (e.g install_config.o),
   so if you make this call then you will need to link with it in
   addition to libparrot */
void Parrot_set_config_hash(void);

int Parrot_revision(void);

#endif /* PARROT_EMBED_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
