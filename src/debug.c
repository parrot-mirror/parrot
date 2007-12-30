/*
Copyright (C) 2001-2007, The Perl Foundation.
$Id$

=head1 NAME

src/debug.c - Parrot debugging

=head1 DESCRIPTION

This file implements Parrot debugging and is used by C<pdb>, the Parrot
debugger, and the C<debug> ops.

=head2 Functions

=over 4

=cut

*/

#include <stdio.h>
#include <stdlib.h>
#include "parrot/parrot.h"
#include "interp_guts.h"
#include "parrot/oplib.h"
#include "trace.h"
#include "parrot/debug.h"
#include "parrot/oplib/ops.h"


/* Not sure how we want to handle this sort of cross-project header */
PARROT_API
void
IMCC_warning(PARROT_INTERP, ARGIN(const char *fmt), ...);
extern void imcc_init(PARROT_INTERP);



/* HEADERIZER HFILE: include/parrot/debug.h */

/* HEADERIZER BEGIN: static */

static void dump_string(PARROT_INTERP, ARGIN_NULLOK(const STRING *s))
        __attribute__nonnull__(1);

static int GDB_B(PARROT_INTERP, NOTNULL(char *s))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static const char* GDB_P(PARROT_INTERP, ARGIN(const char *s))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static char const * nextarg(NOTNULL(char const *command))
        __attribute__nonnull__(1);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * parse_command(
    ARGIN(const char *command),
    NOTNULL(unsigned long *cmdP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * parse_int(ARGIN(const char *str), ARGOUT(int *intP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char* parse_key(PARROT_INTERP,
    ARGIN(const char *str),
    ARGOUT(PMC **keyP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * parse_string(PARROT_INTERP,
    ARGIN(const char *str),
    ARGOUT(STRING **strP))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_CANNOT_RETURN_NULL
static const char * skip_command(ARGIN(const char *str))
        __attribute__nonnull__(1);

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char * skip_ws(ARGIN(const char *str))
        __attribute__nonnull__(1);

/* HEADERIZER END: static */


/*

=item C<static char const * nextarg>

Returns the position just past the current argument in the PASM instruction
C<command>. This is not the same as C<skip_command()>, which is intended for
debugger commands. This function is used for C<eval>.

=cut

*/

PARROT_CAN_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static char const *
nextarg(NOTNULL(char const *command))
{
    /* as long as the character pointed to by command is not NULL,
     * and it is either alphanumeric, a comma or a closing bracket,
     * continue looking for the next argument.
     */
    while (*command && (isalnum((unsigned char) *command) || *command == ',' ||
        *command == ']'))
            command++;

    /* eat as much space as possible */
    while (*command && isspace((unsigned char) *command))
        command++;

    return command;
}

/*

=item C<static const char * skip_ws>

Returns the pointer past any whitespace.

=cut

*/

PARROT_CANNOT_RETURN_NULL
PARROT_WARN_UNUSED_RESULT
static const char *
skip_ws(ARGIN(const char *str))
{
    /* as long as str is not NULL and it contains space, skip it */
    while (*str && isspace((unsigned char) *str))
        str++;

    return str;
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
    while (*str && isspace((unsigned char) *str))
        str++;

    return str;
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
    *strP = string_make(interp, string_start, str - string_start, NULL, 0);

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
PARROT_WARN_UNUSED_RESULT
static const char *
parse_command(ARGIN(const char *command), NOTNULL(unsigned long *cmdP))
{
    int           i;
    unsigned long c = 0;

    if (*command == '\0') {
        *cmdP = c;
        return NULL;
    }

    for (i = 0; *command && isalpha((unsigned char) *command); command++, i++)
        c += (tolower((unsigned char) *command) + (i + 1)) * ((i + 1) * 255);

    /* Nonempty and did not start with a letter */
    if (c == 0)
        c = (unsigned long)-1;

    *cmdP = c;

    return command;
}

/*

=item C<void PDB_get_command>

Get a command from the user input to execute.

It saves the last command executed (in C<< pdb->last_command >>), so it
first frees the old one and updates it with the current one.

Also prints the next line to run if the program is still active.

The user input can't be longer than 255 characters.

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

    /* not used any more */
    if (pdb->last_command && *pdb->cur_command) {
        mem_sys_free(pdb->last_command);
        pdb->last_command = NULL;
    }

    /* update the last command */
    if (pdb->cur_command && *pdb->cur_command)
        pdb->last_command = pdb->cur_command;

    /* if the program is stopped and running show the next line to run */
    if ((pdb->state & PDB_STOPPED) && (pdb->state & PDB_RUNNING)) {
        PDB_line_t *line = pdb->file->line;

        while (pdb->cur_opcode != line->opcode)
            line = line->next;

        PIO_eprintf(interp, "%li  ", line->number);
        c = pdb->file->source + line->source_offset;

        while (c && (*c != '\n'))
            PIO_eprintf(interp, "%c", *(c++));
    }

    i = 0;

    /* RT#46109 who frees that */
    /* need to allocate 256 chars as string is null-terminated i.e. 255 + 1*/
    c = (char *)mem_sys_allocate(256);

    PIO_eprintf(interp, "\n(pdb) ");

    /* skip leading whitespace */
    do {
        ch = fgetc(stdin);
    } while (isspace((unsigned char)ch) && ch != '\n');

    /* generate string (no more than 255 chars) */
    while (ch != EOF && ch != '\n' && (i < 255)) {
        c[i++] = (char)ch;
        ch     = fgetc(stdin);
    }

    c[i] = '\0';

    if (ch == -1)
        strcpy(c, "quit");

    pdb->cur_command = c;
}

/*

=item C<void PDB_script_file>

Interprets the contents of a file as user input commands

=cut

*/

void
PDB_script_file(PARROT_INTERP, ARGIN(const char *command))
{
    char buf[1024];
    const char *ptr = (const char *)&buf;
    int line = 0;
    FILE *fd;

    command = nextarg(command);

    fd = fopen(command, "r");
    if (!fd) {
        IMCC_warning(interp, "script_file: "
            "Error reading script file %s.\n",
            command);
        return;
    }

    while (!feof(fd)) {
        line++;
        buf[0]='\0';
        fgets(buf, 1024, fd);

        /* skip spaces */
        for (ptr=(char *)&buf;*ptr&&isspace((unsigned char)*ptr);ptr=ptr+1);

        /* avoid null blank and commented lines */
        if (*buf == '\0' || *buf == '#')
            continue;

        buf[strlen(buf)-1]='\0';
        /* RT#46117: handle command error and print out script line
         *       PDB_run_command should return non-void value?
         *       stop execution of script if fails
         * RT#46115: avoid this verbose output? add -v flag? */
        if (PDB_run_command(interp, buf)) {
            IMCC_warning(interp, "script_file: "
                "Error interpreting command at line %d (%s).\n",
                line, command);
                break;
        }
    }
    fclose(fd);
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
    const char   * const original_command = command;

    /* keep a pointer to the command, in case we need to report an error */

    /* get a number from what the user typed */
    command = parse_command(original_command, &c);

    if (command)
        skip_command(command);
    else
        return 0;

    switch (c) {
        case c_script_file:
            PDB_script_file(interp, command);
            break;
        case c_disassemble:
            PDB_disassemble(interp, command);
            break;
        case c_load:
            PDB_load_source(interp, command);
            break;
        case c_l:
        case c_list:
            PDB_list(interp, command);
            break;
        case c_b:
        case c_break:
            PDB_set_break(interp, command);
            break;
        case c_w:
        case c_watch:
            PDB_watchpoint(interp, command);
            break;
        case c_d:
        case c_delete:
            PDB_delete_breakpoint(interp, command);
            break;
        case c_disable:
            PDB_disable_breakpoint(interp, command);
            break;
        case c_enable:
            PDB_enable_breakpoint(interp, command);
            break;
        case c_r:
        case c_run:
            PDB_init(interp, command);
            PDB_continue(interp, NULL);
            break;
        case c_c:
        case c_continue:
            PDB_continue(interp, command);
            break;
        case c_p:
        case c_print:
            PDB_print(interp, command);
            break;
        case c_n:
        case c_next:
            PDB_next(interp, command);
            break;
        case c_t:
        case c_trace:
            PDB_trace(interp, command);
            break;
        case c_e:
        case c_eval:
            PDB_eval(interp, command);
            break;
        case c_info:
            PDB_info(interp);
            break;
        case c_h:
        case c_help:
            PDB_help(interp, command);
            break;
        case c_q:
        case c_quit:
            pdb->state |= PDB_EXIT;
            break;
        case 0:
            if (pdb->last_command)
                PDB_run_command(interp, pdb->last_command);
            break;
        default:
            PIO_eprintf(interp,
                        "Undefined command: \"%s\".  Try \"help\".", original_command);
            return 1;
    }
    return 0;
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
    unsigned long  n   = 1;
    PDB_t  * const pdb = interp->pdb;

    /* Init the program if it's not running */
    if (!(pdb->state & PDB_RUNNING))
        PDB_init(interp, command);

    command = nextarg(command);
    /* Get the number of operations to execute if any */
    if (command && isdigit((unsigned char) *command))
        n = atol(command);

    /* Erase the stopped flag */
    pdb->state &= ~PDB_STOPPED;

    /* Execute */
    for (; n && pdb->cur_opcode; n--)
        DO_OP(pdb->cur_opcode, pdb->debugee);

    /* Set the stopped flag */
    pdb->state |= PDB_STOPPED;

    /* If program ended */

    /*
     * RT#46119 this doesn't handle resume opcodes
     */
    if (!pdb->cur_opcode)
        (void)PDB_program_end(interp);
}

/*

=item C<void PDB_trace>

Execute the next N operations; if no number is specified, it defaults to 1.

=cut

*/

void
PDB_trace(PARROT_INTERP, ARGIN_NULLOK(const char *command))
{
    unsigned long  n   = 1;
    PDB_t *  const pdb = interp->pdb;
    Interp        *debugee;

    /* if debugger is not running yet, initialize */
    if (!(pdb->state & PDB_RUNNING))
        PDB_init(interp, command);

    command = nextarg(command);
    /* if the number of ops to run is specified, convert to a long */
    if (command && isdigit((unsigned char) *command))
        n = atol(command);

    /* clear the PDB_STOPPED flag, we'll be running n ops now */
    pdb->state &= ~PDB_STOPPED;
    debugee     = pdb->debugee;

    /* execute n ops */
    for (; n && pdb->cur_opcode; n--) {
        trace_op(debugee,
                debugee->code->base.data,
                debugee->code->base.data +
                debugee->code->base.size,
                debugee->pdb->cur_opcode);
        DO_OP(pdb->cur_opcode, debugee);
    }

    /* we just stopped */
    pdb->state |= PDB_STOPPED;

    /* If program ended */
    if (!pdb->cur_opcode)
        (void)PDB_program_end(interp);
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
    int              i, reg_number;
    char             str[255];

    /* Return if no more arguments */
    if (!(command && *command)) {
        PIO_eprintf(interp, "No condition specified\n");
        return NULL;
    }

    /* Allocate new condition */
    condition = mem_allocate_typed(PDB_condition_t);

    switch (*command) {
        case 'i':
        case 'I':
            condition->type = PDB_cond_int;
            break;
        case 'n':
        case 'N':
            condition->type = PDB_cond_num;
            break;
        case 's':
        case 'S':
            condition->type = PDB_cond_str;
            break;
        case 'p':
        case 'P':
            condition->type = PDB_cond_pmc;
            break;
        default:
            PIO_eprintf(interp, "First argument must be a register\n");
            mem_sys_free(condition);
            return NULL;
    }

    /* get the register number */
    condition->reg = (unsigned char)atoi(++command);

    /* the next argument might have no spaces between the register and the
     * condition. */
    command++;

    /* RT#46121 Does /this/ have to do with the fact that PASM registers used to have
     * maximum of 2 digits? If so, there should be a while loop, I think.
     */
    if (condition->reg > 9)
        command++;

    if (*command == ' ')
        skip_command(command);

    /* Now the condition */
    switch (*command) {
        case '>':
            if (*(command + 1) == '=')
                condition->type |= PDB_cond_ge;
            else if (*(command + 1) == ' ')
                condition->type |= PDB_cond_gt;
            else
                goto INV_COND;
            break;
        case '<':
            if (*(command + 1) == '=')
                condition->type |= PDB_cond_le;
            else if (*(command + 1) == ' ')
                condition->type |= PDB_cond_lt;
            else
                goto INV_COND;
            break;
        case '=':
            if (*(command + 1) == '=')
                condition->type |= PDB_cond_eq;
            else
                goto INV_COND;
            break;
        case '!':
            if (*(command + 1) == '=')
                condition->type |= PDB_cond_ne;
            else
                goto INV_COND;
            break;
        default:
INV_COND:   PIO_eprintf(interp, "Invalid condition\n");
            mem_sys_free(condition);
            return NULL;
    }

    /* if there's an '=', skip it */
    if (*(command + 1) == '=')
        command += 2;
    else
        command++;

    if (*command == ' ')
        skip_command(command);

    /* return if no more arguments */
    if (!(command && *command)) {
        PIO_eprintf(interp, "Can't compare a register with nothing\n");
        mem_sys_free(condition);
        return NULL;
    }

    if (isalpha((unsigned char)*command)) {
        /* It's a register - we first check that it's the correct type */
        switch (*command) {
            case 'i':
            case 'I':
                if (!(condition->type & PDB_cond_int))
                    goto WRONG_REG;
                break;
            case 'n':
            case 'N':
                if (!(condition->type & PDB_cond_num))
                    goto WRONG_REG;
                break;
            case 's':
            case 'S':
                if (!(condition->type & PDB_cond_str))
                    goto WRONG_REG;
                break;
            case 'p':
            case 'P':
                if (!(condition->type & PDB_cond_pmc))
                    goto WRONG_REG;
                break;
            default:
WRONG_REG:      PIO_eprintf(interp, "Register types don't agree\n");
                mem_sys_free(condition);
                return NULL;
        }

        /* Now we check and store the register number */
        reg_number = (int)atoi(++command);

        if (reg_number < 0) {
            PIO_eprintf(interp, "Out-of-bounds register\n");
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
        for (i = 1; ((command[i] != '"') && (i < 255)); i++)
            str[i - 1] = command[i];
        str[i - 1] = '\0';
        condition->value = string_make(interp,
            str, i - 1, NULL, PObj_external_FLAG);
        condition->type |= PDB_cond_const;
    }
    else if (condition->type & PDB_cond_pmc) {
        /* RT#46123 Need to figure out what to do in this case.
         * For the time being, we just bail. */
        PIO_eprintf(interp, "Can't compare PMC with constant\n");
        mem_sys_free(condition);
        return NULL;
    }

    /* We're not part of a list yet */
    condition->next = NULL;

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
PDB_set_break(PARROT_INTERP, ARGIN(const char *command))
{
    PDB_t            * const pdb      = interp->pdb;
    PDB_breakpoint_t *newbreak = NULL;
    PDB_breakpoint_t *sbreak;
    PDB_condition_t  *condition;
    PDB_line_t       *line;
    long              i;

    command = nextarg(command);
    /* If no line number was specified, set it at the current line */
    if (command && *command) {
        const long ln = atol(command);

        /* Move to the line where we will set the break point */
        line = pdb->file->line;

        for (i = 1; ((i < ln) && (line->next)); i++)
            line = line->next;

        /* Abort if the line number provided doesn't exist */
        if (!line->next) {
            PIO_eprintf(interp,
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
                PIO_eprintf(interp,
                   "No current line found and no line number specified\n");
                return;
            }
        }
    }

    /* Skip lines that are not related to an opcode */
    while (!line->opcode)
        line = line->next;

    /* Allocate the new break point */
    newbreak = mem_allocate_typed(PDB_breakpoint_t);

    if (command) {
        skip_command(command);
    }
    else {
        real_exception(interp, NULL, 1, "NULL command passed to PDB_set_break");
    }
    condition = NULL;

    /* if there is another argument to break, besides the line number,
     * it should be an 'if', so we call another handler. */
    if (command && *command) {
        skip_command(command);
        if ((condition = PDB_cond(interp, command)))
            newbreak->condition = condition;
    }

    /* If there are no other arguments, or if there isn't a valid condition,
       then condition will be NULL */
    if (!condition)
        newbreak->condition = NULL;

    /* Set the address where to stop */
    newbreak->pc   = line->opcode;

    /* No next breakpoint */
    newbreak->next = NULL;

    /* Don't skip (at least initially) */
    newbreak->skip = 0;

    /* Add the breakpoint to the end of the list */
    i      = 0;
    sbreak = pdb->breakpoint;

    if (sbreak) {
        while (sbreak->next)
            sbreak = sbreak->next;

        newbreak->prev = sbreak;
        sbreak->next   = newbreak;
        i              = sbreak->next->id = sbreak->id + 1;
    }
    else {
        newbreak->prev  = NULL;
        pdb->breakpoint = newbreak;
        i               = pdb->breakpoint->id = 0;
    }

    PIO_eprintf(interp, "Breakpoint %li at line %li\n", i, line->number);
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
        PIO_eprintf(interp, "Restarting\n");

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
    PDB_t *pdb = interp->pdb;

    /* Skip any breakpoint? */
    if (command && *command) {
        long ln;
        if (!pdb->breakpoint) {
            PIO_eprintf(interp, "No breakpoints to skip\n");
            return;
        }

        command = nextarg(command);
        ln = atol(command);
        PDB_skip_breakpoint(interp, ln);
    }

    /* Run while no break point is reached */
    while (!PDB_break(interp))
        DO_OP(pdb->cur_opcode, pdb->debugee);
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
    command = nextarg(command);
    if (isdigit((unsigned char) *command)) {
        const long n = atol(command);
        PDB_breakpoint_t *breakpoint = interp->pdb->breakpoint;

        while (breakpoint && breakpoint->id != n)
            breakpoint = breakpoint->next;

        if (!breakpoint) {
            PIO_eprintf(interp, "No breakpoint number %ld", n);
            return NULL;
        }

        return breakpoint;
    }
    else {
        /* Report an appropriate error */
        if (*command)
            PIO_eprintf(interp, "Not a valid breakpoint");
        else
            PIO_eprintf(interp, "No breakpoint specified");

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
        PDB_line_t *line = interp->pdb->file->line;

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
PDB_delete_condition(SHIM_INTERP, NOTNULL(PDB_breakpoint_t *breakpoint))
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
PDB_skip_breakpoint(PARROT_INTERP, long i)
{
    interp->pdb->breakpoint_skip = i ? i-1 : i;
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

    PIO_eprintf(interp, "Program exited.\n");
    return 1;
}

/*

=item C<char PDB_check_condition>

Returns true if the condition was met.

=cut

*/

PARROT_WARN_UNUSED_RESULT
char
PDB_check_condition(PARROT_INTERP, NOTNULL(PDB_condition_t *condition))
{
    if (condition->type & PDB_cond_int) {
        INTVAL   i,  j;
        /*
         * RT#46125 verify register is in range
         */
        i = REG_INT(interp, condition->reg);

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

        k = REG_NUM(interp, condition->reg);

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

        m = REG_STR(interp, condition->reg);

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

    return 0;
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
    PDB_breakpoint_t *breakpoint = pdb->breakpoint;
    PDB_condition_t  *watchpoint = pdb->watchpoint;

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

    /* If we have to skip breakpoints, do so. */
    if (pdb->breakpoint_skip) {
        pdb->breakpoint_skip--;
        return 0;
    }

    while (breakpoint) {
        /* if we are in a break point */
        if (pdb->cur_opcode == breakpoint->pc) {
            if (breakpoint->skip < 0)
                return 0;

            /* Check if there is a condition for this breakpoint */
            if ((breakpoint->condition) &&
                (!PDB_check_condition(interp, breakpoint->condition)))
                    return 0;

            /* Add the STOPPED state and stop */
            pdb->state |= PDB_STOPPED;
            return 1;
        }
        breakpoint = breakpoint->next;
    }

    return 0;
}

/*

=item C<char * PDB_escape>

Escapes C<">, C<\r>, C<\n>, C<\t>, C<\a> and C<\\>.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
char *
PDB_escape(ARGIN(const char *string), INTVAL length)
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
PDB_unescape(NOTNULL(char *string))
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
PDB_disassemble_op(PARROT_INTERP, ARGOUT(char *dest), int space,
                   NOTNULL(op_info_t *info), NOTNULL(opcode_t *op),
                   NULLOK(PDB_file_t *file), NULLOK(opcode_t *code_start), int full_name)
{
    int         j;
    int         size = 0;

    /* Write the opcode name */
    const char * const p = full_name ? info->full_name : info->name;
    strcpy(dest, p);
    size += strlen(p);

    dest[size++] = ' ';

    /* Concat the arguments */
    for (j = 1; j < info->op_count; j++) {
        char      buf[256];
        INTVAL    i = 0;
        FLOATVAL  f;
        PMC      *k;

        PARROT_ASSERT(size + 2 < space);

        switch (info->types[j-1]) {
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
            if (j == 1 && info->types[j-1] == PARROT_ARG_IC
                && (strcmp(info->name, "infix") == 0
                    || strcmp(info->name, "n_infix") == 0)) {
                PARROT_ASSERT(size + 20 < space);

                size += sprintf(&dest[size], " [%s]",
                        /* [kludge: the "2+" skips the leading underscores.  --
                           rgr, 6-May-07.] */
                        2 + Parrot_MMD_method_name(interp, op[j]));
            }
            break;
        case PARROT_ARG_NC:
            /* Convert the float to a string */
            f = interp->code->const_table->constants[op[j]]->u.number;
            Parrot_snprintf(interp, buf, sizeof (buf), FLOATVAL_FMT, f);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            break;
        case PARROT_ARG_SC:
            dest[size++] = '"';
            if (interp->code->const_table->constants[op[j]]->
                    u.string->strlen)
            {
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
            dest[size-1] = '['; Parrot_snprintf(interp, buf, sizeof (buf),
                            "P" INTVAL_FMT, op[j]);
            strcpy(&dest[size], buf);
            size += strlen(buf);
            dest[size++] = ']';
            break;
        case PARROT_ARG_KC:
            dest[size-1] = '[';
            k            = interp->code->const_table->constants[op[j]]->u.key;
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
                        char *temp;
                        temp = string_to_cstring(interp, PMC_str_val(k));
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
            real_exception(interp, NULL, 1, "Unknown opcode type");
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
        const char *flag_names[] = { "",
                                     "",
                                     " :unused004",
                                     " :unused008",
                                     " :const",
                                     " :flat",	/* should be :slurpy for args */
                                     " :unused040",
                                     " :optional",
                                     " :opt_flag",
                                     " :named",
                                     NULL
        };
        /* Register decoding.  It would be good to abstract this, too. */
        const char *regs = "ISPN";

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
                   get too close to the end of buf. */
                while (flags && idx < sizeof (buf)-100) {
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
    PDB_t       *pdb = interp->pdb;
    PDB_file_t  *pfile;
    PDB_line_t  *pline, *newline;
    PDB_label_t *label;
    opcode_t    *code_end;
    opcode_t    *pc = interp->code->base.data;

    const unsigned int default_size = 32768;
    size_t space;  /* How much space do we have? */
    size_t size, alloced, n;

    pfile = mem_allocate_typed(PDB_file_t);
    pline = mem_allocate_typed(PDB_line_t);

    /* If we already got a source, free it */
    if (pdb->file)
        PDB_free_file(interp);

    pline->number        = 1;
    pline->label         = NULL;
    pfile->line          = pline;
    pfile->label         = NULL;
    pfile->size          = 0;
    pfile->source        = (char *)mem_sys_allocate(default_size);
    pline->source_offset = 0;

    alloced              = space = default_size;
    code_end             = pc + interp->code->base.size;

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

        if (!(pline)) {
            PIO_eprintf(interp,
                        "Label number %li out of bounds.\n", label->number);
            /* RT#46127: free allocated memory */
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
PDB_add_label(NOTNULL(PDB_file_t *file), NOTNULL(opcode_t *cur_opcode), opcode_t offset)
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
        PDB_line_t *line = file->line;
        PDB_label_t *label;
        PDB_file_t  *nfile;

        while (line) {
            PDB_line_t * const nline = line->next;
            mem_sys_free(line);
            line  = nline;
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

void
PDB_load_source(PARROT_INTERP, ARGIN(const char *command))
{
    FILE          *file;
    char           f[255];
    int            i, c;
    PDB_file_t    *pfile;
    PDB_line_t    *pline, *newline;
    PDB_t         *pdb  = interp->pdb;
    opcode_t      *pc   = pdb->cur_opcode;
    unsigned long  size = 0;

    /* If there was a file already loaded or the bytecode was
       disassembled, free it */
    if (pdb->file)
        PDB_free_file(interp);

    /* Get the name of the file */
    for (i = 0; command[i]; i++)
        f[i] = command[i];

    f[i] = '\0';

    /* open the file */
    file = fopen(f, "r");

    /* abort if fopen failed */
    if (!file) {
        PIO_eprintf(interp, "Unable to load %s\n", f);
        return;
    }

    pfile = mem_allocate_zeroed_typed(PDB_file_t);
    pline = mem_allocate_zeroed_typed(PDB_line_t);

    pfile->source = (char *)mem_sys_allocate(1024);
    pfile->line   = pline;
    pline->number = 1;

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
            if (PDB_hasinstruction(pfile->source + pline->source_offset)) {
                size_t n;
                pline->opcode = pc;
                n             = interp->op_info_table[*pc].op_count;
                ADD_OP_VAR_PART(interp, interp->code, pc, n);
                pc += n;
            }
            newline              = mem_allocate_zeroed_typed(PDB_line_t);
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
}

/*

=item C<char PDB_hasinstruction>

Return true if the line has an instruction.

RT#46129:

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
            /* this is a label. RT#46137 right? */
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
    long           line_number;
    unsigned long  i;
    PDB_line_t    *line;
    PDB_t         *pdb = interp->pdb;
    unsigned long  n   = 10;

    if (!pdb->file) {
        PIO_eprintf(interp, "No source file loaded\n");
        return;
    }

    command = nextarg(command);
    /* set the list line if provided */
    if (isdigit((unsigned char) *command)) {
        line_number = atol(command) - 1;
        if (line_number < 0)
            pdb->file->list_line = 0;
        else
            pdb->file->list_line = (unsigned long) line_number;

        skip_command(command);
    }
    else {
        pdb->file->list_line = 0;
    }

    /* set the number of lines to print */
    if (isdigit((unsigned char) *command)) {
        n = atol(command);
        skip_command(command);
    }

    /* if n is zero, we simply return, as we don't have to print anything */
    if (n == 0)
        return;

    line = pdb->file->line;

    for (i = 0; i < pdb->file->list_line && line->next; i++)
        line = line->next;

    i = 1;
    while (line->next) {
        PIO_eprintf(interp, "%li  ", pdb->file->list_line + i);
        /* If it has a label print it */
        if (line->label)
            PIO_eprintf(interp, "L%li:\t", line->label->number);

        c = pdb->file->source + line->source_offset;

        while (*c != '\n')
            PIO_eprintf(interp, "%c", *(c++));

        PIO_eprintf(interp, "\n");

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
    STRING     *key      = const_string(interp, "PASM");
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

=item C<int PDB_extend_const_table>

Extend the constant table.

=cut

*/

int
PDB_extend_const_table(PARROT_INTERP)
{
    int k = ++interp->code->const_table->const_count;

    /* Update the constant count and reallocate */
    if (interp->code->const_table->constants) {
        interp->code->const_table->constants =
            (PackFile_Constant **)mem_sys_realloc(interp->code->const_table->constants,
                            k * sizeof (PackFile_Constant *));
    }
    else {
        interp->code->const_table->constants =
            (PackFile_Constant **)mem_sys_allocate(k * sizeof (PackFile_Constant *));
    }

    /* Allocate a new constant */
    interp->code->const_table->constants[--k] =
        PackFile_Constant_new(interp);

    return k;
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

=item C<void PDB_print_user_stack>

Print an entry from the user stack.

=cut

*/

void
PDB_print_user_stack(PARROT_INTERP, ARGIN(const char *command))
{
    Stack_Entry_t *entry;
    long           depth = 0;
    Stack_Chunk_t * const chunk = CONTEXT(interp->ctx)->user_stack;

    command = nextarg(command);
    if (*command)
        depth = atol(command);

    entry = stack_entry(interp, chunk, (INTVAL)depth);

    if (!entry) {
        PIO_eprintf(interp, "No such entry on stack\n");
        return;
    }

    switch (entry->entry_type) {
        case STACK_ENTRY_INT:
            PIO_eprintf(interp, "Integer\t=\t%8vi\n", UVal_int(entry->entry));
            break;
        case STACK_ENTRY_FLOAT:
            PIO_eprintf(interp, "Float\t=\t%8.4vf\n", UVal_num(entry->entry));
            break;
        case STACK_ENTRY_STRING:
            PIO_eprintf(interp, "String =\n");
            dump_string(interp, UVal_str(entry->entry));
            break;
        case STACK_ENTRY_PMC:
            PIO_eprintf(interp, "PMC =\n%PS\n", UVal_ptr(entry->entry));
            break;
        case STACK_ENTRY_POINTER:
            PIO_eprintf(interp, "POINTER\n");
            break;
        case STACK_ENTRY_DESTINATION:
            PIO_eprintf(interp, "DESTINATION\n");
            break;
        default:
            PIO_eprintf(interp, "Invalid stack_entry_type!\n");
            break;
    }
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
    const char   *temp = command;

    command = parse_command(command, &c);

    switch (c) {
        case c_disassemble:
            PIO_eprintf(interp, "No documentation yet");
            break;
        case c_load:
            PIO_eprintf(interp, "No documentation yet");
            break;
        case c_list:
            PIO_eprintf(interp,
            "List the source code.\n\n\
Optionally specify the line number to begin the listing from and the number\n\
of lines to display.\n");
            break;
        case c_run:
            PIO_eprintf(interp,
            "Run (or restart) the program being debugged.\n\n\
Arguments specified after \"run\" are passed as command line arguments to\n\
the program.\n");
            break;
        case c_break:
            PIO_eprintf(interp,
"Set a breakpoint at a given line number (which must be specified).\n\n\
Optionally, specify a condition, in which case the breakpoint will only\n\
activate if the condition is met. Conditions take the form:\n\n\
           if [REGISTER] [COMPARISON] [REGISTER or CONSTANT]\n\n\
\
For example:\n\n\
           break 10 if I4 > I3\n\n\
           break 45 if S1 == \"foo\"\n\n\
The command returns a number which is the breakpoint identifier.");
            break;
        case c_script_file:
PIO_eprintf(interp, "Interprets a file.\n\
Usage:\n\
(pdb) script file.script\n");
            break;
        case c_watch:
            PIO_eprintf(interp, "No documentation yet");
            break;
        case c_delete:
            PIO_eprintf(interp,
"Delete a breakpoint.\n\n\
The breakpoint to delete must be specified by its breakpoint number.\n\
Deleted breakpoints are gone completely. If instead you want to\n\
temporarily disable a breakpoint, use \"disable\".\n");
            break;
        case c_disable:
            PIO_eprintf(interp,
"Disable a breakpoint.\n\n\
The breakpoint to disable must be specified by its breakpoint number.\n\
Disabled breakpoints are not forgotten, but have no effect until re-enabled\n\
with the \"enable\" command.\n");
            break;
        case c_enable:
            PIO_eprintf(interp, "Re-enable a disabled breakpoint.\n");
            break;
        case c_continue:
            PIO_eprintf(interp,
"Continue the program execution.\n\n\
Without arguments, the program runs until a breakpoint is found\n\
(or until the program terminates for some other reason).\n\n\
If a number is specified, then skip that many breakpoints.\n\n\
If the program has terminated, then \"continue\" will do nothing;\n\
use \"run\" to re-run the program.\n");
            break;
        case c_next:
            PIO_eprintf(interp,
"Execute a specified number of instructions.\n\n\
If a number is specified with the command (e.g. \"next 5\"), then\n\
execute that number of instructions, unless the program reaches a\n\
breakpoint, or stops for some other reason.\n\n\
If no number is specified, it defaults to 1.\n");
            break;
        case c_eval:
            PIO_eprintf(interp, "No documentation yet");
            break;
        case c_trace:
            PIO_eprintf(interp,
"Similar to \"next\", but prints additional trace information.\n\
This is the same as the information you get when running Parrot with\n\
the -t option.\n");
            break;
        case c_print:
            PIO_eprintf(interp, "Print register: e.g. p I2\n");
            break;
        case c_info:
            PIO_eprintf(interp,
                    "Print information about the current interpreter\n");
            break;
        case c_quit:
            PIO_eprintf(interp, "Exit the debugger.\n");
            break;
        case c_help:
            PIO_eprintf(interp, "Print a list of available commands.\n");
            break;
        case 0:
            /* C89: strings need to be 509 chars or less */
            PIO_eprintf(interp, "\
List of commands:\n\
    disassemble  -- disassemble the bytecode\n\
    load         -- load a source code file\n\
    list     (l) -- list the source code file\n\
    run      (r) -- run the program\n\
    break    (b) -- add a breakpoint\n\
    script   (f) -- interprets a file as user commands\n\
    watch    (w) -- add a watchpoint\n\
    delete   (d) -- delete a breakpoint\n\
    disable      -- disable a breakpoint\n\
    enable       -- reenable a disabled breakpoint\n\
    continue (c) -- continue the program execution\n");
            PIO_eprintf(interp, "\
    next     (n) -- run the next instruction\n\
    eval     (e) -- run an instruction\n\
    trace    (t) -- trace the next instruction\n\
    print    (p) -- print the interpreter registers\n\
    stack    (s) -- examine the stack\n\
    info         -- print interpreter information\n\
    quit     (q) -- exit the debugger\n\
    help     (h) -- print this help\n\n\
Type \"help\" followed by a command name for full documentation.\n\n");
            break;
        default:
            PIO_eprintf(interp, "Unknown command: \"%s\".", temp);
            break;
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
    parrot_context_t *ctx = CONTEXT(interp->ctx);

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

=item C<static const char* GDB_P>

RT#48260: Not yet documented!!!

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
static const char*
GDB_P(PARROT_INTERP, ARGIN(const char *s))
{
    int t, n;
    switch (*s) {
        case 'I': t = REGNO_INT; break;
        case 'N': t = REGNO_NUM; break;
        case 'S': t = REGNO_STR; break;
        case 'P': t = REGNO_PMC; break;
        default: return "no such reg";
    }
    if (s[1] && isdigit((unsigned char)s[1]))
        n = atoi(s + 1);
    else
        return "no such reg";

    if (n >= 0 && n < CONTEXT(interp->ctx)->n_regs_used[t]) {
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

/* RT#46141 move these to debugger interpreter
 */
static PDB_breakpoint_t *gdb_bps;

/*
 * GDB_pb   gdb> pb 244     # set breakpoint at opcode 244
 *
 * RT#46143 We can't remove the breakpoint yet, executing the next ins
 * most likely fails, as the length of the debug-brk stmt doesn't
 * match the old opcode
 * Setting a breakpoint will also fail, if the bytecode os r/o
 *
 */
/*

=item C<static int GDB_B>

RT#48260: Not yet documented!!!

=cut

*/

static int
GDB_B(PARROT_INTERP, NOTNULL(char *s)) {
    int               nr;
    opcode_t         *pc;
    PDB_breakpoint_t *bp, *newbreak;

    if ((unsigned long)s < 0x10000) {
        /* HACK alarm  pb 45 is passed as the integer not a string */
        /* RT#46145 check if in bounds */
        pc = interp->code->base.data + (unsigned long)s;

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

F<include/parrot/debug.h>, F<src/pdb.c> and F<ops/debug.ops>.

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
