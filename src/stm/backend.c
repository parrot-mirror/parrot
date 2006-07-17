#include <parrot/parrot.h>
#include <parrot/atomic.h>

/*
=head1 NAME

src/stm/backend.c -- Software transactional memory implementation

=head1 DESCRIPTION

This file implements the non-user-visible parts of the Software
Transactional Memory implementation, including handling of all
the low-level synchornization.

=head2 Functions

=over 4

=cut
*/


#include "stm_internal.h"

#define STM_DEBUG 0

#if STM_DEBUG
#  define STM_TRACE(x...) PIO_fprintf(interp, PIO_STDERR(interp), x); PIO_fprintf(interp, PIO_STDERR(interp), "\n")
#  define STM_TRACE_SAFE(x...) fprintf(stderr, x); fprintf(stderr, "\n");
#else
static void STM_TRACE(const char *x, ...) {
}
static void STM_TRACE_SAFE(const char *x, ...) {
}
#endif

static UINTVAL handle_is_version(Parrot_STM_PMC_handle data) {
    void *ptr;
    ATOMIC_PTR_GET(ptr, data->owner_or_version);
    return PTR2UINTVAL(ptr) & 1;
}

static STM_tx_log *Parrot_STM_tx_log_alloc(Interp *interp, size_t size) {
    int i;
    STM_tx_log *log;
    log = mem_sys_allocate_zeroed(size);

    interp->thread_data->stm_log = (void *) log;

    /* initialize the various fields of the transaction log */

    for (i = 0; i < STM_MAX_TX_DEPTH; ++i) {
        ATOMIC_INT_INIT(log->inner[i].status);
        ATOMIC_INT_INIT(log->inner[i].wait_length);
        ATOMIC_INT_SET(log->inner[i].status, STM_STATUS_INVALID);
        assert((PTR2UINTVAL(&log->inner[i]) & 1) == 0);
    }
    log->inner[0].first_read = log->inner[0].first_write = 0;

    log->writes = mem_sys_allocate(sizeof(STM_write_record) * STM_MAX_RECORDS);

    log->reads = mem_sys_allocate(sizeof(STM_read_record) * STM_MAX_RECORDS);

    log->last_read = log->last_write = -1;

    log->depth = 0;

    return log;
}

STM_tx_log *Parrot_STM_tx_log_get(Interp *interp) {
    STM_tx_log *log = interp->thread_data->stm_log; /* FIXME */
    if (!log) {
        log = Parrot_STM_tx_log_alloc(interp, sizeof(STM_tx_log));
    }

    assert(log->depth >= 0);

    return log;
}

typedef struct Parrot_STM_PMC_handle_data handle_data;

/*
=item C<Parrot_STM_PMC_handle Parrot_STM_alloc(Interp *interp, PMC *pmc)>

Create a new handle that will wrap a STM-managed PMC. The initial value
of the PMC will be a copy of C<pmc>.

=cut
*/
Parrot_STM_PMC_handle Parrot_STM_alloc(Interp *interp, PMC *pmc) {
    handle_data *handle;
    STM_TRACE("Parrot_STM_alloc");

    make_bufferlike_pool(interp, sizeof(handle_data));
    handle = new_bufferlike_header(interp, sizeof(handle_data));
    PObj_external_SET(&handle->buf);
    PObj_is_shared_SET(&handle->buf);
    ATOMIC_PTR_SET(handle->owner_or_version, UINTVAL2PTR(void *, 1)); /* XXX */
    handle->last_version = UINTVAL2PTR(void *, 1);
    handle->value = pmc; /* XXX make shared, make copy, with NULL handling */
    Parrot_STM_waitlist_init(interp, &handle->change_waitlist);
    return handle;
}

/* XXX FIXME these are just to make Parrot_clone work.
 * Real solution will require knowing when we are cloning
 * and when it is a normal freeze/thaw -- or implementing
 * cloning seperately.
 */
void Parrot_freeze_STM_PMC_handle(Interp *interp, IMAGE_IO *io, 
            Parrot_STM_PMC_handle handle) {
    io->vtable->push_pmc(interp, io, (PMC*) handle);
}

Parrot_STM_PMC_handle Parrot_thaw_STM_PMC_handle(Interp *interp, IMAGE_IO *io) {
    Parrot_STM_PMC_handle handle;
    handle = (Parrot_STM_PMC_handle) io->vtable->shift_pmc(interp, io);
    return handle;
}


static STM_write_record *get_write(Interp *interp, STM_tx_log *log, int i) {
    assert(i >= 0);
    assert(i <= log->last_write);
    return &log->writes[i];
}

static STM_read_record *get_read(Interp *interp, STM_tx_log *log, int i) {
    assert(i >= 0);
    assert(i <= log->last_read);
    return &log->reads[i];
}

/* alloc_write and alloc_read zero out the records so that if a GC run
 * occurs in the middle of them -- e.g. because a debugging function
 * triggered a string allocation -- then the transaction log may be
 * marked with the value uninitialized.
 */

static STM_write_record *alloc_write(Interp *interp, STM_tx_log *log) {
    STM_write_record *write;
    int i = ++log->last_write;
    if (i >= STM_MAX_RECORDS) {
        /* XXX FIXME resize instead */
        abort();
    }
    write = get_write(interp, log, i);
    write->value = NULL;
    return write;
}

static STM_read_record *alloc_read(Interp *interp, STM_tx_log *log) {
    STM_read_record *read;
    int i = ++log->last_read;
    if (i >= STM_MAX_RECORDS) {
        abort();
    }
    read = get_read(interp, log, i);
    read->value = NULL;
    return read;
}


static void *next_version(void *old_version) {
    UINTVAL v = PTR2UINTVAL(old_version);
    v += 2;
    return UINTVAL2PTR(void *, v);
}

static int is_version(void *maybe_version) {
    UINTVAL v = PTR2UINTVAL(maybe_version);
    return v & 1;
}

static STM_tx_log_sub *get_sublog(STM_tx_log *log, int i) {
    assert(i > 0);
    assert(i <= log->depth);
    return &log->inner[i - 1];
}

static int is_aborted(STM_tx_log *log) {
    int i;

    for (i = 1; i <= log->depth; ++i) {
        STM_tx_log_sub *sublog;
        int status;

        sublog = get_sublog(log, i);
        ATOMIC_INT_GET(status, sublog->status);
        if (status == STM_STATUS_ABORTED) {
            return 1;
        }
    }
    return 0;
}

/* 
=head1 C<Parrot_STM_start_transaction(Interp *interp)>

Start a new transaction for the interpreter C<interp>. If there is
already a transaction in progress, starts a nested transaction.

=cut
*/

void Parrot_STM_start_transaction(Interp *interp) {
    STM_tx_log *log = Parrot_STM_tx_log_get(interp);

    STM_tx_log_sub *newsub;

    ++log->depth;
    newsub = get_sublog(log, log->depth);
    ATOMIC_INT_SET(newsub->wait_length, 0);
    newsub->first_read = log->last_read + 1;
    newsub->first_write = log->last_write + 1;
    if (log->depth == 1) {
        assert(newsub->first_read == 0);
        assert(newsub->first_write == 0);
    }
    ATOMIC_INT_SET(newsub->status, STM_STATUS_ACTIVE);
    STM_TRACE("starting transaction, depth=%d", log->depth);
}

/*
 * To 'commit' an inner transaction, we merge it into the outer transaction.
 * In the process of doing this, we may detect that the inner transaction should
 * abort despite the outer transaction being safe. In that case, we can abort
 * the inner transaction by itself so long as the outer transaction reamins valid.
 *
 * FIXME "the outer transaction remains valid" logic is not yet handled
 */
static int merge_transactions(Interp *interp, STM_tx_log *log,
        STM_tx_log_sub *outer, STM_tx_log_sub *inner) {
    int i;
    int status;
    int need_abort = 0;

    ATOMIC_INT_GET(status, inner->status);
    if (status == STM_STATUS_ABORTED) {
        return 0;
    }

    for (i = inner->first_write; !need_abort && i <= log->last_write; ++i) {
        STM_write_record *write;
        int successp;

        write = get_write(interp, log, i);
        ATOMIC_PTR_CAS(successp, write->handle->owner_or_version, inner, outer);

        if (!successp) {
            need_abort = 1;
        }
    }

    ATOMIC_INT_GET(status, inner->status);
    if (status == STM_STATUS_ABORTED) {
        need_abort = 1;
    }

    if (need_abort) {
        /* unmerge, mark as aborted the outer transaction */
        for (i = inner->first_write; i <= log->last_write; ++i) {
            STM_write_record *write;
            int successp;

            write = get_write(interp, log, i);
            ATOMIC_PTR_CAS(successp, write->handle->owner_or_version, outer, inner);
            /* doesn't matter if it fails */
        }
        ATOMIC_INT_SET(outer->status, STM_STATUS_ABORTED);
        return 0;
    } else {
        return 1;
    }
}

static PMC *force_sharing(Interp *interp, PMC *pmc) {
    if (!PMC_IS_NULL(pmc)) {
        return VTABLE_share_ro(interp, pmc);
    } else {
        return PMCNULL;
    }
}

/* Returns the depth of the innermost transactions whose reads 
 * are all valid.
 */
static int
get_read_valid_depth(Interp *interp, STM_tx_log *log) {
    int i;
    int validp = 1;
    int cur_depth = 1;

    if (log->depth == 0) {
        return 0;
    }

    while (validp && cur_depth <= log->depth) {
        STM_tx_log_sub *current;
        int last_read;

        current = get_sublog(log, cur_depth);
        if (cur_depth == log->depth) {
            last_read = log->last_read;
        } else {
            last_read = get_sublog(log, cur_depth + 1)->first_read - 1;
        }

        for (i = current->first_read; i <= log->last_read; ++i) {
            STM_read_record *read;
            void *found_version;

            read = get_read(interp, log, i);

            ATOMIC_PTR_GET(found_version, read->handle->owner_or_version);
            if (found_version != read->saw_version) {
                STM_TRACE("verifying reads: got %p, expected %p", 
                    found_version, read->saw_version);
                if (is_version(found_version) 
                        || (STM_tx_log_sub*) found_version < log->inner 
                        || (STM_tx_log_sub*) found_version >= 
                            log->inner + STM_MAX_TX_DEPTH) {
                    validp = 0;
                    break;
                }
            }
        }
        ++cur_depth;
    }
    --cur_depth;
    return validp ? cur_depth : cur_depth - 1;
}

/* Does a top-level commit. Returns true if successful.
 * Inner transactions are committed by merge_transaction().
 */
static int
do_real_commit(Interp *interp, STM_tx_log *log) {
    int i;
    int successp;
    int can_update = 1;
    STM_tx_log_sub *inner;

    assert(log->depth == 1);

    inner = get_sublog(log, 1);

    ATOMIC_INT_CAS(successp, inner->status, STM_STATUS_ACTIVE, STM_STATUS_COMMITTED);
    if (!successp) {
        STM_TRACE("already aborted");
        return 0;
    }

    if (get_read_valid_depth(interp, log) == 0) {
        STM_TRACE("reads failed to verify");
        /* read contention; can't actually commit */
        ATOMIC_INT_SET(inner->status, STM_STATUS_ABORTED);
        return 0;
    }

    STM_TRACE("reads verified");
    for (i = inner->first_write; i <= log->last_write; ++i) {
        STM_write_record *write;
        int successp;
        void *new_version;

        write = get_write(interp, log, i);

        new_version = next_version(write->saw_version);
        write->value = force_sharing(interp, write->value);
        write->handle->last_version = new_version;
        write->handle->value = write->value; /* actually update */
        ATOMIC_PTR_CAS(successp, write->handle->owner_or_version, inner,
            new_version);
        STM_TRACE("wrote version %p into handle %p", new_version, write->handle);
        assert(successp); /* no one should steal our ownership when we are committed */

        Parrot_STM_waitlist_signal(interp, &write->handle->change_waitlist);
        STM_TRACE("done waitlist_signal");
    }
    STM_TRACE("%p: done committing", interp);

    log->last_write = -1;
    log->last_read = -1;

    return 1;
}


/* Set the specified transaction as aborted and unreserve
 * all the write records of it, but don't actually reset our
 * transaction log.
 */
static void
do_partial_abort(Interp *interp, STM_tx_log *log, STM_tx_log_sub *inner) {
    int i;

    STM_TRACE("partial abort");
    ATOMIC_INT_SET(inner->status, STM_STATUS_ABORTED);
    
    for (i = log->last_write; i >= inner->first_write; --i) {
        STM_write_record *write;
        int successp;

        write = get_write(interp, log, i);

        /* if it's not a version, an outer transaction has the 'real version' of this */
        ATOMIC_PTR_CAS(successp, write->handle->owner_or_version, inner,
            write->saw_version);
        /* it doesn't matter if this fails */
        STM_TRACE("unreserving write record %d [saw_version=%p]; successp=%d",
            i, write->saw_version, successp);
    }
}

/* Does an abort. This is also used for inner transactions. */
static void
do_real_abort(Interp *interp, STM_tx_log *log, STM_tx_log_sub *inner) {
    int i;

    STM_TRACE("really aborting");
    do_partial_abort(interp, log, inner);

    log->last_read = inner->first_read - 1;
    log->last_write = inner->first_write - 1;
}

/* Replay writes of a partial_abort'd transaction. 
 * 'from' is the depth of the outermost transaction to replay.
 * 'to' is the depth of the innermost transaction to replay.
 * Replays from outermost to innermost.
 * If replaying fails in the middle, the subtransaction in
 * question is re-partial-aborted.
 */
static void
replay_writes(Interp *interp, STM_tx_log *log, int from, int to) {
    int i;
    int validp = 1;
    int cur_depth = from;

    while (validp && cur_depth <= to) {
        STM_tx_log_sub *current;
        int last_write;
        current = get_sublog(log, cur_depth);
        if (cur_depth == log->depth) {
            last_write = log->last_write;
        } else {
            last_write = get_sublog(log, cur_depth + 1)->first_write - 1;
        }

        ATOMIC_INT_SET(current->status, STM_STATUS_ACTIVE);

        for (i = current->first_write; i <= last_write; ++i) {
            STM_write_record *write;
            int successp;

            write = get_write(interp, log, i);

            ATOMIC_PTR_CAS(successp, write->handle->owner_or_version,
                write->saw_version, current);
            
            if (!successp) {
                validp = 0;
                break;
            }
        }

        ++cur_depth;
    }

    --cur_depth;

    if (!validp) {
        do_partial_abort(interp, log, get_sublog(log, cur_depth));
    }
}

/*
=item C<int Parrot_STM_commit(Interp *interp)>

Tries to commit the currently active transaction. Returns true if the commit
succeeds. If it returns false, the transaction was aborted instead.

Throws an exception if there is no active transaction.

=cut
*/

int Parrot_STM_commit(Interp *interp) {
    STM_tx_log *log = Parrot_STM_tx_log_get(interp);
    STM_tx_log_sub *cursub;
    int successp;
    STM_TRACE("commit");


    if (log->depth == 0) {
        internal_exception(1, "stm_commit without transaction\n");
        return 0;
    }

    assert(log->depth > 0);

    cursub = get_sublog(log, log->depth);

    if (log->depth > 1) {
        successp = merge_transactions(interp, log,
            get_sublog(log, log->depth - 1), cursub);
    } else {
        successp = do_real_commit(interp, log);
    }

    if (!successp) {
        /* XXX FIXME check if outer transaction needs to abort;
         * if so, we need to pretend to commit the inner transaction
         * instead.
         */
        do_real_abort(interp, log, cursub);
    }
    --log->depth;
    return successp;
}

/*
=item C<void Parrot_STM_abort(Interp *interp)>

Aborts the currently active transaction.

Throws an exception if there is no active transaction.

=cut
*/

void Parrot_STM_abort(Interp *interp) {
    STM_tx_log *log = Parrot_STM_tx_log_get(interp);
    STM_tx_log_sub *cursub;
    STM_TRACE("abort");

    if (log->depth == 0) {
        internal_exception(1, "stm_abort without transaction\n");
        return;
    }

    assert(log->depth > 0);

    cursub = get_sublog(log, log->depth);

    do_real_abort(interp, log, cursub);
    --log->depth;
}

/* 
=item C<void Parrot_STM_wait(Interp *interp)>

Abort the currently active transaction, and then wait
for something the transaction was dependent on to change, including
any of the outer transactions becoming invalid. The caller is responsible
for verifying that any outer transaction is invalid after calling this.

(If it's not, then the retrying may never succeed.)

(Not yet implemented. Right now just aborts.)
=cut
*/

/* returns true if we still need to wait, false if we're already done. 
 * assumes transcation is _not_ yet aborted.
 */
static int setup_wait(Interp *interp, STM_tx_log *log) {
    int i;
    int need_wait = 1;
    STM_tx_log_sub *cursub;

    for (i = 0; need_wait && i <= log->last_read; ++i) {
        STM_read_record *read;
        void *version;
        read = get_read(interp, log, i);
        Parrot_STM_waitlist_add_self(interp, &read->handle->change_waitlist);
        ATOMIC_PTR_GET(version, read->handle->owner_or_version);
        if (version != read->saw_version && is_version(version)) {
            need_wait = 0;
        }
    }

    for (i = 0; need_wait && i <= log->last_write; ++i) {
        STM_write_record *write;
        write = get_write(interp, log, i);
        Parrot_STM_waitlist_add_self(interp, &write->handle->change_waitlist);
    }
    
    if (!need_wait) {
        Parrot_STM_waitlist_remove_all(interp);
    }

    return need_wait;
}



void Parrot_STM_wait(Interp *interp) {
    int i;
    STM_tx_log *log;
    int need_wait;

    STM_TRACE("%p: wait", interp);

    log = Parrot_STM_tx_log_get(interp);

    need_wait = setup_wait(interp, log);

    STM_TRACE("%p: done setup_wait; need_wait=%d", interp, need_wait);
    
    /* abort the most inner transaction completely */
    Parrot_STM_abort(interp);

    if (need_wait) {
        /* softly abort the rest so write reservations do not
         * impede progress
         */
        if (log->depth) {
            do_partial_abort(interp, log, get_sublog(log, 1));
        }

        STM_TRACE("%p: now entering waitlist wait", interp);

        /* actually wait */
        Parrot_STM_waitlist_wait(interp);
        
        Parrot_STM_waitlist_remove_all(interp);

        STM_TRACE("%p: done waitlist wait", interp);

        /* replay as much of the rest as we can get away */
        if (log->depth) {
            replay_writes(interp, log, 1, get_read_valid_depth(interp, log));
        }
    }
}

/*
=item C<int Parrot_STM_validate(Interp *interp)>

Return true if the currently active transaction might commit;
false otherwise. Always returns true in the special case of no
active transaction.

=cut
*/

int Parrot_STM_validate(Interp *interp) {
    STM_tx_log *log;
    STM_tx_log_sub *inner;
    int status;

    log = Parrot_STM_tx_log_get(interp);

    if (log->depth == 0) {
        return 1;
    }

    inner = get_sublog(log, log->depth);

    STM_TRACE("validate");

    ATOMIC_INT_GET(status, inner->status);

    /* XXX FIXME actually validate transaction */

    return status != STM_STATUS_ABORTED;
}

/*
=item C<int Parrot_STM_mark_transaction(Interp *interp)>

Mark items in our transaction log as living so the GC doesn't
collect them from us.

=cut
*/

void Parrot_STM_mark_transaction(Interp *interp) {
    int i;
    STM_tx_log *log;
    STM_TRACE("mark txlog");

    log = Parrot_STM_tx_log_get(interp);

    for (i = 0; i <= log->last_write; ++i) {
        PMC *value = get_write(interp, log, i)->value;
        if (value) 
            pobject_lives(interp, (PObj*) value);
    }

    for (i = 0; i <= log->last_read; ++i) {
        PMC *value = get_read(interp, log, i)->value;
        if (value)
            pobject_lives(interp, (PObj*) value);
    }
}

/*
=item C<void Parrot_STM_mark_pmc_handle(Interp *interp, Parrot_STM_PMC_handle handle)>

Mark items associated with the corresponding PMC handle as reachable so the GC
doesn't collect the handle or objects it refers to as reachable.

=cut
*/

void Parrot_STM_mark_pmc_handle(Interp *interp, Parrot_STM_PMC_handle handle) {
    PMC *value;
    if (!handle) {
        return;
    }
    STM_TRACE_SAFE("mark handle %p", handle);
    /* XXX FIXME is this enough? What about shared status? */
    pobject_lives(interp, (PObj*) handle);
    value = handle->value;
    if (!PMC_IS_NULL(value)) {
        pobject_lives(interp, (PObj*) value);
    }
}

/*
=item C<int Parrot_STM_transaction_depth(Interp *interp)>

Return the number of active transactions in this thread.

=cut
*/
int Parrot_STM_transaction_depth(Interp *interp) {
    STM_tx_log *log = Parrot_STM_tx_log_get(interp);

    return log->depth; 
}


/* Wait for C<*in_what> to contain a version number instead of
 * an owner indication of exclusive lock. (See also Ennals's
 * paper 'STM should not be obstruct-free.')
 *
 * This may mark us as aborted and return NULL.
 */
static void *wait_for_version(Interp *interp, 
        STM_tx_log *log, Parrot_STM_PMC_handle handle) {
    UINTVAL wait_count = 0;
    STM_tx_log_sub *curlog;
    Parrot_atomic_pointer *in_what = &handle->owner_or_version;
    void *version;
    STM_TRACE("%p: wait for version");
    Parrot_block_DOD(interp);
    for (;;) {
        unsigned other_wait_len;
        unsigned our_wait_len;
        STM_tx_log_sub *other;
        ATOMIC_PTR_GET(version, *in_what);
        if (is_version(version)) {
            if (wait_count) {
                ATOMIC_INT_SET(curlog->wait_length, 0);
            }
            break;
        }

        ++wait_count;

        /* poor man's deadlock detection:
         * wait_len = (whoever we are waiting on's wait_len) + 1
         * this means that if wait_len > num_threads, we have a deadlock
         *
         * This algorithm is borrowed from Ennals' implementation.
         * FIXME XXX look for better alternative (esp. one that'll let
         *           us do non-spinlocking?)
         * FIXME XXX race in accessing n_interpreters?
         * FIXME XXX race if other log goes away
         */
        assert(n_interpreters > 1);
        other = version;
        curlog = get_sublog(log, log->depth);
        ATOMIC_INT_GET(other_wait_len, other->wait_length);
        ATOMIC_INT_GET(our_wait_len, curlog->wait_length);
        STM_TRACE("wait_lens: ours = %d /other = %d\n", 
                our_wait_len, other_wait_len);
        if (our_wait_len < other_wait_len + 1) {
            our_wait_len = other_wait_len + 1;
            /* don't bother setting if we'll just abort ourselves */
            if (our_wait_len <= n_interpreters) {
                STM_TRACE("updating wait_len to %d\n", our_wait_len);
                ATOMIC_INT_SET(curlog->wait_length, our_wait_len);
            }
        }

        if (our_wait_len > n_interpreters) {
            int successp;
            STM_TRACE("deadlock detected, avoiding...\n");
            /* forcibly evict the other */
            ATOMIC_INT_CAS(successp, other->status, STM_STATUS_ACTIVE,
                STM_STATUS_ABORTED);
            if (successp) {
                ATOMIC_INT_SET(curlog->wait_length, 0);
                ATOMIC_PTR_CAS(successp, *in_what, other, handle->last_version);
            }
        }

        if (wait_count > 50) {
            STM_TRACE("waited too long, aborting...\n");
            ATOMIC_INT_SET(curlog->status, STM_STATUS_ABORTED);
            ATOMIC_INT_SET(curlog->wait_length, 0);
            version = NULL;
            break;
        }
        
        YIELD;
        /* XXX better spinning -- esp. detect or block DOD request */
    }
    Parrot_unblock_DOD(interp);
    return version;
}

/*
=item C<PMC *Parrot_STM_read(Interp *interp, Parrot_STM_PMC_handle handle)>

Read the value stored in the PMC wrapped by C<handle>.

=cut
*/

PMC *Parrot_STM_read(Interp *interp, Parrot_STM_PMC_handle handle) {
    STM_write_record *write;
    STM_read_record *read;
    STM_tx_log *log;
    void *check_version;
    int i;

    log = Parrot_STM_tx_log_get(interp);
    if (log->depth == 0) {
        /* special case outside of transaction */
        int committedp = 0;
        PMC *ret;
        do {
            Parrot_STM_start_transaction(interp);
            ret = Parrot_STM_read(interp, handle);
            committedp = Parrot_STM_commit(interp);
        } while (!committedp);
        return ret;
    }

    read = NULL;
    write = NULL;

    STM_TRACE("STM_read %p", handle);

    /* search for previous write record */
    for (i = 0; i <= log->last_write; ++i) {
        if (handle == get_write(interp, log, i)->handle) {
            write = get_write(interp, log, i);
        }
    }


    if (write) {
        STM_TRACE("found old write record");
        return write->value;
    }

    /* search for previous read record */
    for (i = 0; i <= log->last_read; ++i) {
        if (handle == get_read(interp, log, i)->handle) {
            read = get_read(interp, log, i);
        }
    }

    if (read) {
        STM_TRACE("found old read record");
        return read->value;
    }

    /* otherwise allocate a read record */
    read = alloc_read(interp, log);
    STM_TRACE("needed new read record");

    read->handle = handle;
    /* XXX loop needed? */
    do {
        STM_TRACE("trying read");
        read->saw_version = wait_for_version(interp, log, handle);
        STM_TRACE("read: saw version %p", read->saw_version);
        read->value = handle->value;
        ATOMIC_PTR_GET(check_version, handle->owner_or_version);
    } while (read->saw_version != check_version && !is_aborted(log)); 
    STM_TRACE("version is %p", read->saw_version);

    return read->value;
}

static int safe_to_clone(Interp *interp, PMC *original) {
    if (    original->vtable->base_type == enum_class_Integer
        ||  original->vtable->base_type == enum_class_Undef
        ||  original->vtable->base_type == enum_class_Float
        ||  original->vtable->base_type == enum_class_BigInt
        ||  original->vtable->base_type == enum_class_IntList
        ) {
        return 1;
    } else {
        return 0;
    }
}

static PMC *local_pmc_copy(Interp *interp, PMC *original) {
    if (PMC_IS_NULL(original)) {
        return PMCNULL;
    } else if (safe_to_clone(interp, original)) {
        return VTABLE_clone(interp, original);
    } else {
        return Parrot_clone(interp, original);
    }
}

/* Find a write record corresponding to C<handle> in our log or create
 * one if needed.
 *
 * If C<overwrite_p> is true, assume we are going to overwrite this record,
 * so initialize it to PMCNULL.
 */
static STM_write_record *find_write_record(Interp *interp, STM_tx_log *log,
        Parrot_STM_PMC_handle handle, int overwrite_p) {
    /* FIXME check for read log or previous tx's write log */
    STM_tx_log_sub *cursub;
    int have_old_value = 0;
    PMC *old_value;
    STM_read_record *read;
    STM_tx_log_sub *outersub;
    STM_write_record *write;
    int i;

    STM_TRACE("finding write record for %p", handle);

    log = Parrot_STM_tx_log_get(interp);
    assert(log->depth > 0);
    cursub = get_sublog(log, log->depth);
    outersub = NULL;

    STM_TRACE("searching %d local; %d non-local; %d read",
                log->last_write - cursub->first_write + 1,
                cursub->first_write,
                log->last_read + 1);

    write = NULL;
    read = NULL;

    for (i = cursub->first_write; i <= log->last_write; ++i) {
        STM_TRACE("current record %d (%p), handle = %p", 
            i, get_write(interp, log, i), 
            get_write(interp, log, i)->handle);
        if (get_write(interp, log, i)->handle == handle) {
            write = get_write(interp, log, i);
        }
    }
    
    {
        int j = log->depth - 1;
        for (i = cursub->first_write - 1; i >= 0; --i) {
            STM_TRACE("outer[depth=%d] record %d (%p), handle = %p", 
                j, i, get_write(interp, log, i),
                get_write(interp, log, i)->handle);
            if (get_write(interp, log, i)->handle == handle) {
                old_value = get_write(interp, log, i)->value;
                have_old_value = 1;
                break;
            }
            while (j > 0 && get_sublog(log, j)->first_write == i) {
                --j;
            }
        }
        if (j > 0) {
            outersub = get_sublog(log, j);
        }
    }

    if (!have_old_value) {
        for (i = log->last_read; i >= 0; --i) {
            if (get_read(interp, log, i)->handle == handle) {
                read = get_read(interp, log, i);
                old_value = get_read(interp, log, i)->value;
                have_old_value = 1;
                break;
            }
        }
    }

    if (!write) {
        int successp;
        STM_TRACE("didn't find old write record");
        write = alloc_write(interp, log);
        write->handle = handle;
        STM_TRACE("allocated record %d", log->last_write);
        if (have_old_value) {
            STM_TRACE("have old value");
            if (read) {
                STM_TRACE("... from a read record");
                write->saw_version = read->saw_version;
                ATOMIC_PTR_CAS(successp, handle->owner_or_version, 
                    read->saw_version, cursub);
            } else  {
                assert(outersub);
                STM_TRACE("... from outer transaction's write record");
                ATOMIC_PTR_GET(write->saw_version, handle->owner_or_version);
                ATOMIC_PTR_CAS(successp, handle->owner_or_version, outersub,
                    cursub);
            } 
            if (!successp) {
                STM_TRACE("... but the old value is out-of-date");
                ATOMIC_INT_SET(cursub->status, STM_STATUS_ABORTED);
            }
            write->value = local_pmc_copy(interp, old_value);
        } else {
            STM_TRACE("don't have old value");
            /* avoiding creating write records when we are actually aborted
             * XXX in the future we will do this by throwing an exception to
             * abort the transaction
             */
            if (!is_aborted(log)) {
                do {
                    STM_TRACE("trying write");
                    write->saw_version = wait_for_version(interp, log, handle);
                    STM_TRACE("write saw version %p", write->saw_version);
                    ATOMIC_PTR_CAS(successp, handle->owner_or_version, write->saw_version,
                                    cursub);
                } while (!successp && !is_aborted(log));
                STM_TRACE("... and acquired it");
            } else {
                STM_TRACE("... but already aborted anyways");
                write->saw_version = NULL;
            }
            if (overwrite_p) {
                write->value = PMCNULL;
            } else {
                write->value = local_pmc_copy(interp, handle->value);
            }
        }
    }

    return write;
}

/*
=item C<PMC *Parrot_STM_begin_update(Interp *interp, Parrot_STM_PMC_handle handle)>

Get a editable copy of the PMC wrapped by C<handle>. The updates will be visible
to other threads after a successful commit. The PMC should not be used after
the transaction commits (and especially not be written to, as other threads may
be given it when they read the value).

=cut
*/

PMC *Parrot_STM_begin_update(Interp *interp, Parrot_STM_PMC_handle handle) {
    STM_write_record *write;
    STM_tx_log *log;

    log = Parrot_STM_tx_log_get(interp);

    if (log->depth == 0) {
        internal_exception(1, "STM_begin_update outside transaction");
        return PMCNULL;
    }

    write = find_write_record(interp, log, handle, 0);

    return write->value;
}

/*
=item C<void Parrot_STM_write(Interp *interp, Parrot_STM_PMC_handle handle, PMC *new_value)>

Write C<new_value> into the PMC wrapped by C<handle>.

=cut
*/
void Parrot_STM_write(Interp *interp, Parrot_STM_PMC_handle handle, PMC* new_value) {
    /* XXX no transaction case */
    STM_write_record *write;
    STM_tx_log *log;

    log = Parrot_STM_tx_log_get(interp);

    if (log->depth == 0) {
        /* error for now */
        internal_exception(1, "STM_write outside transaction");
        return;
    }

    write = find_write_record(interp, log, handle, 1);

    write->value = new_value;
}


