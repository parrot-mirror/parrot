/* resources.c 
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Allocate and deallocate tracked resources
 *  Data Structure and Algorithms:
 *     
 *  History:
 *     Initial version by Dan on 2001.10.2
 *  Notes:
 *  References:
 */

#include "parrot/parrot.h"

/* Function prototypes for static functions */
static void *mem_allocate(struct Parrot_Interp *interpreter, size_t *req_size,
                          struct Memory_Pool *pool);
static void *alloc_new_block(struct Parrot_Interp *, size_t, 
                             struct Memory_Pool *);


/* Create a new tracked resource pool */
static struct Resource_Pool *
new_resource_pool(struct Parrot_Interp *interpreter, size_t free_pool_size,
                  size_t unit_size, size_t units_per_alloc,
             void (*replenish)(struct Parrot_Interp *, struct Resource_Pool *))
{
    struct Resource_Pool *pool;
    size_t temp_len;

    pool = mem_sys_allocate(sizeof(struct Resource_Pool));
    temp_len = free_pool_size * sizeof(void *);
    pool->free_pool_buffer.bufstart = 
        mem_allocate(interpreter, &temp_len, 
                     interpreter->arena_base->memory_pool);
    pool->free_pool_buffer.buflen = temp_len;
    pool->free_pool_buffer.flags = BUFFER_live_FLAG;
    pool->free_entries = 0;
    pool->unit_size = unit_size;
    pool->units_per_alloc = units_per_alloc;
    pool->replenish = replenish;
    return pool;
}

/* Add entry to free pool 
 * Requires that any object-specific processing (eg flag setting, statistics) 
 * has already been done by the caller 
 */
static void
add_to_free_pool(struct Parrot_Interp *interpreter,
                 struct Resource_Pool *pool, void *to_add)
{
    void **temp_ptr;

    /* First, check and see if there's enough space in the free pool. If
     * we're within the size of a pointer, we make it bigger */
    if (pool->free_entries * sizeof(void *) >=
        pool->free_pool_buffer.buflen - sizeof(void *)) {
        /* If not, make the free pool bigger. We enlarge it by 20% */
        Parrot_reallocate(interpreter,
                          &pool->free_pool_buffer,
                          (UINTVAL)(pool->free_pool_buffer.buflen * 1.2));
    }
#ifdef GC_DEBUG
    Parrot_go_collect(interpreter);
#endif

    /* Okay, so there's space. Add the header on */
    temp_ptr = pool->free_pool_buffer.bufstart;
    temp_ptr += pool->free_entries;
    *temp_ptr = to_add;
    pool->free_entries++;
}

/* Get an entity from the specified free pool
 * If the pool is empty, try a DOD sweep
 * If the pool is still empty, call the replenishment function
 */
static void *
get_from_free_pool(struct Parrot_Interp *interpreter,
                   struct Resource_Pool *pool)
{
    void ** ptr;

    if (!pool->free_entries) {
        Parrot_do_dod_run(interpreter);
    }

    if (!pool->free_entries) {
        (*pool->replenish)(interpreter, pool);
    }

    if (!pool->free_entries) {
        return NULL;
    }

    ptr = pool->free_pool_buffer.bufstart;
    ptr += --pool->free_entries;
    return *ptr;
}

/* We have no more headers on the free header pool. Go allocate more
 * and put them on */
static void 
alloc_more_pmc_headers(struct Parrot_Interp *interpreter,
                       struct Resource_Pool *pool)
{
    struct PMC_Arena *new_arena;
    PMC *cur_pmc;
    UINTVAL i;

    new_arena = mem_sys_allocate(sizeof(struct PMC_Arena));
    new_arena->GC_data = 
        mem_sys_allocate(sizeof(PMC *) * pool->units_per_alloc);
    memset(new_arena->GC_data, 0, sizeof(PMC *) * pool->units_per_alloc);
    new_arena->start_PMC = 
        mem_sys_allocate(sizeof(PMC) * pool->units_per_alloc);
    memset(new_arena->start_PMC, 0, sizeof(PMC) * pool->units_per_alloc);
    new_arena->used = pool->units_per_alloc;
    new_arena->next = NULL;
    new_arena->prev = pool->last_Arena;
    /* Is there a previous arena */
    if (new_arena->prev) {
        new_arena->prev->next = new_arena;
    }

    pool->last_Arena = new_arena;

    /* Note it in our stats */
    interpreter->total_PMCs += pool->units_per_alloc;

    cur_pmc = new_arena->start_PMC;
    for (i = 0; i < pool->units_per_alloc; i++) {
        cur_pmc->flags = PMC_on_free_list_FLAG;
        add_to_free_pool(interpreter, pool, cur_pmc++);
    }
}

PMC *
new_pmc_header(struct Parrot_Interp *interpreter)
{
    PMC *return_me;

    /* We return system memory if we've got no interpreter yet */
    if (NULL == interpreter) {
        return_me = mem_sys_allocate(sizeof(PMC));
        return_me->flags = PMC_live_FLAG;
        return_me->vtable = NULL;
        return_me->data = NULL;
        return return_me;
    }

    /* Get a PMC from the free pool */
    return_me = get_from_free_pool(interpreter,
                                   interpreter->arena_base->pmc_pool);
    /* Count that we've allocated it */
    interpreter->active_PMCs++;
    /* Mark it live */
    return_me->flags = PMC_live_FLAG;
    /* Don't let it point to garbage memory */
    return_me->data = NULL;
    /* Return it */
    return return_me;
}

void
free_pmc(PMC *pmc)
{
    if (pmc) {
        memset(pmc, 0, sizeof(PMC));
    }
}

Buffer *
new_tracked_header(struct Parrot_Interp *interpreter, size_t size)
{
    UNUSED(interpreter);
    return (Buffer *)mem_sys_allocate(size);
}


/* We have no more headers on the free header pool. Go allocate more
 * and put them on */
static void
alloc_more_buffer_headers(struct Parrot_Interp *interpreter,
                          struct Resource_Pool *pool)
{
    struct Buffer_Arena *new_arena;
    Buffer *cur_buffer;
    UINTVAL i;

    new_arena = mem_sys_allocate(sizeof(struct Buffer_Arena));
    new_arena->start_Buffer = 
        mem_sys_allocate(pool->unit_size * pool->units_per_alloc);
    memset(new_arena->start_Buffer, 0, 
           pool->unit_size * pool->units_per_alloc);
    new_arena->used = pool->units_per_alloc;
    new_arena->next = NULL;
    new_arena->prev = pool->last_Arena;
    /* Is there a previous arena */
    if (new_arena->prev) {
        new_arena->prev->next = new_arena;
    }

    pool->last_Arena = new_arena;

    /* Note it in our stats */
    interpreter->total_Buffers += pool->units_per_alloc;

    cur_buffer = new_arena->start_Buffer;
    for (i = 0; i < pool->units_per_alloc; i++) {
        cur_buffer->flags = BUFFER_on_free_list_FLAG;
        add_to_free_pool(interpreter, pool, cur_buffer);
        cur_buffer = (Buffer *)((char *)cur_buffer + pool->unit_size);
    }
}

/* Get a buffer out of our free pool */
Buffer *
new_buffer_header(struct Parrot_Interp *interpreter)
{
    Buffer *return_me;

    /* Icky special case. Grab system memory if there's no interpreter
     * yet */
    if (interpreter == NULL) {
        return_me = mem_sys_allocate(sizeof(Buffer));
        return_me->flags = BUFFER_live_FLAG;
        return return_me;
    }

    /* get buffer header from the free pool */
    return_me = get_from_free_pool(interpreter,
                                  interpreter->arena_base->buffer_header_pool);
    /* Count that we've allocated it */
    interpreter->active_Buffers++;
    /* Mark it live */
    return_me->flags = BUFFER_live_FLAG;
    /* Don't let it point to garbage memory */
    return_me->bufstart = NULL;
    /* Return it */
    return return_me;
}

void
free_buffer(Buffer *thing)
{
    if (thing) {
        if (thing->bufstart && (thing->flags & BUFFER_sysmem_FLAG)) {
            mem_sys_free(thing->bufstart);
        }
        thing->bufstart = NULL;
        thing->buflen = 0;
        thing->flags = 0;
    }
}

/* Mark all the PMCs as not in use.  */
static void
mark_PMCs_unused(struct Parrot_Interp *interpreter)
{
    struct PMC_Arena *cur_arena;
    UINTVAL i;

    /* Run through all the buffer header pools and mark */
    for (cur_arena = interpreter->arena_base->pmc_pool->last_Arena;
         NULL != cur_arena;
         cur_arena = cur_arena->prev) {
        PMC *pmc_array = cur_arena->start_PMC;
        for (i = 0; i < cur_arena->used; i++) {
            /* Tentatively unused, unless it's a constant */
            if (!(pmc_array[i].flags & PMC_constant_FLAG)) {
                pmc_array[i].flags &= ~PMC_live_FLAG;
            }
            /* But the GC pointer's NULLed anyway */
            pmc_array[i].next_for_GC = NULL;
        }
    }
}

/* Mark all the buffers as unused */
static void
mark_buffers_unused(struct Parrot_Interp *interpreter,
                    struct Resource_Pool *pool) 
{
    struct Buffer_Arena *cur_arena;
    UINTVAL i;

    /* Run through all the buffer header pools and mark */
    for (cur_arena = pool->last_Arena;
         NULL != cur_arena;
         cur_arena = cur_arena->prev) {
        Buffer *b = cur_arena->start_Buffer;
        for (i = 0; i < cur_arena->used; i++) {
            /* Tentatively unused, unless it's a constant */
            if (!(b->flags & BUFFER_constant_FLAG)) {
                b->flags &= ~BUFFER_live_FLAG;
            }
            b = (Buffer *)((char *)b + pool->unit_size);
        }
    }
}

PMC *
mark_used(PMC *used_pmc, PMC *current_end_of_list)
{
    /* If the PMC we've been handed has already been marked as live
     * (ie we put it on the list already) we just return. Otherwise we
     * could get in some nasty loops */
    if (used_pmc->next_for_GC) {
        return current_end_of_list;
    }

    /* First, mark the PMC itself as used */
    used_pmc->flags |= PMC_live_FLAG;

    /* Now put it on the end of the list */
    current_end_of_list->next_for_GC = used_pmc;

    /* Explicitly make the tail of the linked list be self-referential */
    used_pmc->next_for_GC = used_pmc;

    /* return the PMC we were passed as the new end of the list */
    return used_pmc;
}

/* Tag a buffer header as alive. Used by the GC system when tracing
 * the root set, and used by the PMC GC handling routines to tag their
 * individual pieces if they have private ones */
INLINE void
buffer_lives(Buffer *buffer)
{
    buffer->flags |= BUFFER_live_FLAG;
}

/* Do a full trace run and mark all the PMCs as active if they are */
static void
trace_active_PMCs(struct Parrot_Interp *interpreter)
{
    PMC *last, *current, *prev; /* Pointers to the last marked PMC, the
                                 * currently being processed PMC, and in
                                 * the previously processed PMC in a loop. */
    unsigned int i, j, chunks_traced;
    Stack_chunk *cur_stack, *start_stack;
    struct PRegChunk *cur_chunk;

    /* We have to start somewhere, and the global stash is a good
     * place */
    last = current = interpreter->perl_stash->stash_hash;

    /* mark it as used and get an updated end of list */
    last = mark_used(current, last);

    /* Now, go run through the PMC registers and mark them as live */
    /* First mark the current set. */
    for (i = 0; i < NUM_REGISTERS; i++) {
        if (interpreter->pmc_reg.registers[i]) {
            last = mark_used(interpreter->pmc_reg.registers[i], last);
        }
    }

    /* Now walk the pmc stack. Make sure to walk from top down
     * since stack may have segments above top that we shouldn't walk. */
    for (cur_chunk = interpreter->pmc_reg_top; cur_chunk;
         cur_chunk = cur_chunk->prev) {
        for (j = 0; j < cur_chunk->used; j++) {
            for (i = 0; i < NUM_REGISTERS; i++) {
                if (cur_chunk->PReg[j].registers[i]) {
                    last = mark_used(cur_chunk->PReg[j].registers[i], last);
                }
            }
        }
    }

    /* Finally the general stack */
    start_stack = cur_stack = interpreter->user_stack;
    chunks_traced = 0;
    /* The general stack's circular, so we need to be careful */
    while (cur_stack && ((start_stack != cur_stack) || (chunks_traced == 0))) {
        for (i = 0; i < cur_stack->used; i++) {
            if (STACK_ENTRY_PMC == cur_stack->entry[i].entry_type) {
                last = mark_used(cur_stack->entry[i].entry.pmc_val, last);
            }
        }

        chunks_traced++;
        cur_stack = cur_stack->prev;
    }


    /* Okay, we've marked the whole root set, and should have a
     * good-sized list 'o things to look at. Run through it */
    prev = NULL;
    for (; current != prev; current = current->next_for_GC) {
        UINTVAL mask = PMC_is_PMC_ptr_FLAG | PMC_is_buffer_ptr_FLAG 
                     | PMC_custom_mark_FLAG;
        UINTVAL bits = current->flags & mask;

        /* Start by checking if there's anything at all. This assumes
         * that the largest percentage of PMCs won't have anything in
         * their data pointer that we need to trace */
        if (bits) {
            if (bits == PMC_is_PMC_ptr_FLAG) {
                last = mark_used(current->data, last);
            }
            else if (bits == PMC_is_buffer_ptr_FLAG) {
                if (current->data) {
                    buffer_lives(current->data);
                }
            }
            else if (bits == (PMC_is_buffer_ptr_FLAG | PMC_is_PMC_ptr_FLAG)) {
                /* buffer of PMCs */
                Buffer *trace_buf = current->data;
                PMC **cur_pmc = trace_buf->bufstart;
                /* Mark the damn buffer as used! */
                buffer_lives(trace_buf);
                for (i = 0; i < trace_buf->buflen / sizeof(*cur_pmc); i++) {
                    if (cur_pmc[i]) {
                        last = mark_used(cur_pmc[i], last);
                    }
                }
            }
            else {
                /* All that's left is the custom */
                last = current->vtable->mark(interpreter, current, last);
            }
        }

        prev = current;
    }
}

/* Scan any buffers in S registers and other non-PMC places and mark
 * them as active */
static void
trace_active_buffers(struct Parrot_Interp *interpreter)
{
    UINTVAL i, j, chunks_traced;
    Stack_chunk *cur_stack, *start_stack;
    struct SRegChunk *cur_chunk;

    /* First mark the current set. We assume that all pointers in S
     * registers are pointing to valid buffers. This is not a good
     * assumption, but it'll do for now */
    for (i = 0; i < NUM_REGISTERS; i++) {
        if (interpreter->string_reg.registers[i]) {
            buffer_lives((Buffer *)interpreter->string_reg.registers[i]);
        }
    }

    /* Now walk the string stack. Make sure to walk from top down
     * since stack may have segments above top that we shouldn't walk. */
    for (cur_chunk = interpreter->string_reg_top;
         cur_chunk; cur_chunk = cur_chunk->prev) {
        for (j = 0; j < cur_chunk->used; j++) {
            for (i = 0; i < NUM_REGISTERS; i++) {
                if (cur_chunk->SReg[j].registers[i]) {
                    buffer_lives((Buffer *)cur_chunk->SReg[j].registers[i]);
                }
            }
        }
    }

    /* Finally the general stack */
    start_stack = cur_stack = interpreter->user_stack;
    chunks_traced = 0;
    /* The general stack's circular, so we need to be careful */
    while (cur_stack && ((start_stack != cur_stack) || (chunks_traced == 0))) {
        for (i = 0; i < cur_stack->used; i++) {
            if (STACK_ENTRY_STRING == cur_stack->entry[i].entry_type) {
                buffer_lives((Buffer *)cur_stack->entry[i].entry.string_val);
            }
        }

        chunks_traced++;
        cur_stack = cur_stack->prev;
    }
}

/* Free up any PMCs that aren't in use */
static void
free_unused_PMCs(struct Parrot_Interp *interpreter)
{
    struct PMC_Arena *cur_arena;
    UINTVAL i;

    /* Run through all the buffer header pools and mark */
    for (cur_arena = interpreter->arena_base->pmc_pool->last_Arena;
         NULL != cur_arena;
         cur_arena = cur_arena->prev) {
        PMC *pmc_array = cur_arena->start_PMC;
        for (i = 0; i < cur_arena->used; i++) {
            /* If it's not live or on the free list, put it on the free list */
            if (!(pmc_array[i].flags & (PMC_live_FLAG | PMC_immune_FLAG |
                                        PMC_on_free_list_FLAG))) {
                interpreter->active_PMCs--;
                pmc_array[i].flags = PMC_on_free_list_FLAG;
                add_to_free_pool(interpreter,
                                interpreter->arena_base->pmc_pool,
                                &pmc_array[i]);
            }
        }
    }
}

/* Put any free buffers that aren't on the free list on the free list */
static void
free_unused_buffers(struct Parrot_Interp *interpreter, 
                    struct Resource_Pool *pool)
{
    struct Buffer_Arena *cur_arena;
    UINTVAL i;

    /* Run through all the buffer header pools and mark */
    for (cur_arena = pool->last_Arena;
         NULL != cur_arena;
         cur_arena = cur_arena->prev) {
        Buffer *b = cur_arena->start_Buffer;
        for (i = 0; i < cur_arena->used; i++) {
            /* If it's not live or on the free list, put it on the free list */
            if (!(b->flags & (BUFFER_live_FLAG |
                              BUFFER_on_free_list_FLAG))) {
                interpreter->active_Buffers--;
                b->flags = BUFFER_on_free_list_FLAG;
                add_to_free_pool(interpreter, pool, b);
            }
            b = (Buffer *)((char *)b + pool->unit_size);
        }
    }
}

/* See if we can find some unused headers */
void
Parrot_do_dod_run(struct Parrot_Interp *interpreter)
{
    if (interpreter->DOD_block_level) {
        return;
    }

    /* First go mark all PMCs as unused */
    mark_PMCs_unused(interpreter);

    /* Then mark the buffers as unused */
    mark_buffers_unused(interpreter, 
                        interpreter->arena_base->buffer_header_pool);
    mark_buffers_unused(interpreter,
                        interpreter->arena_base->string_header_pool);

    /* Now go trace the PMCs */
    trace_active_PMCs(interpreter);

    /* And the buffers */
    trace_active_buffers(interpreter);

    /* Now put unused PMCs on the free list */
    free_unused_PMCs(interpreter);

    /* And unused buffers on the free list */
    free_unused_buffers(interpreter,
                        interpreter->arena_base->string_header_pool);
    free_unused_buffers(interpreter,
                        interpreter->arena_base->buffer_header_pool);

    /* Note it */
    interpreter->dod_runs++;

    return;
}

/* Fetch a string header from the free header pool */
STRING *
new_string_header(struct Parrot_Interp *interpreter, UINTVAL flags)
{
    STRING *return_me;

    /* Icky special case. Grab system memory if there's no interpreter
     * yet */
    if (interpreter == NULL) {
        return_me = mem_sys_allocate(sizeof(STRING));
        return_me->flags = flags | BUFFER_live_FLAG;
        return return_me;
    }

    /* Get string header from the free pool */
    if (flags & BUFFER_constant_FLAG) {
        return_me = 
            get_from_free_pool(interpreter,
                        interpreter->arena_base->constant_string_header_pool);
    }
    else {
        return_me = 
        get_from_free_pool(interpreter,
                           interpreter->arena_base->string_header_pool);
    }
    /* Count that we've allocated it */
    interpreter->active_Buffers++;
    /* Mark it live */
    return_me->flags = flags | BUFFER_live_FLAG;
    /* Don't let it point to garbage memory */
    return_me->bufstart = NULL;
    /* Return it */
    return return_me;
}

/* Initialize the pools for the tracked resources */
void
Parrot_initialize_resource_pools(struct Parrot_Interp *interpreter)
{
    /* Init the string header pool */
    interpreter->arena_base->string_header_pool = 
        new_resource_pool(interpreter, 256, sizeof(STRING), 
                          STRING_HEADERS_PER_ALLOC,
                          alloc_more_buffer_headers);
    
    /* Init the buffer header pool */
    interpreter->arena_base->buffer_header_pool =
        new_resource_pool(interpreter, 256, sizeof(Buffer),
                          BUFFER_HEADERS_PER_ALLOC,
                          alloc_more_buffer_headers);
    
    /* Init the PMC header pool */
    interpreter->arena_base->pmc_pool =
        new_resource_pool(interpreter, 256, sizeof(PMC),
                          PMC_HEADERS_PER_ALLOC,
                          alloc_more_pmc_headers);

    /* Init the constant string header pool */
    interpreter->arena_base->constant_string_header_pool = 
        new_resource_pool(interpreter, 256, sizeof(STRING),
                          STRING_HEADERS_PER_ALLOC,
                          alloc_more_buffer_headers);
}

/* Figure out how much memory's been allocated total for buffered
 * things */
static UINTVAL
calc_total_size(struct Parrot_Interp *interpreter, struct Memory_Pool *pool)
{
    UINTVAL size = 0;
    struct Memory_Block *block;
    for (block = pool->top_block; NULL != block; block = block->prev) {
        size += block->size;
    }
    return size;
}

/* Compact the buffer pool */
static void
compact_buffer_pool(struct Parrot_Interp *interpreter,
                    struct Memory_Pool *pool)
{
    UINTVAL total_size;
    struct Memory_Block *new_block;        /* A pointer to our working block */
    char *cur_spot;               /* Where we're currently copying to */
    UINTVAL cur_size;     /* How big our chunk is going to be */
    struct Buffer_Arena *cur_buffer_arena;
    struct Resource_Pool *header_pool;
    Buffer *b;   /* temporary tidy-up for free pool collection */

    /* Bail if we're blocked */
    if (interpreter->GC_block_level) {
        return;
    }

    /* We're collecting */
    interpreter->mem_allocs_since_last_collect = 0;
    interpreter->collect_runs++;

    /* Find out how much memory we've used so far. We're guaranteed to
     * use no more than this in our collection run */
    total_size = calc_total_size(interpreter, pool);
    /* Snag a block big enough for everything */
    new_block = alloc_new_block(interpreter, total_size, NULL);
  
    /* Start at the beginning */
    cur_spot = new_block->start;
  
    /* FIXME: This is a mess! */

    /* First collect the free string header pool */
    b = &interpreter->arena_base->string_header_pool->free_pool_buffer;
    memcpy(cur_spot, b->bufstart, b->buflen);
    b->bufstart = cur_spot;
    cur_size = b->buflen;
    cur_size = (cur_size + pool->align_1) & ~pool->align_1;
    cur_spot += cur_size;

    /* Collect the PMC header pool */
    b = &interpreter->arena_base->pmc_pool->free_pool_buffer;
    memcpy(cur_spot, b->bufstart, b->buflen);
    b->bufstart = cur_spot;
    cur_size = b->buflen;
    cur_size = (cur_size + pool->align_1) & ~pool->align_1;
    cur_spot += cur_size;

    /* And the buffer header pool */
    b = &interpreter->arena_base->buffer_header_pool->free_pool_buffer;
    memcpy(cur_spot, b->bufstart, b->buflen);
    b->bufstart = cur_spot;
    cur_size = b->buflen;
    cur_size = (cur_size + pool->align_1) & ~pool->align_1;
    cur_spot += cur_size;

    /* And the constant string header pool */
    b = &interpreter->arena_base->constant_string_header_pool->free_pool_buffer;
    memcpy(cur_spot, b->bufstart, b->buflen);
    b->bufstart = cur_spot;
    cur_size = b->buflen;
    cur_size = (cur_size + pool->align_1) & ~pool->align_1;
    cur_spot += cur_size;

    /* Run through all the Buffer header pools and copy */
    header_pool = interpreter->arena_base->buffer_header_pool;
    for (cur_buffer_arena = header_pool->last_Arena;
         NULL != cur_buffer_arena;
         cur_buffer_arena = cur_buffer_arena->prev) {
        UINTVAL i;
        Buffer *buffer_array = cur_buffer_arena->start_Buffer;
        for (i = 0; i < cur_buffer_arena->used; i++) {
            /* Is the string live, and can we move it? */
            if (buffer_array[i].flags & BUFFER_live_FLAG
                && !(buffer_array[i].flags & BUFFER_immobile_FLAG)
                && buffer_array[i].bufstart) {
                memcpy(cur_spot, buffer_array[i].bufstart,
                       buffer_array[i].buflen);
                buffer_array[i].bufstart = cur_spot;
                cur_size = buffer_array[i].buflen;
                cur_size = (cur_size + pool->align_1) & ~pool->align_1;
                cur_spot += cur_size;
            }
        }
    }

    /* Okay, we're done with the copy. Set the bits in the pool struct */
    /* First, where we allocate next */
    new_block->top = cur_spot;
    /* How much is free. That's the total size minus the amount we used */
    new_block->free = new_block->size - (new_block->top - new_block->start);

    interpreter->memory_collected += (new_block->top - new_block->start);

    /* Now we're done. Put us as the only block on the free list and
     * free the rest */
    {
        struct Memory_Block *cur_block, *next_block;
    
        cur_block = pool->top_block;
        while (cur_block) {
            next_block = cur_block->prev;
            /* Note that we don't have it any more */
            interpreter->memory_allocated -= cur_block->size;
            /* We know the pool body and pool header are a single chunk, so
               this is enough to get rid of 'em both */
            mem_sys_free(cur_block);
            cur_block = next_block;
        }

        /* Set our new pool as the only pool */
        pool->top_block = new_block;
        new_block->next = NULL;
        new_block->prev = NULL;
    }
}

/* Compact the string pool 
 * Ignore constants as these currently share the same header pool but use
 * different memory pools */
static void
compact_string_pool(struct Parrot_Interp *interpreter,
                    struct Memory_Pool *pool)
{
    UINTVAL total_size;
    struct Memory_Block *new_block;        /* A pointer to our working block */
    char *cur_spot;               /* Where we're currently copying to */
    UINTVAL cur_size;     /* How big our chunk is going to be */
    struct Buffer_Arena *cur_arena; /* The arena we're working on */
    struct Resource_Pool *header_pool;

    /* Bail if we're blocked */
    if (interpreter->GC_block_level) {
        return;
    }

    /* We're collecting */
    interpreter->mem_allocs_since_last_collect = 0;
    interpreter->collect_runs++;

    /* Find out how much memory we've used so far. We're guaranteed to
       use no more than this in our collection run */
    total_size = calc_total_size(interpreter, pool);
    /* Snag a block big enough for everything */
    new_block = alloc_new_block(interpreter, total_size, NULL);

    /* Start at the beginning */
    cur_spot = new_block->start;

    /* Run through all the STRING header pools and copy */
    header_pool = interpreter->arena_base->string_header_pool;
    for (cur_arena = header_pool->last_Arena;
         NULL != cur_arena;
         cur_arena = cur_arena->prev) {
        UINTVAL i;
        STRING *s = (STRING *)cur_arena->start_Buffer;

        for (i = 0; i < cur_arena->used; i++) {
            /* Is the string live, and can we move it? */
            if (s->flags & BUFFER_live_FLAG
                && !(s->flags & BUFFER_immobile_FLAG)
                && !(s->flags & BUFFER_constant_FLAG)
                && s->bufstart) {
                memcpy(cur_spot, s->bufstart, s->buflen);
                s->bufstart = cur_spot;
                cur_size = s->buflen;
                cur_size = (cur_size + pool->align_1) & ~pool->align_1;
                cur_spot += cur_size;
            }
            s++;
        }
    }

    /* Okay, we're done with the copy. Set the bits in the pool struct */
    /* First, where we allocate next */
    new_block->top = cur_spot;
    /* How much is free. That's the total size minus the amount we used */
    new_block->free = new_block->size - (new_block->top - new_block->start);
  
    interpreter->memory_collected += (new_block->top - new_block->start);

    /* Now we're done. Put us as the only block on the free list and
     * free the rest */
    {
        struct Memory_Block *cur_block, *next_block;
    
        cur_block = pool->top_block;
        while (cur_block) {
            next_block = cur_block->prev;
            /* Note that we don't have it any more */
            interpreter->memory_allocated -= cur_block->size;
            /* We know the pool body and pool header are a single chunk, so
               this is enough to get rid of 'em both */
            mem_sys_free(cur_block);
            cur_block = next_block;
        }

        /* Set our new pool as the only pool */
        pool->top_block = new_block;
        new_block->next = NULL;
        new_block->prev = NULL;
    }
}

/* Go do a GC run. This only scans the string pools and compacts them,
 * it doesn't check for string liveness */
void
Parrot_go_collect(struct Parrot_Interp *interpreter)
{
    compact_buffer_pool(interpreter, interpreter->arena_base->memory_pool);
    compact_string_pool(interpreter, interpreter->arena_base->string_pool);
}

/* Initialize the managed memory pools */
void
Parrot_initialize_memory_pools(struct Parrot_Interp *interpreter)
{
    /* Buffers */
    interpreter->arena_base->memory_pool = 
        mem_sys_allocate(sizeof(struct Memory_Pool));
    interpreter->arena_base->memory_pool->top_block = NULL;
    interpreter->arena_base->memory_pool->compact = &compact_buffer_pool;
    interpreter->arena_base->memory_pool->minimum_block_size = 16384;
    interpreter->arena_base->memory_pool->align_1 = 16 - 1;
    alloc_new_block(interpreter, 8192, 
                    interpreter->arena_base->memory_pool);

    /* Strings */
    interpreter->arena_base->string_pool = 
        mem_sys_allocate(sizeof(struct Memory_Pool));
    interpreter->arena_base->string_pool->top_block = NULL;
    interpreter->arena_base->string_pool->compact = &compact_string_pool;
    interpreter->arena_base->string_pool->minimum_block_size = 32768;
    interpreter->arena_base->string_pool->align_1 = 4 - 1;

    /* Constant strings - not compacted */
    interpreter->arena_base->constant_string_pool = 
        mem_sys_allocate(sizeof(struct Memory_Pool));
    interpreter->arena_base->constant_string_pool->top_block = NULL;
    interpreter->arena_base->constant_string_pool->compact = NULL;
    interpreter->arena_base->constant_string_pool->minimum_block_size = 8192;
    interpreter->arena_base->constant_string_pool->align_1 = 4 - 1;
}

/* Allocate a new memory block. We allocate the larger of however much
 * was asked for or the default size, whichever's larger */
static void *
alloc_new_block(struct Parrot_Interp *interpreter,
                       size_t size, struct Memory_Pool *pool)
{
    size_t alloc_size;
    struct Memory_Block *new_block;

    if (pool) {
        alloc_size = (size > pool->minimum_block_size) 
                   ? size : pool->minimum_block_size;
    }
    else {
        alloc_size = size;
    }

    /* Allocate a new block. Header info's on the front, plus a fudge
     * factor for good measure */
    new_block = mem_sys_allocate(sizeof(struct Memory_Block) + alloc_size + 32);
    if (!new_block) {
        return NULL;
    }

    new_block->free = alloc_size;
    new_block->size = alloc_size;
    new_block->next = NULL;
    new_block->prev = NULL;
    new_block->start = (char *)new_block + sizeof(struct Memory_Block);
    new_block->top = new_block->start;

    /* Note that we've allocated it */
    interpreter->memory_allocated += alloc_size;

    /* If this is for a public pool, add it to the list */
    if (pool) {
        new_block->prev = pool->top_block;
        /* If we're not first, then tack us on the list */
        if (pool->top_block) {
            pool->top_block->next = new_block;
        }
        pool->top_block = new_block;
    }
    return new_block;
}

/* Takes an interpreter, a buffer pointer, and a new size. The buffer
 * pointer is in as a void * because we may take a STRING or
 * something, and C doesn't subclass */
void *
Parrot_reallocate(struct Parrot_Interp *interpreter, void *from, size_t tosize)
{
    /* Put our void * pointer into something we don't have to cast
     * around with */
    Buffer *buffer;
    size_t copysize;
    size_t alloc_size = tosize;
    void *mem;

    buffer = from;
    copysize = (buffer->buflen > tosize ? tosize : buffer->buflen);

    mem = mem_allocate(interpreter, &alloc_size, 
                       interpreter->arena_base->memory_pool);
    if (!mem) {
        return NULL;
    }
    /* We shouldn't ever have a 0 from size, but we do. If we can
     * track down those bugs, this can be removed which would make
     * things cheaper */
    if (copysize) {
        memcpy(mem, buffer->bufstart, copysize);
    }
    buffer->bufstart = mem;
    buffer->buflen = tosize;
    return mem;
}

/* Takes an interpreter, a STRING pointer, and a new size. 
 * The destination may be bigger, since we round up to the allocation quantum */
void *
Parrot_reallocate_string(struct Parrot_Interp *interpreter, STRING *str, 
                         size_t tosize)
{
    size_t copysize;
    size_t alloc_size = tosize;
    void *mem;
    struct Memory_Pool *pool;

    copysize = (str->buflen > tosize ? tosize : str->buflen);
    pool = (str->flags & BUFFER_constant_FLAG)
         ? interpreter->arena_base->constant_string_pool
         : interpreter->arena_base->string_pool;

    mem = mem_allocate(interpreter, &alloc_size, pool);
    if (!mem) {
        return NULL;
    }
    /* We shouldn't ever have a 0 from size, but we do. If we can
     * track down those bugs, this can be removed which would make
     * things cheaper */
    if (copysize) {
        memcpy(mem, str->bufstart, copysize);
    }
    str->bufstart = mem;
    str->buflen = alloc_size;
    return mem;
}

/* Allocate exactly as much memory as they asked for */
void *
Parrot_allocate(struct Parrot_Interp *interpreter, void *buffer, size_t size)
{
    size_t req_size = size;
    ((Buffer *)buffer)->buflen = 0;
    ((Buffer *)buffer)->bufstart = NULL;
    ((Buffer *)buffer)->bufstart = mem_allocate(interpreter, &req_size, 
                       interpreter->arena_base->memory_pool);
    ((Buffer *)buffer)->buflen = size;
    return buffer;
}

/* Allocate at least as much memory as they asked for. We round the
 * amount up to the allocation quantum */
void *
Parrot_allocate_string(struct Parrot_Interp *interpreter, STRING *str, 
                       size_t size)
{
    size_t req_size = size;
    struct Memory_Pool *pool;

    str->buflen = 0;
    str->bufstart = NULL;

    if (!interpreter) {
        str->bufstart = mem_allocate(NULL, &req_size, NULL);
    }
    else {
        pool = (str->flags & BUFFER_constant_FLAG)
             ? interpreter->arena_base->constant_string_pool
             : interpreter->arena_base->string_pool;
        str->bufstart = mem_allocate(interpreter, &req_size, pool);
    }
    str->buflen = req_size;
    return str;
}

static void *
mem_allocate(struct Parrot_Interp *interpreter, size_t *req_size,
             struct Memory_Pool *pool)
{
    char *return_val;
    size_t size = *req_size;
    if (NULL == interpreter) {
        void *mem = mem_sys_allocate(size);
        return mem;
    }
#ifdef GC_DEBUG
    Parrot_go_collect(interpreter);
#endif

    /* Round up to requested alignment */
    size = (size + pool->align_1) & ~pool->align_1;

    /* If not enough room, try to find some */
    if (pool->top_block == NULL) {
        alloc_new_block(interpreter, size, pool);
        interpreter->mem_allocs_since_last_collect++;
    }
    if (pool->top_block->free < size) {
        if (pool->compact) {
          (*pool->compact)(interpreter, pool);
        }
        if (pool->top_block->free < size) {
            alloc_new_block(interpreter, size, pool);
            interpreter->mem_allocs_since_last_collect++;
            if (pool->top_block->free < size) {
                return NULL;
            }
        }
    }

    return_val = pool->top_block->top;
    pool->top_block->top += size;
    pool->top_block->free -= size;
    *req_size = size;
    return (void *)return_val;
}

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
