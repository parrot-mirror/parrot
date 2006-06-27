#if !defined(PARROT_STM_BACKEND_H_GAURD)
#define PARROT_STM_BACKEND_H_GAURD

#include <parrot/parrot.h>

struct Parrot_STM_PMC_handle_data;

typedef struct Parrot_STM_PMC_handle_data *Parrot_STM_PMC_handle;

Parrot_STM_PMC_handle Parrot_STM_alloc(Interp *, PMC *);

void Parrot_STM_start_transaction(Interp *);

PMC *Parrot_STM_read(Interp *, Parrot_STM_PMC_handle);

PMC *Parrot_STM_begin_update(Interp *, Parrot_STM_PMC_handle);

void Parrot_STM_write(Interp *, Parrot_STM_PMC_handle, PMC *);

int Parrot_STM_commit(Interp *);

void Parrot_STM_abort(Interp *);

void Parrot_STM_wait(Interp *);

int Parrot_STM_validate(Interp *);

void Parrot_STM_mark_transaction(Interp *);

void Parrot_STM_mark_pmc_handle(Interp *, Parrot_STM_PMC_handle);

int Parrot_STM_transaction_depth(Interp *);


#endif
