#if !defined(PARROT_SMALLOBJECT_H_GUARD)
#define PARROT_SMALLOBJECT_H_GUARD

#include "parrot/parrot.h"

struct Small_Object_Arena {
    size_t used;
    size_t total_objects;
#if ARENA_DOD_FLAGS
    size_t object_size;     /* size in bytes of an individual pool item */
    UINTVAL * dod_flags;
    struct Small_Object_Pool * pool;
    size_t live_objects;
#endif /* ARENA_DOD_FLAGS */
    struct Small_Object_Arena *prev;
    struct Small_Object_Arena *next;
    void *start_objects;
#if PARROT_GC_GMC
    void *start_looking; /* Start looking for free objects from here. */
#endif
};

#if ARENA_DOD_FLAGS
/*
 * objects on the free list are overlaid with
 * this data structure just for resetting
 * the on_free_list FLAG cheaper
 *
 * this structure should not be bigger then a PMC
 */
typedef struct {
    void *free_list_ptr;        /* generic free list ptr */
    size_t object_buflen_dont_use;
    UINTVAL object_flags_dont_use;
    UINTVAL *arena_dod_flag_ptr;/* ptr to the dod flag nibble */
    int flag_shift;         /* shift inside dod_flags */
} Dead_PObj;

#endif /* ARENA_DOD_FLAGS */

struct Small_Object_Pool;

typedef void (*add_free_object_fn_type)(Interp *,
                             struct Small_Object_Pool *, void *);
#if PARROT_GC_GMC
typedef void * (*get_free_typed_object_fn_type)(Interp *,
                             struct Small_Object_Pool *, INTVAL);
typedef void * (*get_free_sized_object_fn_type)(Interp *,
                             struct Small_Object_Pool *, size_t);
#endif
typedef void * (*get_free_object_fn_type)(Interp *,
                             struct Small_Object_Pool *);
typedef void  (*alloc_objects_fn_type)(Interp *,
                           struct Small_Object_Pool *);

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

#define PObj_to_GMSH(o) ( ((Gc_gms_hdr*)o)-1 )
#define GMSH_to_PObj(p) ( (PObj*) (p+1) )

/* the structure uses 2 ptrs itself */
#define GC_GMS_STORE_SIZE (64-2)

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
    UINTVAL gen_no;		        /* generation number */
    UINTVAL timely_destruct_obj_sofar; 	/* sum up to this generation */
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

#endif


#if PARROT_GC_GMC

/* Arbitrary values, tune them later. */

/* Size of a generation. */
#define GMC_GEN_SIZE (128*32)

/* Number of generations at init time. */
#define GMC_GEN_INIT_NUMBER 16

/* Number of new object headers added when pool->alloc_objects is called */
#define GMC_NUM_NEW_OBJ 512


/* This header is appended to all gc objects. */
typedef struct _gc_gmc_hdr {
  UINTVAL gmc_flags; /* Various GC flags for internal use. */
  PMC* pmc;          /* Corresponding PMC header. */
} Gc_gmc_hdr;


/* FIXME: the flags definition isn't really in the good file.
 * smallobject.h ? pobj.h ? gc_gmc.h ? */
typedef enum gmc_flags {
    /* Private GC flags, for internal use. */
    Gmc_marking_FLAG = 1 << 0,
    Gmc_private_1_FLAG = 1 << 1,
    Gmc_private_2_FLAG = 1 << 2,
    Gmc_private_3_FLAG = 1 << 3,
    Gmc_private_4_FLAG = 1 << 4,
    Gmc_private_5_FLAG = 1 << 5,
    Gmc_private_6_FLAG = 1 << 6,
    Gmc_has_ext_FLAG = 1 << 7, /*  flag */
    Gmc_is_pmc_FLAG = 1 << 8, /* True if the object is a PMC, is a PObj if not. */
} Gmc_flags;


/* Macros for access from header. */
#define Gmc_PMC_hdr_get_BODY(pmc_hdr)		    ((PMC_BODY*)((char*)(pmc_hdr) + sizeof(Gc_gmc_hdr)))
#define Gmc_PMC_hdr_get_FLAGS(pmc_hdr)		    ((pmc_hdr)->gmc_flags)
#define Gmc_PMC_hdr_get_PMC(pmc_hdr)		    ((pmc_hdr)->pmc)
#define Gmc_PMC_hdr_flag_TEST(flag, pmc_hdr)	    (Gmc_PMC_hdr_get_FLAGS(pmc_hdr) & (Gmc_ ## flag ## _FLAG))
#define Gmc_PMC_hdr_flag_SET(flag, pmc_hdr)	    (Gmc_PMC_hdr_get_FLAGS(pmc_hdr) |= (Gmc_ ## flag ## _FLAG))
#define Gmc_PMC_hdr_flag_CLEAR(flag, pmc_hdr)	    (Gmc_PMC_hdr_get_FLAGS(pmc_hdr) &= \
							  ~(UINTVAL)(Gmc_ ## flag ## _FLAG))

/* Macros for access from body. */
#define Gmc_PMC_body_get_HDR(pmc_body)		    ((Gc_gmc_hdr*)((char*)(pmc_body) - sizeof(Gc_gmc_hdr)))
#define Gmc_PMC_body_get_FLAGS(pmc_body)	    Gmc_PMC_hdr_get_FLAGS(Gmc_PMC_body_get_hdr(pmc_body))
#define Gmc_PMC_body_get_PMC(pmc_body)  	    Gmc_PMC_hdr_get_PMC(Gmc_PMC_body_get_hdr(pmc_body))
#define Gmc_PMC_body_flag_TEST(flag, pmc_body)	    Gmc_PMC_hdr_flag_TEST(flag, Gmc_PMC_body_get_hdr(pmc_body))
#define Gmc_PMC_body_flag_SET(flag, pmc_body)	    Gmc_PMC_hdr_flag_SET(flag, Gmc_PMC_body_get_hdr(pmc_body))
#define Gmc_PMC_body_flag_CLEAR(flag, pmc_body)	    Gmc_PMC_hdr_flag_CLEAR(flag, Gmc_PMC_body_get_hdr(pmc_body))

/* Macros for access from PMC*. */
#define Gmc_PMC_get_HDR(pmc)			    Gmc_PMC_body_get_HDR(PMC_body(pmc))
#define Gmc_PMC_get_FLAGS(pmc)			    Gmc_PMC_hdr_get_FLAGS(Gmc_PMC_get_HDR(pmc))
#define Gmc_PMC_flag_TEST(flag, pmc)		    Gmc_PMC_hdr_flag_TEST(flag, Gmc_PMC_get_HDR(pmc))
#define Gmc_PMC_flag_SET(flag, pmc)		    Gmc_PMC_hdr_flag_SET(flag, Gmc_PMC_get_HDR(pmc))
#define Gmc_PMC_flag_CLEAR(flag, pmc)		    Gmc_PMC_hdr_flag_CLEAR(flag, Gmc_PMC_get_HDR(pmc))

#define Gmc_has_PMC_EXT_TEST(pmc)		    Gmc_PMC_flag_TEST(has_ext, pmc)


/* Same structure than in GMS for header lists. */
#define GC_GMC_STORE_SIZE (64-2)

typedef struct _gc_gmc_hdr_store {
    struct _gc_gmc_hdr_store *next;
    Gc_gmc_hdr **ptr;                           /* insert location */
    Gc_gmc_hdr * (store[GC_GMC_STORE_SIZE]);    /* array of hdr pointers */
} Gc_gmc_hdr_store;


typedef struct _gc_gmc_hdr_list {
  Gc_gmc_hdr_store *first;
  Gc_gmc_hdr_store *last;
} Gc_gmc_hdr_list;


typedef struct _gc_gmc_header_area {
    void *fst;
    void *lst;
} Gc_gmc_header_area;


/* A generation for GMC. */
typedef struct _gc_gmc_gen {
  struct _gc_gmc_gen *next;  /* Next generation in the linked list. */
  struct _gc_gmc_gen *prev;  /* Previous generation. */
  void *first;               /* Array of objects. */
  void *fst_free;            /* First free place. */
  size_t remaining;          /* Remaining size. */
  UINTVAL alloc_obj;         /* Number of allocated objects. */
  Gc_gmc_hdr_list *IGP;      /* Inter Generational pointers set. */
} Gc_gmc_gen;


/* The whole GC structure */
typedef struct _gc_gmc {
  UINTVAL nb_gen;       /* Total number of generations. */
  UINTVAL nb_empty_gen; /* Number of empty generations. */
  UINTVAL alloc_obj;    /* Number of allocated objects. */
  Gc_gmc_gen *yng_fst;  /* First generation (aggregate, young objects). */
  Gc_gmc_gen *yng_lst;  /* End of aggregate objects. */
  Gc_gmc_gen *old_fst;  /* Beginning of non-aggregate, old objects. */
  Gc_gmc_gen *old_lst;  /* Very last generation. */
  Gc_gmc_gen *timely;   /* Objects needing timely destruction. */
  Gc_gmc_gen *constant; /* Objects that will never be collected. */
} Gc_gmc;

#endif



/* Tracked resource pool */
struct Small_Object_Pool {
    struct Small_Object_Arena *last_Arena;
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
    UINTVAL align_1;    /* alignment (must be power of 2) minus one */
    /* adds a free object to the pool's free list  */
    add_free_object_fn_type     add_free_object;
#if PARROT_GC_GMC
    get_free_typed_object_fn_type get_free_typed_object;
    get_free_sized_object_fn_type get_free_sized_object;
#endif
    get_free_object_fn_type     get_free_object;
    alloc_objects_fn_type       alloc_objects;
    alloc_objects_fn_type       more_objects;
    /* gets and removes a free object from the pool's free list */
    /* allocates more objects */
    void *mem_pool;
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

#if PARROT_GC_GMC
    Gc_gmc *gc;
#endif
};

/*
 * macros used in arena scan code to convert from object pointers
 * to arena pointers ...
 */

#if PARROT_GC_GMS
#  define GC_HEADER_SIZE (sizeof(Gc_gms_hdr))
#  define PObj_to_ARENA(o) PObj_to_GMSH(o)
#  define ARENA_to_PObj(p) GMSH_to_PObj((Gc_gms_hdr*)(p))
#else
#  define GC_HEADER_SIZE 0
#  define PObj_to_ARENA(o) (o)
#  define ARENA_to_PObj(p) (p)
#endif

INTVAL contained_in_pool(Interp *,
                         struct Small_Object_Pool *, void *);
size_t get_max_pool_address(Interp *interpreter,
                            struct Small_Object_Pool *pool);
size_t get_min_pool_address(Interp *interpreter,
                            struct Small_Object_Pool *pool);

struct Small_Object_Pool * new_small_object_pool(Interp *,
                                                 size_t, size_t);

int Parrot_is_const_pmc(Parrot_Interp, PMC *);

void Parrot_append_arena_in_pool(Interp *, struct Small_Object_Pool *pool,
    struct Small_Object_Arena *new_arena, size_t size);
void Parrot_add_to_free_list(Interp *, struct Small_Object_Pool *pool,
        struct Small_Object_Arena *arena, UINTVAL start, UINTVAL end);

#endif /* PARROT_SMALLOBJECT_H_GUARD */

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
