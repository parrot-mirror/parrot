/*
Copyright: 2001-2006 The Perl Foundation.  All Rights Reserved.
$Id$

=head1 NAME

src/thread.c - Thread handling stuff

=head1 DESCRIPTION

Threads are created by creating new C<ParrotInterpreter> objects.

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include <assert.h>

static int running_threads;

void Parrot_really_destroy(int exit_code, void *interpreter);

/*

=item C<static PMC*
make_local_copy(Parrot_Interp interpreter, PMC *original)>

Create a local copy of the PMC if necessary. (No copy is made if it
is marked shared.)

=cut

*/

static PMC *
make_local_copy(Parrot_Interp interpreter, PMC *arg)
{
    PMC *ret_val;
    if (PMC_IS_NULL(arg)) {
        ret_val = PMCNULL;
    } else if (PObj_is_PMC_shared_TEST(arg)) { 
        ret_val = arg;
    } else {
        ret_val = VTABLE_clone(interpreter, arg);
    }
    return ret_val;
}


/*
=item C<static PMC *
make_local_args_copy(Parrot_Interp interpreter, PMC *args)>

Make a local copy of the corresponding array of arguments.

=cut
*/

static PMC *
make_local_args_copy(Parrot_Interp interpreter, Parrot_Interp old_interp, PMC *args)
{
    PMC *ret_val;
    INTVAL old_size;
    INTVAL i;

    if (PMC_IS_NULL(args)) {
        return PMCNULL;
    }

    old_size = VTABLE_get_integer(old_interp, args);
    
    /* XXX should this be a different type? */
    ret_val = pmc_new(interpreter, enum_class_FixedPMCArray);
    VTABLE_set_integer_native(interpreter, ret_val, old_size);
    
    for (i = 0; i < old_size; ++i) {
        PMC *copy;

        copy = make_local_copy(interpreter, 
                VTABLE_get_pmc_keyed_int(old_interp, args, i));

        VTABLE_set_pmc_keyed_int(interpreter, ret_val, i, copy); 
    }
    return ret_val;
}

/*

=item C<static void*
thread_func(void *arg)>

The actual thread function.

=cut

*/

static void*
thread_func(void *arg)
{
    PMC * const self = (PMC*) arg;
    UINTVAL tid;
    PMC *ret_val = NULL;
    PMC *sub;
    PMC *sub_arg;
    Parrot_exception exp;
    PMC *except_handler;


    Parrot_Interp interpreter = PMC_data(self);
    sub = PMC_struct_val(self);
    sub_arg = PMC_pmc_val(self);


    if (setjmp(exp.destination)) {
        Parrot_exception *except;
        /* caught exception */
        ret_val = PMCNULL;
        except = interpreter->exceptions;
        /* XXX what should we really do here */
        PIO_eprintf(interpreter,
            "Unhandled exception in thread with tid %d (message=%Ss, number=%d)\n",
            interpreter->thread_data->tid,
            except->msg,
            except->error);
    } else {
        /* run normally */
        push_new_c_exception_handler(interpreter, &exp);
        ret_val = Parrot_runops_fromc_args(interpreter, sub, "P@", sub_arg);
    }
    /*
     * thread is finito
     */
    LOCK(interpreter_array_mutex);
    interpreter->thread_data->state |= THREAD_STATE_FINISHED;
    tid = interpreter->thread_data->tid;
    if (interpreter != interpreter_array[tid]) {
        UNLOCK(interpreter_array_mutex);
        PANIC("thread finished: interpreter mismatch");
    }
    if (interpreter->thread_data->state & THREAD_STATE_DETACHED) {
        interpreter_array[tid] = NULL;
        Parrot_really_destroy(0, interpreter);
    }
    UNLOCK(interpreter_array_mutex);

    return ret_val;
}


/*

=back

=head2 Helper functions used also for running plain interpreters

=over 4

=item C<void
pt_clone_code(Parrot_Interp d, Parrot_Interp s)>

Copy/clone the packfile/code from interpreter C<s> to C<d>. All
resources are created in C<d>.

=cut

*/

void
pt_clone_code(Parrot_Interp d, const Parrot_Interp s)
{
    Interp_flags_SET(d, PARROT_EXTERN_CODE_FLAG);
    d->code = s->code;
    /* XXX FIXME should this be here or elsewhere? */
    CONTEXT(d->ctx)->constants = 
        d->code->const_table->constants; 
    Parrot_prepare_cs_for_interp(d);
}

/*

=item C<void
pt_thread_prepare_for_run(Parrot_Interp d, Parrot_Interp s)>

Setup code, and TODO ...

=cut

*/

void
pt_thread_prepare_for_run(Parrot_Interp d, Parrot_Interp s)
{
    pt_clone_code(d, s);
}

/*

=back

=head2 ParrotThread methods

=over 4

=item C<int
pt_thread_run(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)>

Run the C<*sub> PMC in a separate thread using interpreter in
C<*dest_interp>.

C<arg> should be an array of arguments for the subroutine.

=cut

*/

int
pt_thread_run(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)
{
    assert(dest_interp);
    Parrot_Interp interpreter = PMC_data(dest_interp);

    PMC * const parent = VTABLE_get_pmc_keyed_int(interp, interp->iglobals,
                IGLOBALS_INTERPRETER);

    /*
     * TODO check if thread flags are consistent
     */
    if (interp->flags & PARROT_THR_COPY_INTERP)
        clone_interpreter(dest_interp, parent);
    /*
     * TODO thread pools
     */

    pt_thread_prepare_for_run(interpreter, interp);

    PMC_struct_val(dest_interp) = sub;
    PMC_pmc_val(dest_interp) = make_local_args_copy(interpreter, interp, arg);

    /*
     * set regs according to pdd03
     */
    interpreter->current_object = dest_interp;
    /*
     * create a joinable thread
     */
    interpreter->thread_data->state = THREAD_STATE_JOINABLE;
    THREAD_CREATE_JOINABLE(interpreter->thread_data->thread,
            thread_func, dest_interp);
    return 0;
}

/*

=item C<int
pt_thread_run_1(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)>

Runs a type 1 thread. Nothing is shared, both interpreters are free
running without any communication.

=cut

*/

int
pt_thread_run_1(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)
{
    interp->flags |= PARROT_THR_TYPE_1;
    return pt_thread_run(interp, dest_interp, sub, arg);
}

/*

=item C<int
pt_thread_run_2(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)>

Runs a type 2 thread. No shared variables, threads are communicating by
sending messages.

=cut

*/

int
pt_thread_run_2(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)
{
    interp->flags |= PARROT_THR_TYPE_2;
    return pt_thread_run(interp, dest_interp, sub, arg);
}

/*

=item C<int
pt_thread_run_3(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)>

Run a type 3 thread. Threads may have shared variables and are managed
in a thread pool.

=cut

*/

int
pt_thread_run_3(Parrot_Interp interp, PMC* dest_interp, PMC* sub, PMC *arg)
{
    interp->flags |= PARROT_THR_TYPE_3;
    return pt_thread_run(interp, dest_interp, sub, arg);
}

/*

=item C<void
pt_thread_yield(void)>

Relinquishes hold on the processor.

=cut

*/

void
pt_thread_yield(void)
{
    YIELD;
}

/*

=item C<static Parrot_Interp
pt_check_tid(UINTVAL tid, const char *from)>

Helper function. Check if C<tid> is valid. The caller holds the mutex.
Returns the interpreter for C<tid>.

=cut

*/

static Parrot_Interp
pt_check_tid(UINTVAL tid, const char *from)
{
    if (tid >= n_interpreters) {
        UNLOCK(interpreter_array_mutex);
        internal_exception(1, "%s: illegal thread tid %d", from, tid);
    }
    if (tid == 0) {
        UNLOCK(interpreter_array_mutex);
        internal_exception(1, "%s: llegal thread tid %d (main)", from, tid);
    }
    if (!interpreter_array[tid]) {
        UNLOCK(interpreter_array_mutex);
        internal_exception(1, "%s: illegal thread tid %d - empty", from, tid);
    }
    return interpreter_array[tid];
}


/*

=item C<static void
mutex_unlock(void *arg)>

Unlocks the mutex C<*arg>.

=cut

*/

static void
mutex_unlock(void *arg)
{
    UNLOCK(*(Parrot_mutex*) arg);
}

/*

=item C<PMC*
pt_thread_join(Parrot_Interp parent, UINTVAL tid)>

Join (wait for) a joinable thread.

=cut

*/

PMC*
pt_thread_join(Parrot_Interp parent, UINTVAL tid)
{
    int state;
    Parrot_Interp interpreter;

    LOCK(interpreter_array_mutex);
    interpreter = pt_check_tid(tid, "join");
    if (interpreter == parent)
        do_panic(parent, "Can't join self", __FILE__, __LINE__);
    if (interpreter->thread_data->state == THREAD_STATE_JOINABLE ||
            interpreter->thread_data->state == THREAD_STATE_FINISHED) {
        PMC *retval = NULL;
        interpreter->thread_data->state |= THREAD_STATE_JOINED;
        UNLOCK(interpreter_array_mutex);
        JOIN(interpreter->thread_data->thread, retval);
        /*
         * we need to push a cleanup handler here: if cloning
         * of the retval fails (e.g. it's a NULLPMC) this lock
         * isn't released until eternity or someone hits ^C
         *
         * TODO This is needed for all places holding a lock for
         *      non-trivial tasks
         *      -leo
         * TODO remove that and replace it with proper exception
         *      handling, so that a failing clone in the parent
         *      just stops that thread
         *      -leo
         */
        LOCK(interpreter_array_mutex);
        CLEANUP_PUSH(mutex_unlock, &interpreter_array_mutex);

        if (retval) {
            PMC *parent_ret;
            /*
             * clone the PMC into caller, if its not a shared PMC
             * the PMC is not in the parents root set nor in the
             * stack so block DOD during clone
             * XXX should probably acquire the parent's interpreter mutex
             */
            Parrot_block_DOD(parent);
            parent_ret = make_local_copy(parent, retval);
            /* this PMC is living only in the stack of this currently
             * dying interpreter, so register it in parents DOD registry
             */
            dod_register_pmc(parent, parent_ret);
            Parrot_unblock_DOD(parent);
            retval = parent_ret;
        } else {
            retval = PMCNULL;
        }
        interpreter_array[tid] = NULL;
        running_threads--;
        if (Interp_debug_TEST(parent, PARROT_THREAD_DEBUG_FLAG))
            fprintf(stderr, "running threads %d\n", running_threads);
        Parrot_really_destroy(0, interpreter);
        CLEANUP_POP(1);
        /*
         * interpreter destruction is done - unregister the return
         * value, caller gets it now
         */
        if (retval)
            dod_unregister_pmc(parent, retval);
        return retval;
    }
    /*
     * when here thread was in wrong state
     */
    state = interpreter->thread_data->state;
    UNLOCK(interpreter_array_mutex);
    internal_exception(1, "join: illegal thread state %d tid %d",
            state, tid);
    return NULL;
}

/*

=item C<void
pt_join_threads(Parrot_Interp interpreter)>

Possibly wait for other running threads. This is called when destroying
C<interpreter>.

=cut

*/

void
pt_join_threads(Parrot_Interp interpreter)
{
    size_t i;

    /*
     * if no threads where started - fine
     */
    LOCK(interpreter_array_mutex);
    if (n_interpreters <= 1) {
        UNLOCK(interpreter_array_mutex);
        return;
    }
    /*
     * only the first interpreter waits for other threads
     */
    if (interpreter != interpreter_array[0]) {
        UNLOCK(interpreter_array_mutex);
        return;
    }

    for (i = 1; i < n_interpreters; ++i) {
        Parrot_Interp thread_interp = interpreter_array[i];
        if (thread_interp == NULL)
            continue;
        if (thread_interp->thread_data->state == THREAD_STATE_JOINABLE ||
            (thread_interp->thread_data->state & THREAD_STATE_FINISHED)) {

            void *retval = NULL;
            thread_interp->thread_data->state |= THREAD_STATE_JOINED;
            UNLOCK(interpreter_array_mutex);
            JOIN(thread_interp->thread_data->thread, retval);
            LOCK(interpreter_array_mutex);
        }
    }
    UNLOCK(interpreter_array_mutex);
    return;
}

/*

=item C<static Parrot_Interp
detach(UINTVAL tid)>

Helper for detach and kill.

Returns the interpreter, if it didn't finish yet.

=cut

*/

static Parrot_Interp
detach(UINTVAL tid)
{
    Parrot_Interp interpreter;

    LOCK(interpreter_array_mutex);
    interpreter = pt_check_tid(tid, "detach");
    /*
     * if interpreter is joinable, we detach em
     */
    if (interpreter->thread_data->state == THREAD_STATE_JOINABLE ||
            interpreter->thread_data->state == THREAD_STATE_FINISHED) {
        DETACH(interpreter->thread_data->thread);
        interpreter->thread_data->state |= THREAD_STATE_DETACHED;
        if (interpreter->thread_data->state & THREAD_STATE_FINISHED) {
            interpreter_array[tid] = NULL;
            Parrot_really_destroy(0, interpreter);
            interpreter = NULL;
        }
    }
    UNLOCK(interpreter_array_mutex);
    return interpreter;
}

/*

=item C<void
pt_thread_detach(UINTVAL tid)>

Detaches (make non-joinable) the thread.

=cut

*/

void
pt_thread_detach(UINTVAL tid)
{
    (void) detach(tid);
}

/*

=item C<void
pt_thread_kill(UINTVAL tid)>

Kills the thread.

=cut

*/

void
pt_thread_kill(UINTVAL tid)
{
    Parrot_Interp interpreter = detach(tid);

    if (interpreter) {
        /*
         * schedule a terminate event for that interpreter
         */
        Parrot_new_terminate_event(interpreter);
    }
}

/*

=back

=head2 Threaded interpreter book-keeping

=over 4

=item C<void
pt_add_to_interpreters(Parrot_Interp interpreter, Parrot_Interp new_interp)>

All threaded interpreters are stored in an array. Assumes that caller
holds LOCK.

=cut

*/

void
pt_add_to_interpreters(Parrot_Interp interpreter, Parrot_Interp new_interp)
{
    size_t i;

    if (!new_interp) {
        /*
         * Create an entry for the very first interpreter, event
         * handling needs it
         */
        assert(!interpreter_array);
        assert(n_interpreters == 0);

        interpreter_array = mem_sys_allocate(sizeof(Interp*));
        interpreter_array[0] = interpreter;
        n_interpreters = 1;
        
        /* XXX try to defer this until later */
        assert(interpreter == interpreter_array[0]);
        interpreter->thread_data =
            mem_sys_allocate_zeroed(sizeof(Thread_data));
        INTERPRETER_LOCK_INIT(interpreter);
        interpreter->thread_data->tid = 0;

        return;
    }
    
    
    new_interp->thread_data = mem_sys_allocate_zeroed(sizeof(Thread_data));
    INTERPRETER_LOCK_INIT(new_interp);
    running_threads++;
    if (Interp_debug_TEST(interpreter, PARROT_THREAD_DEBUG_FLAG))
        fprintf(stderr, "running threads %d\n", running_threads);
    /*
     * look for an empty slot
     */
    for (i = 0; i < n_interpreters; ++i) {
        if (interpreter_array[i] == NULL) {
            interpreter_array[i] = new_interp;
            new_interp->thread_data->tid = i;
            new_interp->thread_data->state = THREAD_STATE_NOT_STARTED;
            return;
        }
    }
    /*
     * need to resize
     */
    interpreter_array = mem_sys_realloc(interpreter_array,
            (n_interpreters + 1) * sizeof(Interp*));
    interpreter_array[n_interpreters] = new_interp;
    new_interp->thread_data->tid = n_interpreters;
    new_interp->thread_data->state = THREAD_STATE_NOT_STARTED;
    ++n_interpreters;
}

/*

=back

=head2 DOD Synchronization Functions

=over 4

=item C<void
pt_DOD_start_mark(Parrot_Interp interpreter)>

DOD is gonna start the mark phase. In the presence of shared PMCs, we
can only run one DOD run at a time because
C<< PMC->next_for_GC >> may be changed.

TODO - Have a count of shared PMCs and check it during DOD.

TODO - Evaluate, if a interpreter lock is cheaper, when C<dod_mark_ptr>
is updated.

=cut

*/

void
pt_DOD_start_mark(Parrot_Interp interpreter)
{
    /* if no other threads are running, we are safe */
    if (!running_threads)
        return;
    /*
     * TODO now check, if we are the owner of a shared memory pool
     * if yes:
     * - suspend all other threads by sending them a suspend event
     *   (or put a LOCK around updating the mark pointers)
     * - return and continue the mark phase
     * - then s. comments below
     */


    /*
     * we can't allow parallel running DODs both would mess with shared PMCs
     * next_for_GC pointers
     */
    LOCK(interpreter_array_mutex);
}

/*

=item C<void
pt_DOD_mark_root_finished(Parrot_Interp interpreter)>

DOD is finished for the root set.

=cut

*/

void
pt_DOD_mark_root_finished(Parrot_Interp interpreter)
{
    if (!running_threads)
        return;
    /*
     * TODO now check, if we are the owner of a shared memory pool
     * if yes:
     * - now run DOD_mark on all members of our pool
     * - if all shared PMCs are marked by all threads then
     *   - we can continue to free unused objects
     */
}

/*

=item C<void
pt_DOD_stop_mark(Parrot_Interp interpreter)>

DOD's mark phase is done.

=cut

*/

void
pt_DOD_stop_mark(Parrot_Interp interpreter)
{
    if (!running_threads)
        return;
    /*
     * normal operation can continue now
     *   - other threads may or not free unused objects then,
     *     depending on their resource statistics
     */
    UNLOCK(interpreter_array_mutex);
}

/*

=back

=head1 HISTORY

2003.12.18 leo initial rev

=head1 SEE ALSO

F<src/pmc/parrotinterpreter.pmc>, F<docs/dev/events.pod>.

=cut

*/

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
