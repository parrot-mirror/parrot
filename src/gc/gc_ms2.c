/*
Copyright (C) 2001-2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/gc_tms.c - TriColour M&S

=head1 DESCRIPTION

=cut

*/

#include "parrot/parrot.h"
#include "parrot/gc_api.h"
#include "gc_private.h"
#include "list.h"
#include "pool_allocator.h"

#define PANIC_OUT_OF_MEM(size) failed_allocation(__LINE__, (size))

/* Private information */
typedef struct MarkSweep_GC {
    /* Allocator for PMC headers */
    struct Pool_Allocator *pmc_allocator;

    struct Linked_List    *objects;

    /** statistics for GC **/
    size_t  gc_mark_runs;       /* Number of times we've done a mark run */
    size_t  gc_lazy_mark_runs;  /* Number of successful lazy mark runs */
    size_t  gc_collect_runs;    /* Number of times we've done a memory
                                   compaction */
    size_t  mem_allocs_since_last_collect;      /* The number of memory
                                                 * allocations from the
                                                 * system since the last
                                                 * compaction run */
    size_t  header_allocs_since_last_collect;   /* The size of header
                                                 * blocks allocated from
                                                 * the system since the last
                                                 * GC run */
    /* GC blocking */
    UINTVAL gc_mark_block_level;  /* How many outstanding GC block
                                     requests are there? */
    UINTVAL gc_sweep_block_level; /* How many outstanding GC block
                                     requests are there? */

} MarkSweep_GC;

/* HEADERIZER HFILE: src/gc/gc_private.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_DOES_NOT_RETURN
static void failed_allocation(unsigned int line, unsigned long size);

static void gc_ms2_allocate_buffer_storage(SHIM_INTERP,
    ARGMOD(Buffer *buffer),
    size_t size)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*buffer);

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static Buffer* gc_ms2_allocate_bufferlike_header(SHIM_INTERP,
    SHIM(size_t size));

PARROT_CAN_RETURN_NULL
static void* gc_ms2_allocate_fixed_size_storage(SHIM_INTERP, size_t size);

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void * gc_ms2_allocate_memory_chunk(SHIM_INTERP, size_t size);

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void * gc_ms2_allocate_memory_chunk_zeroed(SHIM_INTERP, size_t size);

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static void* gc_ms2_allocate_pmc_attributes(SHIM_INTERP, ARGMOD(PMC *pmc))
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pmc);

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static PMC* gc_ms2_allocate_pmc_header(PARROT_INTERP, UINTVAL flags)
        __attribute__nonnull__(1);

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static STRING* gc_ms2_allocate_string_header(SHIM_INTERP,
    SHIM(UINTVAL flags));

static void gc_ms2_allocate_string_storage(SHIM_INTERP,
    ARGMOD(STRING *str),
    size_t size)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*str);

static void gc_ms2_block_GC_mark(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_ms2_block_GC_sweep(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_ms2_compact_memory_pool(SHIM_INTERP);
static void gc_ms2_free_bufferlike_header(SHIM_INTERP,
    ARGFREE(Buffer *b),
    SHIM(size_t size));

static void gc_ms2_free_fixed_size_storage(SHIM_INTERP,
    SHIM(size_t size),
    ARGMOD(void *data))
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*data);

static void gc_ms2_free_memory_chunk(SHIM_INTERP, ARGFREE(void *data));
static void gc_ms2_free_pmc_attributes(SHIM_INTERP, ARGMOD(PMC *pmc))
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*pmc);

static void gc_ms2_free_pmc_header(PARROT_INTERP, ARGFREE(PMC *pmc))
        __attribute__nonnull__(1);

static void gc_ms2_free_string_header(SHIM_INTERP, ARGFREE(STRING *s));
static size_t gc_ms2_get_gc_info(SHIM_INTERP, SHIM(Interpinfo_enum what));
static unsigned int gc_ms2_is_blocked_GC_mark(PARROT_INTERP)
        __attribute__nonnull__(1);

static unsigned int gc_ms2_is_blocked_GC_sweep(PARROT_INTERP)
        __attribute__nonnull__(1);

static int gc_ms2_is_pmc_ptr(PARROT_INTERP, ARGIN_NULLOK(void *ptr))
        __attribute__nonnull__(1);

static void gc_ms2_mark_and_sweep(PARROT_INTERP, UINTVAL flags)
        __attribute__nonnull__(1);

static void gc_ms2_mark_pmc_header(PARROT_INTERP, ARGIN(PMC *pmc))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

static void gc_ms2_mark_pobj_header(PARROT_INTERP, ARGIN_NULLOK(PObj * obj))
        __attribute__nonnull__(1);

static void gc_ms2_reallocate_buffer_storage(SHIM_INTERP,
    ARGMOD(Buffer *buffer),
    size_t size)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*buffer);

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void * gc_ms2_reallocate_memory_chunk(SHIM_INTERP,
    ARGFREE(void *from),
    size_t size);

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void * gc_ms2_reallocate_memory_chunk_zeroed(SHIM_INTERP,
    ARGFREE(void *data),
    size_t newsize,
    size_t oldsize);

static void gc_ms2_reallocate_string_storage(SHIM_INTERP,
    ARGMOD(STRING *str),
    size_t size)
        __attribute__nonnull__(2)
        FUNC_MODIFIES(*str);

static void gc_ms2_unblock_GC_mark(PARROT_INTERP)
        __attribute__nonnull__(1);

static void gc_ms2_unblock_GC_sweep(PARROT_INTERP)
        __attribute__nonnull__(1);

#define ASSERT_ARGS_failed_allocation __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_allocate_buffer_storage \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(buffer))
#define ASSERT_ARGS_gc_ms2_allocate_bufferlike_header \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_allocate_fixed_size_storage \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_allocate_memory_chunk __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_allocate_memory_chunk_zeroed \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_allocate_pmc_attributes \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(pmc))
#define ASSERT_ARGS_gc_ms2_allocate_pmc_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_allocate_string_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_allocate_string_storage \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(str))
#define ASSERT_ARGS_gc_ms2_block_GC_mark __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_block_GC_sweep __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_compact_memory_pool __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_free_bufferlike_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_free_fixed_size_storage \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(data))
#define ASSERT_ARGS_gc_ms2_free_memory_chunk __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_free_pmc_attributes __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(pmc))
#define ASSERT_ARGS_gc_ms2_free_pmc_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_free_string_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_get_gc_info __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_is_blocked_GC_mark __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_is_blocked_GC_sweep __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_is_pmc_ptr __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_mark_and_sweep __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_mark_pmc_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(pmc))
#define ASSERT_ARGS_gc_ms2_mark_pobj_header __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_reallocate_buffer_storage \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(buffer))
#define ASSERT_ARGS_gc_ms2_reallocate_memory_chunk \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_reallocate_memory_chunk_zeroed \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_gc_ms2_reallocate_string_storage \
     __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(str))
#define ASSERT_ARGS_gc_ms2_unblock_GC_mark __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
#define ASSERT_ARGS_gc_ms2_unblock_GC_sweep __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=head1 Functions

=over 4

=item C<static void gc_ms2_mark_and_sweep(PARROT_INTERP, UINTVAL flags)>

This function would perform a GC run, if we needed to. Luckily we have
infinite memory!

This function is called from the GC API function C<Parrot_gc_mark_and_sweep>.

Flags can be a combination of these values:

  GC_finish_FLAG
  GC_lazy_FLAG
  GC_trace_stack_FLAG

=cut

*/

/*

=item C<static void gc_ms2_compact_memory_pool(PARROT_INTERP)>

Stub for compacting memory pools.

=cut

*/
static void
gc_ms2_compact_memory_pool(SHIM_INTERP)
{
    ASSERT_ARGS(gc_ms2_compact_memory_pool)
}

/*

=item C<static PMC* gc_ms2_allocate_pmc_header(PARROT_INTERP, UINTVAL flags)>

=item C<static void gc_ms2_free_pmc_header(PARROT_INTERP, PMC *pmc)>

=item C<static STRING* gc_ms2_allocate_string_header(PARROT_INTERP, UINTVAL
flags)>

=item C<static void gc_ms2_free_string_header(PARROT_INTERP, STRING *s)>

=item C<static Buffer* gc_ms2_allocate_bufferlike_header(PARROT_INTERP, size_t
size)>

=item C<static void gc_ms2_free_bufferlike_header(PARROT_INTERP, Buffer *b,
size_t size)>

=item C<static void* gc_ms2_allocate_pmc_attributes(PARROT_INTERP, PMC *pmc)>

=item C<static void gc_ms2_free_pmc_attributes(PARROT_INTERP, PMC *pmc)>

=item C<static void gc_ms2_allocate_string_storage(PARROT_INTERP, STRING *str,
size_t size)>

=item C<static void gc_ms2_reallocate_string_storage(PARROT_INTERP, STRING *str,
size_t size)>

=item C<static void gc_ms2_allocate_buffer_storage(PARROT_INTERP, Buffer
*buffer, size_t size)>

=item C<static void gc_ms2_reallocate_buffer_storage(PARROT_INTERP, Buffer
*buffer, size_t size)>

=item C<static void* gc_ms2_allocate_fixed_size_storage(PARROT_INTERP, size_t
size)>

=item C<static void gc_ms2_free_fixed_size_storage(PARROT_INTERP, size_t size,
void *data)>

Functions for allocating/deallocating various objects.

*/

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static STRING*
gc_ms2_allocate_string_header(SHIM_INTERP, SHIM(UINTVAL flags))
{
    ASSERT_ARGS(gc_ms2_allocate_string_header)
    return (STRING*)calloc(sizeof (STRING), 1);
}

static void
gc_ms2_free_string_header(SHIM_INTERP, ARGFREE(STRING *s))
{
    ASSERT_ARGS(gc_ms2_free_string_header)
    if (s)
        free(s);
}

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static Buffer*
gc_ms2_allocate_bufferlike_header(SHIM_INTERP, SHIM(size_t size))
{
    ASSERT_ARGS(gc_ms2_allocate_bufferlike_header)
    return (Buffer*)calloc(sizeof (Buffer), 1);
}

static void
gc_ms2_free_bufferlike_header(SHIM_INTERP, ARGFREE(Buffer *b), SHIM(size_t size))
{
    ASSERT_ARGS(gc_ms2_free_bufferlike_header)
    if (b)
        free(b);
}

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static void*
gc_ms2_allocate_pmc_attributes(SHIM_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(gc_ms2_allocate_pmc_attributes)
    const size_t attr_size = pmc->vtable->attr_size;
    PMC_data(pmc) = calloc(attr_size, 1);
    return PMC_data(pmc);
}

static void
gc_ms2_free_pmc_attributes(SHIM_INTERP, ARGMOD(PMC *pmc))
{
    ASSERT_ARGS(gc_ms2_free_pmc_attributes)
    if (PMC_data(pmc))
        free(PMC_data(pmc));
}


static void
gc_ms2_allocate_string_storage(SHIM_INTERP, ARGMOD(STRING *str), size_t size)
{
    ASSERT_ARGS(gc_ms2_allocate_string_storage)

    Buffer_buflen(str)   = size;

    if (size > 0) {
        char * const mem = (char *)mem_internal_allocate(size);

        Buffer_bufstart(str) = str->strstart = mem;
    }
    else {
        Buffer_bufstart(str) = NULL;
    }
}

static void
gc_ms2_reallocate_string_storage(SHIM_INTERP, ARGMOD(STRING *str), size_t size)
{
    ASSERT_ARGS(gc_ms2_reallocate_string_storage)
    char * const mem     = (char *)mem_internal_realloc(Buffer_bufstart(str), size);

    Buffer_bufstart(str) = str->strstart = mem;
    Buffer_buflen(str)   = size;
}


static void
gc_ms2_allocate_buffer_storage(SHIM_INTERP, ARGMOD(Buffer *buffer), size_t size)
{
    ASSERT_ARGS(gc_ms2_allocate_buffer_storage)
    char *mem;

    Buffer_buflen(buffer)   = 0;
    Buffer_bufstart(buffer) = NULL;

    if (size == 0)
        return;

    mem      = (char *)mem_internal_allocate(size);

    Buffer_bufstart(buffer) = mem;
    Buffer_buflen(buffer)   = size;
}

static void
gc_ms2_reallocate_buffer_storage(SHIM_INTERP, ARGMOD(Buffer *buffer), size_t size)
{
    ASSERT_ARGS(gc_ms2_reallocate_buffer_storage)
    char * const mem = (char *)mem_internal_realloc(Buffer_bufstart(buffer), size);

    Buffer_bufstart(buffer) = mem;
    Buffer_buflen(buffer)   = size;
}

PARROT_CAN_RETURN_NULL
static void*
gc_ms2_allocate_fixed_size_storage(SHIM_INTERP, size_t size)
{
    ASSERT_ARGS(gc_ms2_allocate_fixed_size_storage)
    return calloc(size, 1);
}

static void
gc_ms2_free_fixed_size_storage(SHIM_INTERP, SHIM(size_t size), ARGMOD(void *data))
{
    ASSERT_ARGS(gc_ms2_free_fixed_size_storage)
    if (data)
        mem_internal_free(data);
}

/*

=item C<static size_t gc_ms2_get_gc_info(PARROT_INTERP, Interpinfo_enum what)>

Stub for GC introspection function.

=cut

*/
static size_t
gc_ms2_get_gc_info(SHIM_INTERP, SHIM(Interpinfo_enum what))
{
    ASSERT_ARGS(gc_ms2_get_gc_info)
    return 0;
}




/*

=item C<void Parrot_gc_ms2_init(PARROT_INTERP)>

Initializes the infinite memory collector. Installs the necessary function
pointers into the Memory_Pools structure. The two most important are the
C<mark_and_sweep> and C<pool_init> functions. C<finalize_gc_system> function
will be called at Parrot exit and will shut down the GC system if things
need to be flushed/closed/deactivated/freed/etc. It can be set to NULL if no
finalization is necessary.

=cut

*/

void
Parrot_gc_ms2_init(PARROT_INTERP)
{
    ASSERT_ARGS(Parrot_gc_ms2_init)
    struct MarkSweep_GC *self;

    interp->gc_sys->do_gc_mark         = gc_ms2_mark_and_sweep;
    interp->gc_sys->finalize_gc_system = NULL;

    interp->gc_sys->do_gc_mark              = gc_ms2_mark_and_sweep;
    interp->gc_sys->compact_string_pool     = gc_ms2_compact_memory_pool;

    /*
    interp->gc_sys->mark_special                = gc_ms2_mark_special;
    interp->gc_sys->pmc_needs_early_collection  = gc_ms2_pmc_needs_early_collection;
    */

    interp->gc_sys->allocate_pmc_header     = gc_ms2_allocate_pmc_header;
    interp->gc_sys->free_pmc_header         = gc_ms2_free_pmc_header;

    interp->gc_sys->allocate_string_header  = gc_ms2_allocate_string_header;
    interp->gc_sys->free_string_header      = gc_ms2_free_string_header;

    interp->gc_sys->allocate_bufferlike_header  = gc_ms2_allocate_bufferlike_header;
    interp->gc_sys->free_bufferlike_header      = gc_ms2_free_bufferlike_header;

    interp->gc_sys->allocate_pmc_attributes = gc_ms2_allocate_pmc_attributes;
    interp->gc_sys->free_pmc_attributes     = gc_ms2_free_pmc_attributes;

    interp->gc_sys->is_pmc_ptr              = gc_ms2_is_pmc_ptr;
    interp->gc_sys->mark_pmc_header         = gc_ms2_mark_pmc_header;
    interp->gc_sys->mark_pobj_header        = gc_ms2_mark_pobj_header;

    interp->gc_sys->block_mark      = gc_ms2_block_GC_mark;
    interp->gc_sys->unblock_mark    = gc_ms2_unblock_GC_mark;
    interp->gc_sys->is_blocked_mark = gc_ms2_is_blocked_GC_mark;

    interp->gc_sys->block_sweep      = gc_ms2_block_GC_sweep;
    interp->gc_sys->unblock_sweep    = gc_ms2_unblock_GC_sweep;
    interp->gc_sys->is_blocked_sweep = gc_ms2_is_blocked_GC_sweep;

    interp->gc_sys->allocate_string_storage = gc_ms2_allocate_string_storage;
    interp->gc_sys->reallocate_string_storage = gc_ms2_reallocate_string_storage;

    interp->gc_sys->allocate_buffer_storage = gc_ms2_allocate_buffer_storage;
    interp->gc_sys->reallocate_buffer_storage = gc_ms2_reallocate_buffer_storage;

    interp->gc_sys->allocate_fixed_size_storage = gc_ms2_allocate_fixed_size_storage;
    interp->gc_sys->free_fixed_size_storage     = gc_ms2_free_fixed_size_storage;

    /* We don't distinguish between chunk and chunk_with_pointers */
    interp->gc_sys->allocate_memory_chunk   = gc_ms2_allocate_memory_chunk;
    interp->gc_sys->reallocate_memory_chunk = gc_ms2_reallocate_memory_chunk;
    interp->gc_sys->allocate_memory_chunk_with_interior_pointers
                = gc_ms2_allocate_memory_chunk_zeroed;
    interp->gc_sys->reallocate_memory_chunk_with_interior_pointers
                = gc_ms2_reallocate_memory_chunk_zeroed;
    interp->gc_sys->free_memory_chunk       = gc_ms2_free_memory_chunk;

    interp->gc_sys->get_gc_info      = gc_ms2_get_gc_info;

    if (interp->parent_interpreter && interp->parent_interpreter->gc_sys) {
        /* This is a "child" interpreter. Just reuse parent one */
        self = (MarkSweep_GC*)interp->parent_interpreter->gc_sys->gc_private;
    }
    else {
        self = mem_allocate_zeroed_typed(MarkSweep_GC);

        self->pmc_allocator = Parrot_gc_create_pool_allocator(
            sizeof (List_Item_Header) + sizeof (PMC));

        self->objects = Parrot_gc_allocate_linked_list(interp);

    }
    interp->gc_sys->gc_private = self;
}

PARROT_MALLOC
PARROT_CAN_RETURN_NULL
static PMC*
gc_ms2_allocate_pmc_header(PARROT_INTERP, UINTVAL flags)
{
    ASSERT_ARGS(gc_ms2_allocate_pmc_header)
    MarkSweep_GC      *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    List_Item_Header *ptr;
    PMC              *ret;

    /* Invoke M&S early. Freshly allocated "header" isn't header yet */
    if (++self->header_allocs_since_last_collect > 1024) {
        gc_ms2_mark_and_sweep(interp, 0);
    }

    ptr = (List_Item_Header *)Parrot_gc_pool_allocate(interp,
        self->pmc_allocator);
    LIST_APPEND(self->objects, ptr);

    ret = LLH2Obj_typed(ptr, PMC);

    /* Quick hack to register "constant" pmcs */
    if (flags & PObj_constant_FLAG) {
        //Parrot_pmc_gc_register(interp, ret);
    }

    return ret;
}

static void
gc_ms2_free_pmc_header(PARROT_INTERP, ARGFREE(PMC *pmc))
{
    ASSERT_ARGS(gc_ms2_free_pmc_header)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    if (pmc) {
        if (PObj_on_free_list_TEST(pmc))
            return;
        Parrot_gc_list_remove(interp, self->objects, Obj2LLH(pmc));
        PObj_on_free_list_SET(pmc);
        Parrot_gc_pool_free(self->pmc_allocator, Obj2LLH(pmc));
    }
}

static void
gc_ms2_mark_and_sweep(PARROT_INTERP, UINTVAL flags)
{
    ASSERT_ARGS(gc_ms2_mark_and_sweep)
    MarkSweep_GC      *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    List_Item_Header *tmp;
    Linked_List      *list;
    size_t            counter;
    UNUSED(flags);

    /* GC is blocked */
    if (self->gc_mark_block_level)
        return;

    if (flags & GC_finish_FLAG) {
        /* FIXME Cleanup here */
        return;
    }

    ++self->gc_mark_block_level;

    gc_ms2_mark_pmc_header(interp, PMCNULL);

    Parrot_gc_trace_root(interp, NULL, GC_TRACE_FULL);

    if (interp->pdb && interp->pdb->debugger) {
        Parrot_gc_trace_root(interp->pdb->debugger, NULL, (Parrot_gc_trace_type)0);
    }


    tmp = self->objects->first;
    counter = 0;
    while (tmp) {
        List_Item_Header *next = tmp->next;
        PMC              *pmc  = LLH2Obj_typed(tmp, PMC);
        if (PObj_live_TEST(pmc)) {
            /* Paint live objects white */
            PObj_live_CLEAR(pmc);
        }
        else if (!PObj_constant_TEST(pmc)) {
            PObj_on_free_list_SET(pmc);
            LIST_REMOVE(self->objects, tmp);
            Parrot_gc_pool_free(self->pmc_allocator, tmp);
        }
        tmp = next;
        ++counter;
    }

    self->header_allocs_since_last_collect = 0;
    self->gc_mark_block_level--;
    self->gc_mark_runs++;
}

/*

=item C<static void gc_ms2_mark_pmc_header(PARROT_INTERP, PMC *pmc)>

mark as grey

=cut

*/

static void
gc_ms2_mark_pmc_header(PARROT_INTERP, ARGIN(PMC *pmc))
{
    ASSERT_ARGS(gc_ms2_mark_pmc_header)
    MarkSweep_GC      *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    List_Item_Header  *item = Obj2LLH(pmc);

    /* Object was already marked as grey. Or live. Or dead. Skip it */
    if (PObj_is_live_or_free_TESTALL(pmc))
        return;

    /* mark it live */
    PObj_live_SET(pmc);

    /* if object is a PMC and contains buffers or PMCs, then attach the PMC
     * to the chained mark list. */
    if (PObj_is_special_PMC_TEST(pmc)) {
        if (PObj_custom_mark_TEST(pmc))
            VTABLE_mark(interp, pmc);
    }

    if (PMC_metadata(pmc))
        Parrot_gc_mark_PMC_alive(interp, PMC_metadata(pmc));
}

/*

=item C<static int gc_ms2_is_pmc_ptr(PARROT_INTERP, void *ptr)>

establish if *ptr is.owned

=cut

*/

static int
gc_ms2_is_pmc_ptr(PARROT_INTERP, ARGIN_NULLOK(void *ptr))
{
    ASSERT_ARGS(gc_ms2_is_pmc_ptr)
    MarkSweep_GC      *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    List_Item_Header *item = Obj2LLH(ptr);
    PMC              *pmc  = (PMC *)ptr;

    if (!ptr || !item)
        return 0;

    if (!Parrot_gc_pool_is_owned(self->pmc_allocator, item))
        return 0;

    /* black or white objects marked already. */
    if (PObj_is_live_or_free_TESTALL(pmc))
        return 0;

    /* Pool.is_owned isn't precise enough (yet) */
    if (Parrot_gc_list_is_owned(interp, self->objects, item))
        return 1;

    /* We don't care about non-dead objects here. They will be marked anyway */
    return 0;
}

/*

=item C<static void gc_ms2_mark_pobj_header(PARROT_INTERP, PObj * obj)>

if already marked mark as grey else make as live

=cut

*/

static void
gc_ms2_mark_pobj_header(PARROT_INTERP, ARGIN_NULLOK(PObj * obj))
{
    ASSERT_ARGS(gc_ms2_mark_pobj_header)
    if (obj) {
        if (PObj_is_PMC_TEST(obj))
            gc_ms2_mark_pmc_header(interp, (PMC *)obj);
        else
            PObj_live_SET(obj);
    }
}


/*

=item C<static void gc_ms2_block_GC_mark(PARROT_INTERP)>

Blocks the GC from performing its mark phase.

=item C<static void gc_ms2_unblock_GC_mark(PARROT_INTERP)>

Unblocks the GC mark.

=item C<static void gc_ms2_block_GC_sweep(PARROT_INTERP)>

Blocks the GC from performing its sweep phase.

=item C<static void gc_ms2_unblock_GC_sweep(PARROT_INTERP)>

Unblocks GC sweep.

=item C<static unsigned int gc_ms2_is_blocked_GC_mark(PARROT_INTERP)>

Determines if the GC mark is currently blocked.

=item C<static unsigned int gc_ms2_is_blocked_GC_sweep(PARROT_INTERP)>

Determines if the GC sweep is currently blocked.

=cut

*/

static void
gc_ms2_block_GC_mark(PARROT_INTERP)
{
    ASSERT_ARGS(gc_ms2_block_GC_mark)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    ++self->gc_mark_block_level;
    Parrot_shared_gc_block(interp);
}

static void
gc_ms2_unblock_GC_mark(PARROT_INTERP)
{
    ASSERT_ARGS(gc_ms2_unblock_GC_mark)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    if (self->gc_mark_block_level) {
        --self->gc_mark_block_level;
        Parrot_shared_gc_unblock(interp);
    }
}

static void
gc_ms2_block_GC_sweep(PARROT_INTERP)
{
    ASSERT_ARGS(gc_ms2_block_GC_sweep)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    ++self->gc_sweep_block_level;
}

static void
gc_ms2_unblock_GC_sweep(PARROT_INTERP)
{
    ASSERT_ARGS(gc_ms2_unblock_GC_sweep)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    if (self->gc_sweep_block_level)
        --self->gc_sweep_block_level;
}

static unsigned int
gc_ms2_is_blocked_GC_mark(PARROT_INTERP)
{
    ASSERT_ARGS(gc_ms2_is_blocked_GC_mark)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    return self->gc_mark_block_level;
}

static unsigned int
gc_ms2_is_blocked_GC_sweep(PARROT_INTERP)
{
    ASSERT_ARGS(gc_ms2_is_blocked_GC_sweep)
    MarkSweep_GC *self = (MarkSweep_GC *)interp->gc_sys->gc_private;
    return self->gc_sweep_block_level;
}



/*

=item C<static void * gc_ms2_allocate_memory_chunk(PARROT_INTERP, size_t size)>

=item C<static void * gc_ms2_reallocate_memory_chunk(PARROT_INTERP, void *from,
size_t size)>

=item C<static void * gc_ms2_allocate_memory_chunk_zeroed(PARROT_INTERP, size_t
size)>

=item C<static void * gc_ms2_reallocate_memory_chunk_zeroed(PARROT_INTERP, void
*data, size_t newsize, size_t oldsize)>

=item C<static void gc_ms2_free_memory_chunk(PARROT_INTERP, void *data)>

=item C<static void failed_allocation(unsigned int line, unsigned long size)>

TODO Write docu.

*/

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void *
gc_ms2_allocate_memory_chunk(SHIM_INTERP, size_t size)
{
    ASSERT_ARGS(gc_ms2_allocate_memory_chunk)
    void * const ptr = malloc(size);
#ifdef DETAIL_MEMORY_DEBUG
    fprintf(stderr, "Allocated %i at %p\n", size, ptr);
#endif
    if (!ptr)
        PANIC_OUT_OF_MEM(size);
    return ptr;
}

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void *
gc_ms2_reallocate_memory_chunk(SHIM_INTERP, ARGFREE(void *from), size_t size)
{
    ASSERT_ARGS(gc_ms2_reallocate_memory_chunk)
    void *ptr;
#ifdef DETAIL_MEMORY_DEBUG
    fprintf(stderr, "Freed %p (realloc -- %i bytes)\n", from, size);
#endif
    if (from)
        ptr = realloc(from, size);
    else
        ptr = calloc(1, size);
#ifdef DETAIL_MEMORY_DEBUG
    fprintf(stderr, "Allocated %i at %p\n", size, ptr);
#endif
    if (!ptr)
        PANIC_OUT_OF_MEM(size);
    return ptr;
}

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void *
gc_ms2_allocate_memory_chunk_zeroed(SHIM_INTERP, size_t size)
{
    ASSERT_ARGS(gc_ms2_allocate_memory_chunk_zeroed)
    void * const ptr = calloc(1, (size_t)size);
#ifdef DETAIL_MEMORY_DEBUG
    fprintf(stderr, "Allocated %i at %p\n", size, ptr);
#endif
    if (!ptr)
        PANIC_OUT_OF_MEM(size);
    return ptr;
}

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
static void *
gc_ms2_reallocate_memory_chunk_zeroed(SHIM_INTERP, ARGFREE(void *data),
        size_t newsize, size_t oldsize)
{
    ASSERT_ARGS(gc_ms2_reallocate_memory_chunk_zeroed)
    void * const ptr = realloc(data, newsize);
    if (newsize > oldsize)
        memset((char*)ptr + oldsize, 0, newsize - oldsize);
    return ptr;
}

static void
gc_ms2_free_memory_chunk(SHIM_INTERP, ARGFREE(void *data))
{
    ASSERT_ARGS(gc_ms2_free_memory_chunk)
#ifdef DETAIL_MEMORY_DEBUG
    fprintf(stderr, "Freed %p\n", data);
#endif
    if (data)
        free(data);
}

PARROT_DOES_NOT_RETURN
static void
failed_allocation(unsigned int line, unsigned long size)
{
    ASSERT_ARGS(failed_allocation)
    fprintf(stderr, "Failed allocation of %lu bytes\n", size);
    do_panic(NULL, "Out of mem", __FILE__, line);
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
