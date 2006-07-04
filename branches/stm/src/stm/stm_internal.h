#if !defined(PARROT_STM_INTERNAL_H_GAURD)
#define PARROT_STM_INTERNAL_H_GAURD

#include <parrot/parrot.h>
#include "stm_waitlist.h"

struct Parrot_STM_PMC_handle_data {
    Buffer buf;
    Parrot_atomic_pointer owner_or_version;
    PMC *value;
    STM_waitlist change_waitlist;
};

struct STM_tx_log;

typedef struct STM_tx_log STM_tx_log;

struct STM_write_record {
    Parrot_STM_PMC_handle handle;
    void *saw_version;
    PMC *value;
};

struct STM_read_record {
    Parrot_STM_PMC_handle handle;
    void *saw_version;
    PMC *value;
};

typedef struct STM_write_record STM_write_record;
typedef struct STM_read_record STM_read_record;

enum {
    STM_STATUS_ACTIVE = 0,
    STM_STATUS_ABORTED = 1,
    STM_STATUS_COMMITTED = 2,
    STM_STATUS_INVALID = 3
};

#define STM_MAX_RECORDS 128 /* TODO: remove limitation */
 
#define STM_MAX_TX_DEPTH 32 /* TODO: remove limitation */

struct STM_tx_log_sub;

typedef struct STM_tx_log_sub STM_tx_log_sub;

/* log for a sub transaction */
struct STM_tx_log_sub {
    Parrot_atomic_int status;
    /* for poor man's deadlock detection; based on Ennals' implementation */
    Parrot_atomic_int wait_length;
    int first_write;
    int first_read;
};

struct STM_tx_log {
    int depth;

    STM_tx_log_sub inner[STM_MAX_TX_DEPTH];

    int last_write;
    int last_read;
    /* TODO: probably better to make these a list of hashes (one for each tx) */
    STM_write_record *writes;
    STM_read_record *reads;
    
    struct waitlist_thread_data *waitlist_data;
};

STM_tx_log *Parrot_STM_tx_log_get(Interp *interp);

#endif
