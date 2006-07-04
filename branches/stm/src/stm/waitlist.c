#include <parrot/parrot.h>
#include "stm_internal.h"
#include "stm_waitlist.h"

#define WAITLIST_DEBUG 0

static struct waitlist_thread_data *
get_thread(Parrot_Interp interp) {
    STM_tx_log *txlog;
    txlog = Parrot_STM_tx_log_get(interp);
    if (!txlog->waitlist_data) {
        txlog->waitlist_data = 
            mem_sys_allocate_zeroed(sizeof(*txlog->waitlist_data));
        MUTEX_INIT(txlog->waitlist_data->signal_mutex);
        txlog->waitlist_data->signal_cond = &interp->thread_data->interp_cond;
    }
    return txlog->waitlist_data;
}

static struct waitlist_entry *
alloc_entry(Parrot_Interp interp) {
    struct waitlist_thread_data *thr;
    size_t i;

    thr = get_thread(interp);

    if (!thr->entries) {
        thr->entries = mem_sys_allocate_zeroed(sizeof(*thr->entries) * 4);
        thr->entry_count = 4;
    }

    if (thr->used_entries >= thr->entry_count) {
        size_t i;
        thr->entries = mem_sys_realloc(thr->entries,
            sizeof(*thr->entries) * thr->entry_count * 2);
        for (i = thr->entry_count; i <= thr->entry_count * 2; ++i) {
            thr->entries[i] = NULL;
        }
        thr->entry_count *= 2;
    }
    
    i = thr->used_entries++;
    if (!thr->entries[i]) {
        thr->entries[i] = mem_sys_allocate_zeroed(sizeof(**thr->entries));
        thr->entries[i]->thread = thr;
    }

    return thr->entries[i];
}

static void
add_entry(STM_waitlist *waitlist, struct waitlist_entry *entry) {
    int successp;
    do {
        ATOMIC_PTR_GET(entry->next, waitlist->first);
        ATOMIC_PTR_CAS(successp, waitlist->first, entry->next, entry);
    } while (!successp);
#if WAITLIST_DEBUG
    fprintf(stderr, "added %p to waitlist %p\n", waitlist, entry);
#endif
}

static int
remove_first(STM_waitlist *waitlist, struct waitlist_entry *expect_first) {
    int successp;
    ATOMIC_PTR_CAS(successp, waitlist->first, expect_first,
                        expect_first->next);
#if WAITLIST_DEBUG
    fprintf(stderr, "tried removing %p from beginning of waitlist %p, successp=%d\n",
                expect_first, waitlist, successp);
#endif
    return successp;
}

static void
waitlist_remove(STM_waitlist *waitlist, struct waitlist_entry *what) {
    struct waitlist_entry *cur;

    ATOMIC_PTR_GET(cur, waitlist->first);
    if (cur == what && remove_first(waitlist, what)) {
        return;
    }

    if (!cur) {
        return;
    }

    LOCK(waitlist->remove_mutex);
    ATOMIC_PTR_GET(cur, waitlist->first);
    if (!cur) {
        UNLOCK(waitlist->remove_mutex);
        return;
    }
    while (cur->next && cur->next != what) { 
        cur = cur->next;
    }

    if (cur->next == what) {
        cur->next = what->next;
    } 
    UNLOCK(waitlist->remove_mutex);

    what->next = NULL;
    what->head = NULL;
}

static void
waitlist_signal_one(struct waitlist_entry *who) {
    struct waitlist_thread_data *thread;

    thread = who->thread;
#if WAITLIST_DEBUG
    fprintf(stderr, "about to signal %p\n", who);
#endif
    LOCK(thread->signal_mutex);
#if WAITLIST_DEBUG
    fprintf(stderr, "acquired their lock\n");
#endif
    thread->signaled_p = 1;
    UNLOCK(thread->signal_mutex);
    COND_SIGNAL(*thread->signal_cond);
#if WAITLIST_DEBUG
    fprintf(stderr, "signalled them\n");
#endif
}

static void
waitlist_signal_all(STM_waitlist *list) {
    int successp;
    struct waitlist_entry *cur;
    do {
        ATOMIC_PTR_GET(cur, list->first);
        ATOMIC_PTR_CAS(successp, list->first, cur, NULL);
    } while (!successp);
    
    if (!cur) {
        return;
    }

    if (!cur->next) {
        waitlist_signal_one(cur);
        return;
    }

    /* assure that any removals pending on the list are finished;
     * none can start after we replace the head pointer.
     */
    LOCK(list->remove_mutex);
    UNLOCK(list->remove_mutex);

    while (cur) {
        struct waitlist_entry *next;
        next = cur->next;
        waitlist_signal_one(cur);
        cur = next;
    }
}

void
Parrot_STM_waitlist_add_self(Parrot_Interp interp, STM_waitlist *waitlist) {
    struct waitlist_entry *entry;

    entry = alloc_entry(interp);
    entry->head = waitlist;
    add_entry(waitlist, entry);
}

void
Parrot_STM_waitlist_signal(Parrot_Interp interp, STM_waitlist *waitlist) {
    waitlist_signal_all(waitlist);
}

void
Parrot_STM_waitlist_remove_all(Parrot_Interp interp) {
    struct waitlist_thread_data *thr;
    size_t i;
    thr = get_thread(interp);
    for (i = 0; i < thr->used_entries; ++i) {
        struct waitlist_entry *entry;
        entry = thr->entries[i];
        waitlist_remove(entry->head, entry);
    }
    thr->used_entries = 0;
    LOCK(thr->signal_mutex);
    thr->signaled_p = 0;
    UNLOCK(thr->signal_mutex);
}

/* TODO handle events here */
void
Parrot_STM_waitlist_wait(Parrot_Interp interp) {
    struct waitlist_thread_data *thr;
    thr = get_thread(interp);
    LOCK(thr->signal_mutex);
    while (!thr->signaled_p) {
        pt_thread_wait_with(interp, &thr->signal_mutex);
    }
    UNLOCK(thr->signal_mutex);
}

void
Parrot_STM_waitlist_init(Parrot_Interp interp, STM_waitlist *waitlist) {
    ATOMIC_PTR_INIT(waitlist->first);
    ATOMIC_PTR_SET(waitlist->first, NULL);
    MUTEX_INIT(waitlist->remove_mutex);
}
