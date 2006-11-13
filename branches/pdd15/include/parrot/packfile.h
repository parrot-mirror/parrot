/* packfile.h
*
* $Id$
*/

#if !defined(PARROT_PACKFILE_H_GUARD)
#define PARROT_PACKFILE_H_GUARD

#include <parrot/parrot.h>

/* Macros for getting at underlying structures from the Packfile PMCs. */
#define PMC_PackFile(p) ((struct Parrot_PackFile*)PMC_struct_val(p))
#define PMC_PackFileDirectory(p) \
    ((struct Parrot_PackFile_Directory*)PMC_struct_val(p))
#define PMC_PackFileConstTable(p) \
    ((struct Parrot_PackFile_ConstTable*)PMC_struct_val(p))
#define PMC_PackFileFixupTable(p) \
    ((struct Parrot_PackFile_FixupTable*)PMC_struct_val(p))
#define PMC_PackFileByteCode(p) \
    ((struct Parrot_PackFile_ByteCode*)PMC_struct_val(p))

/* Getting at the constants. */
#define PF_NCONST(pf)  (VTABLE_elements(interpreter, PMC_PackFileByteCode(pf)->const_table))
#define PF_CONST(pf,i) (PMC_PackFileConstTable(PMC_PackFileByteCode(pf)->const_table)->constants[(i)])

/* Segment names. */
#define DIRECTORY_SEGMENT_NAME   "DIRECTORY"
#define FIXUP_TABLE_SEGMENT_NAME "FIXUP"
#define CONSTANT_SEGMENT_NAME    "CONSTANT"
#define BYTE_CODE_SEGMENT_NAME   "BYTECODE"

/* Directory version. */
#define PARROT_PF_DIR_FORMAT 1

/* UUID types. */
#define PARROT_UUID_TYPE_NONE 0
#define PARROT_UUID_TYPE_MD5 1

/*
** Structure Definitions:
*/

/*
 * The header of a packfile. PACKFILE_HEADER_BYTES stores the number of bytes
 * that can be read directly from the file or written directly to it.
 */
#define PACKFILE_HEADER_BYTES 18
struct Parrot_PackFile_Header {
    /* Magic string. */
    unsigned char magic[8];
    
    /* Format of integers, floats, etc. */
    unsigned char wordsize;
    unsigned char byteorder;
    unsigned char floattype;
    
    /* Parrot versoin that wrote the file. */
    unsigned char parrot_major;
    unsigned char parrot_minor;
    unsigned char parrot_patch;
    
    /* Version of the bytecode format. */
    unsigned char bytecode_major;
    unsigned char bytecode_minor;
    
    /* UUID related. */
    unsigned char uuid_type;
    unsigned char uuid_length;
    unsigned char* uuid_value;
};

/*
** PackFile_FixupTable:
*/
typedef enum {
    enum_fixup_none,
    enum_fixup_label,
    enum_fixup_sub
} enum_fixup_t;

typedef struct Parrot_PackFile_FixupEntry {
    opcode_t type;              /* who knows, what fixups we need */
    opcode_t name_const_offset; /* name of the label */
    opcode_t offset;            /* location of the item */
    STRING *name;
    PMC *seg;
} Parrot_PackFile_FixupEntry;

typedef struct Parrot_PackFile_FixupTable {
    PMC *pf;
    PMC *directory;
    /* ResizablePMCArray holding entries. */
    PMC* entries;
    PMC *seg; /* where this segment belongs to */
} Parrot_PackFile_FixupTable;


#define PFC_NONE    '\0'
/* no ascii chars use numbers: for n,s,k,p */
#define PFC_NUMBER  '\156'
#define PFC_STRING  '\163'
#define PFC_KEY     '\153'
#define PFC_PMC     '\160'

/* Duplicates with PARROT_ prefix */
#define PARROT_PFC_NONE    '\0'
/* no ascii chars use numbers: for n,s,k,p */
#define PARROT_PFC_NUMBER  '\156'
#define PARROT_PFC_STRING  '\163'
#define PARROT_PFC_KEY     '\153'
#define PARROT_PFC_PMC     '\160'

enum PF_VARTYPE {                  /* s. also imcc/symreg.h */
    PF_VT_START_SLICE = 1 << 10,   /* x .. y slice range */
    PF_VT_END_SLICE   = 1 << 11,
    PF_VT_START_ZERO  = 1 << 12,   /* .. y 0..start */
    PF_VT_END_INF     = 1 << 13,   /* x..  start..inf */
    PF_VT_SLICE_BITS  = PF_VT_START_SLICE | PF_VT_END_SLICE |
                        PF_VT_START_ZERO | PF_VT_END_INF
};

struct Parrot_PackFile_Constant {
    opcode_t type;
    union {
        opcode_t integer;
        FLOATVAL number;
        STRING *string;
        PMC *key;
    } u;
};

struct Parrot_PackFile_ConstTable {
    PMC *pf;
    PMC *directory;
    opcode_t const_count;
    struct Parrot_PackFile_Constant ** constants;
    struct PMC *code;   /* where this segment belongs to */
};

struct Parrot_PackFile_ByteCode {
    PMC *pf;
    PMC *directory;
    opcode_t length;
    opcode_t *data;
    Prederef prederef;          /* The predereferenced code and info */
    void *jit_info;             /* JITs data */
    Parrot_PIC_store *pic_store;      /* PIC storage */
    PMC *pic_index; /* segment of indices into store */
    PMC *prev;   /* was executed previous */
    PMC *debugs;
    PMC *const_table;
    PMC *fixups;
};

enum PF_DEBUGMAPPINGTYPE {
    PF_DEBUGMAPPINGTYPE_NONE = 0,
    PF_DEBUGMAPPINGTYPE_FILENAME,
    PF_DEBUGMAPPINGTYPE_SOURCESEG
};

/* XXX Debug info to be replaced by annotations table. */
struct PackFile_DebugMapping {
    opcode_t offset;
    opcode_t mapping_type;
    union {
        opcode_t filename;
        opcode_t source_seg; /* XXX Source segments currently unimplemented. */
    } u;
};
/* XXX Debug info to be replaced by annotations table. */
struct PackFile_Debug {
    opcode_t num_mappings;
    struct PackFile_DebugMapping ** mappings;
    struct PackFile_ByteCode  * code;   /* where this segment belongs to */
};

/* This structure describes a Packfile directory. */
struct Parrot_PackFile_Directory {
    /* The PackFile that this is a directory for. */
    PMC* parent;

    /* ResizablePMCArray holding segments. */
    PMC* segments;
    
    /* ResizableStringArray holding segment names. */
    PMC* segment_names;
};

/* Types of segment that we can have. */
typedef enum {
    PARROT_PACKFILE_SEG_DEFAULT = 1,
    PARROT_PACKFILE_SEG_FIXUP = 2,
    PARROT_PACKFILE_SEG_CONSTANTTABLE = 3,
    PARROT_PACKFILE_SEG_BYTECODE = 4,
    PARROT_PACKFILE_SEG_ANNOTATIONS = 5,
    PARROT_PACKFILE_SEG_PIC = 6,
    PARROT_PACKFILE_SEG_DEPENDENCIES = 7
} Parrot_PackFile_Segment_Types;

/* This structure describes a PackFile. */
struct Parrot_PackFile {
    /* The PackFile header. */
    struct Parrot_PackFile_Header *header;

    /* Packfile directory. */
    struct PMC *directory;

    /* Word size and endian-change related stuff. */
    INTVAL   need_wordsize;
    INTVAL   need_endianize;
    opcode_t (*fetch_op)(unsigned char *);
    INTVAL   (*fetch_iv)(unsigned char *);
    void     (*fetch_nv)(unsigned char *, unsigned char *);

    /* Source. */
    opcode_t *src;       /* the (possibly mmap()ed) start of the PF */
    size_t size;         /* size in bytes */
    INTVAL is_mmap_ped;  /* 0 if it's not mmap()ed */

    /* Runtime. */
    PMC *cur_cs;         /* used during PF loading */
};

/*
** PackFile Functions:
*/

PARROT_API PMC *PackFile_new(Interp *, INTVAL is_mapped);
PARROT_API PMC *PackFile_new_dummy(Interp *, const char* name);

PARROT_API STRING* PackFile_pack(Interp *, struct PMC* self);

PARROT_API opcode_t PackFile_unpack(Interp *interpreter,
                         PMC *self, opcode_t *packed,
                         size_t packed_size);

PARROT_API INTVAL
PackFile_Header_Unpack(Interp* interpreter, opcode_t* packed, 
                       PMC *self);

PARROT_API INTVAL
PackFile_Header_Pack(Interp* interpreter, opcode_t* packed, 
                     PMC *self);

typedef enum {
    PBC_MAIN   = 1,
    PBC_LOADED = 2,
    PBC_PBC    = 4,
    PBC_IMMEDIATE = 8,
    PBC_POSTCOMP  = 16
} pbc_action_enum_t;

PARROT_API void PackFile_fixup_subs(Interp *, pbc_action_enum_t, PMC *eval_pmc);
void do_sub_pragmas(Interp *, struct PackFile_ByteCode *, int, PMC *eval_pmc);

/*
 * directory functions
 */

PARROT_API INTVAL PackFile_add_segment (Interp *, PMC *dir,
        PMC *);

PARROT_API PMC * PackFile_find_segment (Interp *,
        PMC *dir, const char *name, int recurse);

PARROT_API PMC *
PackFile_remove_segment_by_name (Interp *, PMC *dir, const char *);

typedef INTVAL (*PackFile_map_segments_func_t) (Interp *,
        PMC *seg, void *user_data);

PARROT_API INTVAL PackFile_map_segments (Interp *, PMC *dir,
                              PackFile_map_segments_func_t callback,
                              void* usr_data);

PARROT_API PMC * PackFile_Segment_new_seg(Interp *,
        PMC *dir, UINTVAL type, const char *name, int add);

PARROT_API struct PackFile_ByteCode * PF_create_default_segs(Interp*,
        const char *file_name, int add);

PARROT_API void Parrot_load_bytecode(Interp *, STRING *filename);
/*
** PackFile_Segment Functions:
*/

PARROT_API void PackFile_Segment_dump(Interp *, PMC *);
void default_dump_header (Interp *, PMC *);

PARROT_API PMC *PackFile_Segment_new(Interp *, PMC *pf, const char*,
        int);

/*
** PackFile_FixupTable Functions:
*/

PARROT_API void PackFile_FixupTable_clear(Interp *, PMC *self);

PARROT_API void PackFile_Fixup_dump(Interp *, PMC *ft);

/* create new fixup entry */
PARROT_API void PackFile_FixupTable_new_entry(Interp *, char *label,
                enum_fixup_t, opcode_t offs);
/* find entry */
PARROT_API struct Parrot_PackFile_FixupEntry * PackFile_find_fixup_entry(Interp *,
        enum_fixup_t type, char *);

/*
** PackFile_ByteCode Functions:
*/

PARROT_API PMC* Parrot_switch_to_cs(Interp *,
    PMC *bc, int really);
PARROT_API void Parrot_switch_to_cs_by_nr(Interp *, opcode_t seg);
PARROT_API void Parrot_pop_cs(Interp *);

PARROT_API void Parrot_destroy_constants(Interp *);

/*
** PackFile_Debug Functions:
*/
PARROT_API struct PackFile_Debug * Parrot_new_debug_seg(Interp *,
        struct PackFile_ByteCode *cs, size_t size);
PARROT_API STRING * Parrot_debug_pc_to_filename(Interp *interpreter,
        struct PackFile_Debug *debug, opcode_t pc);
PARROT_API void Parrot_debug_add_mapping(Interp *interpreter,
                         struct PackFile_Debug *debug,
                         opcode_t offset, int mapping_type,
                         const char *filename, int source_seg);

/*
** PackFile_ConstTable Functions:
*/

void mark_const_subs(Interp* interpreter);
PARROT_API void PackFile_ConstTable_clear(Interp *, struct PackFile_ConstTable * self);

PARROT_API void PackFile_ConstTable_dump(Interp *,
                              struct PackFile_ConstTable *);

/*
** PackFile_Constant Functions:
*/

PARROT_API struct Parrot_PackFile_Constant *PackFile_Constant_new(Interp *);

PARROT_API size_t PackFile_Constant_pack_size(Interp *, struct Parrot_PackFile_Constant * self);

PARROT_API opcode_t * PackFile_Constant_pack(Interp *, struct Parrot_PackFile_Constant *, opcode_t *);

PARROT_API void PackFile_Constant_destroy(Interp *, struct Parrot_PackFile_Constant * self);

PARROT_API opcode_t * PackFile_Constant_unpack(Interp *interpreter,
        PMC *ct, struct Parrot_PackFile_Constant *, opcode_t *);

PARROT_API opcode_t * PackFile_Constant_unpack_key(Interp *interpreter,
        PMC *ct, struct Parrot_PackFile_Constant *, opcode_t *);

PARROT_API opcode_t * PackFile_Constant_unpack_pmc(Interp *interpreter,
        PMC *ct, struct Parrot_PackFile_Constant *, opcode_t *);

/*
 * pf_items low level Parrot items fetch routines
 */
opcode_t PF_fetch_opcode(struct Parrot_PackFile *pf, opcode_t **stream);
INTVAL   PF_fetch_integer(struct Parrot_PackFile *pf, opcode_t **stream);
FLOATVAL PF_fetch_number(struct Parrot_PackFile *pf, opcode_t **stream);
STRING*  PF_fetch_string(Interp*, struct Parrot_PackFile *pf, opcode_t **stream);
char *   PF_fetch_cstring(struct Parrot_PackFile *pf, opcode_t **stream);

size_t   PF_size_opcode(void);
size_t   PF_size_integer(void);
size_t   PF_size_number(void);
size_t   PF_size_string(STRING *);
size_t   PF_size_cstring(const char *);

opcode_t* PF_store_opcode(opcode_t *, opcode_t);
opcode_t* PF_store_integer(opcode_t *, INTVAL);
opcode_t* PF_store_number (opcode_t *, FLOATVAL *);
opcode_t* PF_store_string (opcode_t *, STRING *);
opcode_t* PF_store_cstring(opcode_t *, const char *);

void PackFile_assign_transforms(struct Parrot_PackFile *pf);

/*
** Byte Ordering Functions (byteorder.c)
*/

INTVAL fetch_iv_le(INTVAL w);
INTVAL fetch_iv_be(INTVAL w);
opcode_t fetch_op_be(opcode_t w);
opcode_t fetch_op_le(opcode_t w);
void fetch_buf_be_4(unsigned char * rb, unsigned char * b);
void fetch_buf_le_4(unsigned char * rb, unsigned char * b);
void fetch_buf_be_8(unsigned char * rb, unsigned char * b);
void fetch_buf_le_8(unsigned char * rb, unsigned char * b);
void fetch_buf_le_12(unsigned char * rb, unsigned char * b);
void fetch_buf_be_12(unsigned char * rb, unsigned char * b);
void fetch_buf_le_16(unsigned char * rb, unsigned char * b);
void fetch_buf_be_16(unsigned char * rb, unsigned char * b);

#endif /* PARROT_PACKFILE_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
