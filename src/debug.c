/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id$

=head1 NAME

src/debug.c - Parrot debugging

=head1 DESCRIPTION

This file implements Parrot debugging and is used by C<parrot_debugger>,
the Parrot debugger, and the C<debug> ops.

=head2 Functions

=over 4

=cut

*/

#include <stdio.h>
#include <stdlib.h>
#include "parrot/parrot.h"
#include "parrot/extend.h"
#include "parrot/embed.h"
#include "interp_guts.h"
#include "parrot/oplib.h"
#include "trace.h"
#include "parrot/debugger.h"
#include "parrot/oplib/ops.h"
#include "debug.str"

/* Hand switched debugger tracing
 * Set to 1 to enable tracing to stderr
 * Set to 0 to disable
 */
#define TRACE_DEBUGGER 0

#if TRACE_DEBUGGER
#  define TRACEDEB_MSG(msg) fprintf(stderr, "%s\n", (msg))
#else
#  define TRACEDEB_MSG(msg)
#endif

/* Length of command line buffers */
#define DEBUG_CMD_BUFFER_LENGTH 255

/* Not sure how we want to handle this sort of cross-project header */
PARROT_API
void
IMCC_warning(PARROT_INTERP, ARGIN(const char *fmt), ...);

/*
 * These constants correspond to the debugger commands.
 * To map command strings to their numeric values,
 * use the algorithm from parse_command().
 */

enum DebugCmd {
    debug_cmd_b           = 25245,
    debug_cmd_c           = 25500,
    debug_cmd_d           = 25755,
    debug_cmd_e           = 26010,
    debug_cmd_f           = 26265,
    debug_cmd_h           = 26775,
    debug_cmd_i           = 27030,
    debug_cmd_l           = 27795,
    debug_cmd_n           = 28305,
    debug_cmd_p           = 28815,
    debug_cmd_q           = 29070,
    debug_cmd_r           = 29325,
    debug_cmd_s           = 29580,
    debug_cmd_t           = 29835,
    debug_cmd_w           = 30600,
    debug_cmd_int         = 175185,
    debug_cmd_run         = 176460,
    debug_cmd_num         = 174675,
    debug_cmd_str         = 179265,
    debug_cmd_pmc         = 163455,
    debug_cmd_eval        = 277950,
    debug_cmd_help        = 282540,
    debug_cmd_info        = 281775,
    debug_cmd_list        = 295035,
    debug_cmd_load        = 268005,
    debug_cmd_next        = 297330,
    debug_cmd_quit        = 294780,
    debug_cmd_break       = 409785,
    debug_cmd_print       = 441150,
    debug_cmd_stack       = 414120,
    debug_cmd_trace       = 405705,
    debug_cmd_watch       = 416160,
    debug_cmd_enable      = 571455,
    debug_cmd_delete      = 588285,
    debug_cmd_script_file = 617610,
    debug_cmd_disable     = 772140,
    debug_cmd_continue    = 1053405,
    debug_cmd_disassemble = 1903830,
    debug_cmd_gcdebug     = 779790,
    debug_cmd_echo        = 276675
};

/* HEADERIZER HFILE: include/parrot/debugger.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

static void chop_newline(ARGMOD(char * buf))
        __attribute__nonnull__(1)
        FUNC_MODIFIES(* buf);

static void close_script_file(PARROT_INTERP)
        __attribute__nonnull__(1);

static void debugger_cmdline(PARROT_INTERP)
        __attribute__nonnull__(1);

static void dump_string(PARROT_INTERP, ARGIN_NULLOK(const STRING *s))
        __attribute__nonnull__(1);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static const char* GDB_P(PARROT_INTERP, ARGIN(const char *s))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static const char* GDB_print_reg(PARROT_INTERP, int t, int n)
        __attribute__nonnull__(1);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * nextarg(ARGIN_NULLOK(const char *command));

PARROT_CAN_RETURN_NULL
PARROT_IGNORABLE_RESULT
static const char * parse_command(
    ARGIN(const char *command),
    ARGOUT(unsigned long *cmdP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*cmdP);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * parse_int(ARGIN(const char *str), ARGOUT(int *intP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*intP);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char* parse_key(PARROT_INTERP,
    ARGIN(const char *str),
    ARGOUT(PMC **keyP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*keyP);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * parse_string(PARROT_INTERP,
    ARGIN(const char *str),
    ARGOUT(STRING **strP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*strP);

PARROT_CANNOT_RETURN_NULL
static const char * skip_command(ARGIN(const char *str))
        __attribute__nonnull__(1);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*
 *  Command functions and help dispatch
 */

typedef void (* debugger_func_t)(ARGIN(PDB_t * pdb), ARGIN(const char * cmd));


static void dbg_break(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_break");

    PDB_set_break(pdb->debugee, cmd);
}

static void dbg_continue(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_continue");

    PDB_continue(pdb->debugee, cmd);
}

static void dbg_delete(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_delete");

    PDB_delete_breakpoint(pdb->debugee, cmd);
}

static void dbg_disable(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_disable");

    PDB_disable_breakpoint(pdb->debugee, cmd);
}

static void dbg_disassemble(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_disassemble");

    PDB_disassemble(pdb->debugee, cmd);
}

static void dbg_echo(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_echo");

    if (pdb->state & PDB_ECHO) {
        TRACEDEB_MSG("Disabling echo");
        pdb->state &= ~PDB_ECHO;
    }
    else {
        TRACEDEB_MSG("Enabling echo");
        pdb->state |= PDB_ECHO;
    }
}

static void dbg_enable(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    PDB_enable_breakpoint(pdb->debugee, cmd);
}

static void dbg_eval(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    PDB_eval(pdb->debugee, cmd);
}

static void dbg_gcdebug(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_gcdebug");

    if (pdb->state & PDB_GCDEBUG) {
        TRACEDEB_MSG("Disabling gcdebug mode");
        pdb->state &= ~PDB_GCDEBUG;
    }
    else {
        TRACEDEB_MSG("Enabling gcdebug mode");
        pdb->state |= PDB_GCDEBUG;
    }
}

static void dbg_help(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_help");

    PDB_help(pdb->debugee, cmd);
}

static void dbg_info(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_info");

    PDB_info(pdb->debugger);
}

static void dbg_list(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_list");

    PDB_list(pdb->debugee, cmd);
}

static void dbg_load(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_load");

    PDB_load_source(pdb->debugee, cmd);
}

static void dbg_next(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_next");

    PDB_next(pdb->debugee, cmd);
}

static void dbg_print(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_print");

    PDB_print(pdb->debugee, cmd);
}

static void dbg_quit(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_quit");

    pdb->state |= PDB_EXIT;
    pdb->state &= ~PDB_STOPPED;
}

static void dbg_run(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_run");

    PDB_init(pdb->debugee, cmd);
    PDB_continue(pdb->debugee, NULL);
}

static void dbg_script(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_script");

    PDB_script_file(pdb->debugee, cmd);
}

static void dbg_stack(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_stack");

    PDB_backtrace(pdb->debugee);
}

static void dbg_trace(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_trace");

    PDB_trace(pdb->debugee, cmd);
}

static void dbg_watch(ARGIN(PDB_t * pdb), ARGIN(const char * cmd)) /* HEADERIZER SKIP */
{
    TRACEDEB_MSG("dbg_watch");

    PDB_watchpoint(pdb->debugee, cmd);
}

typedef struct DebuggerCmd_t {
    debugger_func_t func;
    const char * const help;
} DebuggerCmd;

static const DebuggerCmd
    cmd_break = {
        & dbg_break,
"Set a breakpoint at a given line number (which must be specified).\n\n\
Optionally, specify a condition, in which case the breakpoint will only\n\
activate if the condition is met. Conditions take the form:\n\n\
           if [REGISTER] [COMPARISON] [REGISTER or CONSTANT]\n\n\
\
For example:\n\n\
           break 10 if I4 > I3\n\n\
           break 45 if S1 == \"foo\"\n\n\
The command returns a number which is the breakpoint identifier."
    },
    cmd_continue = {
        & dbg_continue,
"Continue the program execution.\n\n\
Without arguments, the program runs until a breakpoint is found\n\
(or until the program terminates for some other reason).\n\n\
If a number is specified, then skip that many breakpoints.\n\n\
If the program has terminated, then \"continue\" will do nothing;\n\
use \"run\" to re-run the program."
    },
    cmd_delete = {
        & dbg_delete,
"Delete a breakpoint.\n\n\
The breakpoint to delete must be specified by its breakpoint number.\n\
Deleted breakpoints are gone completely. If instead you want to\n\
temporarily disable a breakpoint, use \"disable\"."
    },
    cmd_disable = {
        & dbg_disable,
"Disable a breakpoint.\n\n\
The breakpoint to disable must be specified by its breakpoint number.\n\
Disabled breakpoints are not forgotten, but have no effect until re-enabled\n\
with the \"enable\" command."
    },
    cmd_disassemble = {
        & dbg_disassemble,
"Disassemble code"
    },
    cmd_echo = {
        & dbg_echo,
"Toggle echo mode.\n\n\
In echo mode the script commands are written to stderr before executing."
    },
    cmd_enable = {
        & dbg_enable,
"Re-enable a disabled breakpoint."
    },
    cmd_eval = {
        & dbg_eval,
"No documentation yet"
    },
    cmd_gcdebug = {
        & dbg_gcdebug,
"Toggle gcdebug mode.\n\n\
In gcdebug mode a garbage collection cycle is run before each opcocde,\n\
same as using the gcdebug core."
    },
    cmd_help = {
        & dbg_help,
"Print a list of available commands."
    },
    cmd_info = {
        & dbg_info,
"Print information about the current interpreter"
    },
    cmd_list = {
        & dbg_list,
"List the source code.\n\n\
Optionally specify the line number to begin the listing from and the number\n\
of lines to display."
    },
    cmd_load = {
        & dbg_load,
"Load a source code file."
    },
    cmd_next = {
        & dbg_next,
"Execute a specified number of instructions.\n\n\
If a number is specified with the command (e.g. \"next 5\"), then\n\
execute that number of instructions, unless the program reaches a\n\
breakpoint, or stops for some other reason.\n\n\
If no number is specified, it defaults to 1."
    },
    cmd_print = {
        & dbg_print,
"Print register: e.g. \"p i2\"\n\
Note that the register type is case-insensitive. If no digits appear\n\
after the register type, all registers of that type are printed."
    },
    cmd_quit = {
        & dbg_quit,
"Exit the debugger"
    },
    cmd_run = {
        & dbg_run,
"Run (or restart) the program being debugged.\n\n\
Arguments specified after \"run\" are passed as command line arguments to\n\
the program.\n"
    },
    cmd_script = {
        & dbg_script,
"Interprets a file s user commands.\n\
Usage:\n\
(pdb) script file.script"
    },
    cmd_stack = {
        & dbg_stack,
"Print a stack trace of the parrot VM"
    },
    cmd_trace = {
        & dbg_trace,
"Similar to \"next\", but prints additional trace information.\n\
This is the same as the information you get when running Parrot with\n\
the -t option.\n"
    },
    cmd_watch = {
        & dbg_watch,
"Add a watchpoint"
    };

static const DebuggerCmd * get_command(unsigned long cmdhash) /* HEADERIZER SKIP */
{
    switch ((enum DebugCmd)cmdhash) {
        case debug_cmd_break:
            return & cmd_break;
        case debug_cmd_continue:
        case debug_cmd_c:
            return & cmd_continue;
        case debug_cmd_delete:
        case debug_cmd_d:
            return & cmd_delete;
        case debug_cmd_disable:
            return & cmd_disable;
        case debug_cmd_disassemble:
            return & cmd_disassemble;
        case debug_cmd_echo:
            return & cmd_echo;
        case debug_cmd_enable:
            return & cmd_enable;
        case debug_cmd_eval:
        case debug_cmd_e:
            return & cmd_eval;
        case debug_cmd_gcdebug:
            return & cmd_gcdebug;
        case debug_cmd_help:
        case debug_cmd_h:
            return & cmd_help;
        case debug_cmd_info:
            return & cmd_info;
        case debug_cmd_list:
        case debug_cmd_l:
            return & cmd_list;
        case debug_cmd_load:
            return & cmd_load;
        case debug_cmd_next:
        case debug_cmd_n:
            return & cmd_next;
        case debug_cmd_print:
        case debug_cmd_p:
             return & cmd_print;
        case debug_cmd_quit:
        case debug_cmd_q:
             return & cmd_quit;
        case debug_cmd_r:
        case debug_cmd_run:
             return & cmd_run;
        case debug_cmd_script_file:
        case debug_cmd_f:
            return & cmd_script;
        case debug_cmd_stack:
        case debug_cmd_s:
            return & cmd_stack;
        case debug_cmd_trace:
        case debug_cmd_t:
            return & cmd_trace;
        case debug_cmd_watch:
        case debug_cmd_w:
            return & cmd_watch;
        default:
            return NULL;
    }
}


static const char * skip_whitespace(ARGIN(const char *cmd)) /* HEADERIZER SKIP */
{
    while (isspace((unsigned char)*cmd))
        ++cmd;
    return cmd;
}

static unsigned long get_uint(ARGMOD(const char **cmd), unsigned int def) /* HEADERIZER SKIP */
{
    char *cmdnext;
    unsigned int result = strtoul(skip_whitespace(* cmd), & cmdnext, 0);
    if (cmdnext != * cmd)
        * cmd = cmdnext;
    else
        result = def;
    return result;
}

static unsigned long get_ulong(ARGMOD(const char **cmd), unsigned long def) /* HEADERIZER SKIP */
{
    char *cmdnext;
    unsigned long result = strtoul(skip_whitespace(* cmd), & cmdnext, 0);
    if (cmdnext != * cmd)
        * cmd = cmdnext;
    else
        result = def;
    return result;
}

/*

=item C<static void chop_newline>

If the C string argument end with a newline, delete it.

=cut

*/

static void
chop_newline(ARGMOD(char * buf))
{
    int l = strlen(buf);
    if (l > 0 && buf [l - 1] == '\n')
        buf [l - 1] = '\0';
}

/*

=item C<static const char * nextarg>

Returns the position just past the current argument in the PASM instruction
C<command>. This is not the same as C<skip_command()>, which is intended for
debugger commands. This function is used for C<eval>.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char *
nextarg(ARGIN_NULLOK(const char *command))
{
    /* as long as the character pointed to by command is not NULL,
     * and it is either alphanumeric, a comma or a closing bracket,
     * continue looking for the next argument.
     */
    if (command) {
        while (isalnum((unsigned char) *command) || *command == ',' || *command == ']')
            command++;

        /* eat as much space as possible */
        command = skip_whitespace(command);
    }

    return command;
}

/*

=item C<static const char * skip_command>

Returns the pointer past the current debugger command. (This is an
alternative to the C<skip_command()> macro above.)

=cut

*/

PARROT_CANNOT_RETURN_NULL
static const char *
skip_command(ARGIN(const char *str))
{
    /* while str is not null and it contains a command (no spaces),
     * skip the character
     */
    while (*str && !isspace((unsigned char) *str))
        str++;

    /* eat all space after that */
    return skip_whitespace(str);
}

/*

=item C<static const char * parse_int>

Parse an C<int> out of a string and return a pointer to just after the C<int>.
The output parameter C<intP> contains the parsed value.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char *
parse_int(ARGIN(const char *str), ARGOUT(int *intP))
{
    char *end;

    *intP = strtol(str, &end, 0);

    return end;
}

/*

=item C<static const char * parse_string>

Parse a double-quoted string out of a C string and return a pointer to
just after the string. The parsed string is converted to a Parrot
C<STRING> and placed in the output parameter C<strP>.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char *
parse_string(PARROT_INTERP, ARGIN(const char *str), ARGOUT(STRING **strP))
{
    const char *string_start;

    /* if this is not a quoted string, there's nothing to parse */
    if (*str != '"')
        return NULL;

    /* skip the quote */
    str++;

    string_start = str;

    /* parse while there's no closing quote */
    while (*str && *str != '"') {
        /* skip any potentially escaped quotes */
        if (*str == '\\' && str[1])
            str += 2;
        else
            str++;
    }

    /* create the output STRING */
    *strP = string_make(interp, string_start, (UINTVAL)(str - string_start),
        NULL, 0);

    /* skip the closing quote */
    if (*str)
        str++;

    return str;
}

/*

=item C<static const char* parse_key>

Parse an aggregate key out of a string and return a pointer to just
after the key. Currently only string and integer keys are allowed.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char*
parse_key(PARROT_INTERP, ARGIN(const char *str), ARGOUT(PMC **keyP))
{
    /* clear output parameter */
    *keyP = NULL;

    /* make sure it's a key */
    if (*str != '[')
        return NULL;

    /* Skip [ */
    str++;

    /* if this is a string key, create a Parrot STRING */
    if (*str == '"') {
        STRING *parrot_string;
        str   = parse_string(interp, str, &parrot_string);
        *keyP = key_new_string(interp, parrot_string);
    }
    /* if this is a numeric key */
    else if (isdigit((unsigned char) *str)) {
        int value;
        str   = parse_int(str, &value);
        *keyP = key_new_integer(interp, (INTVAL) value);
    }
    /* unsupported case; neither a string nor a numeric key */
    else {
        return NULL;
    }

    /* hm, but if this doesn't match, it's probably an error */
    /* XXX str can be NULL from parse_string() */
    if (*str != ']')
        return NULL;

    /* skip the closing brace on the key */
    return ++str;
}

/*

=item C<static const char * parse_command>

Convert the command at the beginning of a string into a numeric value
that can be used as a switch key for fast lookup.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_IGNORABLE_RESULT
static const char *
parse_command(ARGIN(const char *command), ARGOUT(unsigned long *cmdP))
{
    int           i;
    unsigned long c = 0;

    /* Skip leading whitespace. */
    command = skip_whitespace(command);

    if (*command == '\0') {
        *cmdP = c;
        return NULL;
    }

    for (i = 0; isalpha((unsigned char) *command); command++, i++)
        c += (tolower((unsigned char) *command) + (i + 1)) * ((i + 1) * 255);

    /* Nonempty and did not start with a letter */
    if (c == 0)
        c = (unsigned long)-1;

    *cmdP = c;

    return command;
}

/*

=item C<static void debugger_cmdline>

Debugger command line.

Gets and executes commands, looping until the debugger state
is chnaged, either to exit or to start executing code.

=cut

*/

static void
debugger_cmdline(PARROT_INTERP)
{
    TRACEDEB_MSG("debugger_cmdline");

    /*while (!(interp->pdb->state & PDB_EXIT)) {*/
    while (interp->pdb->state & PDB_STOPPED) {
        const char * command;
        interp->pdb->state &= ~PDB_TRACING;
        PDB_get_command(interp);
        command = interp->pdb->cur_command;
        if (command[0] == '\0')
            command = interp->pdb->last_command;

        PDB_run_command(interp, command);
    }
    TRACEDEB_MSG("debugger_cmdline finished");
}

/*

=item C<static void close_script_file>

Close the script file, returning to command prompt mode.

=cut

*/

static void
close_script_file(PARROT_INTERP)
{
    TRACEDEB_MSG("Closing debugger script file");
    if (interp->pdb->script_file) {
        fclose(interp->pdb->script_file);
        interp->pdb->script_file = NULL;
        interp->pdb->state|= PDB_STOPPED;
        interp->pdb->last_command[0] = '\0';
        interp->pdb->cur_command[0] = '\0';
    }
}

/*

=item C<void Parrot_debugger_init>

Initializes the Parrot debugger, if it's not already initialized.

=cut

*/

PARROT_API
void
Parrot_debugger_init(PARROT_INTERP)
{
    TRACEDEB_MSG("Parrot_debugger_init");

    if (! interp->pdb) {
        PDB_t          *pdb      = mem_allocate_zeroed_typed(PDB_t);
        Parrot_Interp   debugger = Parrot_new(interp);
        interp->pdb              = pdb;
        debugger->pdb            = pdb;
        pdb->debugee             = interp;
        pdb->debugger            = debugger;

        /* Allocate space for command line buffers, NUL terminated c strings */
        pdb->cur_command = (char *)mem_sys_allocate_zeroed(DEBUG_CMD_BUFFER_LENGTH + 1);
        pdb->last_command = (char *)mem_sys_allocate_zeroed(DEBUG_CMD_BUFFER_LENGTH + 1);
    }

    /* PDB_disassemble(interp, NULL); */

    interp->pdb->state     |= PDB_RUNNING;
}

/*

=item C<void Parrot_debugger_destroy>

Destroy the current Parrot debugger instance.

=cut

*/

PARROT_API
void
Parrot_debugger_destroy(PARROT_INTERP)
{
    /* Unfinished.
       Free all debugger allocated resources.
     */
    PDB_t *pdb = interp->pdb;

    TRACEDEB_MSG("Parrot_debugger_destroy");

    PARROT_ASSERT(pdb);
    PARROT_ASSERT(pdb->debugee == interp);

    mem_sys_free(pdb->last_command);
    mem_sys_free(pdb->cur_command);

    mem_sys_free(pdb);
    interp->pdb = NULL;
}

/*

=item C<void Parrot_debugger_load>

Loads a Parrot source file for the current program.

=cut

*/

PARROT_API
void
Parrot_debugger_load(PARROT_INTERP, ARGIN_NULLOK(STRING *filename))
{
    char *file;

    TRACEDEB_MSG("Parrot_debugger_load");

    if (!interp->pdb)
        Parrot_ex_throw_from_c_args(interp, NULL, 0, "No debugger");

    file = string_to_cstring(interp, filename);
    PDB_load_source(interp, file);
    string_cstring_free(file);
}

/*

=item C<void Parrot_debugger_start>

Start debugger.

=cut

*/

PARROT_API
void
Parrot_debugger_start(PARROT_INTERP, ARGIN(opcode_t * cur_opcode))
{
    TRACEDEB_MSG("Parrot_debugger_start");

    if (!interp->pdb)
        Parrot_ex_throw_from_c_args(interp, NULL, 0, "No debugger");

    interp->pdb->cur_opcode = interp->code->base.data;

    if (interp->pdb->state & PDB_ENTER) {
        if (!interp->pdb->file) {
            /* PDB_disassemble(interp, NULL); */
        }
        interp->pdb->state &= ~PDB_ENTER;
    }

    interp->pdb->cur_opcode = cur_opcode;

    interp->pdb->state |= PDB_STOPPED;

    debugger_cmdline(interp);

    if (interp->pdb->state & PDB_EXIT)
        Parrot_exit(interp, 0);
}

/*

=item C<void Parrot_debugger_break>

Breaks execution and drops into the debugger.  If we are already into the
debugger and it is the first call, set a breakpoint.

When you re run/continue the program being debugged it will pay no attention to
the debug ops.

RT #42377: clone the interpreter to allow people to play into the
debugger and then continue the normal execution of the program.

=cut

*/

PARROT_API
void
Parrot_debugger_break(PARROT_INTERP, ARGIN(opcode_t * cur_opcode))
{
    TRACEDEB_MSG("Parrot_debugger_break");

    if (!interp->pdb)
        Parrot_ex_throw_from_c_args(interp, NULL, 0, "No debugger");

    if (!interp->pdb->file)
        Parrot_ex_throw_from_c_args(interp, NULL, 0, "No file loaded to debug");

    if (!(interp->pdb->state & PDB_BREAK)) {
        const char * command;
        new_runloop_jump_point(interp);
        if (setjmp(interp->current_runloop->resume)) {
            fprintf(stderr, "Unhandled exception in debugger\n");
            return;
        }

        interp->pdb->state     |= PDB_BREAK;
        interp->pdb->state     |= PDB_STOPPED;
        interp->pdb->cur_opcode = (opcode_t *)cur_opcode + 1;

        PDB_set_break(interp, NULL);

        debugger_cmdline(interp);

        /* RT #42378 this is not ok */
        /* exit(EXIT_SUCCESS); */
    }
    else {
        interp->pdb->cur_opcode = (opcode_t *)cur_opcode + 1;
        PDB_set_break(interp, NULL);
    }
}

/*

=item C<void PDB_get_command>

Get a command from the user input to execute.

It saves the last command executed (in C<< pdb->last_command >>), so it
first frees the old one and updates it with the current one.

Also prints the next line to run if the program is still active.

The user input can't be longer than DEBUG_CMD_BUFFER_LENGTH characters.

The input is saved in C<< pdb->cur_command >>.

=cut

*/

void
PDB_get_command(PARROT_INTERP)
{
    unsigned int  i;
    int           ch;
    char         *c;
    PDB_t        * const pdb = interp->pdb;

    /* flush the buffered data */
    fflush(stdout);

    TRACEDEB_MSG("PDB_get_command");

    PARROT_ASSERT(pdb->last_command);
    PARROT_ASSERT(pdb->cur_command);

    if (interp->pdb->script_file) {
        FILE *fd = interp->pdb->script_file;
        char buf[DEBUG_CMD_BUFFER_LENGTH+1];
        const char *ptr;

        do {
            if (fgets(buf, DEBUG_CMD_BUFFER_LENGTH, fd) == NULL) {
                close_script_file(interp);
                return;
            }
            ++pdb->script_line;
            chop_newline(buf);
#if TRACE_DEBUGGER
            fprintf(stderr, "script (%lu): '%s'\n", pdb->script_line, buf);
#endif

            /* skip spaces */
            ptr = skip_whitespace(buf);

            /* skip blank and commented lines */
       } while (*ptr == '\0' || *ptr == '#');

        if (pdb->state & PDB_ECHO)
            Parrot_eprintf(pdb->debugger, "[%lu %s]\n", pdb->script_line, buf);

#if TRACE_DEBUGGER
        fprintf(stderr, "(script) %s\n", buf);
#endif

        strcpy(pdb->cur_command, buf);
    }
    else {

        /* update the last command */
        if (pdb->cur_command[0] != '\0')
            strcpy(pdb->last_command, pdb->cur_command);

        i = 0;

        c = pdb->cur_command;

        PIO_eprintf(pdb->debugger, "\n(pdb) ");

        /* skip leading whitespace */
        do {
            ch = fgetc(stdin);
        } while (isspace((unsigned char)ch) && ch != '\n');

        /* generate string (no more than buffer length) */
        while (ch != EOF && ch != '\n' && (i < DEBUG_CMD_BUFFER_LENGTH)) {
            c[i++] = (char)ch;
            ch     = fgetc(stdin);
        }

        c[i] = '\0';

        if (ch == -1)
            strcpy(c, "quit");
    }
}

/*

=item C<void PDB_script_file>

Interprets the contents of a file as user input commands

=cut

*/

PARROT_API
void
PDB_script_file(PARROT_INTERP, ARGIN(const char *command))
{
    FILE *fd;

    TRACEDEB_MSG("PDB_script_file");

    /* If already executing a script, close it */
    close_script_file(interp);

    TRACEDEB_MSG("Opening debugger script file");

    fd = fopen(command, "r");
    if (!fd) {
        IMCC_warning(interp, "script_file: "
            "Error reading script file %s.\n",
            command);
        return;
    }
    interp->pdb->script_file = fd;
    interp->pdb->script_line = 0;
    TRACEDEB_MSG("PDB_script_file finished");
}

/*

=item C<int PDB_run_command>

Run a command.

Hash the command to make a simple switch calling the correct handler.

=cut

*/

PARROT_IGNORABLE_RESULT
int
PDB_run_command(PARROT_INTERP, ARGIN(const char *command))
{
    unsigned long c;
    PDB_t        * const pdb = interp->pdb;
    const DebuggerCmd *cmd;

    /* keep a pointer to the command, in case we need to report an error */
    /* get a number from what the user typed */
    const char * cmdline = parse_command(command, &c);

    TRACEDEB_MSG("PDB_run_command");

    cmd = get_command(c);

    if (cmd) {
        (* cmd->func)(pdb, cmdline);
        return 0;
    }
    else {
        if (c == 0) {
            /*
            if (pdb->last_command)
                PDB_run_command(interp, pdb->last_command);
            */
            return 0;
        }
        else {
            PIO_eprintf(pdb->debugger,
                        "Undefined command: \"%s\"", command);
            if (pdb->script_file)
                PIO_eprintf(pdb->debugger, " in line %lu", pdb->script_line);
            PIO_eprintf(pdb->debugger, ".  Try \"help\".");
#if TRACE_DEBUGGER
            fprintf(stderr, " (parse_command result: %li)", c);
#endif
            close_script_file(interp);
            return 1;
        }
    }
}

/*

=item C<void PDB_next>

Execute the next N operation(s).

Inits the program if needed, runs the next N >= 1 operations and stops.

=cut

*/

void
PDB_next(PARROT_INTERP, ARGIN_NULLOK(const char *command))
{
    unsigned long  n;
    PDB_t  * const pdb = interp->pdb;
    Interp *debugee;

    TRACEDEB_MSG("PDB_next");

    /* Init the program if it's not running */
    if (!(pdb->state & PDB_RUNNING))
        PDB_init(interp, command);

    /* Get the number of operations to execute if any */
    n = get_ulong(& command, 1);

    /* Erase the stopped flag */
    pdb->state &= ~PDB_STOPPED;

    /* Testing use of the debugger runloop */
    #if 0

    /* Execute */
    for (; n && pdb->cur_opcode; n--)
        DO_OP(pdb->cur_opcode, pdb->debugee);

    /* Set the stopped flag */
    pdb->state |= PDB_STOPPED;

    /* If program ended */

    /*
     * RT #46119 this doesn't handle resume opcodes
     */
    if (!pdb->cur_opcode)
        (void)PDB_program_end(interp);
    #endif

    debugee     = pdb->debugee;

    new_runloop_jump_point(debugee);
    if (setjmp(debugee->current_runloop->resume)) {
        Parrot_eprintf(pdb->debugger, "Unhandled exception while tracing\n");
        pdb->state |= PDB_STOPPED;
        return;
    }
    pdb->tracing = n;
    pdb->debugee->run_core = PARROT_DEBUGGER_CORE;

    TRACEDEB_MSG("PDB_next finished");
}

/*

=item C<void PDB_trace>

Execute the next N operations; if no number is specified, it defaults to 1.

=cut

*/

void
PDB_trace(PARROT_INTERP, ARGIN_NULLOK(const char *command))
{
    unsigned long  n;
    PDB_t *  const pdb = interp->pdb;
    Interp        *debugee;

    TRACEDEB_MSG("PDB_trace");

    /* if debugger is not running yet, initialize */
    /*
    if (!(pdb->state & PDB_RUNNING))
        PDB_init(interp, command);
    */

    /* ge the number of ops to run, if specified */
    n = get_ulong(& command, 1);

    /* clear the PDB_STOPPED flag, we'll be running n ops now */
    pdb->state &= ~PDB_STOPPED;
    debugee     = pdb->debugee;

    /* execute n ops */
    new_runloop_jump_point(debugee);
    if (setjmp(debugee->current_runloop->resume)) {
        Parrot_eprintf(pdb->debugger, "Unhandled exception while tracing\n");
        pdb->state |= PDB_STOPPED;
        return;
    }
    pdb->tracing = n;
    pdb->debugee->run_core = PARROT_DEBUGGER_CORE;
    pdb->state |= PDB_TRACING;

    /* Clear the following when done some testing */

    /* we just stopped */
    pdb->state |= PDB_STOPPED;

    /* If program ended */
    if (!pdb->cur_opcode)
        (void)PDB_program_end(interp);
    pdb->state |= PDB_RUNNING;
    pdb->state &= ~PDB_STOPPED;

    TRACEDEB_MSG("PDB_trace finished");
}

static unsigned short condition_regtype(ARGIN(const char *cmd)) /* HEADERIZER SKIP */
{
    switch (*cmd) {
        case 'i':
        case 'I':
            return PDB_cond_int;
        case 'n':
        case 'N':
            return PDB_cond_num;
        case 's':
        case 'S':
            return PDB_cond_str;
        case 'p':
        case 'P':
            return PDB_cond_pmc;
        default:
            return 0;
    }
}

/*

=item C<PDB_condition_t * PDB_cond>

Analyzes a condition from the user input.

=cut

*/

PARROT_CAN_RETURN_NULL
PDB_condition_t *
PDB_cond(PARROT_INTERP, ARGIN(const char *command))
{
    PDB_condition_t *condition;
    const char      *auxcmd;
    char             str[DEBUG_CMD_BUFFER_LENGTH + 1];
    unsigned short   cond_argleft;
    unsigned short   cond_type;
    unsigned char    regleft;
    int              i, reg_number;

    /* Return if no more arguments */
    if (!(command && *command)) {
        PIO_eprintf(interp->pdb->debugger, "No condition specified\n");
        return NULL;
    }

    command = skip_whitespace(command);
#if TRACE_DEBUGGER
    fprintf(stderr, "PDB_trace: '%s'\n", command);
#endif

    cond_argleft = condition_regtype(command);

    /* get the register number */
    auxcmd = ++command;
    regleft = (unsigned char)get_uint(&command, 0);
    if (auxcmd == command) {
        PIO_eprintf(interp->pdb->debugger, "Invalid register\n");
            return NULL;
    }

    /* Now the condition */
    command = skip_whitespace(command);
    switch (*command) {
        case '>':
            if (*(command + 1) == '=')
                cond_type = PDB_cond_ge;
            else
                cond_type = PDB_cond_gt;
            break;
        case '<':
            if (*(command + 1) == '=')
                cond_type = PDB_cond_le;
            else
                cond_type = PDB_cond_lt;
            break;
        case '=':
            if (*(command + 1) == '=')
                cond_type = PDB_cond_eq;
            else
                goto INV_COND;
            break;
        case '!':
            if (*(command + 1) == '=')
                cond_type = PDB_cond_ne;
            else
                goto INV_COND;
            break;
        case '\0':
            if (cond_argleft != PDB_cond_str && cond_argleft != PDB_cond_pmc) {
                PIO_eprintf(interp->pdb->debugger, "Invalid null condition\n");
                return NULL;
            }
            cond_type = PDB_cond_notnull;
            break;
        default:
INV_COND:   PIO_eprintf(interp->pdb->debugger, "Invalid condition\n");
            return NULL;
    }

    /* if there's an '=', skip it */
    if (*(command + 1) == '=')
        command += 2;
    else
        command++;

    command = skip_whitespace(command);

    /* return if no notnull condition and no more arguments */
    if (!(command && *command) && (cond_type != PDB_cond_notnull)) {
        PIO_eprintf(interp->pdb->debugger, "Can't compare a register with nothing\n");
        return NULL;
    }

    /* Allocate new condition */
    condition = mem_allocate_zeroed_typed(PDB_condition_t);

    condition->type = cond_argleft | cond_type;

    if (cond_type != PDB_cond_notnull) {

        if (isalpha((unsigned char)*command)) {
            /* It's a register - we first check that it's the correct type */

            unsigned short cond_argright = condition_regtype(command);

            if (cond_argright != cond_argleft) {
                PIO_eprintf(interp->pdb->debugger, "Register types don't agree\n");
                mem_sys_free(condition);
                return NULL;
            }

            /* Now we check and store the register number */
            auxcmd = ++command;
            reg_number = (int)get_uint(&command, 0);
            if (auxcmd == command) {
                PIO_eprintf(interp->pdb->debugger, "Invalid register\n");
                    mem_sys_free(condition);
                    return NULL;
            }

            if (reg_number < 0) {
                PIO_eprintf(interp->pdb->debugger, "Out-of-bounds register\n");
                mem_sys_free(condition);
                return NULL;
            }

            condition->value         = mem_allocate_typed(int);
            *(int *)condition->value = reg_number;
        }
        /* If the first argument was an integer */
        else if (condition->type & PDB_cond_int) {
            /* This must be either an integer constant or register */
            condition->value             = mem_allocate_typed(INTVAL);
            *(INTVAL *)condition->value  = (INTVAL)atoi(command);
            condition->type             |= PDB_cond_const;
        }
        else if (condition->type & PDB_cond_num) {
            condition->value               = mem_allocate_typed(FLOATVAL);
            *(FLOATVAL *)condition->value  = (FLOATVAL)atof(command);
            condition->type               |= PDB_cond_const;
        }
        else if (condition->type & PDB_cond_str) {
            for (i = 1; ((command[i] != '"') && (i < DEBUG_CMD_BUFFER_LENGTH)); i++)
                str[i - 1] = command[i];
            str[i - 1] = '\0';
#if TRACE_DEBUGGER
            fprintf(stderr, "PDB_break: '%s'\n", str);
#endif
            condition->value = string_make(interp, str, (UINTVAL)(i - 1),
                NULL, 0);

            condition->type |= PDB_cond_const;
        }
        else if (condition->type & PDB_cond_pmc) {
            /* RT #46123 Need to figure out what to do in this case.
             * For the time being, we just bail. */
            PIO_eprintf(interp->pdb->debugger, "Can't compare PMC with constant\n");
            mem_sys_free(condition);
            return NULL;
        }

    }

    return condition;
}

/*

=item C<void PDB_watchpoint>

Set a watchpoint.

=cut

*/

void
PDB_watchpoint(PARROT_INTERP, ARGIN(const char *command))
{
    PDB_t           * const pdb = interp->pdb;
    PDB_condition_t * const condition = PDB_cond(interp, command);

    if (!condition)
        return;

    /* Add it to the head of the list */
    if (pdb->watchpoint)
        condition->next = pdb->watchpoint;

    pdb->watchpoint = condition;
}

/*

=item C<void PDB_set_break>

Set a break point, the source code file must be loaded.

=cut

*/

void
PDB_set_break(PARROT_INTERP, ARGIN_NULLOK(const char *command))
{
    PDB_t            * const pdb      = interp->pdb;
    PDB_breakpoint_t *newbreak;
    PDB_breakpoint_t **lbreak;
    PDB_line_t       *line = NULL;
    long              bp_id;
    opcode_t         *breakpos = NULL;

    unsigned long ln = get_ulong(& command, 0);

    TRACEDEB_MSG("PDB_set_break");


    /* If there is a source file use line number, else opcode position */

    if (pdb->file) {
        /* If no line number was specified, set it at the current line */
        if (ln != 0) {
            unsigned long i;

            /* Move to the line where we will set the break point */
            line = pdb->file->line;

            for (i = 1; ((i < ln) && (line->next)); i++)
                line = line->next;

            /* Abort if the line number provided doesn't exist */
            if (!line->next) {
                PIO_eprintf(pdb->debugger,
                    "Can't set a breakpoint at line number %li\n", ln);
                return;
            }
        }
        else {
            /* Get the line to set it */
            line = pdb->file->line;

            while (line->opcode != pdb->cur_opcode) {
                line = line->next;
                if (!line) {
                    PIO_eprintf(pdb->debugger,
                       "No current line found and no line number specified\n");
                    return;
                }
            }
        }
        /* Skip lines that are not related to an opcode */
        while (line && !line->opcode)
            line = line->next;
        /* Abort if the line number provided doesn't exist */
        if (!line) {
            PIO_eprintf(pdb->debugger,
                "Can't set a breakpoint at line number %li\n", ln);
            return;
        }

        breakpos = line->opcode;
    }
    else {
        breakpos = interp->code->base.data + ln;
    }

    /* Allocate the new break point */
    newbreak = mem_allocate_zeroed_typed(PDB_breakpoint_t);

    if (command) {
        /*command = skip_command(command);*/
    }
    else {
        Parrot_ex_throw_from_c_args(interp, NULL, 1,
            "NULL command passed to PDB_set_break");
    }

    /* if there is another argument to break, besides the line number,
     * it should be an 'if', so we call another handler. */
    if (command && *command) {
        command = skip_whitespace(command);
        while (! isspace((unsigned char)*command))
            ++command;
        command = skip_whitespace(command);
        newbreak->condition = PDB_cond(interp, command);
    }

    /* Set the address where to stop */
    newbreak->pc   = breakpos;

    /* No next breakpoint */
    newbreak->next = NULL;

    /* Don't skip (at least initially) */
    newbreak->skip = 0;

    /* Add the breakpoint to the end of the list */
    bp_id = 1;
    lbreak = & pdb->breakpoint;
    while (*lbreak) {
        bp_id = (*lbreak)->id + 1;
        lbreak = & (*lbreak)->next;
    }
    newbreak->prev = *lbreak;
    *lbreak = newbreak;
    newbreak->id = bp_id;

    /* Show breakpoint position */

    PIO_eprintf(pdb->debugger, "Breakpoint %li at", newbreak->id);
    if (line)
        PIO_eprintf(pdb->debugger, " line %li", line->number);
    PIO_eprintf(pdb->debugger, " pos %li\n", newbreak->pc - interp->code->base.data);
}

/*

=item C<void PDB_init>

Init the program.

=cut

*/

void
PDB_init(PARROT_INTERP, SHIM(const char *command))
{
    PDB_t * const pdb = interp->pdb;

    /* Restart if we are already running */
    if (pdb->state & PDB_RUNNING)
        PIO_eprintf(pdb->debugger, "Restarting\n");

    /* Add the RUNNING state */
    pdb->state |= PDB_RUNNING;
}

/*

=item C<void PDB_continue>

Continue running the program. If a number is specified, skip that many
breakpoints.

=cut

*/

void
PDB_continue(PARROT_INTERP, ARGIN_NULLOK(const char *command))
{
    PDB_t * const pdb = interp->pdb;
    unsigned long ln = 0;

    TRACEDEB_MSG("PDB_continue");

    /* Skip any breakpoint? */
    if (command)
        ln = get_ulong(& command, 0);

    if (ln != 0) {
        if (!pdb->breakpoint) {
            PIO_eprintf(pdb->debugger, "No breakpoints to skip\n");
            return;
        }

        PDB_skip_breakpoint(interp, ln);
    }

    /* Run while no break point is reached */
    /*
    while (!PDB_break(interp))
        DO_OP(pdb->cur_opcode, pdb->debugee);
    */

    #if 0
    pdb->tracing = 0;
    pdb->debugee->run_core = PARROT_DEBUGGER_CORE;
    new_internal_exception(pdb->debugee);
    if (setjmp(pdb->debugee->exceptions->destination)) {
        Parrot_eprintf(pdb->debugee, "Unhandled exception while debugging: %Ss\n",
            pdb->debugee->exceptions->msg);
        pdb->state |= PDB_STOPPED;
        return;
    }
    runops_int(pdb->debugee, pdb->debugee->code->base.data - pdb->cur_opcode);
    if (!pdb->cur_opcode)
        (void)PDB_program_end(interp);
    #endif
    pdb->state |= PDB_RUNNING;
    pdb->state &= ~PDB_STOPPED;
}

/*

=item C<PDB_breakpoint_t * PDB_find_breakpoint>

Find breakpoint number N; returns C<NULL> if the breakpoint doesn't
exist or if no breakpoint was specified.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
PDB_breakpoint_t *
PDB_find_breakpoint(PARROT_INTERP, ARGIN(const char *command))
{
    const char *oldcmd = command;
    const unsigned long n = get_ulong(&command, 0);
    if (command != oldcmd) {
        PDB_breakpoint_t *breakpoint = interp->pdb->breakpoint;

        while (breakpoint && breakpoint->id != n)
            breakpoint = breakpoint->next;

        if (!breakpoint) {
            PIO_eprintf(interp->pdb->debugger, "No breakpoint number %ld", n);
            return NULL;
        }

        return breakpoint;
    }
    else {
        /* Report an appropriate error */
        if (*command)
            PIO_eprintf(interp->pdb->debugger, "Not a valid breakpoint");
        else
            PIO_eprintf(interp->pdb->debugger, "No breakpoint specified");

        return NULL;
    }
}

/*

=item C<void PDB_disable_breakpoint>

Disable a breakpoint; it can be reenabled with the enable command.

=cut

*/

void
PDB_disable_breakpoint(PARROT_INTERP, ARGIN(const char *command))
{
    PDB_breakpoint_t * const breakpoint = PDB_find_breakpoint(interp, command);

    /* if the breakpoint exists, disable it. */
    if (breakpoint)
        breakpoint->skip = -1;
}

/*

=item C<void PDB_enable_breakpoint>

Reenable a disabled breakpoint; if the breakpoint was not disabled, has
no effect.

=cut

*/

void
PDB_enable_breakpoint(PARROT_INTERP, ARGIN(const char *command))
{
    PDB_breakpoint_t * const breakpoint = PDB_find_breakpoint(interp, command);

    /* if the breakpoint exists, and it was disabled, enable it. */
    if (breakpoint && breakpoint->skip == -1)
        breakpoint->skip = 0;
}

/*

=item C<void PDB_delete_breakpoint>

Delete a breakpoint.

=cut

*/

void
PDB_delete_breakpoint(PARROT_INTERP, ARGIN(const char *command))
{
    PDB_breakpoint_t * const breakpoint = PDB_find_breakpoint(interp, command);

    if (breakpoint) {
        const PDB_line_t *line = interp->pdb->file->line;

        while (line->opcode != breakpoint->pc)
            line = line->next;

        /* Delete the condition structure, if there is one */
        if (breakpoint->condition) {
            PDB_delete_condition(interp, breakpoint);
            breakpoint->condition = NULL;
        }

        /* Remove the breakpoint from the list */
        if (breakpoint->prev && breakpoint->next) {
            breakpoint->prev->next = breakpoint->next;
            breakpoint->next->prev = breakpoint->prev;
        }
        else if (breakpoint->prev && !breakpoint->next) {
            breakpoint->prev->next = NULL;
        }
        else if (!breakpoint->prev && breakpoint->next) {
            breakpoint->next->prev  = NULL;
            interp->pdb->breakpoint = breakpoint->next;
        }
        else {
            interp->pdb->breakpoint = NULL;
        }

        /* Kill the breakpoint */
        mem_sys_free(breakpoint);
    }
}

/*

=item C<void PDB_delete_condition>

Delete a condition associated with a breakpoint.

=cut

*/

void
PDB_delete_condition(SHIM_INTERP, ARGMOD(PDB_breakpoint_t *breakpoint))
{
    if (breakpoint->condition->value) {
        if (breakpoint->condition->type & PDB_cond_str) {
            /* 'value' is a string, so we need to be careful */
            PObj_external_CLEAR((STRING*)breakpoint->condition->value);
            PObj_on_free_list_SET((STRING*)breakpoint->condition->value);
            /* it should now be properly garbage collected after
               we destroy the condition */
        }
        else {
            /* 'value' is a float or an int, so we can just free it */
            mem_sys_free(breakpoint->condition->value);
            breakpoint->condition->value = NULL;
        }
    }

    mem_sys_free(breakpoint->condition);
    breakpoint->condition = NULL;
}

/*

=item C<void PDB_skip_breakpoint>

Skip C<i> times all breakpoints.

=cut

*/

void
PDB_skip_breakpoint(PARROT_INTERP, unsigned long i)
{
#if TRACE_DEBUGGER
        fprintf(stderr, "PDB_skip_breakpoint: %li\n", i);
#endif

    interp->pdb->breakpoint_skip = i;
}

/*

=item C<char PDB_program_end>

End the program.

=cut

*/

char
PDB_program_end(PARROT_INTERP)
{
    PDB_t * const pdb = interp->pdb;

    /* Remove the RUNNING state */
    pdb->state &= ~PDB_RUNNING;

    PIO_eprintf(pdb->debugger, "Program exited.\n");
    return 1;
}

/*

=item C<char PDB_check_condition>

Returns true if the condition was met.

=cut

*/

PARROT_WARN_UNUSED_RESULT
char
PDB_check_condition(PARROT_INTERP, ARGIN(const PDB_condition_t *condition))
{
    Parrot_Context *ctx = CONTEXT(interp);

    TRACEDEB_MSG("PDB_check_condition");

    PARROT_ASSERT(ctx);

    if (condition->type & PDB_cond_int) {
        INTVAL   i,  j;
        if (condition->reg >= ctx->n_regs_used[REGNO_INT])
            return 0;
        i = CTX_REG_INT(ctx, condition->reg);

        if (condition->type & PDB_cond_const)
            j = *(INTVAL *)condition->value;
        else
            j = REG_INT(interp, *(int *)condition->value);

        if (((condition->type & PDB_cond_gt) && (i >  j)) ||
            ((condition->type & PDB_cond_ge) && (i >= j)) ||
            ((condition->type & PDB_cond_eq) && (i == j)) ||
            ((condition->type & PDB_cond_ne) && (i != j)) ||
            ((condition->type & PDB_cond_le) && (i <= j)) ||
            ((condition->type & PDB_cond_lt) && (i <  j)))
                return 1;

        return 0;
    }
    else if (condition->type & PDB_cond_num) {
        FLOATVAL k,  l;

        if (condition->reg >= ctx->n_regs_used[REGNO_NUM])
            return 0;
        k = CTX_REG_NUM(ctx, condition->reg);

        if (condition->type & PDB_cond_const)
            l = *(FLOATVAL *)condition->value;
        else
            l = REG_NUM(interp, *(int *)condition->value);

        if (((condition->type & PDB_cond_gt) && (k >  l)) ||
            ((condition->type & PDB_cond_ge) && (k >= l)) ||
            ((condition->type & PDB_cond_eq) && (k == l)) ||
            ((condition->type & PDB_cond_ne) && (k != l)) ||
            ((condition->type & PDB_cond_le) && (k <= l)) ||
            ((condition->type & PDB_cond_lt) && (k <  l)))
                return 1;

        return 0;
    }
    else if (condition->type & PDB_cond_str) {
        STRING  *m, *n;

        if (condition->reg >= ctx->n_regs_used[REGNO_STR])
            return 0;
        m = CTX_REG_STR(ctx, condition->reg);

        if (condition->type & PDB_cond_notnull)
            return ! STRING_IS_NULL(m);

        if (condition->type & PDB_cond_const)
            n = (STRING *)condition->value;
        else
            n = REG_STR(interp, *(int *)condition->value);

        if (((condition->type & PDB_cond_gt) &&
                (string_compare(interp, m, n) >  0)) ||
            ((condition->type & PDB_cond_ge) &&
                (string_compare(interp, m, n) >= 0)) ||
            ((condition->type & PDB_cond_eq) &&
                (string_compare(interp, m, n) == 0)) ||
            ((condition->type & PDB_cond_ne) &&
                (string_compare(interp, m, n) != 0)) ||
            ((condition->type & PDB_cond_le) &&
                (string_compare(interp, m, n) <= 0)) ||
            ((condition->type & PDB_cond_lt) &&
                (string_compare(interp, m, n) <  0)))
                    return 1;

        return 0;
    }
    else if (condition->type & PDB_cond_pmc) {
        PMC *m;

        if (condition->reg >= ctx->n_regs_used[REGNO_PMC])
            return 0;
        m = CTX_REG_PMC(ctx, condition->reg);

        if (condition->type & PDB_cond_notnull)
            return ! PMC_IS_NULL(m);
        return 0;
    }
    else
        return 0;
}

/*

=item C<static PDB_breakpoint_t * current_breakpoint>>

Returns a pointer to the breakpoint at the current position,
or NULL if there is none.

=cut

*/

static PDB_breakpoint_t * current_breakpoint(ARGIN(PDB_t * pdb)) /* HEADERIZER SKIP */
{
    PDB_breakpoint_t *breakpoint = pdb->breakpoint;
    while (breakpoint) {
        if (pdb->cur_opcode == breakpoint->pc)
            break;
        breakpoint = breakpoint->next;
    }
    return breakpoint;
}

/*

=item C<char PDB_break>

Returns true if we have to stop running.

=cut

*/

PARROT_WARN_UNUSED_RESULT
char
PDB_break(PARROT_INTERP)
{
    PDB_t            * const pdb = interp->pdb;
    PDB_condition_t  *watchpoint = pdb->watchpoint;
    PDB_breakpoint_t *breakpoint;

    TRACEDEB_MSG("PDB_break");

    /* Check the watchpoints first. */
    while (watchpoint) {
        if (PDB_check_condition(interp, watchpoint)) {
            pdb->state |= PDB_STOPPED;
            return 1;
        }

        watchpoint = watchpoint->next;
    }

    /* If program ended */
    if (!pdb->cur_opcode)
        return PDB_program_end(interp);

    /* If the program is STOPPED allow it to continue */
    if (pdb->state & PDB_STOPPED) {
        pdb->state &= ~PDB_STOPPED;
        return 0;
    }

    breakpoint = current_breakpoint(pdb);
    if (breakpoint) {
        /* If we have to skip breakpoints, do so. */
        if (pdb->breakpoint_skip) {
            TRACEDEB_MSG("PDB_break skipping");
            pdb->breakpoint_skip--;
            return 0;
        }

        if (breakpoint->skip < 0)
            return 0;

        /* Check if there is a condition for this breakpoint */
        if ((breakpoint->condition) &&
            (!PDB_check_condition(interp, breakpoint->condition)))
                return 0;

        TRACEDEB_MSG("PDB_break stopping");

        /* Add the STOPPED state and stop */
        pdb->state |= PDB_STOPPED;
        return 1;
    }

    return 0;
}

/*

=item C<char * PDB_escape>

Escapes C<">, C<\r>, C<\n>, C<\t>, C<\a> and C<\\>.

The returned string must be freed.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
PARROT_MALLOC
char *
PDB_escape(ARGIN(const char *string), UINTVAL length)
{
    const char *end;
    char       *_new, *fill;

    length = length > 20 ? 20 : length;
    end    = string + length;

    /* Return if there is no string to escape*/
    if (!string)
        return NULL;

    fill = _new = (char *)mem_sys_allocate(length * 2 + 1);

    for (; string < end; string++) {
        switch (*string) {
            case '\0':
                *(fill++) = '\\';
                *(fill++) = '0';
                break;
            case '\n':
                *(fill++) = '\\';
                *(fill++) = 'n';
                break;
            case '\r':
                *(fill++) = '\\';
                *(fill++) = 'r';
                break;
            case '\t':
                *(fill++) = '\\';
                *(fill++) = 't';
                break;
            case '\a':
                *(fill++) = '\\';
                *(fill++) = 'a';
                break;
            case '\\':
                *(fill++) = '\\';
                *(fill++) = '\\';
                break;
            case '"':
                *(fill++) = '\\';
                *(fill++) = '"';
                break;
            default:
                *(fill++) = *string;
                break;
        }
    }

    *fill = '\0';

    return _new;
}

/*

=item C<int PDB_unescape>

Do inplace unescape of C<\r>, C<\n>, C<\t>, C<\a> and C<\\>.

=cut

*/

int
PDB_unescape(ARGMOD(char *string))
{
    int l = 0;

    for (; *string; string++) {
        l++;

        if (*string == '\\') {
            char *fill;
            int i;

            switch (string[1]) {
                case 'n':
                    *string = '\n';
                    break;
                case 'r':
                    *string = '\r';
                    break;
                case 't':
                    *string = '\t';
                    break;
                case 'a':
                    *string = '\a';
                    break;
                case '\\':
                    *string = '\\';
                    break;
                default:
                    continue;
            }

            fill = string;

            for (i = 1; fill[i + 1]; i++)
                fill[i] = fill[i + 1];

            fill[i] = '\0';
        }
    }

    return l;
}

/*

=item C<size_t PDB_disassemble_op>

Disassembles C<op>.

=cut

*/

size_t
PDB_disassemble_op(PARROT_INTERP, ARGOUT(char *dest), size_t space,
        ARGIN(const op_info_t *info), ARGIN(const opcode_t *op),
        ARGMOD_NULLOK(PDB_file_t *file), ARGIN_NULLOK(const opcode_t *code_start),
        int full_name)
{
    int         j;
    size_t     size = 0;

    /* Write the opcode name */
    const char * p = full_name ? info->full_name : info->name;

    TRACEDEB_MSG("PDB_disassemble_op");

    if (! p)
        p= "**UNKNOWN**";
    strcpy(dest, p);
    size += strlen(p);

    dest[size++] = ' ';

    /* Concat the arguments */
    for (j = 1; j < info->op_count; j++) {
        char      buf[256];
        INTVAL    i = 0;

        PARROT_ASSERT(size + 2 < space);

        switch (info->types[j - 1]) {
        case PARROT_ARG_I:
            dest[size++] = 'I';
            goto INTEGER;
        case PARROT_ARG_N:
            dest[size++] = 'N';
            goto INTEGER;
        case PARROT_ARG_S:
            dest[size++] = 'S';
            goto INTEGER;
        case PARROT_ARG_P:
            dest[size++] = 'P';
            goto INTEGER;
        case PARROT_ARG_IC:
            /* If the opcode jumps and this is the last argument,
               that means this is a label */
            if ((j == info->op_count - 1) &&
                (info->jump & PARROT_JUMP_RELATIVE)) {
                if (file) {
                    dest[size++] = 'L';
                    i            = PDB_add_label(file, op, op[j]);
                }
                else if (code_start) {
                    dest[size++] = 'O';
                    dest[size++] = 'P';
                    i            = op[j] + (op - code_start);
                }
                else {
                    if (op[j] > 0)
                        dest[size++] = '+';
                    i = op[j];
                }
            }

            /* Convert the integer to a string */
            INTEGER:
            if (i == 0)
                i = (INTVAL) op[j];

            PARROT_ASSERT(size + 20 < space);

            size += sprintf(&dest[size], INTVAL_FMT, i);

            /* If this is a constant dispatch arg to an "infix" op, then show
               the corresponding symbolic op name. */
            if (j == 1 && info->types[j - 1] == PARROT_ARG_IC
                && (STREQ(info->name, "infix") || STREQ(info->name, "n_infix"))) {
                PARROT_ASSERT(size + 20 < space);

                size += sprintf(&dest[size], " [%s]",
                        /* [kludge: the "2+" skips the leading underscores.  --
                           rgr, 6-May-07.] */
                        2 + Parrot_MMD_method_name(interp, op[j]));
            }
            break;
        case PARROT_ARG_NC:
            {
            /* Convert the float to a string */
            const FLOATVAL f = interp->code->const_table->constants[op[j]]->u.number;
            Parrot_snprintf(interp, buf, sizeof (buf), FLOATVAL_FMT, f);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            }
            break;
        case PARROT_ARG_SC:
            dest[size++] = '"';
            if (interp->code->const_table->constants[op[j]]-> u.string->strlen) {
                char * const escaped =
                    PDB_escape(interp->code->const_table->
                           constants[op[j]]->u.string->strstart,
                           interp->code->const_table->
                           constants[op[j]]->u.string->strlen);
                if (escaped) {
                    strcpy(&dest[size], escaped);
                    size += strlen(escaped);
                    mem_sys_free(escaped);
                }
            }
            dest[size++] = '"';
            break;
        case PARROT_ARG_PC:
            Parrot_snprintf(interp, buf, sizeof (buf), "PMC_CONST(%d)", op[j]);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            break;
        case PARROT_ARG_K:
            dest[size - 1] = '[';
            Parrot_snprintf(interp, buf, sizeof (buf), "P" INTVAL_FMT, op[j]);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            dest[size++] = ']';
            break;
        case PARROT_ARG_KC:
            {
            PMC * k      = interp->code->const_table->constants[op[j]]->u.key;
            dest[size - 1] = '[';
            while (k) {
                switch (PObj_get_FLAGS(k)) {
                case 0:
                    break;
                case KEY_integer_FLAG:
                    Parrot_snprintf(interp, buf, sizeof (buf),
                                    INTVAL_FMT, PMC_int_val(k));
                    strcpy(&dest[size], buf);
                    size += strlen(buf);
                    break;
                case KEY_number_FLAG:
                    Parrot_snprintf(interp, buf, sizeof (buf),
                                    FLOATVAL_FMT, PMC_num_val(k));
                    strcpy(&dest[size], buf);
                    size += strlen(buf);
                    break;
                case KEY_string_FLAG:
                    dest[size++] = '"';
                    {
                        char * const temp = string_to_cstring(interp, PMC_str_val(k));
                        strcpy(&dest[size], temp);
                        string_cstring_free(temp);
                    }
                    size += string_length(interp, PMC_str_val(k));
                    dest[size++] = '"';
                    break;
                case KEY_integer_FLAG|KEY_register_FLAG:
                    Parrot_snprintf(interp, buf, sizeof (buf),
                                    "I" INTVAL_FMT, PMC_int_val(k));
                    strcpy(&dest[size], buf);
                    size += strlen(buf);
                    break;
                case KEY_number_FLAG|KEY_register_FLAG:
                    Parrot_snprintf(interp, buf, sizeof (buf),
                                    "N" INTVAL_FMT, PMC_int_val(k));
                    strcpy(&dest[size], buf);
                    size += strlen(buf);
                    break;
                case KEY_string_FLAG|KEY_register_FLAG:
                    Parrot_snprintf(interp, buf, sizeof (buf),
                                    "S" INTVAL_FMT, PMC_int_val(k));
                    strcpy(&dest[size], buf);
                    size += strlen(buf);
                    break;
                case KEY_pmc_FLAG|KEY_register_FLAG:
                    Parrot_snprintf(interp, buf, sizeof (buf),
                                    "P" INTVAL_FMT, PMC_int_val(k));
                    strcpy(&dest[size], buf);
                    size += strlen(buf);
                    break;
                default:
                    dest[size++] = '?';
                    break;
                }
                k = PMC_data_typed(k, PMC *);
                if (k)
                    dest[size++] = ';';
            }
            dest[size++] = ']';
            }
            break;
        case PARROT_ARG_KI:
            dest[size - 1] = '[';
            Parrot_snprintf(interp, buf, sizeof (buf), "I" INTVAL_FMT, op[j]);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            dest[size++] = ']';
            break;
        case PARROT_ARG_KIC:
            dest[size - 1] = '[';
            Parrot_snprintf(interp, buf, sizeof (buf), INTVAL_FMT, op[j]);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            dest[size++] = ']';
            break;
        default:
            Parrot_ex_throw_from_c_args(interp, NULL, 1, "Unknown opcode type");
        }

        if (j != info->op_count - 1)
            dest[size++] = ',';
    }

    /* Special decoding for the signature used in args/returns.  Such ops have
       one fixed parameter (the signature vector), plus a varying number of
       registers/constants.  For each arg/return, we show the register and its
       flags using PIR syntax. */
    if (*(op) == PARROT_OP_set_args_pc ||
            *(op) == PARROT_OP_get_results_pc ||
            *(op) == PARROT_OP_get_params_pc ||
            *(op) == PARROT_OP_set_returns_pc) {
        char buf[1000];
        PMC * const sig = interp->code->const_table->constants[op[1]]->u.key;
        int n_values = SIG_ELEMS(sig);
        /* The flag_names strings come from Call_bits_enum_t (with which it
           should probably be colocated); they name the bits from LSB to MSB.
           The two least significant bits are not flags; they are the register
           type, which is decoded elsewhere.  We also want to show unused bits,
           which could indicate problems.
        */
        const char * const flag_names[] = {
                                     "",
                                     "",
                                     " :unused004",
                                     " :unused008",
                                     " :const",
                                     " :flat", /* should be :slurpy for args */
                                     " :unused040",
                                     " :optional",
                                     " :opt_flag",
                                     " :named",
                                     NULL
        };

        /* Register decoding.  It would be good to abstract this, too. */
        static const char regs[] = "ISPN";

        for (j = 0; j < n_values; j++) {
            unsigned int idx = 0;
            const int sig_value = VTABLE_get_integer_keyed_int(interp, sig, j);

            /* Print the register name, e.g. P37. */
            buf[idx++] = ',';
            buf[idx++] = ' ';
            buf[idx++] = regs[sig_value & PARROT_ARG_TYPE_MASK];
            Parrot_snprintf(interp, &buf[idx], sizeof (buf)-idx,
                            INTVAL_FMT, op[j+2]);
            idx = strlen(buf);

            /* Add flags, if we have any. */
            {
                int flag_idx = 0;
                int flags = sig_value;

                /* End when we run out of flags, off the end of flag_names, or
                 * get too close to the end of buf.
                 * 100 is just an estimate of all buf lengths added together.
                 */
                while (flags && idx < sizeof (buf) - 100) {
                    const char * const flag_string = flag_names[flag_idx];
                    if (! flag_string)
                        break;
                    if (flags & 1 && *flag_string) {
                        const size_t n = strlen(flag_string);
                        strcpy(&buf[idx], flag_string);
                        idx += n;
                    }
                    flags >>= 1;
                    flag_idx++;
                }
            }

            /* Add it to dest. */
            buf[idx++] = '\0';
            strcpy(&dest[size], buf);
            size += strlen(buf);
        }
    }

    dest[size] = '\0';
    return ++size;
}

/*

=item C<void PDB_disassemble>

Disassemble the bytecode.

=cut

*/

void
PDB_disassemble(PARROT_INTERP, SHIM(const char *command))
{
    PDB_t    * const pdb = interp->pdb;
    opcode_t * pc        = interp->code->base.data;

    PDB_file_t  *pfile;
    PDB_line_t  *pline, *newline;
    PDB_label_t *label;
    opcode_t    *code_end;

    const unsigned int default_size = 32768;
    size_t space;  /* How much space do we have? */
    size_t size, alloced, n;

    TRACEDEB_MSG("PDB_disassemble");

    pfile = mem_allocate_zeroed_typed(PDB_file_t);
    pline = mem_allocate_zeroed_typed(PDB_line_t);

    /* If we already got a source, free it */
    if (pdb->file)
        PDB_free_file(interp);

    pfile->line   = pline;
    pline->number = 1;
    pfile->source = (char *)mem_sys_allocate(default_size);

    alloced       = space = default_size;
    code_end      = pc + interp->code->base.size;

    while (pc != code_end) {
        /* Grow it early */
        if (space < default_size) {
            alloced += default_size;
            space   += default_size;
            pfile->source = (char *)mem_sys_realloc(pfile->source, alloced);
        }

        size = PDB_disassemble_op(interp, pfile->source + pfile->size,
                space, &interp->op_info_table[*pc], pc, pfile, NULL, 1);
        space       -= size;
        pfile->size += size;
        pfile->source[pfile->size - 1] = '\n';

        /* Store the opcode of this line */
        pline->opcode = pc;
        n             = interp->op_info_table[*pc].op_count;

        ADD_OP_VAR_PART(interp, interp->code, pc, n);
        pc += n;

        /* Prepare for next line */
        newline              = mem_allocate_typed(PDB_line_t);
        newline->label       = NULL;
        newline->next        = NULL;
        newline->number      = pline->number + 1;
        pline->next          = newline;
        pline                = newline;
        pline->source_offset = pfile->size;
    }

    /* Add labels to the lines they belong to */
    label = pfile->label;

    while (label) {
        /* Get the line to apply the label */
        pline = pfile->line;

        while (pline && pline->opcode != label->opcode)
            pline = pline->next;

        if (!pline) {
            PIO_eprintf(pdb->debugger,
                        "Label number %li out of bounds.\n", label->number);
            /* RT #46127: free allocated memory */
            return;
        }

        pline->label = label;

        label        = label->next;
    }

    pdb->state |= PDB_SRC_LOADED;
    pdb->file   = pfile;
}

/*

=item C<long PDB_add_label>

Add a label to the label list.

=cut

*/

long
PDB_add_label(ARGMOD(PDB_file_t *file), ARGIN(const opcode_t *cur_opcode),
        opcode_t offset)
{
    PDB_label_t *_new;
    PDB_label_t *label = file->label;

    /* See if there is already a label at this line */
    while (label) {
        if (label->opcode == cur_opcode + offset)
            return label->number;
        label = label->next;
    }

    /* Allocate a new label */
    label        = file->label;
    _new         = mem_allocate_typed(PDB_label_t);
    _new->opcode = cur_opcode + offset;
    _new->next   = NULL;

    if (label) {
        while (label->next)
            label = label->next;

        _new->number = label->number + 1;
        label->next  = _new;
    }
    else {
        file->label  = _new;
        _new->number = 1;
    }

    return _new->number;
}

/*

=item C<void PDB_free_file>

Frees any allocated source files.

=cut

*/

void
PDB_free_file(PARROT_INTERP)
{
    PDB_file_t *file = interp->pdb->file;

    while (file) {
        /* Free all of the allocated line structures */
        PDB_line_t  *line = file->line;
        PDB_label_t *label;
        PDB_file_t  *nfile;

        while (line) {
            PDB_line_t * const nline = line->next;
            mem_sys_free(line);
            line = nline;
        }

        /* Free all of the allocated label structures */
        label = file->label;

        while (label) {
            PDB_label_t * const nlabel = label->next;

            mem_sys_free(label);
            label  = nlabel;
        }

        /* Free the remaining allocated portions of the file structure */
        if (file->sourcefilename)
            mem_sys_free(file->sourcefilename);

        if (file->source)
            mem_sys_free(file->source);

        nfile = file->next;
        mem_sys_free(file);
        file  = nfile;
    }

    /* Make sure we don't end up pointing at garbage memory */
    interp->pdb->file = NULL;
}

/*

=item C<void PDB_load_source>

Load a source code file.

=cut

*/

PARROT_API
void
PDB_load_source(PARROT_INTERP, ARGIN(const char *command))
{
    FILE          *file;
    char           f[DEBUG_CMD_BUFFER_LENGTH + 1];
    int            i, j, c;
    PDB_file_t    *pfile;
    PDB_line_t    *pline;
    PDB_t         * const pdb = interp->pdb;
    opcode_t      *pc         = interp->code->base.data;

    unsigned long  size = 0;

    TRACEDEB_MSG("PDB_load_source");

    /* If there was a file already loaded or the bytecode was
       disassembled, free it */
    if (pdb->file)
        PDB_free_file(interp->pdb->debugee);

    /* Get the name of the file */
    for (j = 0; command[j] == ' '; ++j)
        continue;
    for (i = 0; command[j]; i++, j++)
        f[i] = command[j];

    f[i] = '\0';

    /* open the file */
    file = fopen(f, "r");

    /* abort if fopen failed */
    if (!file) {
        PIO_eprintf(pdb->debugger, "Unable to load '%s'\n", f);
        return;
    }

    pfile = mem_allocate_zeroed_typed(PDB_file_t);
    pline = mem_allocate_zeroed_typed(PDB_line_t);

    pfile->source = (char *)mem_sys_allocate(1024);
    pfile->line   = pline;
    pline->number = 1;

    PARROT_ASSERT(interp->op_info_table);
    PARROT_ASSERT(pc);

    while ((c = fgetc(file)) != EOF) {
        /* Grow it */
        if (++size == 1024) {
            pfile->source = (char *)mem_sys_realloc(pfile->source,
                                            (size_t)pfile->size + 1024);
            size = 0;
        }
        pfile->source[pfile->size] = (char)c;

        pfile->size++;

        if (c == '\n') {
            /* If the line has an opcode move to the next one,
               otherwise leave it with NULL to skip it. */
            PDB_line_t *newline = mem_allocate_zeroed_typed(PDB_line_t);

            if (PDB_hasinstruction(pfile->source + pline->source_offset)) {
                size_t n      = interp->op_info_table[*pc].op_count;
                pline->opcode = pc;
                ADD_OP_VAR_PART(interp, interp->code, pc, n);
                pc           += n;

                /* don't walk off the end of the program into neverland */
                if (pc >= interp->code->base.data + interp->code->base.size)
                    return;
            }

            newline->number      = pline->number + 1;
            pline->next          = newline;
            pline                = newline;
            pline->source_offset = pfile->size;
            pline->opcode        = NULL;
            pline->label         = NULL;
        }
    }

    pdb->state |= PDB_SRC_LOADED;
    pdb->file   = pfile;

    TRACEDEB_MSG("PDB_load_source finished");
}

/*

=item C<char PDB_hasinstruction>

Return true if the line has an instruction.

RT #46129:

=over 4

=item * This should take the line, get an instruction, get the opcode for
that instruction and check that is the correct one.

=item * Decide what to do with macros if anything.

=back

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_PURE_FUNCTION
char
PDB_hasinstruction(ARGIN(const char *c))
{
    char h = 0;

    /* as long as c is not NULL, we're not looking at a comment (#...) or a '\n'... */
    while (*c && *c != '#' && *c != '\n') {
        /* ... and c is alphanumeric or a quoted string then the line contains
         * an instruction. */
        if (isalnum((unsigned char) *c) || *c == '"') {
            h = 1;
        }
        else if (*c == ':') {
            /* this is a label. RT #46137 right? */
            h = 0;
        }

        c++;
    }

    return h;
}

/*

=item C<void PDB_list>

Show lines from the source code file.

=cut

*/

void
PDB_list(PARROT_INTERP, ARGIN(const char *command))
{
    char          *c;
    unsigned long  line_number;
    unsigned long  i;
    PDB_line_t    *line;
    PDB_t         *pdb = interp->pdb;
    unsigned long  n   = 10;

    if (!pdb->file) {
        PIO_eprintf(pdb->debugger, "No source file loaded\n");
        return;
    }

    /* set the list line if provided */
    line_number = get_ulong(&command, 0);
    pdb->file->list_line = (unsigned long) line_number;

    /* set the number of lines to print */
    n = get_ulong(&command, 10);

    /* if n is zero, we simply return, as we don't have to print anything */
    if (n == 0)
        return;

    line = pdb->file->line;

    for (i = 0; i < pdb->file->list_line && line->next; i++)
        line = line->next;

    i = 1;
    while (line->next) {
        PIO_eprintf(pdb->debugger, "%li  ", pdb->file->list_line + i);
        /* If it has a label print it */
        if (line->label)
            PIO_eprintf(pdb->debugger, "L%li:\t", line->label->number);

        c = pdb->file->source + line->source_offset;

        while (*c != '\n')
            PIO_eprintf(pdb->debugger, "%c", *(c++));

        PIO_eprintf(pdb->debugger, "\n");

        line = line->next;

        if (i++ == n)
            break;
    }

    if (--i != n)
        pdb->file->list_line = 0;
    else
        pdb->file->list_line += n;
}

/*

=item C<void PDB_eval>

C<eval>s an instruction.

=cut

*/

void
PDB_eval(PARROT_INTERP, ARGIN(const char *command))
{
    /* This code is almost certainly wrong. The Parrot debugger needs love. */
    opcode_t *run = PDB_compile(interp, command);

    if (run)
        DO_OP(run, interp);
}

/*

=item C<opcode_t * PDB_compile>

Compiles instructions with the PASM compiler.

Appends an C<end> op.

This may be called from C<PDB_eval> above or from the compile opcode
which generates a malloced string.

=cut

*/

PARROT_CAN_RETURN_NULL
opcode_t *
PDB_compile(PARROT_INTERP, ARGIN(const char *command))
{
    STRING     *buf;
    const char *end      = "\nend\n";
    STRING     *key      = CONST_STRING(interp, "PASM");
    PMC *compreg_hash    = VTABLE_get_pmc_keyed_int(interp,
            interp->iglobals, IGLOBALS_COMPREG_HASH);
    PMC        *compiler = VTABLE_get_pmc_keyed_str(interp, compreg_hash, key);

    if (!VTABLE_defined(interp, compiler)) {
        fprintf(stderr, "Couldn't find PASM compiler");
        return NULL;
    }

    buf = Parrot_sprintf_c(interp, "%s%s", command, end);

    return VTABLE_invoke(interp, compiler, buf);
}

/*

=item C<static void dump_string>

Dumps the buflen, flags, bufused, strlen, and offset associated with a string
and the string itself.

=cut

*/

static void
dump_string(PARROT_INTERP, ARGIN_NULLOK(const STRING *s))
{
    if (!s)
        return;

    PIO_eprintf(interp, "\tBuflen  =\t%12ld\n", PObj_buflen(s));
    PIO_eprintf(interp, "\tFlags   =\t%12ld\n", PObj_get_FLAGS(s));
    PIO_eprintf(interp, "\tBufused =\t%12ld\n", s->bufused);
    PIO_eprintf(interp, "\tStrlen  =\t%12ld\n", s->strlen);
    PIO_eprintf(interp, "\tOffset  =\t%12ld\n",
                    (char*) s->strstart - (char*) PObj_bufstart(s));
    PIO_eprintf(interp, "\tString  =\t%S\n", s);
}

/*

=item C<void PDB_print>

Print interp registers.

=cut

*/

void
PDB_print(PARROT_INTERP, ARGIN(const char *command))
{
    const char * const s = GDB_P(interp->pdb->debugee, command);
    PIO_eprintf(interp, "%s\n", s);
}


/*

=item C<void PDB_info>

Print the interpreter info.

=cut

*/

void
PDB_info(PARROT_INTERP)
{
    PIO_eprintf(interp, "Total memory allocated = %ld\n",
            interpinfo(interp, TOTAL_MEM_ALLOC));
    PIO_eprintf(interp, "DOD runs = %ld\n",
            interpinfo(interp, DOD_RUNS));
    PIO_eprintf(interp, "Lazy DOD runs = %ld\n",
            interpinfo(interp, LAZY_DOD_RUNS));
    PIO_eprintf(interp, "Collect runs = %ld\n",
            interpinfo(interp, COLLECT_RUNS));
    PIO_eprintf(interp, "Collect memory = %ld\n",
            interpinfo(interp, TOTAL_COPIED));
    PIO_eprintf(interp, "Active PMCs = %ld\n",
            interpinfo(interp, ACTIVE_PMCS));
    PIO_eprintf(interp, "Extended PMCs = %ld\n",
            interpinfo(interp, EXTENDED_PMCS));
    PIO_eprintf(interp, "Timely DOD PMCs = %ld\n",
            interpinfo(interp, IMPATIENT_PMCS));
    PIO_eprintf(interp, "Total PMCs = %ld\n",
            interpinfo(interp, TOTAL_PMCS));
    PIO_eprintf(interp, "Active buffers = %ld\n",
            interpinfo(interp, ACTIVE_BUFFERS));
    PIO_eprintf(interp, "Total buffers = %ld\n",
            interpinfo(interp, TOTAL_BUFFERS));
    PIO_eprintf(interp, "Header allocations since last collect = %ld\n",
            interpinfo(interp, HEADER_ALLOCS_SINCE_COLLECT));
    PIO_eprintf(interp, "Memory allocations since last collect = %ld\n",
            interpinfo(interp, MEM_ALLOCS_SINCE_COLLECT));
}

/*

=item C<void PDB_help>

Print the help text. "Help" with no arguments prints a list of commands.
"Help xxx" prints information on command xxx.

=cut

*/

void
PDB_help(PARROT_INTERP, ARGIN(const char *command))
{
    unsigned long c;
    const DebuggerCmd *cmd;

    /* Extract the command after leading whitespace (for error messages). */
    const char * cmdline = skip_whitespace(command);
    parse_command(cmdline, &c);

    cmd = get_command(c);

    if (cmd) {
        PIO_eprintf(interp->pdb->debugger, "%s\n", cmd->help);
    }
    else {
        if (c == 0) {
            /* C89: strings need to be 509 chars or less */
            PIO_eprintf(interp->pdb->debugger, "\
List of commands:\n\
    disassemble  -- disassemble the bytecode\n\
    load         -- load a source code file\n\
    list     (l) -- list the source code file\n\
    run      (r) -- run the program\n\
    break    (b) -- add a breakpoint\n\
    script   (f) -- interprets a file as user commands\n\
    echo         -- toggle echo of script commands\n\
    watch    (w) -- add a watchpoint\n\
    delete   (d) -- delete a breakpoint\n\
    disable      -- disable a breakpoint\n\
    enable       -- reenable a disabled breakpoint\n\
    continue (c) -- continue the program execution\n");
            PIO_eprintf(interp->pdb->debugger, "\
    next     (n) -- run the next instruction\n\
    eval     (e) -- run an instruction\n\
    trace    (t) -- trace the next instruction\n\
    print    (p) -- print the interpreter registers\n\
    stack    (s) -- examine the stack\n\
    info         -- print interpreter information\n\
    gcdebug      -- toggle gcdebug mode\n\
    quit     (q) -- exit the debugger\n\
    help     (h) -- print this help\n\n\
Type \"help\" followed by a command name for full documentation.\n\n");
        }
        else {
            PIO_eprintf(interp->pdb->debugger, "Unknown command: %s\n", command);
        }
    }
}

/*

=item C<void PDB_backtrace>

Prints a backtrace of the interp's call chain.

=cut

*/

void
PDB_backtrace(PARROT_INTERP)
{
    STRING           *str;
    PMC              *old       = PMCNULL;
    int               rec_level = 0;

    /* information about the current sub */
    PMC              *sub = interpinfo_p(interp, CURRENT_SUB);
    Parrot_Context   *ctx = CONTEXT(interp);

    if (!PMC_IS_NULL(sub)) {
        str = Parrot_Context_infostr(interp, ctx);
        if (str)
            PIO_eprintf(interp, "%Ss\n", str);
    }

    /* backtrace: follow the continuation chain */
    while (1) {
        Parrot_cont *sub_cont;
        sub = ctx->current_cont;

        if (!sub)
            break;

        sub_cont = PMC_cont(sub);

        if (!sub_cont)
            break;

        str = Parrot_Context_infostr(interp, sub_cont->to_ctx);

        if (!str)
            break;

        /* recursion detection */
        if (!PMC_IS_NULL(old) && PMC_cont(old) &&
            PMC_cont(old)->to_ctx->current_pc ==
            PMC_cont(sub)->to_ctx->current_pc &&
            PMC_cont(old)->to_ctx->current_sub ==
            PMC_cont(sub)->to_ctx->current_sub) {
                ++rec_level;
        }
        else if (rec_level != 0) {
            PIO_eprintf(interp, "... call repeated %d times\n", rec_level);
            rec_level = 0;
        }

        /* print the context description */
        if (rec_level == 0)
            PIO_eprintf(interp, "%Ss\n", str);

        /* get the next Continuation */
        ctx = PMC_cont(sub)->to_ctx;
        old = sub;

        if (!ctx)
            break;
    }

    if (rec_level != 0)
        PIO_eprintf(interp, "... call repeated %d times\n", rec_level);
}

/*
 * GDB functions
 *
 * GDB_P  gdb> pp $I0   print register I0 value
 *
 * RT46139 more, more
 */

/*

=item C<static const char* GDB_print_reg>

Used by GDB_P to convert register values for display.  Takes register
type and number as arguments.

Returns a pointer to the start of the string, (except for PMCs, which
print directly and return "").

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static const char*
GDB_print_reg(PARROT_INTERP, int t, int n)
{

    if (n >= 0 && n < CONTEXT(interp)->n_regs_used[t]) {
        switch (t) {
            case REGNO_INT:
                return string_from_int(interp, REG_INT(interp, n))->strstart;
            case REGNO_NUM:
                return string_from_num(interp, REG_NUM(interp, n))->strstart;
            case REGNO_STR:
                return REG_STR(interp, n)->strstart;
            case REGNO_PMC:
                /* prints directly */
                trace_pmc_dump(interp, REG_PMC(interp, n));
                return "";
            default:
                break;
        }
    }
    return "no such reg";
}

/*

=item C<static const char* GDB_P>

Used by PDB_print to print register values.  Takes a pointer to the
register name(s).

Returns "" or error message.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static const char*
GDB_P(PARROT_INTERP, ARGIN(const char *s))
{
    int t;
    char reg_type;

    /* Skip leading whitespace. */
    while (isspace((unsigned char)*s))
        s++;

    reg_type = (unsigned char) toupper((unsigned char)*s);
    switch (reg_type) {
        case 'I': t = REGNO_INT; break;
        case 'N': t = REGNO_NUM; break;
        case 'S': t = REGNO_STR; break;
        case 'P': t = REGNO_PMC; break;
        default: return "Need a register.";
    }
    if (! s[1]) {
        /* Print all registers of this type. */
        const int max_reg = CONTEXT(interp)->n_regs_used[t];
        int n;

        for (n = 0; n < max_reg; n++) {
            /* this must be done in two chunks because PMC's print directly. */
            PIO_eprintf(interp, "\n  %c%d = ", reg_type, n);
            PIO_eprintf(interp, "%s", GDB_print_reg(interp, t, n));
        }
        return "";
    }
    else if (s[1] && isdigit((unsigned char)s[1])) {
        const int n = atoi(s + 1);
        return GDB_print_reg(interp, t, n);
    }
    else
        return "no such reg";

}

/* RT #46141 move these to debugger interpreter
 */
static PDB_breakpoint_t *gdb_bps;

/*
 * GDB_pb   gdb> pb 244     # set breakpoint at opcode 244
 *
 * RT #46143 We can't remove the breakpoint yet, executing the next ins
 * most likely fails, as the length of the debug-brk stmt doesn't
 * match the old opcode
 * Setting a breakpoint will also fail, if the bytecode os r/o
 *
 */
/*

=item C<static int GDB_B>

Inserts a break-point into a table (which it creates if necessary).
Takes an instruction counter (?).

Currently unused.

Returns break-point count, or -1 if point is out of bounds.

=cut

*/

static int
GDB_B(PARROT_INTERP, ARGIN(const char *s)) {
    if ((unsigned long)s < 0x10000) {
        /* HACK alarm pb 45 is passed as the integer not a string */
        /* RT #46145 check if in bounds */
        opcode_t * const pc = interp->code->base.data + (unsigned long)s;
        PDB_breakpoint_t *bp, *newbreak;
        int nr;

        if (!gdb_bps) {
            nr             = 0;
            newbreak       = mem_allocate_typed(PDB_breakpoint_t);
            newbreak->prev = NULL;
            newbreak->next = NULL;
            gdb_bps        = newbreak;
        }
        else {
            /* create new one */
            for (nr = 0, bp = gdb_bps; ; bp = bp->next, ++nr) {
                if (bp->pc == pc)
                    return nr;

                if (!bp->next)
                    break;
            }

            ++nr;
            newbreak       = mem_allocate_typed(PDB_breakpoint_t);
            newbreak->prev = bp;
            newbreak->next = NULL;
            bp->next       = newbreak;
        }

        newbreak->pc = pc;
        newbreak->id = *pc;
        *pc          = PARROT_OP_trap;

        return nr;
    }

    return -1;
}

/*

=back

=head1 SEE ALSO

F<include/parrot/debugger.h>, F<src/pdb.c> and F<ops/debug.ops>.

=head1 HISTORY

=over 4

=item Initial version by Daniel Grunblatt on 2002.5.19.

=item Start of rewrite - leo 2005.02.16

The debugger now uses its own interpreter. User code is run in
Interp *debugee. We have:

  debug_interp->pdb->debugee->debugger
    ^                            |
    |                            v
    +------------- := -----------+

Debug commands are mostly run inside the C<debugger>. User code
runs of course in the C<debugee>.

=back

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
