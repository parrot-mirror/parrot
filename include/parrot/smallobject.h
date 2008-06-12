/*
 * $Id$
 * Copyright (C) 2002-2008, The Perl Foundation
 */

#ifndef PARROT_SMALLOBJECT_H_GUARD
#define PARROT_SMALLOBJECT_H_GUARD

#  include "parrot/parrot.h"

typedef struct Small_Object_Arena {
    size_t                     used;
    size_t                     total_objects;
    struct Small_Object_Arena *prev;
    struct Small_Object_Arena *next;
    void                      *start_objects;
#if PARROT_GC_IT
    struct _gc_it_card        *cards;
    union {        /* store 2 16-bit values, force UINTVAL alignment */
        struct {   /* These shouldn't get bigger then 65535, i don't think */
            unsigned           card_size:16;
            unsigned           last_index:16;
        } _d;
        UINTVAL                _align_x;
    } _card
#endif
} Small_Object_Arena;

struct Small_Object_Pool;

typedef void (*add_free_object_fn_type)(PARROT_INTERP, struct Small_Object_Pool *, void *);
typedef void * (*get_free_object_fn_type)(PARROT_INTERP, struct Small_Object_Pool *);
typedef void (*alloc_objects_fn_type)(PARROT_INTERP, struct Small_Object_Pool *);
typedef void (*dod_object_fn_type)(PARROT_INTERP, struct Small_Object_Pool *, PObj *);

#if PARROT_GC_GMS
/*
 * all objects have this header in front of the actual
 * object pointer. The prev/next pointers chain all existing
 * objects for one pool (sizeclass) together.
 *
 * XXX this could lead to unaligned FLOATVALs in the adjacent PMC
 *     if that's true either insert a dummy or reorder PMC members
 *     ??? How is that possible?
 */
typedef struct _gc_gms_hdr {
    struct _gc_gms_hdr *prev;
    struct _gc_gms_hdr *next;
    struct _gc_gms_gen *gen;
    void *gc_dummy_align;       /* see above */
} Gc_gms_hdr;

#  define PObj_to_GMSH(o) (((Gc_gms_hdr*)(o))-1)
#  define GMSH_to_PObj(p) ((PObj*) ((p)+1))

/* the structure uses 2 ptrs itself */
#  define GC_GMS_STORE_SIZE (64-2)

typedef struct _gc_gms_hdr_store {
    struct _gc_gms_hdr_store *next;
    Gc_gms_hdr **ptr;                           /* insert location */
    Gc_gms_hdr * (store[GC_GMS_STORE_SIZE]);    /* array of hdr pointers */
} Gc_gms_hdr_store;

typedef struct _gc_gms_hdr_list {
    Gc_gms_hdr_store *first;
    Gc_gms_hdr_store *last;
} Gc_gms_hdr_list;


/*
 * all objects belong to one generation
 */
typedef struct _gc_gms_gen {
    UINTVAL gen_no;                     /* generation number */
    UINTVAL timely_destruct_obj_sofar;  /* sum up to this generation */
    UINTVAL black_color;                /* live color of this generation */
    struct _gc_gms_hdr *first;          /* first header in this generation */
    struct _gc_gms_hdr *last;           /* last header in this generation */
    struct _gc_gms_hdr *fin;            /* need destruction/finalization */
    struct Small_Object_Pool *pool;     /* where this generation belongs to */
    Gc_gms_hdr_list igp;                /* IGPs for this generation */
    UINTVAL n_possibly_dead;            /* overwritten count */
    UINTVAL n_objects;                  /* live objects count */
    struct _gc_gms_gen *prev;
    struct _gc_gms_gen *next;
} Gc_gms_gen;

#endif /* PARROT_GC_GMS */

#if PARROT_GC_IT /* Incremental Tricolor Garbage Collector, PDD09 */

/* Switches and modes */

#define GC_IT_INCREMENT_MODE 1
/* #define GC_IT_BATCH_MODE 1 */
#define GC_IT_SERIAL_MODE 1
/* #define GC_IT_PARALLEL_MODE 1 */

#ifdef GC_IT_PARALLEL_MODE
#   define GC_IT_THREAD_MAX 4
#endif

#define GC_IT_INITIAL_CONFIG XXX /* define this to be whatever */

/*
 * Header, a linked list.
 Contains a link to the pool/arena (don't know which) that contains this item
 Contains a link to the next header, to form linked lists.
 Contains an index number that represents the position of the item in the pool
 this item is not manipulated once set, unless the object (including the
   header) is moved to somewhere else.
 */
typedef struct _gc_it_hdr {
    struct _gc_it_hdr *next;
    Small_Object_Arena * parent_pool;
    UINTVAL index;
} Gc_it_hdr;

/*
 * a basic structure to facilitate cardmarking. An array of these will represent
 * the card for a particular pool. Using uchar for the basic card element,
 * and assuming that a uchar is always 8bits or greater (we are simply ignoring
 * any additional bits)
 * The bitfield member will allow us to unwind the inner loop a little bit, and
 * avoid a lot of manual bitwise arithmetic
 */

typedef union _gc_it_card {
    unsigned char _c;  /* the card */
    struct _card_flag_overlay { /* easy-access bitfield overlays */
        unsigned flag1:2;
        unsigned flag2:2;
        unsigned flag3:2;
        unsigned flag4:2;
    } _f;
} Gc_it_card;

#define GC_IT_FLAGS_PER_CARD 4
#define GC_IT_CARD_WHITE 0x00
#define GC_IT_CARD_GREY  0x01
#define GC_IT_CARD_BLACK 0x03
#define GC_IT_CARD_NEW   0x02       /* items which are newly created and should
                                       not be scanned until the next mark */
#define GC_IT_CARD_ALL_WHITE 0x00
#define GC_IT_CARD_ALL_BLACK 0xFF
#define GC_IT_CARD_ALL_GREY  0x55
#define GC_IT_CARD_ALL_NEW   0xAA

#define PObj_to_IT_HDR(o) (((Gc_it_hdr*)(o))-1)
#define IT_HDR_to_PObj(p) ((PObj*) ((p)+1))

/*
 * Structure to define individual generations.
 * Initially borrowed from the GC_GMS
 */

typedef struct _gc_it_gen {
    UINTVAL gen_no;                     /* generation number */
    UINTVAL timely_destruct_obj_sofar;  /* sum up to this generation */
    struct _gc_it_hdr *first;           /* first header in this generation */
    struct _gc_it_hdr *last;            /* last header in this generation */
    struct _gc_it_hdr *finalize;        /* need destruction/finalization */
    struct Small_Object_Pool *pool;     /* where this generation belongs to */
    Gc_gms_hdr_list igp;                /* IGPs for this generation */
    UINTVAL n_possibly_dead;            /* overwritten count */
    UINTVAL n_objects;                  /* live objects count */
    struct _gc_gms_gen *prev;
    struct _gc_gms_gen *next;
} Gc_gms_gen;

/*
 * Other structures to help with generational capabilities.
 * Borrowed from GC_GMS, initially. I actually don't think I need these
 * store structures, so I'll probably delete them
 */

#  define GC_IT_STORE_SIZE (64-2)

typedef struct _gc_it_hdr_store {
    struct _gc_it_hdr_store *next;
    Gc_it_hdr **ptr;                           /* insert location */
    Gc_it_hdr * (store[GC_IT_STORE_SIZE]);     /* array of hdr pointers */
} Gc_it_hdr_store;

typedef struct _gc_it_hdr_list {
    Gc_it_hdr_store *first;
    Gc_it_hdr_store *last;
} Gc_it_hdr_list;

/*
 * GC States
 * Determines where in a sweep the GC is
 */

typedef enum _gc_it_state {
    GC_IT_READY = 0,
    GC_IT_START_MARK,
    GC_IT_RESUME_MARK,
    GC_IT_START_SWEEP,
    GC_IT_RESUME_SWEEP,
    GC_IT_START_BUFFERS,
    GC_IT_START_CLEANUP
} Gc_it_state;

/* Structure to contain configuration data about the GC, to determine
   how it operates */

typedef struct _gc_it_config {
    UINTVAL num_to_mark;
}

/* A private datastructure for the GC. All the global data that we need to
   operate will be stored here. */

typedef struct _gc_it_data {
    UINTVAL item_count;       /* number of items scanned in current run */
    UINTVAL total_count;      /* number of items scanned since beginning of mark phase */
    UINTVAL num_generations;  /* number of generations */
    Gc_it_state state;            /* status of the current run */
    Gc_it_config config;           /* config data to tell how the GC operates */
#if GC_IT_PARALLEL_MODE
    UINTVAL num_threads;    /* number of currently active threads */
#endif
} Gc_it_data;

/*
 * GC data per pool. Contains information that the GC needs in every pool.
 * This structure is changing rapidly, and some of the things in it are
 * probably unnecessary.
 */
typedef struct _gc_it_pool_data {
    Gc_it_gen * first_gen;  /* linked list of generations, youngest first, i assume */
    Gc_it_gen * last_gen;   /* Most recent generation, or oldest, or whatever */
    /* struct _gc_it_hdr * items;          all items not in queue or finalized */
    struct _gc_it_hdr * queue;          /* list of grey items, to mark */
    struct _gc_it_hdr * new_list;       /* list of items created before the end of the scan */
} Gc_it_pool_data;

#endif /* PARROT_GC_IT */

/* Tracked resource pool */
typedef struct Small_Object_Pool {
    Small_Object_Arena *last_Arena;
    /* Size in bytes of an individual pool item. This size may include
     * a GC-system specific GC header.
     * See the macros below.
     */
    size_t object_size;
    size_t objects_per_alloc;
    size_t total_objects;
    size_t num_free_objects;    /* number of resources in the free pool */
    int skip;
    size_t replenish_level;
    void *free_list;
    /* adds a free object to the pool's free list  */
    add_free_object_fn_type     add_free_object;
    get_free_object_fn_type     get_free_object;
    alloc_objects_fn_type       alloc_objects;
    alloc_objects_fn_type       more_objects;
    dod_object_fn_type          dod_object;
    /* gets and removes a free object from the pool's free list */
    /* allocates more objects */
    struct Memory_Pool *mem_pool;
    size_t start_arena_memory;
    size_t end_arena_memory;
    const char *name;
#if PARROT_GC_GMS
    struct _gc_gms_hdr marker;          /* limit of list */
    struct _gc_gms_hdr *black;          /* alive */
    struct _gc_gms_hdr *black_fin;      /* alive, needs destruction */
    struct _gc_gms_hdr *gray;           /* to be scanned */
    struct _gc_gms_hdr *white;          /* unprocessed */
    struct _gc_gms_hdr *white_fin;      /* unprocessed, needs destruction */

    struct _gc_gms_gen *first_gen;      /* linked list of generations */
    struct _gc_gms_gen *last_gen;
#endif
#if PARROT_GC_IT
    struct _gc_it_pool_data gc_it_pool_data; /* Data for use by the IT GC */
#endif
} Small_Object_Pool;

/*
 * macros used in arena scan code to convert from object pointers
 * to arena pointers ...
 */


#if PARROT_GC_GMS
#  define GC_HEADER_SIZE (sizeof (Gc_gms_hdr))
#  define PObj_to_ARENA(o) PObj_to_GMSH(o)
#  define ARENA_to_PObj(p) GMSH_to_PObj((Gc_gms_hdr*)(p))
#else
#  define GC_HEADER_SIZE 0
#  define PObj_to_ARENA(o) (o)
#  define ARENA_to_PObj(p) (p)
#endif


/* HEADERIZER BEGIN: src/gc/smallobject.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_WARN_UNUSED_RESULT
INTVAL contained_in_pool(
    ARGIN(const Small_Object_Pool *pool),
    ARGIN(const void *ptr))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

void gc_pmc_ext_pool_init(ARGMOD(Small_Object_Pool *pool))
        __attribute__nonnull__(1)
        FUNC_MODIFIES(*pool);

PARROT_MALLOC
PARROT_CANNOT_RETURN_NULL
Small_Object_Pool * new_small_object_pool(
    size_t object_size,
    size_t objects_per_alloc);

void Parrot_add_to_free_list(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGMOD(Small_Object_Arena *arena))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*arena);

void Parrot_append_arena_in_pool(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *pool),
    ARGMOD(Small_Object_Arena *new_arena),
    size_t size)
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*pool)
        FUNC_MODIFIES(*new_arena);

void Parrot_gc_ms_init(PARROT_INTERP)
        __attribute__nonnull__(1);

int Parrot_is_const_pmc(PARROT_INTERP, ARGIN(const PMC *pmc))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

void Parrot_small_object_pool_merge(PARROT_INTERP,
    ARGMOD(Small_Object_Pool *dest),
    ARGMOD(Small_Object_Pool *source))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*dest)
        FUNC_MODIFIES(*source);

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/gc/smallobject.c */

#endif /* PARROT_SMALLOBJECT_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
