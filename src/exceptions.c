/*
Copyright (C) 2001-2008, The Perl Foundation.
$Id$

=head1 NAME

src/exceptions.c - Exceptions

=head1 DESCRIPTION

Define the the core subsystem for exceptions.

=head2 Exception Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/exceptions.h"
#include "exceptions.str"

#ifdef PARROT_HAS_BACKTRACE
#  include <execinfo.h>
#  include <dlfcn.h>
#endif

/* HEADERIZER HFILE: include/parrot/exceptions.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static PMC * find_exception_handler(PARROT_INTERP, ARGIN(PMC *exception))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

#include <stdarg.h>

/*

=item C<PMC * Parrot_ex_build_exception>

Constructs a new exception object from the passed in arguments.

=cut

*/
PARROT_API
PARROT_CAN_RETURN_NULL
PMC *
Parrot_ex_build_exception(PARROT_INTERP, INTVAL severity,
        long error, ARGIN_NULLOK(STRING *msg))
{
    PMC *exception = pmc_new(interp, enum_class_Exception);

    VTABLE_set_integer_keyed_str(interp, exception,
            CONST_STRING(interp, "severity"), severity);
    VTABLE_set_integer_keyed_str(interp, exception,
            CONST_STRING(interp, "type"), error);
    if (msg)
        VTABLE_set_string_native(interp, exception, msg);

    return exception;
}

/*

=item C<static PMC * find_exception_handler>

Find the exception handler for C<exception>.

=cut

*/

PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
static PMC *
find_exception_handler(PARROT_INTERP, ARGIN(PMC *exception))
{
    PMC * const handler = Parrot_cx_find_handler_for_task(interp, exception);
    if (!PMC_IS_NULL(handler)) {
        return handler;
/*        PMC * handler_sub =
            VTABLE_get_attr_str(interp, handler, CONST_STRING(interp, "code"));
        Parrot_runops_fromc_args_event(interp, handler_sub,
            "vPP", handler, exception);
*/
    }
    else {
        STRING * const message = VTABLE_get_string(interp, exception);
        INTVAL exit_status = 1;
        const INTVAL severity = VTABLE_get_integer_keyed_str(interp,
                exception, CONST_STRING(interp, "severity"));

        /* flush interpreter output to get things printed in order */
        PIO_flush(interp, PIO_STDOUT(interp));
        PIO_flush(interp, PIO_STDERR(interp));

        if (interp->debugger) {
            PIO_flush(interp->debugger, PIO_STDOUT(interp->debugger));
            PIO_flush(interp->debugger, PIO_STDERR(interp->debugger));
        }

        if (string_equal(interp, message, CONST_STRING(interp, "")) == 1) {
                fprintf(stderr, "%s\n", string_to_cstring(interp, message));
                fflush(stderr); /* caution against output swap (with PDB_backtrace) */
                PDB_backtrace(interp);
        }
        else if (severity == EXCEPT_exit) {
            /* TODO: get exit status based on type */
            exit_status       = VTABLE_get_integer_keyed_str(interp,
                                exception, CONST_STRING(interp, "exit_code"));
            }
        else {
                fprintf(stderr, "No exception handler and no message\n");
                fflush(stderr); /* caution against output swap (with PDB_backtrace) */
                PDB_backtrace(interp);
        }


        /*
         * returning NULL from here returns resume address NULL to the
         * runloop, which will terminate the thread function finally
         *
         * RT #45917 this check should better be in Parrot_exit
         */
        if (interp->thread_data && interp->thread_data->tid) {
            /* we should probably detach the thread here */
            return NULL;
        }

        /*
         * only main should run the destroy functions - exit handler chain
         * is freed during Parrot_exit
         */
        Parrot_exit(interp, exit_status);
    }

}

/*

=item C<PMC* new_c_exception_handler>

Generate an exception handler, that catches PASM level exceptions inside
a C function. This could be a separate class too, for now just a private
flag bit is set.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CANNOT_RETURN_NULL
PMC*
new_c_exception_handler(PARROT_INTERP, ARGIN(Parrot_runloop *jp))
{
    PMC * const handler = pmc_new(interp, enum_class_Exception_Handler);
    /*
     * this flag denotes a C exception handler
     */
    PObj_get_FLAGS(handler) |= SUB_FLAG_C_HANDLER;
    VTABLE_set_pointer(interp, handler, jp);
    return handler;
}

/*

=item C<void push_new_c_exception_handler>

Pushes an new C exception handler onto the stack.

=cut

*/

PARROT_API
void
push_new_c_exception_handler(PARROT_INTERP, ARGIN(Parrot_runloop *jp))
{
    Parrot_cx_add_handler(interp, new_c_exception_handler(interp, jp));
}

/*

=item C<opcode_t * Parrot_ex_throw_from_op>

Runs the exception handler.

=cut

*/

PARROT_API
PARROT_CAN_RETURN_NULL
opcode_t *
Parrot_ex_throw_from_op(PARROT_INTERP, ARGIN(PMC *exception), SHIM(void *dest))
{
    opcode_t *address;
    PMC * const handler = find_exception_handler(interp, exception);

    if (!handler)
        return NULL;

    /* put the handler aka continuation ctx in the interpreter */
    address    = VTABLE_invoke(interp, handler, exception);

    /* address = VTABLE_get_pointer(interp, handler); */
    if (PObj_get_FLAGS(handler) & SUB_FLAG_C_HANDLER) {
        /* its a C exception handler */
        Parrot_runloop * const jump_point = (Parrot_runloop *) address;
        longjmp(jump_point->resume, 1);
    }

    /* return the address of the handler */
    return address;
}

/*

=item C<void Parrot_ex_throw_from_c_args>

Throws a real exception, with an error message constructed from the format
string and arguments.  C<ret_addr> is the address from which to resume, if some
handler decides that is appropriate, or zero to make the error non-resumable.
C<exitcode> is a C<exception_type_enum> value.

See also C<exit_fatal()>, which signals fatal errors, and
C<Parrot_ex_throw_from_op>, which calls the handler.

The 'invoke' vtable function doesn't actually execute a
sub/continuation/handler, it only sets up the environment for invocation and
returns the address of the start of the sub's code. That address then becomes
the next op in the runloop.

When the handler is a sub, it can be invoked in its own runloop with
C<Parrot_runops_fromc_args>.

But when the handler is a continuation taken in the current runloop, the
control flow needs to reroute to a point in the runloop where a new op can be
cleanly executed.  Since exceptions thrown from C code may be buried within an
arbitrary number of C subroutine calls, the most direct way to do this (and to
ensure that no further code runs before the exception is handled) is to use a
C<setjmp> at the relevant location in the runloop, and a C<longjmp> to jump
back to that location. This is not ideal, as C<setjmp>/C<longjmp> are known to
be problematic when compiling under C++. One possible refinement might be to
use C++'s exception mechanism for this transfer of control instead of
C<setjmp>/C<longjmp> when compiling with C++ (using ifdefs).

Exceptions thrown from C and caught by a continuation-based handler are not
resumable at the level of a C instruction, as control is irrevocably
transferred back to the runloop. These exceptions can resume at the Parrot op
level, if they are given an C<opcode_t> pointer for the op to resume at.

Ultimately, we will likely want to deprecate continuation-based exception
handlers.

=cut

*/

PARROT_API
PARROT_DOES_NOT_RETURN
void
Parrot_ex_throw_from_c_args(PARROT_INTERP, ARGIN_NULLOK(void *ret_addr),
        int exitcode, ARGIN(const char *format), ...)
{
    RunProfile * const profile = interp->profile;
    STRING *msg = NULL;
    PMC *exception;

    /* Make and set exception message. */
    if (strchr(format, '%')) {
        va_list arglist;
        va_start(arglist, format);
        msg = Parrot_vsprintf_c(interp, format, arglist);
        va_end(arglist);
    }
    else
        msg = string_make(interp, format, strlen(format),
                NULL, PObj_external_FLAG);

    exception = Parrot_ex_build_exception(interp,
            EXCEPT_error, exitcode, msg);

    if (PMC_IS_NULL(exception)) {
        PIO_eprintf(interp,
            "Parrot_ex_throw_from_c_args (severity:%d error:%d): %Ss\n",
            EXCEPT_error, exitcode, msg);

        /* [what if exitcode is a multiple of 256?] */
        exit(exitcode);
    }

    /* The exception will be retrieved from the scheduler after jumping back to
     * a point in the runloop where the exception handler can be run. */
    Parrot_cx_schedule_task(interp, exception);

    /* If profiling remember end time of lastop and generate entry for
     * exception. */
    if (profile && Interp_flags_TEST(interp, PARROT_PROFILE_FLAG)) {
        const FLOATVAL now = Parrot_floatval_time();

        profile->data[profile->cur_op].time += now - profile->starttime;
        profile->cur_op                      = PARROT_PROF_EXCEPTION;
        profile->starttime                   = now;
        profile->data[PARROT_PROF_EXCEPTION].numcalls++;
    }

    if (Interp_debug_TEST(interp, PARROT_BACKTRACE_DEBUG_FLAG)) {
        PIO_eprintf(interp,
            "Parrot_ex_throw_from_c_args (severity:%d error:%d): %Ss\n",
            EXCEPT_error, exitcode, msg);
        PDB_backtrace(interp);
    }

    /* Jump to a point in the runloop where the handler can be run. */
    longjmp(interp->current_runloop->resume, 1);
}

/*

=item C<void do_exception>

Called from interrupt code. Does a C<longjmp> in front of the runloop, which
calls C<Parrot_ex_calc_handler_offset()>, returning the handler address where
execution then resumes.

=cut

*/

PARROT_API
PARROT_DOES_NOT_RETURN
void
do_exception(PARROT_INTERP, INTVAL severity, long error)
{
    PMC *exception = Parrot_ex_build_exception(interp,
            severity, error, NULL);
    Parrot_cx_schedule_task(interp, exception);

    longjmp(interp->current_runloop->resume, 1);
}


/*

=item C<opcode_t * rethrow_exception>

Rethrow the exception.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
opcode_t *
rethrow_exception(PARROT_INTERP, ARGIN(PMC *exception))
{
    PMC *handler;
    opcode_t *address;

    if (exception->vtable->base_type != enum_class_Exception)
        PANIC(interp, "Illegal rethrow");
    handler = find_exception_handler(interp, exception);
    if (!handler)
        PANIC(interp, "No exception handler found");
    address = VTABLE_invoke(interp, handler, exception);
    /* return the address of the handler */
    return address;
}

/*

=item C<void rethrow_c_exception>

Return back to runloop, assumes exception is still in todo (see RT #45915) and
that this is called from within a handler setup with C<new_c_exception>.

=cut

*/

PARROT_DOES_NOT_RETURN
void
rethrow_c_exception(PARROT_INTERP)
{
    PMC *exception = VTABLE_pop_pmc(interp, interp->scheduler);
    /* RT # 45911 Mark that the current exception was not handled */

    longjmp(interp->current_runloop->resume, 1);
}

/*

=item C<size_t Parrot_ex_calc_handler_offset>

Retrieve an exception from the concurrency scheduler, prepare a call to the
handler, and return the offset to the handler so it can become the next op in
the runloop.

=cut

*/

PARROT_API
size_t
Parrot_ex_calc_handler_offset(PARROT_INTERP)
{
    PMC *exception = VTABLE_pop_pmc(interp, interp->scheduler);

    /* now fill rest of exception, locate handler and get
     * destination of handler */
    opcode_t *handler_address = Parrot_ex_throw_from_op(interp, exception, NULL);

    if (!handler_address)
        PANIC(interp, "Unable to calculate opcode address for exception handler");

    /* return the *offset* of the handler */
    return handler_address - interp->code->base.data;
}

/*

=back

=head2 Error Functions

=over 4

=item C<void Parrot_assert>

A better version of assert() that gives a backtrace.

=cut

*/

PARROT_API
PARROT_DOES_NOT_RETURN_WHEN_FALSE
void
Parrot_assert(INTVAL condition, ARGIN(const char *condition_string),
        ARGIN(const char *file), unsigned int line)
{
    if (!condition)
        Parrot_confess(condition_string, file, line);
}

/*

=item C<void Parrot_confess>

Prints a backtrace and message for a failed assertion.

=cut

*/

PARROT_API
PARROT_DOES_NOT_RETURN
void
Parrot_confess(ARGIN(const char *cond), ARGIN(const char *file), unsigned int line)
{
    fprintf(stderr, "%s:%u: failed assertion '%s'\n", file, line, cond);
    Parrot_print_backtrace();
    abort();
}

/*

=item C<void Parrot_print_backtrace>

Displays the primrose path to disaster, (the stack frames leading up to the
abort).  Used by C<Parrot_confess>.

=cut

*/

void
Parrot_print_backtrace(void)
{
#ifdef PARROT_HAS_BACKTRACE
#  define BACKTRACE_DEPTH 32
/*#  define BACKTRACE_VERBOSE */
    /* stolen from http://www.delorie.com/gnu/docs/glibc/libc_665.html */
    void *array[BACKTRACE_DEPTH];
    size_t i;

    const size_t size = backtrace(array, BACKTRACE_DEPTH);
    char ** const strings;

    fprintf(stderr,
            "Backtrace - Obtained %zd stack frames (max trace depth is %d).\n",
            size, BACKTRACE_DEPTH);
#  ifndef BACKTRACE_VERBOSE
    for (i = 0; i < size; i++) {
        Dl_info frameInfo;
        int found;

        /* always indent */
        const int indent = 2 + (2*i);

        fprintf(stderr, "%*s", indent, "");
        found = dladdr(array[i], &frameInfo);
        if (0 == found || NULL == frameInfo.dli_sname) {
            fprintf(stderr, "(unknown)\n");
        }
        else {
            fprintf(stderr, "%s\n", frameInfo.dli_sname);
        }
    }
#  else
    strings = backtrace_symbols(array, size);
    for (i = 0; i < size; i++)
        fprintf(stderr, "%s\n", strings[i]);

    mem_sys_free(strings);
#  endif

#  undef BACKTRACE_DEPTH
#endif /* ifdef PARROT_HAS_BACKTRACE */
}

/*

=item C<void exit_fatal>

Signal a fatal error condition.  This should only be used with dire errors that
cannot throw an exception (because no interpreter is available, or the nature
of the error would interfere with the exception system).

This involves printing an error message to stderr, and calling C<exit> to exit
the process with the given exitcode. It is not possible for Parrot bytecode to
intercept a fatal error (for that, use C<Parrot_ex_throw_from_c_args>).
C<exit_fatal> does not call C<Parrot_exit> to invoke exit handlers (that would
require an interpreter).

=cut

*/

PARROT_API
PARROT_DOES_NOT_RETURN
void
exit_fatal(int exitcode, ARGIN(const char *format), ...)
{
    va_list arglist;
    va_start(arglist, format);
    vfprintf(stderr, format, arglist);
    fprintf(stderr, "\n");
    /* caution against output swap (with PDB_backtrace) */
    fflush(stderr);
    va_end(arglist);
    exit(exitcode);
}

/* Panic handler */

#ifndef dumpcore
#  define dumpcore() \
     fprintf(stderr, "Sorry, coredump is not yet implemented " \
             "for this platform.\n\n"); \
             exit(EXIT_FAILURE);
#endif

/*

=item C<void do_panic>

Panic handler.

=cut

*/

PARROT_DOES_NOT_RETURN
void
do_panic(NULLOK_INTERP, ARGIN_NULLOK(const char *message),
         ARGIN_NULLOK(const char *file), unsigned int line)
{
    /* Note: we can't format any floats in here--Parrot_sprintf
    ** may panic because of floats.
    ** and we don't use Parrot_sprintf or such, because we are
    ** already in panic --leo
    */
    fprintf(stderr, "Parrot VM: PANIC: %s!\n",
               message ? message : "(no message available)");

    fprintf(stderr, "C file %s, line %u\n",
               file ? file : "(not available)", line);

    fprintf(stderr, "Parrot file (not available), ");
    fprintf(stderr, "line (not available)\n");

    fprintf(stderr, "\n\
We highly suggest you notify the Parrot team if you have not been working on\n\
Parrot.  Use parrotbug (located in parrot's root directory) or send an\n\
e-mail to parrot-porters@perl.org.\n\
Include the entire text of this error message and the text of the script that\n\
generated the error.  If you've made any modifications to Parrot, please\n\
describe them as well.\n\n");

    fprintf(stderr, "Version     : %s\n", PARROT_VERSION);
    fprintf(stderr, "Configured  : %s\n", PARROT_CONFIG_DATE);
    fprintf(stderr, "Architecture: %s\n", PARROT_ARCHNAME);
    fprintf(stderr, "JIT Capable : %s\n", JIT_CAPABLE ? "Yes" : "No");
    if (interp)
        fprintf(stderr, "Interp Flags: %#x\n", (unsigned int)interp->flags);
    else
        fprintf(stderr, "Interp Flags: (no interpreter)\n");
    fprintf(stderr, "Exceptions  : %s\n", "(missing from core)");
    fprintf(stderr, "\nDumping Core...\n");

    dumpcore();
}


/*

=back

=head1 SEE ALSO

F<include/parrot/exceptions.h>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
