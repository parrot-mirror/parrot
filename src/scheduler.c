/*
Copyright (C) 2007, The Perl Foundation.
$Id$

=head1 NAME

src/scheduler.c - The core routines for the concurrency scheduler

=head1 DESCRIPTION

Each interpreter has a concurrency scheduler element in its core struct. The
scheduler is responsible for receiveing, dispatching, and monitoring events,
exceptions, async I/O, and concurrent tasks (threads).

=cut

*/

#include "parrot/parrot.h"
#include "parrot/scheduler_private.h"

#include "pmc/pmc_scheduler.h"
#include "pmc/pmc_task.h"
#include "pmc/pmc_timer.h"

#include "scheduler.str"

#define CX_DEBUG 0

/* HEADERIZER HFILE: include/parrot/scheduler.h */

/* HEADERIZER BEGIN: static */

static void scheduler_process_messages(PARROT_INTERP,
    ARGMOD(PMC *scheduler))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*scheduler);

static void scheduler_process_wait_list(PARROT_INTERP,
    ARGMOD(PMC *scheduler))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*scheduler);

/* HEADERIZER END: static */

/*

=head2 Scheduler Interface Functions

Functions to interface with the concurrency scheduler.

=over 4

=item C<void Parrot_cx_init_scheduler>

Initalize the concurrency scheduler for the interpreter.

=cut

*/

void
Parrot_cx_init_scheduler(PARROT_INTERP)
{
    if (!interp->parent_interpreter) {
        PMC *scheduler;

        /* Add the very first interpreter to the list of interps. */
        pt_add_to_interpreters(interp, NULL);

        scheduler = pmc_new(interp, enum_class_Scheduler);
        scheduler = VTABLE_share_ro(interp, scheduler);

        interp->scheduler = scheduler;

    }
}

/*

=item C<void Parrot_cx_check_tasks>

If a wake request has been received, handle tasks.

=cut

*/

void
Parrot_cx_check_tasks(PARROT_INTERP, ARGMOD(PMC *scheduler))
{
    if (SCHEDULER_wake_requested_TEST(scheduler))
        Parrot_cx_handle_tasks(interp, interp->scheduler);
}

/*

=item C<void Parrot_cx_handle_tasks>

Handle the pending tasks in the scheduler's task list. Returns when there are
no more pending tasks. Returns 0 to terminate the scheduler runloop, or 1 to
continue the runloop.

=cut

*/

PARROT_API
void
Parrot_cx_handle_tasks(PARROT_INTERP, ARGMOD(PMC *scheduler))
{
    SCHEDULER_wake_requested_CLEAR(scheduler);
    Parrot_cx_refresh_task_list(interp, scheduler);

    while (VTABLE_get_integer(interp, scheduler) > 0) {
        PMC * const task = VTABLE_pop_pmc(interp, scheduler);
        if (!PMC_IS_NULL(task)) {
        PMC *type_pmc = VTABLE_get_attr_str(interp, task, CONST_STRING(interp, "type"));
        STRING *type = VTABLE_get_string(interp, type_pmc);

        if (string_equal(interp, type, CONST_STRING(interp, "callback")) == 0) {
            Parrot_cx_invoke_callback(interp, task);
        }
        else if (string_equal(interp, type, CONST_STRING(interp, "timer")) == 0) {
            Parrot_cx_timer_invoke(interp, task);
        }
        else if (string_equal(interp, type, CONST_STRING(interp, "event")) == 0) {
            PMC * const handler = Parrot_cx_find_handler_for_task(interp, task);
            if (!PMC_IS_NULL(handler)) {
                PMC * handler_sub =
                    VTABLE_get_attr_str(interp, handler, CONST_STRING(interp, "code"));
                Parrot_runops_fromc_args_event(interp, handler_sub,
                    "vPP", handler, task);
            }
        }
        else {
            real_exception(interp, NULL, EXCEPTION_INVALID_OPERATION,
                    "Unknown task type '%s'.\n", string_to_cstring(interp, type));
        }
        Parrot_cx_delete_task(interp, task);
        }

        /* If the scheduler was flagged to terminate, make sure you process all
         * tasks. */
        if (SCHEDULER_terminate_requested_TEST(scheduler))
            Parrot_cx_refresh_task_list(interp, scheduler);

    } /* end of pending tasks */

}

/*

=item C<void Parrot_cx_refresh_task_list>

Tell the scheduler to perform maintenance on its list of active tasks, checking
for completed timers or sleep events, sorting for priority, checking for
messages, etc.

=cut

*/

void
Parrot_cx_refresh_task_list(PARROT_INTERP, ARGMOD(PMC *scheduler))
{
    scheduler_process_wait_list(interp, scheduler);
    scheduler_process_messages(interp, scheduler);

    /* TODO: Sort the task list index */

    SCHEDULER_cache_valid_SET(scheduler);
    return;
}

/*

=item C<void Parrot_cx_runloop_wake>

Wake a sleeping scheduler runloop (generally called when new tasks are added to
the scheduler's task list).

=cut

*/

void
Parrot_cx_runloop_wake(PARROT_INTERP, ARGMOD(PMC *scheduler))
{
    enable_event_checking(interp);
    SCHEDULER_wake_requested_SET(scheduler);
}


/*

=item C<void Parrot_cx_runloop_end>

Schedule an event to terminate the scheduler runloop.

=cut

*/

PARROT_API
void
Parrot_cx_runloop_end(PARROT_INTERP)
{
      SCHEDULER_terminate_requested_SET(interp->scheduler);
      Parrot_cx_handle_tasks(interp, interp->scheduler);
}

/*

=item C<void Parrot_cx_schedule_task>

Add a task to scheduler's task list. Cannot be called across
interpreters/threads, must be called from within the interpreter's runloop.

=cut

*/

PARROT_API
void
Parrot_cx_schedule_task(PARROT_INTERP, ARGIN(PMC *task))
{
    if (interp->scheduler)
        VTABLE_push_pmc(interp, interp->scheduler, task);
    else
        real_exception(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "Scheduler was not initialized for this interpreter.\n");
}

/*

=item C<void Parrot_cx_schedule_timer>

Create a new timer event due at C<diff> from now, repeated at C<interval>
and running the passed C<sub>.

=cut

*/

PARROT_API
void
Parrot_cx_schedule_timer(PARROT_INTERP,
        ARGIN_NULLOK(STRING *type), FLOATVAL duration, FLOATVAL interval,
        INTVAL repeat, ARGIN_NULLOK(PMC *sub))
{
    PMC * const timer = pmc_new(interp, enum_class_Timer);

    VTABLE_set_number_keyed_int(interp, timer, PARROT_TIMER_NSEC, duration);
    VTABLE_set_number_keyed_int(interp, timer, PARROT_TIMER_INTERVAL, interval);
    VTABLE_set_integer_keyed_int(interp, timer, PARROT_TIMER_REPEAT, repeat);

    if (!PMC_IS_NULL(sub))
        VTABLE_set_pmc_keyed_int(interp, timer, PARROT_TIMER_HANDLER, sub);

    if (!STRING_IS_NULL(type))
        VTABLE_set_string_native(interp, timer, type);

    if (repeat && FLOAT_IS_ZERO(interval))
        VTABLE_set_number_keyed_int(interp, timer, PARROT_TIMER_INTERVAL, duration);

    Parrot_cx_schedule_task(interp, timer);
}

/*

=item C<void Parrot_cx_schedule_repeat>

Add a repeat task to scheduler's task list.

=cut

*/

PARROT_API
void
Parrot_cx_schedule_repeat(PARROT_INTERP, ARGIN(PMC *task))
{
    INTVAL repeat = VTABLE_get_integer_keyed_int(interp, task,
            PARROT_TIMER_REPEAT);
    FLOATVAL duration = VTABLE_get_number_keyed_int(interp, task,
            PARROT_TIMER_INTERVAL);
    if (repeat != 0) {
        PMC *repeat_task = VTABLE_clone(interp, task);
        VTABLE_set_number_keyed_int(interp, repeat_task, PARROT_TIMER_NSEC, duration);

        if (repeat > 0)
            VTABLE_set_integer_keyed_int(interp, repeat_task,
                PARROT_TIMER_REPEAT, repeat - 1);

        Parrot_cx_schedule_task(interp, repeat_task);
    }
}

/*

=item C<void Parrot_cx_schedule_callback>

Create a new callback event, with an argument for the call.

=cut

*/

PARROT_API
void
Parrot_cx_schedule_callback(PARROT_INTERP,
        ARGIN(PMC *user_data), ARGIN(char *ext_data))
{
    PMC *callback = pmc_new(interp, enum_class_Task);
    Parrot_Task * const task_struct = PARROT_TASK(callback);

    task_struct->type    = CONST_STRING(interp, "callback");
    task_struct->data    = user_data;
    task_struct->cb_data = ext_data;

    Parrot_cx_schedule_task(interp, callback);
}

/*

=item C<void Parrot_cx_request_suspend_for_gc>

Tell the scheduler to suspend for GC at the next safe pause.

=cut

*/

PARROT_API
void
Parrot_cx_request_suspend_for_gc(PARROT_INTERP)
{
#if CX_DEBUG
    fprintf(stderr, "requesting gc suspend [interp=%p]\n", interp);
#endif
    Parrot_cx_send_message(interp, CONST_STRING(interp, "suspend_for_gc"), PMCNULL);
}

/*

=item C<void Parrot_cx_delete_task>

Remove a task from the scheduler's task list.

=cut

*/

PARROT_API
void
Parrot_cx_delete_task(PARROT_INTERP, ARGIN(PMC *task))
{
    if (interp->scheduler) {
        const INTVAL tid = VTABLE_get_integer(interp, task);
        VTABLE_delete_keyed_int(interp, interp->scheduler, tid);
    }
    else
        real_exception(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "Scheduler was not initialized for this interpreter.\n");
}


/*

=item C<PMC * Parrot_cx_delete_suspend_for_gc>

Remove a message that would suspend GC from the message queue. (Provided for
backward compatibility in the threads implementation.)

=cut

*/

PARROT_API
PARROT_CAN_RETURN_NULL
PMC *
Parrot_cx_delete_suspend_for_gc(PARROT_INTERP)
{
    if (interp->scheduler) {
        Parrot_Scheduler * sched_struct = PARROT_SCHEDULER(interp->scheduler);
        INTVAL num_tasks, index;

#if CX_DEBUG
    fprintf(stderr, "called delete_suspend_for_gc\n");
#endif

#if CX_DEBUG
    fprintf(stderr, "locking msg_lock (delete) [interp=%p]\n", interp);
#endif
        LOCK(sched_struct->msg_lock);
        /* Search the task index for GC suspend tasks */
        num_tasks = VTABLE_elements(interp, sched_struct->messages);
        for (index = 0; index < num_tasks; index++) {
            PMC *message = VTABLE_get_pmc_keyed_int(interp, sched_struct->messages, index);
            if (!PMC_IS_NULL(message)
                    && string_equal(interp, VTABLE_get_string(interp, message),
                    CONST_STRING(interp, "suspend_for_gc")) == 0) {
                VTABLE_delete_keyed_int(interp, sched_struct->messages, index);
                UNLOCK(sched_struct->msg_lock);
                return message;
            }
        }
#if CX_DEBUG
    fprintf(stderr, "unlocking msg_lock (delete) [interp=%p]\n", interp);
#endif
        UNLOCK(sched_struct->msg_lock);

    }
    else
        real_exception(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "Scheduler was not initialized for this interpreter.\n");

    return PMCNULL;
}

/*

=item C<void Parrot_cx_add_handler>

Add a task handler to scheduler's list of handlers.

=cut

*/

PARROT_API
void
Parrot_cx_add_handler(PARROT_INTERP, ARGIN(PMC *handler))
{
    if (interp->scheduler)
        Parrot_PCCINVOKE(interp, interp->scheduler,
                CONST_STRING(interp, "add_handler"), "P->", handler);
    else
        real_exception(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "Scheduler was not initialized for this interpreter.\n");
    return;
}

/*

=back

=head2 Scheduler Message Interface Functions

Functions that are used to interface with the message queue in the concurrency
scheduler.

=over 4

=item C<void Parrot_cx_send_message>

Send a message to a scheduler in a different interpreter/thread.

=cut

*/

PARROT_API
void
Parrot_cx_send_message(PARROT_INTERP, ARGIN(STRING *messagetype), ARGIN_NULLOK(PMC *payload))
{
    if (interp->scheduler) {
        Parrot_Scheduler * sched_struct = PARROT_SCHEDULER(interp->scheduler);
        PMC *message = pmc_new(interp, enum_class_SchedulerMessage);
        VTABLE_set_string_native(interp, message, messagetype);
        message = VTABLE_share_ro(interp, message);

#if CX_DEBUG
    fprintf(stderr, "sending message[interp=%p]\n", interp);
#endif

#if CX_DEBUG
    fprintf(stderr, "locking msg_lock (send) [interp=%p]\n", interp);
#endif
        LOCK(sched_struct->msg_lock);
        VTABLE_push_pmc(interp, sched_struct->messages, message);
#if CX_DEBUG
    fprintf(stderr, "unlocking msg_lock (send) [interp=%p]\n", interp);
#endif
        UNLOCK(sched_struct->msg_lock);
        Parrot_cx_runloop_wake(interp, interp->scheduler);

    }

}

/*

=item C<void Parrot_cx_broadcast_message>

Send a message to the schedulers in all interpreters/threads linked to this
one.

=cut

*/

PARROT_API
void
Parrot_cx_broadcast_message(PARROT_INTERP, ARGIN(STRING *messagetype), ARGIN_NULLOK(PMC *data))
{
    UINTVAL i;
    LOCK(interpreter_array_mutex);
    for (i = 0; i < n_interpreters; ++i) {
        Parrot_Interp other_interp = interpreter_array[i];
        if (interp == other_interp)
            continue;
        Parrot_cx_send_message(other_interp, messagetype, data);
    }
    UNLOCK(interpreter_array_mutex);

}

/*

=back

=head2 Task Interface Functions

Functions that are used to interface with a specific task in the concurrency scheduler.

=over 4

=item C<PMC * Parrot_cx_find_handler_for_task>

Retrieve a handler appropriate to a given task. If the scheduler has no
appropriate handler, returns PMCNULL.

=cut

*/

PARROT_API
PARROT_CAN_RETURN_NULL
PMC *
Parrot_cx_find_handler_for_task(PARROT_INTERP, ARGIN(PMC *task))
{
    PMC *handler = PMCNULL;
#if CX_DEBUG
    fprintf(stderr, "searching for handler\n");
#endif

    if (interp->scheduler)
        Parrot_PCCINVOKE(interp, interp->scheduler,
                CONST_STRING(interp, "find_handler"), "P->P", task, &handler);
    else
        real_exception(interp, NULL, EXCEPTION_INVALID_OPERATION,
                "Scheduler was not initialized for this interpreter.\n");

#if CX_DEBUG
    fprintf(stderr, "done searching for handler\n");
#endif
    return handler;
}

/*

=item C<void Parrot_cx_timer_invoke>

Run the associated code block for a timer event, when the timer fires.

=cut

*/

void
Parrot_cx_timer_invoke(PARROT_INTERP, ARGIN(PMC *timer))
{
    Parrot_Timer * const timer_struct = PARROT_TIMER(timer);
#if CX_DEBUG
    fprintf(stderr, "current timer time: %f, %f\n",
                    timer_struct->birthtime + timer_struct->duration,
                    Parrot_floatval_time());
#endif
    if (!PMC_IS_NULL(timer_struct->codeblock)) {
        Parrot_runops_fromc_args_event(interp,
                timer_struct->codeblock, "v");
    }
}

/*

=item C<void Parrot_cx_invoke_callback>

Run the associated code block for a callback event.

=cut

*/

void
Parrot_cx_invoke_callback(PARROT_INTERP, ARGIN(PMC *callback))
{
    Parrot_Task * const task_struct = PARROT_TASK(callback);
    if (!PMC_IS_NULL(task_struct->data)) {
        Parrot_run_callback(interp, task_struct->data,
                task_struct->cb_data);
    }
}

/*

=back

=head2 Opcode Functions

Functions that are called from within opcodes, that take and return an
opcode_t* to allow for changing the code flow.

=over 4


=item C<opcode_t * Parrot_cx_schedule_sleep>

Add a sleep timer to the scheduler. This function is called by the C<sleep>
opcode.

=cut

*/

PARROT_API
PARROT_WARN_UNUSED_RESULT
PARROT_CAN_RETURN_NULL
opcode_t *
Parrot_cx_schedule_sleep(PARROT_INTERP, FLOATVAL time, ARGIN_NULLOK(opcode_t *next))
{
#if PARROT_HAS_THREADS
    Parrot_cond condition;
    Parrot_mutex lock;
    FLOATVAL timer_end = time + Parrot_floatval_time();
    struct timespec time_struct;

    /* Tell the scheduler runloop to wake, this is a good time to process
     * pending tasks. */
    Parrot_cx_runloop_wake(interp, interp->scheduler);

    /* Tell this thread to sleep for the requested time. */
    COND_INIT(condition);
    MUTEX_INIT(lock);
    LOCK(lock);
    time_struct.tv_sec = (time_t) timer_end;
    time_struct.tv_nsec = (long)((timer_end - time_struct.tv_sec)*1000.0f) *1000L*1000L;
    COND_TIMED_WAIT(condition, lock, &time_struct);
    UNLOCK(lock);
    COND_DESTROY(condition);
    MUTEX_DESTROY(lock);
#else
    /* A more primitive, platform-specific, non-threaded form of sleep. */
    Parrot_sleep((UINTVAL) ceil(time));
#endif
    return next;
}


/*

=back

=head2 Internal Functions

Functions that are only used within the scheduler.

=over 4

=item C<static void scheduler_process_wait_list>

Scheduler maintenance, scan the list of waiting tasks to see if any are ready
to become active tasks.

=cut

*/

static void
scheduler_process_wait_list(PARROT_INTERP, ARGMOD(PMC *scheduler))
{
    Parrot_Scheduler * sched_struct = PARROT_SCHEDULER(scheduler);
    INTVAL num_tasks, index;

    /* Sweep the wait list for completed timers */
    num_tasks = VTABLE_elements(interp, sched_struct->wait_index);
    for (index = 0; index < num_tasks; index++) {
        INTVAL tid = VTABLE_get_integer_keyed_int(interp, sched_struct->wait_index, index);
        if (tid > 0) {
            PMC *task = VTABLE_get_pmc_keyed_int(interp, sched_struct->task_list, tid);
            if (PMC_IS_NULL(task)) {
                /* Cleanup expired tasks. */
                VTABLE_set_integer_keyed_int(interp, sched_struct->wait_index, index, 0);
            }
            else {
                /* Move the timer to the active task list if the timer has
                 * completed. */
                FLOATVAL timer_end_time = VTABLE_get_number_keyed_int(interp,
                        task, PARROT_TIMER_NSEC);
                if (timer_end_time <= Parrot_floatval_time()) {
                    VTABLE_push_integer(interp, sched_struct->task_index, tid);
                    VTABLE_set_integer_keyed_int(interp, sched_struct->wait_index, index, 0);
                    Parrot_cx_schedule_repeat(interp, task);
                    SCHEDULER_cache_valid_CLEAR(scheduler);
                }
            }
        }
    }
}

/*

=over 4

=item C<static void scheduler_process_messages>

Scheduler maintenance, scan the list of messages sent from other schedulers and
take appropriate action on any received.

=cut

*/

static void
scheduler_process_messages(PARROT_INTERP, ARGMOD(PMC *scheduler))
{
    Parrot_Scheduler * sched_struct = PARROT_SCHEDULER(scheduler);
    PMC *message;

#if CX_DEBUG
    fprintf(stderr, "processing messages [interp=%p]\n", interp);
#endif

    while (VTABLE_elements(interp, sched_struct->messages) > 0) {
#if CX_DEBUG
    fprintf(stderr, "locking msg_lock (process) [interp=%p]\n", interp);
#endif
        LOCK(sched_struct->msg_lock);
        message = VTABLE_pop_pmc(interp, sched_struct->messages);
#if CX_DEBUG
    fprintf(stderr, "unlocking msg_lock (process) [interp=%p]\n", interp);
#endif
        UNLOCK(sched_struct->msg_lock);
        if (!PMC_IS_NULL(message)
                && string_equal(interp, VTABLE_get_string(interp, message),
                CONST_STRING(interp, "suspend_for_gc")) == 0) {
#if CX_DEBUG
    fprintf(stderr, "found a suspend, suspending [interp=%p]\n", interp);
#endif
            pt_suspend_self_for_gc(interp);
        }
    }

}

/*

=back

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
