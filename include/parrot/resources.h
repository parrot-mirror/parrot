/* register.h
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Defines the resource allocation API
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_RESOURCES_H_GUARD)
#define PARROT_RESOURCES_H_GUARD

#include "parrot/parrot.h"

PMC *new_pmc_header(struct Parrot_Interp *);
void free_pmc(PMC *);

STRING *new_string_header(struct Parrot_Interp *);
Buffer *new_tracked_header(struct Parrot_Interp *, size_t size);
Buffer *new_buffer_header(struct Parrot_Interp *);
void free_buffer(Buffer *);

void *new_bigint_header(struct Parrot_Interp *);
void free_bigint(void);

void *new_bignum_header(struct Parrot_Interp *);
void free_bignum(void);

void *Parrot_allocate(struct Parrot_Interp *, void *, size_t size);
void *Parrot_allocate_about(struct Parrot_Interp *, void *, size_t size);
void *mem_allocate(struct Parrot_Interp *, size_t *req_size);
void *Parrot_alloc_new_block(struct Parrot_Interp *, size_t, UINTVAL);

void Parrot_new_pmc_header_arena(struct Parrot_Interp *interpreter);

void Parrot_do_dod_run(struct Parrot_Interp *);
void Parrot_go_collect(struct Parrot_Interp *);

void *Parrot_reallocate(struct Parrot_Interp *interpreter, void *from, size_t tosize);
void *Parrot_reallocate_about(struct Parrot_Interp *interpreter, void *from, size_t tosize);

void buffer_lives(Buffer *);

void Parrot_initialize_free_pools(struct Parrot_Interp *);

#define STRING_HEADERS_PER_ALLOC 128
#define PMC_HEADERS_PER_ALLOC 128
#define BUFFER_HEADERS_PER_ALLOC 128

struct PMC_Arena {
    size_t free;         /* Count of PMCs free in this arena */
    size_t used;         /* Count of PMCs used in this arena */
    struct PMC_Arena *prev;
    struct PMC_Arena *next;
    PMC *start_PMC;        /* Next PMC in the arena ready to allocate */
    size_t *GC_data;     /* Actually an array with one element per PMC */
};

struct STRING_Arena {
    size_t free;
    size_t used;
    struct STRING_Arena *prev;
    struct STRING_Arena *next;
    STRING *start_STRING;
};

struct Buffer_Arena {
    size_t free;
    size_t used;
    struct Buffer_Arena *prev;
    struct Buffer_Arena *next;
    Buffer *start_Buffer;
};

/* The free header pool */
struct free_pool {
    Buffer pool_buffer;
    size_t entries_in_pool;
    void (*replenish)(struct Parrot_Interp *, struct free_pool *);
};
        
struct Memory_Pool {
    size_t free;
    size_t size;
    struct Memory_Pool *prev;
    struct Memory_Pool *next;
    char *start;
    char *top;
};

struct Arenas {
    struct PMC_Arena *last_PMC_Arena;
    struct STRING_Arena *last_STRING_Arena;
    struct Buffer_Arena *last_Buffer_Arena;
    struct Memory_Pool *memory_pool;
    struct free_pool *string_header_pool;
    struct free_pool *pmc_pool;
    struct free_pool *buffer_header_pool;
};

struct Stash {
    struct PMC *stash_hash;
    struct Stash *parent_stash;
};

#define TOTAL_MEM_ALLOC 1
#define DOD_RUNS 2
#define COLLECT_RUNS 3
#define ACTIVE_PMCS 4
#define ACTIVE_BUFFERS 5
#define TOTAL_PMCS 6
#define TOTAL_BUFFERS 7
#define HEADERS_ALLOC_SINCE_COLLECT 8
#define MEM_ALLOCS_SINCE_COLLECT 9
#define TOTAL_COPIED 10

#endif /* PARROT_RESOURCES_H */

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil 
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
