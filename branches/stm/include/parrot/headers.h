/* headers.h
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     Header management functions. Handles getting of various headers,
 *     and pool creation
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_HEADERS_H_GUARD)
#define PARROT_HEADERS_H_GUARD

#include "parrot/parrot.h"

/*
 * we need an alignment that is the same as malloc(3) have for
 * allocating Buffer items like FLOATVAL (double)
 * This should be either a config hint or tested
 */
#ifdef MALLOC_ALIGNMENT       
#  define BUFFER_ALIGNMENT MALLOC_ALIGNMENT       
#else
/* or (2 * sizeof(size_t)) */
#  define BUFFER_ALIGNMENT 8
#endif

#define BUFFER_ALIGN_1 (BUFFER_ALIGNMENT - 1)
#define BUFFER_ALIGN_MASK ~BUFFER_ALIGN_1 

#define WORD_ALIGN_1 (sizeof(void *) - 1)
#define WORD_ALIGN_MASK ~WORD_ALIGN_1 

/* pool creation and access functions */
struct Small_Object_Pool *new_pmc_pool(Interp *interpreter);
struct Small_Object_Pool *new_bufferlike_pool(Interp *interpreter, size_t unit_size);
struct Small_Object_Pool *new_buffer_pool(Interp *interpreter);
struct Small_Object_Pool *new_string_pool(Interp *interpreter, INTVAL constant);
struct Small_Object_Pool *get_bufferlike_pool(Interp *interpreter, size_t unit_size);

struct Small_Object_Pool *make_bufferlike_pool(Interp *interpreter, size_t unit_size);
/* header creation functions */
PMC *new_pmc_header(Interp *interpreter, UINTVAL flags);
void add_pmc_ext(Interp *interpreter, PMC *pmc);
void add_pmc_sync(Interp *interpreter, PMC *pmc);
STRING *new_string_header(Interp *interpreter, UINTVAL flags);
Buffer *new_buffer_header(Interp *interpreter);
void *new_bufferlike_header(Interp *interpreter, size_t size);

size_t get_max_buffer_address(Interp *interpreter);
size_t get_min_buffer_address(Interp *interpreter);
size_t get_max_pmc_address(Interp *interpreter);
size_t get_min_pmc_address(Interp *interpreter);
int is_buffer_ptr(Interp *, void *);
int is_pmc_ptr(Interp *, void *);

void gc_pmc_ext_pool_init(Interp *, struct Small_Object_Pool *pool);

/* pool iteration */
typedef enum {
    POOL_PMC    = 0x01,
    POOL_BUFFER = 0x02,
    POOL_CONST  = 0x04,
    POOL_ALL    = 0x07
} pool_iter_enum;

typedef int (*pool_iter_fn)(Interp *, struct Small_Object_Pool *, int, void*);
int Parrot_forall_header_pools(Interp *, int, void *arg, pool_iter_fn func);

/* miscellaneous functions */
void Parrot_initialize_header_pools(Interp *);
void Parrot_destroy_header_pools(Interp *interpreter);

void Parrot_merge_header_pools(Interp *dest, Interp *source);

#endif /* PARROT_HEADERS_H_GUARD */

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
