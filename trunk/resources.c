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

#include <assert.h>
#include "parrot/parrot.h"

#define RECLAMATION_FACTOR 0.20
#define MINIMUM_MEMPOOL_SIZE  1
#define MAXIMUM_MEMPOOL_SIZE  8


/** Parrot Memory Management Code **/

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
    new_block = mem_sys_allocate(sizeof(struct Memory_Block) + 
                                 alloc_size + 32);
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
        pool->total_allocated += alloc_size;
    }
    return new_block;
}

static void *
mem_allocate(struct Parrot_Interp *interpreter, size_t *req_size,
             struct Memory_Pool *pool, size_t align_1)
{
    char *return_val;
    size_t size = *req_size;
    if (NULL == interpreter) {
        void *mem = mem_sys_allocate(size);
        return mem;
    }

    /* Round up to requested alignment */
    size = (size + align_1) & ~align_1;

    /* If not enough room, try to find some */
    if (pool->top_block == NULL) {
        alloc_new_block(interpreter, size, pool);
        interpreter->mem_allocs_since_last_collect++;
    }
#if GC_DEBUG
    Parrot_do_dod_run(interpreter);
    if (pool->compact) {
        (*pool->compact)(interpreter, pool);
	}
#endif
    if (pool->top_block->free < size) {
        /* Compact the pool if allowed and worthwhile */
        if (pool->compact) {
             /* don't bother reclaiming if its just chicken feed */
            if (pool->reclaimable > 
                 (size_t)(pool->total_allocated * pool->reclaim_factor)
                 /* don't bother reclaiming if it won't even be enough */
                 && (pool->reclaimable > size)
                 ) 
            {
              (*pool->compact)(interpreter, pool);
            } 
            else {
                Parrot_do_dod_run(interpreter);
            }

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



/** Compaction Code **/

/* Compact the buffer pool */
static void compact_pool(struct Parrot_Interp *interpreter,
                         struct Memory_Pool *pool)
{
    UINTVAL total_size;
    struct Memory_Block *new_block;        /* A pointer to our working block */
    char *cur_spot;               /* Where we're currently copying to */
    UINTVAL cur_size;     /* How big our chunk is going to be */
    struct Small_Object_Arena *cur_buffer_arena;
    struct Small_Object_Pool *header_pool;
    INTVAL j;
    UINTVAL object_size;
    /* Bail if we're blocked */
    if (interpreter->GC_block_level) {
        return;
    }
    interpreter->GC_block_level++;

    /* We're collecting */
    interpreter->mem_allocs_since_last_collect = 0;
    interpreter->header_allocs_since_last_collect = 0;
    interpreter->collect_runs++;

    /* total-reclaimable == currently used. Add a minimum block to the
     * current amount, so we can avoid having to allocate it in the
     * future. */
    total_size = pool->total_allocated - pool->reclaimable + pool->minimum_block_size;
    /* total_size = pool->total_allocated; */
    /* TODO: can reduce this by pool->total_reclaimable if we want to 
     * be precise */
    /* Snag a block big enough for everything */
    new_block = alloc_new_block(interpreter, total_size, pool);
  
    /* Start at the beginning */
    cur_spot = new_block->start;
  
    /* Run through all the Buffer header pools and copy */
    for (j = -2; j < (INTVAL) interpreter->arena_base->num_sized; j++) {
        if (j == -2) header_pool = interpreter->arena_base->buffer_header_pool;
        else if (j == -1) header_pool = interpreter->arena_base->string_header_pool;
        else header_pool = interpreter->arena_base->sized_header_pools[j];
        if (header_pool == NULL) continue;
        
        object_size = header_pool->object_size;
        
        for (cur_buffer_arena = header_pool->last_Arena;
             NULL != cur_buffer_arena;
             cur_buffer_arena = cur_buffer_arena->prev)
        {
            Buffer *b = cur_buffer_arena->start_objects;
            UINTVAL i;
            for (i = 0; i < cur_buffer_arena->used; i++) {
                if (b->bufstart) {
                    /* Is the buffer live, and can we move it? */
                    if (!(b->flags & (BUFFER_on_free_list_FLAG | 
                                      BUFFER_constant_FLAG | 
                                      BUFFER_immobile_FLAG))) 
                    {
                        memcpy(cur_spot, b->bufstart, b->buflen);
                        b->bufstart = cur_spot;
                        cur_size = b->buflen;
                        cur_size = (cur_size + header_pool->align_1) & ~header_pool->align_1;
                        cur_spot += cur_size;
                    }
                }
                b = (Buffer *)((char *)b + object_size);
            }
        }
    }

    /* Run through all the out-of-band Buffer header pools and copy */
    for (j = 0; j < (INTVAL)( interpreter->arena_base->extra_buffer_headers.buflen / sizeof(Buffer*) ); j++) {
        Buffer** buffers = interpreter->arena_base->extra_buffer_headers.bufstart;
        Buffer* b = buffers[j];
        if (b->bufstart) {
            if (!(b->flags & (BUFFER_on_free_list_FLAG | 
                              BUFFER_constant_FLAG | 
                              BUFFER_immobile_FLAG)))
            {
                memcpy(cur_spot, b->bufstart, b->buflen);
                b->bufstart = cur_spot;
                cur_size = b->buflen;
                cur_size = (cur_size + BUFFER_ALIGNMENT - 1) & ~(BUFFER_ALIGNMENT - 1);
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

    /* Now we're done. We're already on the pool's free list, 
     * so let us be the only one on the free list and free the rest */
    {
        struct Memory_Block *cur_block, *next_block;
    
        assert( new_block == pool->top_block );
        cur_block = pool->top_block->prev;
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
        new_block->prev = NULL;
        pool->total_allocated = total_size;
        pool->reclaimable = 0;
    }

    interpreter->GC_block_level--;

}

/* Go do a GC run. This only scans the string pools and compacts them,
 * it doesn't check for string liveness */
void
Parrot_go_collect(struct Parrot_Interp *interpreter)
{
    compact_pool(interpreter, interpreter->arena_base->memory_pool);
}


/** Parrot Re/Allocate Code **/

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
    if (interpreter) {
        interpreter->arena_base->memory_pool->reclaimable +=
            buffer->buflen;
        mem = mem_allocate(interpreter, &alloc_size, 
                           interpreter->arena_base->memory_pool, BUFFER_ALIGNMENT-1);
    }
    else {
        mem = mem_allocate(NULL, &alloc_size, NULL, BUFFER_ALIGNMENT-1);
    }

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
         : interpreter->arena_base->memory_pool;
    pool->reclaimable += str->buflen;

    mem = mem_allocate(interpreter, &alloc_size, pool, STRING_ALIGNMENT-1);
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
                       interpreter->arena_base->memory_pool, BUFFER_ALIGNMENT-1);
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
        str->bufstart = mem_allocate(NULL, &req_size, NULL, STRING_ALIGNMENT-1);
    }
    else {
        pool = (str->flags & BUFFER_constant_FLAG)
             ? interpreter->arena_base->constant_string_pool
             : interpreter->arena_base->memory_pool;
        str->bufstart = mem_allocate(interpreter, &req_size, pool, STRING_ALIGNMENT-1);
    }
    str->buflen = req_size;
    return str;
}




/* Create a new memory pool */
static struct Memory_Pool *
new_memory_pool(size_t min_block, 
                void (*compact)(struct Parrot_Interp *, struct Memory_Pool *))
{
    struct Memory_Pool *pool;

    pool = mem_sys_allocate(sizeof(struct Memory_Pool));
    if (pool) {
        pool->top_block = NULL;
        pool->compact = compact;
        pool->minimum_block_size = min_block;
        pool->total_allocated = 0;
        pool->reclaimable = 0;
        pool->reclaim_factor = RECLAMATION_FACTOR;
    }
    return pool;
}

/* Initialize the managed memory pools */
void
Parrot_initialize_memory_pools(struct Parrot_Interp *interpreter)
{
    /* Buffers */
    interpreter->arena_base->memory_pool = 
        new_memory_pool(16384, 
                        &compact_pool);
    alloc_new_block(interpreter, 32768, 
                    interpreter->arena_base->memory_pool);

    /* Constant strings - not compacted */
    interpreter->arena_base->constant_string_pool = 
        new_memory_pool(8192, NULL);
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
