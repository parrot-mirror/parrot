/*
Copyright (C) 2001-2006, The Perl Foundation.
This program is free software. It is subject to the same license as
Parrot itself.
$Id$

=head1 NAME

src/packfile.c - Parrot PackFile API

=head1 DESCRIPTION

=head2 PackFile Manipulation Functions

This file contains all the functions required for the processing of the
structure of a PackFile. It is not intended to understand the byte code
stream itself, but merely to dissect and reconstruct data from the
various segments. See F<docs/parrotbyte.pod> for information about the
structure of the frozen bytecode.

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/embed.h"
#include "parrot/packfile.h"

#include <assert.h>

#define TRACE_PACKFILE 0
#define TRACE_PACKFILE_PMC 0

/*
** Static functions
*/
static void segment_init (Interp*, struct PackFile_Segment *self,
                          PMC *pf,
                          const char* name);

static void default_destroy (Interp*, struct PackFile_Segment *self);
static size_t default_packed_size (Interp*,
                                   const struct PackFile_Segment *self);
static opcode_t * default_pack (Interp*, const struct PackFile_Segment *self,
                                opcode_t *dest);
static opcode_t * default_unpack (Interp *,
                                  struct PackFile_Segment *self,
                                  opcode_t *dest);
static void default_dump (Interp *,
                          struct PackFile_Segment *self);

static size_t directory_packed_size (Interp*, struct PackFile_Segment *self);
static opcode_t * directory_pack (Interp*, struct PackFile_Segment *,
                                  opcode_t *dest);
static opcode_t * directory_unpack (Interp *,
                                    struct PackFile_Segment *,
                                    opcode_t *cursor);
static void directory_dump (Interp *, struct PackFile_Segment *);

static struct PackFile_Segment *fixup_new (Interp*, PMC *,
        const char *, int);
static size_t fixup_packed_size (Interp*, struct PackFile_Segment *self);
static opcode_t * fixup_pack (Interp*, struct PackFile_Segment * self,
        opcode_t *dest);
static opcode_t * fixup_unpack (Interp *,
        struct PackFile_Segment*, opcode_t *cursor);
static void fixup_destroy (Interp*, struct PackFile_Segment *self);

static struct PackFile_Segment *const_new (Interp*, PMC *,
        const char *, int);
static void const_destroy (Interp*, struct PackFile_Segment *self);

static struct PackFile_Segment *byte_code_new (Interp*, PMC *pf,
        const char *, int);
static void byte_code_destroy (Interp*, struct PackFile_Segment *self);
static INTVAL pf_register_standard_funcs(Interp*, PMC *pf);

static struct PackFile_Segment * pf_debug_new (Interp*, PMC *,
        const char *, int);
static size_t pf_debug_packed_size (Interp*, struct PackFile_Segment *self);
static opcode_t * pf_debug_pack (Interp*, struct PackFile_Segment *self,
        opcode_t *);
static void pf_debug_dump (Interp *, struct PackFile_Segment *);
static opcode_t * pf_debug_unpack (Interp *,
        struct PackFile_Segment *self, opcode_t *);
static void pf_debug_destroy (Interp*, struct PackFile_Segment *self);

static struct PackFile_Constant **find_constants(Interp*,
                                                 struct PackFile_ConstTable *);

#define ROUND_16(val) ( ((val) & 0xf) ? 16 - ((val) & 0xf) : 0 )
#define ALIGN_16(st, cursor) \
    do { \
        (cursor) = (opcode_t *) \
           ((char *)(cursor) \
            + ROUND_16((char *)(cursor) - (char *)(st))); \
    } while (0)

/*

=item C<static INTVAL
PackFile_check_segment_size(opcode_t segment_size, const char *debug)>

Internal function to check C<segment_size % sizeof(opcode_t)>.

=cut

*/

static INTVAL
PackFile_check_segment_size(opcode_t segment_size, const char *debug)
{
#if TRACE_PACKFILE
    PIO_eprintf(NULL,"PackFile_unpack(): Unpacking %ld bytes for %s table...\n",
           (long)segment_size, debug);
#endif

    if (segment_size % sizeof(opcode_t)) {
        PIO_eprintf(NULL,
                    "PackFile_unpack: Illegal %s table segment size "
                    "%ld (must be multiple of %ld)!\n",
                    debug, (long)segment_size, (long)sizeof(opcode_t));
        return 0;
    }
    return 1;
}

/*

=item C<static void
make_code_pointers(struct PackFile_Segment *seg)>

Make compat/shorthand pointers.

The first segments read are the default segments.

=cut

*/

static void
make_code_pointers(PMC *seg)
{
    struct Parrot_PackFile * const pf = PMC_PackFile(seg->pf);

    switch (seg->type) {
        case PF_BYTEC_SEG:
            if (!pf->cur_cs) {
                pf->cur_cs = (struct PackFile_ByteCode*)seg;
            }
            break;
        case PF_FIXUP_SEG:
            if (!pf->cur_cs->fixups) {
                pf->cur_cs->fixups = (struct PackFile_FixupTable *)seg;
                pf->cur_cs->fixups->code = pf->cur_cs;
            }
            break;
        case PF_CONST_SEG:
            if (!pf->cur_cs->const_table) {
                pf->cur_cs->const_table = (struct PackFile_ConstTable*)seg;
                pf->cur_cs->const_table->code = pf->cur_cs;
            }
        case PF_UNKNOWN_SEG:
            if (memcmp(seg->name, "PIC_idx", 7) == 0)
                pf->cur_cs->pic_index = seg;
            break;
        case PF_DEBUG_SEG:
            pf->cur_cs->debugs = (struct PackFile_Debug*)seg;
            pf->cur_cs->debugs->code = pf->cur_cs;
            break;
        default:
            break;
    }
}


/*

=item C<static int
sub_pragma(Parrot_Interp interpreter,
        int action, PMC *sub_pmc)>

Handle :load, :main ... pragmas for B<sub_pmc>

=cut

*/

static int
sub_pragma(Parrot_Interp interpreter, int action, PMC *sub_pmc)
{
    int pragmas = PObj_get_FLAGS(sub_pmc) & SUB_FLAG_PF_MASK;
    int todo = 0;

    pragmas &= ~SUB_FLAG_IS_OUTER;
    if (!pragmas && !Sub_comp_INIT_TEST(sub_pmc))
        return 0;
    switch (action) {
        case PBC_PBC:
        case PBC_MAIN:
            if (interpreter->resume_flag & RESUME_INITIAL) {
                /*
                 * denote MAIN entry in first loaded PASM
                 */
                todo = 1;
            }
            /* :init functions need to be called at MAIN time, so return 1 */
            if (Sub_comp_INIT_TEST(sub_pmc)) /* symreg.h:P_INIT */
                todo = 1;
            break;
        case PBC_LOADED:
            if (pragmas & SUB_FLAG_PF_LOAD) /* symreg.h:P_LOAD */
                todo = 1;
            break;
    }
    if (pragmas & (SUB_FLAG_PF_IMMEDIATE | SUB_FLAG_PF_POSTCOMP))
        todo = 1;
    return todo;
}

/*

=item C<static PMC* run_sub(Parrot_Interp interpreter, PMC* sub_pmc)>

Run the B<sub_pmc> due its B<:load>, B<:immediate>, ... pragma

=cut

*/

static PMC*
run_sub(Parrot_Interp interpreter, PMC* sub_pmc)
{
    const Parrot_Run_core_t old = interpreter->run_core;
    PMC *retval;

    /*
     * turn off JIT and prederef - both would act on the whole
     * PackFile which isn't worth the effort - probably
     */
    if (interpreter->run_core != PARROT_CGOTO_CORE  &&
            interpreter->run_core != PARROT_SLOW_CORE  &&
            interpreter->run_core != PARROT_FAST_CORE)
        interpreter->run_core = PARROT_FAST_CORE;
    CONTEXT(interpreter->ctx)->constants =
        PMC_PackFileByteCode(interpreter->code)->const_table->constants;
    retval = Parrot_runops_fromc_args(interpreter, sub_pmc, "P");
    interpreter->run_core = old;
    return retval;
}

/*

=item <static PMC*
do_1_sub_pragma(Parrot_Interp interpreter, PMC *sub_pmc, int action)>

Run autoloaded or immediate bytecode, mark MAIN subroutine entry

=cut

*/

static PMC*
do_1_sub_pragma(Parrot_Interp interpreter, PMC* sub_pmc, int action)
{

    size_t start_offs;
    struct Parrot_sub * const sub = PMC_sub(sub_pmc);
    PMC *result;
    void *lo_var_ptr;

    switch (action) {
        case PBC_IMMEDIATE:
            /*
             * run IMMEDIATE sub
             */
            if (PObj_get_FLAGS(sub_pmc) & SUB_FLAG_PF_IMMEDIATE) {
                PObj_get_FLAGS(sub_pmc) &= ~SUB_FLAG_PF_IMMEDIATE;
                lo_var_ptr = interpreter->lo_var_ptr;
                result = run_sub(interpreter, sub_pmc);
                /*
                 * reset initial flag so MAIN detection works
                 * and reset lo_var_ptr to prev
                 */
                interpreter->resume_flag = RESUME_INITIAL;
                interpreter->lo_var_ptr = lo_var_ptr;
                return result;
            }
            break;
        case PBC_POSTCOMP:
            /*
             * run POSTCOMP sub
             */
            if (PObj_get_FLAGS(sub_pmc) & SUB_FLAG_PF_POSTCOMP) {
                PObj_get_FLAGS(sub_pmc) &= ~SUB_FLAG_PF_POSTCOMP;
                run_sub(interpreter, sub_pmc);
                /*
                 * reset initial flag so MAIN detection works
                 */
                interpreter->resume_flag = RESUME_INITIAL;
                return NULL;
            }
            break;

        case PBC_LOADED:
            if (PObj_get_FLAGS(sub_pmc) & SUB_FLAG_PF_LOAD) {
                PObj_get_FLAGS(sub_pmc) &= ~SUB_FLAG_PF_LOAD;
                Sub_comp_INIT_CLEAR(sub_pmc); /* if loaded no need for init */
                run_sub(interpreter, sub_pmc);
            }
            break;
        default:
            if (PObj_get_FLAGS(sub_pmc) & SUB_FLAG_PF_MAIN) {
                if ((interpreter->resume_flag & RESUME_INITIAL) &&
                        interpreter->resume_offset == 0) {
                    ptrdiff_t code = (ptrdiff_t) sub->seg->base.data;

                    start_offs =
                        ((ptrdiff_t) VTABLE_get_pointer(interpreter, sub_pmc)
                         - code) / sizeof(opcode_t*);
                    interpreter->resume_offset = start_offs;
                    PObj_get_FLAGS(sub_pmc) &= ~SUB_FLAG_PF_MAIN;
                    CONTEXT(interpreter->ctx)->current_sub = sub_pmc;
                }
                else {
                    /* XXX which warn_class */
                    Parrot_warn(interpreter, PARROT_WARNINGS_ALL_FLAG,
                                ":main sub not allowed\n");
                }
            }

            /* run :init tagged functions */
            if (action == PBC_MAIN && (Sub_comp_INIT_TEST(sub_pmc))) {
                Sub_comp_INIT_CLEAR(sub_pmc); /* if loaded no need for init */
                PObj_get_FLAGS(sub_pmc) &= ~SUB_FLAG_PF_LOAD; /* if inited no need for load */
                run_sub(interpreter, sub_pmc);
                interpreter->resume_flag = RESUME_INITIAL;
            }
            break;
    }
    return NULL;
}

/*
 * while the PMCs should be constant, there possible contents like
 * a property isn't constructed const so we have to mark them
 */
static void
mark_1_seg(Parrot_Interp interpreter, struct PackFile_ConstTable *ct)
{
    opcode_t i;
    struct PackFile_Constant **constants;

    constants = find_constants(interpreter, ct);
    for (i = 0; i < ct->const_count; i++) {
        switch (constants[i]->type) {
            case PFC_PMC:
                {
                PMC * const pmc = constants[i]->u.key;
                if (pmc)
                    pobject_lives(interpreter, (PObj *)pmc);
                }
        }
    }
}

static INTVAL
find_const_iter(Interp* interpreter,
        struct PackFile_Segment *seg, void *user_data)
{
    if (seg->type == PF_DIR_SEG) {
        PackFile_map_segments(interpreter, (PMC*)seg,
                find_const_iter, user_data);
    }
    else if (seg->type == PF_CONST_SEG) {
        mark_1_seg(interpreter, (struct PackFile_ConstTable *)seg);
    }
    return 0;
}

void
mark_const_subs(Parrot_Interp interpreter)
{
    PMC *dir;

    struct Parrot_PackFile* const self = PMC_PackFile(interpreter->initial_pf);
    if (!self)
        return;
    /*
     * locate top level dir
     */
    dir = self->directory;
    /*
     * iterate over all dir/segs
     */
    PackFile_map_segments(interpreter, dir, find_const_iter, NULL);
}

/*

=item C<static void
do_sub_pragmas(Interp *interpreter, struct PackFile_Bytecode *self,
   int action, PMC *eval_pmc)>

B<action> is one of
B<PBC_PBC>, B<PBC_LOADED>, B<PBC_INIT>, or B<PBC_MAIN>. Also store the C<eval_pmc>
in the sub structure, so that the eval PMC is kept alive be living subs.

=cut

*/

void
do_sub_pragmas(Interp *interpreter, struct PackFile_ByteCode *self,
        int action, PMC *eval_pmc)
{
    opcode_t i;
    PMC *sub_pmc, *result;
    struct PackFile_FixupTable *ft = self->fixups;
    struct PackFile_ConstTable *ct = self->const_table;

#if TRACE_PACKFILE
    PIO_eprintf(NULL, "PackFile: do_sub_pragmas (action=%d)\n", action);
#endif

    for (i = 0; i < ft->fixup_count; i++) {
        switch (ft->fixups[i]->type) {
            case enum_fixup_sub:
                {
                /*
                 * offset is an index into the const_table holding
                 * the Sub PMC
                 */
                const opcode_t ci = ft->fixups[i]->offset;
                if (ci < 0 || ci >= ct->const_count)
                    internal_exception(1,
                            "Illegal fixup offset (%d) in enum_fixup_sub");
                sub_pmc = ct->constants[ci]->u.key;
                PMC_sub(sub_pmc)->eval_pmc = eval_pmc;
                if (((PObj_get_FLAGS(sub_pmc) & SUB_FLAG_PF_MASK)
                        || (Sub_comp_get_FLAGS(sub_pmc) & SUB_COMP_FLAG_MASK))
                        && sub_pragma(interpreter, action, sub_pmc)) {
                    result = do_1_sub_pragma(interpreter,
                            sub_pmc, action);
                    /*
                     * replace the Sub PMC with the result of the
                     * computation
                     */
                    if (action == PBC_IMMEDIATE &&
                            !PMC_IS_NULL(result)) {
                        ft->fixups[i]->type = enum_fixup_none;
                        ct->constants[ci]->u.key = result;
                    }
                }
                }
                break;
            case enum_fixup_label:
                /* fill in current bytecode seg */
                ft->fixups[i]->seg = self;
                break;
        }
    }
}

/*

=item C<opcode_t
PackFile_unpack(Interp *interpreter, PMC *pf,
                opcode_t *packed, size_t packed_size)>

Unpack a C<PackFile> from a block of memory.

Returns size of unpacked if everything is OK, else zero (0).

=cut

*/

opcode_t
PackFile_unpack(Interp *interpreter, PMC *pf,
                opcode_t *packed, size_t packed_size)
{
    STRING *s = string_from_cstring(interpreter, packed, packed_size);
    VTABLE_set_string_native(interpreter, pf, s);
    return packed_size;
}


/*

=item C<INTVAL
PackFile_Header_Unpack(Interp* interpreter, opcode_t* packed, 
                       struct Parrot_PackFile *self)

Unpack a packfile header. Returns the length of the unpacked header or, if an
error occurs, 0.

=cut

*/

INTVAL
PackFile_Header_Unpack(Interp* interpreter, opcode_t* packed, 
                       PMC *self)
{
    struct Parrot_PackFile_Header *header;
    INTVAL header_length;

    /* Read the fixed length chunk of the header in. */
    header = PMC_PackFile(self)->header;
    memcpy(header, packed, PACKFILE_HEADER_BYTES);

    /* Now read in the UUID. */
    if (header->uuid_length) {
        header->uuid_value = mem_sys_allocate(header->uuid_length);
        memcpy(header->uuid_value, packed + PACKFILE_HEADER_BYTES,
            header->uuid_length);
    }
    else {
        header->uuid_value = NULL;
    }

    /* Sort out the length, including padding, and return it. */
    header_length = PACKFILE_HEADER_BYTES + header->uuid_length;
    header_length = header_length % 16 == 0 ? header_length :
        header_length + (16 - (header_length % 16));
    return header_length;
}

/*

=item C<INTVAL
PackFile_Header_Pack(Interp* interpreter, opcode_t* packed, 
                     PMC *self)

Packs a packfile header. Returns the length of the packed header or, if an
error occurs, 0.

=cut

*/

INTVAL
PackFile_Header_Pack(Interp* interpreter, opcode_t* packed, 
                     PMC *self_pmc)
{
    int header_length;
    struct Parrot_PackFile* self = PMC_PackFile(self_pmc);

    /* Pack the fixed bit of the header. */
    mem_sys_memcopy(packed, self->header, PACKFILE_HEADER_BYTES);
    
    /* Pack the UUID. */
    if (self->header->uuid_length) {
        memcpy((char*)packed + PACKFILE_HEADER_BYTES, self->header->uuid_value,
            self->header->uuid_length);
    }

    /* Sort out the cursor position for padding. */
    header_length = PACKFILE_HEADER_BYTES + self->header->uuid_length;
    header_length = header_length % 16 == 0 ? header_length :
        header_length + (16 - (header_length % 16));
    return header_length;
}

/*

=item C<INTVAL
PackFile_map_segments (Interp*, PMC *dir,
                       PackFile_map_segments_func_t callback,
                       void *user_data)>

For each segment in the directory C<dir> the callback function
C<callback> is called. The pointer C<user_data> is append to each call.

If a callback returns non-zero the processing of segments is stopped,
and this value is returned.

=cut

*/

INTVAL
PackFile_map_segments (Interp* interpreter, PMC *dir,
                       PackFile_map_segments_func_t callback,
                       void *user_data)
{
    INTVAL i;

    for (i = 0; i < VTABLE_elements(interpreter, dir); i++) {
        const INTVAL ret = callback (interpreter, 
            VTABLE_get_pmc_keyed_int(interpreter, dir, i),
            user_data);
        if (ret)
            return ret;
    }

    return 0;
}

/*

=item C<INTVAL
PackFile_add_segment (PMC *dir,
        struct PackFile_Segment *seg)>

Adds the Segment C<seg> to the directory C<dir> The PackFile becomes the
owner of the segment; that means its getting destroyed, when the
packfile gets destroyed.

=cut

*/

INTVAL
PackFile_add_segment (Interp* interpreter, PMC *dir,
        struct PackFile_Segment *seg)
{
    /* Add to the directory. */
    VTABLE_set_pmc_keyed_str(interpreter, dir,
        string_from_cstring(interpreter, seg->name, strlen(seg->name)),
        seg);

    /* Set the segment's directory. */
    seg->dir = dir;

    return 0;
}

/*

=item C<struct PackFile_Segment *
PackFile_find_segment (Interp *, PMC *dir,
                       const char *name, int sub_dir)>

Finds the segment with the name C<name> in the C<PackFile_Directory> if
C<sub_dir> is true, directories are searched recursively The segment is
returned, but its still owned by the C<PackFile>.

=cut

*/

struct PackFile_Segment *
PackFile_find_segment (Interp *interpreter,
        PMC *dir, const char *name, int sub_dir)
{
    INTVAL i;

    if (!dir)
        return NULL;
    for (i=0; i < VTABLE_elements(interpreter, dir); i++) {
        struct PackFile_Segment *seg = VTABLE_get_pmc_keyed_int(interpreter, dir, i);
        if (seg && strcmp (seg->name, name) == 0) {
            return seg;
        }
        if (sub_dir && seg->type == PF_DIR_SEG) {
            seg = PackFile_find_segment(interpreter,
                    (PMC *)seg, name, sub_dir);
            if (seg)
                return seg;
        }
    }

    return NULL;
}

/*

=item C<struct PackFile_Segment *
PackFile_remove_segment_by_name (Interp *, PMC *dir,
                                 const char *name)>

Finds and removes the segment with name C<name> in the
C<PackFile_Directory>. The segment is returned and must be destroyed by
the user.

=cut

*/

struct PackFile_Segment *
PackFile_remove_segment_by_name (Interp* interpreter,
        PMC *dir, const char *name)
{
    INTVAL i;

    for (i=0; i < VTABLE_elements(interpreter, dir); i++) {
        struct PackFile_Segment * const seg = VTABLE_get_pmc_keyed_int(interpreter, dir, i);
        if (strcmp (seg->name, name) == 0)
            VTABLE_delete_keyed_int(interpreter, dir, i);
    }

    return NULL;
}

/*

=back

=head2 PackFile Structure Functions

=over 4

=item C<static void
PackFile_set_header(PMC *pf)>

Fill a C<PackFile> header with system specific data, magic and so on.

=cut

*/

static void
PackFile_set_header(PMC *pf)
{
    struct Parrot_PackFile *self = PMC_PackFile(pf);

    /* Set magic. */
    memcpy(self->header->magic, "\xfe\x50\x42\x43\x0d\x0a\x1a\x0a", 8);

    /* Set sizes. */
    self->header->wordsize = sizeof(opcode_t);
    self->header->byteorder = PARROT_BIGENDIAN;
    if (NUMVAL_SIZE == 8)
        self->header->floattype = 0;
    else /* if XXX */
        self->header->floattype = 1;
    
    /* Set Parrot version. */
    self->header->parrot_major = PARROT_MAJOR_VERSION;
    self->header->parrot_minor = PARROT_MINOR_VERSION;
    self->header->parrot_patch = PARROT_PATCH_VERSION;

    /* XXX Bytecode version to do. */
    self->header->bytecode_major = 0;
    self->header->bytecode_minor = 1;

    /* UUID - default to none. */
    self->header->uuid_type = PARROT_UUID_TYPE_NONE;
    self->header->uuid_length = 0;
    self->header->uuid_value = NULL;
}

/*

=item C<PMC*
PackFile_new(Interp*, INTVAL is_mapped)>

Allocate a new empty C<PackFile> and setup the directory.

=cut

*/

PMC *
PackFile_new(Interp* interpreter, INTVAL is_mapped)
{
    PMC* pf_pmc = pmc_new(interpreter, enum_class_Packfile);
    struct Parrot_PackFile * const pf =
        PMC_PackFile(pf_pmc);

    if (!pf) {
        PIO_eprintf(NULL, "PackFile_new: Unable to allocate!\n");
        return NULL;
    }
    pf->is_mmap_ped = is_mapped;

    /* Other fields empty for now */
    pf->cur_cs = NULL;
    pf_register_standard_funcs(interpreter, pf_pmc);
    
    /* Set the op fetch functions to null for now. */
    pf->fetch_op = (opcode_t (*)(unsigned char*)) NULLfunc;
    pf->fetch_iv = (INTVAL (*)(unsigned char*)) NULLfunc;
    pf->fetch_nv = (void (*)(unsigned char *, unsigned char *)) NULLfunc;
    return pf_pmc;
}

/*

=item C<PMC* PackFile_new_dummy(Interp*, const char *name)>

Create a new (initial) dummy PackFile. This is needed, if the interpreter
doesn't load any bytecode, but is using Parrot_compile_string.

=cut

*/

PMC*
PackFile_new_dummy(Interp* interpreter, const char *name)
{
    PMC* pf;

    pf = PackFile_new(interpreter, 0);
    interpreter->initial_pf = pf;
    interpreter->code = PMC_PackFile(pf)->cur_cs
        = PF_create_default_segs(interpreter, name, 1);
    return pf;
}

/*

=item C<static opcode_t * default_unpack (Interp *interpreter,
        struct PackFile_Segment *self, opcode_t *cursor)>

The default unpack function.

=cut

*/

static opcode_t *
default_unpack (Interp *interpreter,
        struct PackFile_Segment *self, opcode_t *cursor)
{
    struct Parrot_PackFile* pf = PMC_PackFile(self->pf);

    self->op_count = PF_fetch_opcode(pf, &cursor);
    self->itype = PF_fetch_opcode(pf, &cursor);
    self->id = PF_fetch_opcode(pf, &cursor);
    self->size = PF_fetch_opcode(pf, &cursor);
    if (self->size == 0)
        return cursor;
    /* if the packfile is mmap()ed just point to it if we don't
     * need any fetch transforms
     */
    if (pf->is_mmap_ped &&
            !pf->need_endianize && !pf->need_wordsize) {
        self->data = cursor;
        cursor += self->size;
        return cursor;
    }
    /* else allocate mem */
    self->data = mem_sys_allocate(self->size * sizeof(opcode_t));

    if (!self->data) {
        PIO_eprintf(NULL,
                "PackFile_unpack: Unable to allocate data memory!\n");
        self->size = 0;
        return 0;
    }

    if(!pf->need_endianize && !pf->need_wordsize) {
        mem_sys_memcopy(self->data, cursor, self->size * sizeof(opcode_t));
        cursor += self->size;
    }
    else {
        int i;
        for(i = 0; i < (int)self->size ; i++) {
            self->data[i] = PF_fetch_opcode(pf, &cursor);
#if TRACE_PACKFILE
            PIO_eprintf(NULL, "op[#%d] %u\n", i, self->data[i]);
#endif
        }
    }

    return cursor;
}

/*

=item C<struct PackFile_Segment *
PackFile_Segment_new_seg(Interp*, PMC *dir, UINTVAL type,
        const char *name, int add)>

Create a new segment.

=cut

*/

struct PackFile_Segment *
PackFile_Segment_new_seg(Interp* interpreter,
        PMC *dir, UINTVAL type,
        const char *name, int add)
{
    PMC* const pf_pmc = PMC_PackFileDirectory(dir)->base.pf;
    struct Parrot_PackFile* pf = PMC_PackFile(pf_pmc);
    PackFile_Segment_new_func_t f = pf->PackFuncs[type].new_seg;
    struct PackFile_Segment * const seg = (f)(interpreter, pf_pmc, name, add);
    segment_init(interpreter, seg, pf_pmc, name);
    seg->type = type;
    if (add)
        PackFile_add_segment(interpreter, dir, seg);
    return seg;
}

static struct PackFile_Segment *
create_seg(Interp *interpreter, PMC *dir,
        pack_file_types t, const char *name, const char *file_name, int add)
{
    struct PackFile_Segment *seg;

    const size_t len = strlen(name) + strlen(file_name) + 2;
    char * const buf = malloc(len);

    sprintf(buf, "%s_%s", name, file_name);
    seg = PackFile_Segment_new_seg(interpreter, dir, t, buf, add);
    free(buf);
    return seg;
}

/*

=item C<struct PackFile_ByteCode *
PF_create_default_segs(Interp*, const char *file_name, int add)>

Create bytecode, constant, and fixup segment for C<file_nam>. If C<add>
is true, the current packfile becomes the owner of these segments by
adding the segments to the directory.

=cut

*/

struct PackFile_ByteCode *
PF_create_default_segs(Interp* interpreter, const char *file_name, int add)
{
    struct Parrot_PackFile * const pf = PMC_PackFile(interpreter->initial_pf);
    struct PackFile_Segment *seg =
        create_seg(interpreter, pf->directory,
            PF_BYTEC_SEG, BYTE_CODE_SEGMENT_NAME, file_name, add);
    struct PackFile_ByteCode * const cur_cs = (struct PackFile_ByteCode*)seg;

    seg = create_seg(interpreter, pf->directory,
            PF_FIXUP_SEG, FIXUP_TABLE_SEGMENT_NAME, file_name, add);
    cur_cs->fixups = (struct PackFile_FixupTable *)seg;
    cur_cs->fixups->code = cur_cs;

    seg = create_seg(interpreter, pf->directory,
            PF_CONST_SEG, CONSTANT_SEGMENT_NAME, file_name, add);
    cur_cs->const_table = (struct PackFile_ConstTable*) seg;
    cur_cs->const_table->code = cur_cs;

    seg = create_seg(interpreter, pf->directory,
            PF_UNKNOWN_SEG, "PIC_idx", file_name, add);
    cur_cs->pic_index = seg;

    return cur_cs;
}

/*

=back

*/

/* XXX Should be declared elsewhere */
extern void Parrot_destroy_jit(void *ptr);

/*

=head2 ByteCode

=over 4

*/

static void
byte_code_destroy (Interp* interpreter, struct PackFile_Segment *self)
{
    struct PackFile_ByteCode * const byte_code =
        (struct PackFile_ByteCode *)self;

#ifdef HAS_JIT
    Parrot_destroy_jit(byte_code->jit_info);
#endif
    parrot_PIC_destroy(interpreter, byte_code);
    if (byte_code->prederef.code) {
        Parrot_free_memalign(byte_code->prederef.code);
        byte_code->prederef.code = NULL;
        if (byte_code->prederef.branches) {
            mem_sys_free(byte_code->prederef.branches);
            byte_code->prederef.branches = NULL;
        }
    }
    byte_code->fixups = NULL;
    byte_code->debugs = NULL;
    byte_code->const_table = NULL;
    byte_code->pic_index = NULL;
}

/*

=back

=head2 Debug Info

=item c<void
Parrot_debug_add_mapping(Interp *interpreter,
                         struct PackFile_Debug *debug,
                         opcode_t offset, int mapping_type,
                         const char *filename, int source_seg)>

Add a bytecode offset to filename/source segment mapping. mapping_type may be
one of PF_DEBUGMAPPINGTYPE_NONE (in which case the last two parameters are
ignored), PF_DEBUGMAPPINGTYPE_FILENAME (in which case filename must be given)
or PF_DEBUGMAPPINGTYPE_SOURCESEG (in which case source_seg should contains the
number of the source segment in question).

=cut

*/
void
Parrot_debug_add_mapping(Interp *interpreter,
                         struct PackFile_Debug *debug,
                         opcode_t offset, int mapping_type,
                         const char *filename, int source_seg)
{
    struct PackFile_DebugMapping *mapping;
    struct PackFile_ConstTable * const ct = debug->code->const_table;
    struct PackFile_Constant *fnconst;
    int insert_pos = 0;

    /* Allocate space for the extra entry. */
    debug->mappings = mem_sys_realloc(debug->mappings,
        sizeof(Parrot_Pointer) * (debug->num_mappings + 1));

    /* Can it just go on the end? */
    if (debug->num_mappings == 0 ||
        offset >= debug->mappings[debug->num_mappings - 1]->offset)
    {
        insert_pos = debug->num_mappings;
    }
    else {
        /* Find the right place and shift stuff that's after it. */
        int i;
        for (i = 0; i < debug->num_mappings; i++) {
            if (debug->mappings[i]->offset > offset) {
                insert_pos = i;
                memmove(debug->mappings + i + 1, debug->mappings + i,
                    debug->num_mappings - i);
                break;
            }
        }
    }

    /* Set up new entry and insert it. */
    mapping = mem_sys_allocate(sizeof(struct PackFile_DebugMapping));
    mapping->offset = offset;
    mapping->mapping_type = mapping_type;
    switch (mapping_type) {
        case PF_DEBUGMAPPINGTYPE_NONE:
            break;
        case PF_DEBUGMAPPINGTYPE_FILENAME:
            /* Need to put filename in constants table. */
            ct->const_count = ct->const_count + 1;
            if (ct->constants)
                ct->constants = mem_sys_realloc(ct->constants,
                    ct->const_count * sizeof(Parrot_Pointer));
            else
                ct->constants = mem_sys_allocate(
                    ct->const_count * sizeof(Parrot_Pointer));
            fnconst = PackFile_Constant_new(interpreter);
            fnconst->type = PFC_STRING;
            fnconst->u.string = string_make_direct(interpreter, filename,
                strlen(filename), PARROT_DEFAULT_ENCODING,
                PARROT_DEFAULT_CHARSET, PObj_constant_FLAG);
            ct->constants[ct->const_count - 1] = fnconst;
            mapping->u.filename = ct->const_count - 1;
            break;
        case PF_DEBUGMAPPINGTYPE_SOURCESEG:
            mapping->u.source_seg = source_seg;
            break;
    }
    debug->mappings[insert_pos] = mapping;
    debug->num_mappings = debug->num_mappings + 1;
}

/*
=item C<STRING*
Parrot_debug_pc_to_filename(Interp *interpreter,
        struct PackFile_Debug *debug, opcode_t pc)>

Take a position in the bytecode and return the filename of the source for
that position.

=cut

*/

STRING *
Parrot_debug_pc_to_filename(Interp *interpreter,
        struct PackFile_Debug *debug, opcode_t pc)
{
    /* Look through mappings until we find one that maps the passed
       bytecode offset. */
    int i;
    for (i = 0; i < debug->num_mappings; i++) {
        /* If this is the last mapping or the current position is
           between this mapping and the next one, return a filename. */
        if (i + 1 == debug->num_mappings ||
            (debug->mappings[i]->offset <= pc &&
             debug->mappings[i+1]->offset > pc))
        {
            switch (debug->mappings[i]->mapping_type) {
                case PF_DEBUGMAPPINGTYPE_NONE:
                    return string_from_const_cstring(interpreter,
                        "(unknown file)", 0);
                case PF_DEBUGMAPPINGTYPE_FILENAME:
                    return PF_CONST(debug->code,
                        debug->mappings[i]->u.filename)->u.string;
                case PF_DEBUGMAPPINGTYPE_SOURCESEG:
                    return string_from_const_cstring(interpreter,
                        "(unknown file)", 0);
            }
        }
    }

    /* Otherwise, no mappings = no filename. */
    return string_from_const_cstring(interpreter, "(unknown file)", 0);
}

/*

=item C<void
Parrot_switch_to_cs_by_nr(Interp *interpreter, opcode_t seg)>

Switch to byte code segment number C<seg>.

=cut

*/

void
Parrot_switch_to_cs_by_nr(Interp *interpreter, opcode_t seg)
{
    PMC * const dir = PMC_PackFileByteCode(interpreter->code)->dir;
    const size_t num_segs = VTABLE_elements(interpreter, dir);
    size_t i;
    opcode_t n;

    /* TODO make an index of code segments for faster look up */
    for (i = n = 0; i < num_segs; i++) {
        struct PackFile_Segment *cur_seg = VTABLE_get_pmc_keyed_int(interpreter, dir, i);
        if (cur_seg->type == PF_BYTEC_SEG) {
            if (n == seg) {
                Parrot_switch_to_cs(interpreter, (struct PackFile_ByteCode *)
                        cur_seg, 1);
                return;
            }
            n++;
        }
    }
    internal_exception(1, "Segment number %d not found\n", (int) seg);
}

/*

=item C<struct PackFile_ByteCode *
Parrot_switch_to_cs(Interp *interpreter,
    struct PackFile_ByteCode *new_cs, int really)>

Switch to a byte code segment C<new_cs>, returning the old segment.

=cut

*/

struct PackFile_ByteCode *
Parrot_switch_to_cs(Interp *interpreter,
    struct PackFile_ByteCode *new_cs, int really)
{
    struct PackFile_ByteCode * const cur_cs = interpreter->code;

    if (!new_cs) {
        internal_exception(NO_PREV_CS, "No code segment to switch to\n");
    }
    /* compiling source code uses this function too,
     * which gives misleading trace messages
     */
    if (really && Interp_trace_TEST(interpreter, PARROT_TRACE_SUB_CALL_FLAG)) {
        Interp *tracer = interpreter->debugger ?
            interpreter->debugger : interpreter;
        PIO_eprintf(tracer, "*** switching to %s\n",
                new_cs->base.name);
    }
    interpreter->code = new_cs;
    CONTEXT(interpreter->ctx)->constants =
        really ? find_constants(interpreter, new_cs->const_table) :
        new_cs->const_table->constants;
            /* new_cs->const_table->constants; */
    CONTEXT(interpreter->ctx)->pred_offset =
        new_cs->base.data - (opcode_t*) new_cs->prederef.code;
    new_cs->prev = cur_cs;
    if (really)
        prepare_for_run(interpreter);
    return cur_cs;
}

/*

=item C<void
Parrot_pop_cs(Interp *interpreter)>

Remove current byte code segment from directory and switch to previous.

=cut

*/

void
Parrot_pop_cs(Interp *interpreter)
{
    struct Parrot_PackFile_ByteCode * const cur_cs = 
        PMC_PackFileByteCode(interpreter->code);

    interpreter->code = cur_cs->prev;
    PackFile_remove_segment_by_name (interpreter,
            cur_cs->base.dir, cur_cs->base.name);
    /* FIXME delete returned segment */
}

/*

=item C<static PackFile_Constant **
find_constants(Interp *interpreter, struct PackFile_ConstTable *ct)>

Find the constant table associated with a thread. For now, we need to copy
constant tables because some entries aren't really constant; e.g.
subroutines need to reference namespace pointers.

=cut

*/

static struct PackFile_Constant *
clone_constant(Interp *interpreter, struct PackFile_Constant *old_const) {
    STRING * const _sub = interpreter->vtables[enum_class_Sub]->whoami;

    if (old_const->type == PFC_PMC
            && VTABLE_isa(interpreter, old_const->u.key, _sub)) {
        struct PackFile_Constant *ret;
        PMC *old_sub;
        PMC *new_sub;
        ret = mem_sys_allocate(sizeof(struct PackFile_Constant));

        ret->type = old_const->type;

        old_sub = old_const->u.key;
        new_sub = Parrot_thaw_constants(interpreter,
            Parrot_freeze(interpreter, old_sub));

        PMC_sub(new_sub)->seg = PMC_sub(old_sub)->seg;
        Parrot_store_sub_in_namespace(interpreter, new_sub);

        ret->u.key = new_sub;

        return ret;
    }
    else {
        return old_const;
    }
}

static struct PackFile_Constant **
find_constants(Interp *interpreter, struct PackFile_ConstTable *ct) {
    if (!n_interpreters || !interpreter->thread_data ||
            interpreter->thread_data->tid == 0) {
        return ct->constants;
    }
    else {
        Hash *tables;
        struct PackFile_Constant **new_consts;

        assert(interpreter->thread_data);

        if (!interpreter->thread_data->const_tables) {
            interpreter->thread_data->const_tables =
                mem_sys_allocate(sizeof(Hash));
            parrot_new_pointer_hash(interpreter,
                                    &interpreter->thread_data->const_tables);
        }

        tables = interpreter->thread_data->const_tables;

        new_consts = parrot_hash_get(interpreter, tables, ct);

        if (!new_consts) {
            /* need to construct it */
            struct PackFile_Constant **old_consts;
            INTVAL i;
            INTVAL const num_consts = ct->const_count;

            old_consts = ct->constants;
            new_consts =
                mem_sys_allocate(sizeof(struct PackFile_Constant*)*num_consts);

            for (i = 0; i < num_consts; ++i) {
                new_consts[i] = clone_constant(interpreter, old_consts[i]);
            }

            parrot_hash_put(interpreter, tables, ct, new_consts);
        }

        return new_consts;
    }
}

void
Parrot_destroy_constants(Interp *interpreter) {
    UINTVAL i;
    Hash *hash;
    if (!interpreter->thread_data) {
        return;
    }

    hash = interpreter->thread_data->const_tables;

    if (!hash) {
        return;
    }

    for (i = 0; i <= hash->mask; ++i) {
        HashBucket *bucket = hash->bi[i];
        while (bucket) {
            struct PackFile_ConstTable *const table = bucket->key;
            struct PackFile_Constant **const orig_consts = table->constants;
            struct PackFile_Constant **const consts = bucket->value;
            INTVAL const const_count = table->const_count;
            INTVAL i;
            for (i = 0; i < const_count; ++i) {
                if (consts[i] != orig_consts[i]) {
                    mem_sys_free(consts[i]);
                }
            }
            mem_sys_free(consts);
            bucket = bucket->next;
        }
    }

    parrot_hash_destroy(interpreter, hash);
}

/*

=back

=head2 PackFile FixupTable Structure Functions

=over 4

=item C<void
PackFile_FixupTable_clear(Interp *, struct PackFile_FixupTable *self)>

Clear a PackFile FixupTable.

=cut

*/

void
PackFile_FixupTable_clear(Interp *interpreter, struct PackFile_FixupTable *self)
{
    opcode_t i;
    if (!self) {
        PIO_eprintf(NULL, "PackFile_FixupTable_clear: self == NULL!\n");
        return;
    }

    for (i = 0; i < self->fixup_count; i++) {
        switch (self->fixups[i]->type) {
            case enum_fixup_label:
                mem_sys_free(self->fixups[i]->name);
                self->fixups[i]->name = NULL;
                break;
        }
        mem_sys_free(self->fixups[i]);
        self->fixups[i] = NULL;
    }

    if (self->fixup_count) {
        mem_sys_free(self->fixups);
        self->fixups = NULL;
    }

    self->fixups = NULL;
    self->fixup_count = 0;

    return;
}

/*

=item C<static void
fixup_destroy (Interp*, struct PackFile_Segment *self)>

Just calls C<PackFile_FixupTable_clear()> with C<self>.

=cut

*/

static void
fixup_destroy (Interp* interpreter, struct PackFile_Segment *self)
{
    struct PackFile_FixupTable * const ft = (struct PackFile_FixupTable *) self;
    PackFile_FixupTable_clear(interpreter, ft);
}

/*

=item C<static size_t
fixup_packed_size(Interp*, struct PackFile_Segment *self)>

I<What does this do?>

=cut

*/

static size_t
fixup_packed_size (Interp* interpreter, struct PackFile_Segment *self)
{
    struct PackFile_FixupTable * const ft = (struct PackFile_FixupTable *) self;
    size_t size;
    opcode_t i;

    size = 1;    /* fixup_count */
    for (i = 0; i < ft->fixup_count; i++) {
        size++;  /* fixup_entry type */
        switch (ft->fixups[i]->type) {
            case enum_fixup_label:
            case enum_fixup_sub:
                size += PF_size_cstring(ft->fixups[i]->name);
                size ++; /* offset */
                break;
            case enum_fixup_none:
                break;
            default:
                internal_exception(1, "Unknown fixup type\n");
                return 0;
        }
    }
    return size;
}

/*

=item C<static opcode_t *
fixup_pack (Interp*, struct PackFile_Segment *self, opcode_t *cursor)>

I<What does this do?>

=cut

*/

static opcode_t *
fixup_pack(Interp* interpreter, struct PackFile_Segment *self, opcode_t *cursor)
{
    struct PackFile_FixupTable * const ft = (struct PackFile_FixupTable *) self;
    opcode_t i;

    *cursor++ = ft->fixup_count;
    for (i = 0; i < ft->fixup_count; i++) {
        *cursor++ = (opcode_t) ft->fixups[i]->type;
        switch (ft->fixups[i]->type) {
            case enum_fixup_label:
            case enum_fixup_sub:
                cursor = PF_store_cstring(cursor, ft->fixups[i]->name);
                *cursor++ = ft->fixups[i]->offset;
                break;
            case enum_fixup_none:
                break;
            default:
                internal_exception(1, "Unknown fixup type\n");
                return 0;
        }
    }
    return cursor;
}

/*

=item C<static struct PackFile_Segment *
fixup_new(Interp*, PMC *pf, const char *name, int add)>

Returns a new C<PackFile_FixupTable> segment.

=cut

*/

static struct PackFile_Segment *
fixup_new (Interp* interpreter, PMC *pf, const char *name, int add)
{
    struct PackFile_FixupTable * const fixup =
        mem_sys_allocate(sizeof(struct PackFile_FixupTable));

    fixup->fixup_count = 0;
    fixup->fixups = NULL;
    return (struct PackFile_Segment*) fixup;
}

/*

=item C<static opcode_t *
fixup_unpack(Interp *interpreter,
        struct PackFile_Segment *seg, opcode_t *cursor)>

Unpack a PackFile FixupTable from a block of memory.

Returns one (1) if everything is OK, else zero (0).

=cut

*/

static opcode_t *
fixup_unpack(Interp *interpreter,
        struct PackFile_Segment *seg, opcode_t *cursor)
{
    opcode_t i;
    struct Parrot_PackFile *pf;
    struct PackFile_FixupTable * const self = (struct PackFile_FixupTable *)seg;

    if (!self) {
        PIO_eprintf(interpreter, "PackFile_FixupTable_unpack: self == NULL!\n");
        return 0;
    }

    PackFile_FixupTable_clear(interpreter, self);

    pf = PMC_PackFile(self->base.pf);
    self->fixup_count = PF_fetch_opcode(pf, &cursor);

    if (self->fixup_count) {
        self->fixups = mem_sys_allocate_zeroed(self->fixup_count *
                sizeof(struct PackFile_FixupEntry *));

        if (!self->fixups) {
            PIO_eprintf(interpreter,
                    "PackFile_FixupTable_unpack: Could not allocate "
                    "memory for array!\n");
            self->fixup_count = 0;
            return 0;
        }
    }

    for (i = 0; i < self->fixup_count; i++) {
        struct PackFile_FixupEntry * const entry =
            self->fixups[i] =
            mem_sys_allocate(sizeof(struct PackFile_FixupEntry));
        self->fixups[i]->type = PF_fetch_opcode(pf, &cursor);
        switch (self->fixups[i]->type) {
            case enum_fixup_label:
            case enum_fixup_sub:
                self->fixups[i]->name = PF_fetch_cstring(pf, &cursor);
                self->fixups[i]->offset = PF_fetch_opcode(pf, &cursor);
                break;
            case enum_fixup_none:
                break;
            default:
                PIO_eprintf(interpreter,
                        "PackFile_FixupTable_unpack: Unknown fixup type %d!\n",
                        self->fixups[i]->type);
                return 0;
        }
    }

    return cursor;
}

/*

=item C<void PackFile_FixupTable_new_entry(Interp *interpreter,
        char *label, enum_fixup_t type, opcode_t offs)>

I<What does this do?>

=cut

*/

void
PackFile_FixupTable_new_entry(Interp *interpreter,
        char *label, enum_fixup_t type, opcode_t offs)
{
    struct PackFile_FixupTable *self = PMC_PackFileByteCode(interpreter->code)->fixups;
    opcode_t i;

    if (!self) {
        self = (struct PackFile_FixupTable  *) PackFile_Segment_new_seg(
                interpreter,
                PMC_PackFileByteCode(interpreter->code)->dir, PF_FIXUP_SEG,
                FIXUP_TABLE_SEGMENT_NAME, 1);
        PMC_PackFileByteCode(interpreter->code)->fixups = self;
        self->code = interpreter->code;
    }
    i = self->fixup_count;
    self->fixup_count++;
    if (self->fixups) {
        self->fixups =
            mem_sys_realloc(self->fixups, self->fixup_count *
                            sizeof(struct PackFile_FixupEntry *));
    }
    else {
        self->fixups =
            mem_sys_allocate(sizeof(struct PackFile_FixupEntry *));
    }
    self->fixups[i] = mem_sys_allocate(sizeof(struct PackFile_FixupEntry));
    self->fixups[i]->type = type;
    self->fixups[i]->name = mem_sys_allocate(strlen(label) + 1);
    strcpy(self->fixups[i]->name, label);
    self->fixups[i]->offset = offs;
    self->fixups[i]->seg = self->code;
}

/*

=item C<static struct PackFile_FixupEntry *
find_fixup(struct PackFile_FixupTable *ft, enum_fixup_t type,
        const char *name)>

Finds the fix-up entry for C<name> and returns it.

=cut

*/

static struct PackFile_FixupEntry *
find_fixup(struct PackFile_FixupTable *ft, enum_fixup_t type,
        const char * name)
{
    opcode_t i;
    for (i = 0; i < ft->fixup_count; i++) {
        if ((enum_fixup_t)ft->fixups[i]->type == type &&
                !strcmp(ft->fixups[i]->name, name)) {
            ft->fixups[i]->seg = ft->code;
            return ft->fixups[i];
        }
    }
    return NULL;
}

/*

=item C<static INTVAL
find_fixup_iter(Interp*, struct PackFile_Segment *seg, void *user_data)>

I<What does this do?>

=cut

*/

static INTVAL
find_fixup_iter(Interp* interpreter, struct PackFile_Segment *seg,
        void *user_data)
{
    if (seg->type == PF_DIR_SEG) {
        if (PackFile_map_segments(interpreter, (PMC*)seg,
                find_fixup_iter, user_data))
            return 1;
    }
    else if (seg->type == PF_FIXUP_SEG) {
        struct PackFile_FixupEntry ** const e = user_data;
        struct PackFile_FixupEntry * const fe = find_fixup(
                (struct PackFile_FixupTable *) seg, (*e)->type, (*e)->name);
        if (fe) {
            *e = fe;
            return 1;
        }
    }
    return 0;
}

/*

=item C<struct PackFile_FixupEntry *
PackFile_find_fixup_entry(Interp *interpreter, enum_fixup_t type,
        char * name)>

I<What does this do?>

=cut

*/

struct PackFile_FixupEntry *
PackFile_find_fixup_entry(Interp *interpreter, enum_fixup_t type,
        char * name)
{
    /* TODO make a hash of all fixups */
    PMC *dir = PMC_PackFileByteCode(interpreter->code)->dir;
    struct PackFile_FixupEntry *ep, e;
    int found;

    /*
     * XXX when in eval, the dir is in cur_cs->prev
     */
    if (PMC_PackFileByteCode(interpreter->code)->prev)
        dir = PMC_PackFileByteCode(interpreter->code)->prev->base.dir;

    e.type = type;
    e.name = name;
    ep = &e;
    found = PackFile_map_segments(interpreter, dir, find_fixup_iter,
            (void *) &ep);
    return found ? ep : NULL;
}

/*

=back

=head2 PackFile ConstTable Structure Functions

=over 4

=item C<void
PackFile_ConstTable_clear(Interp*, struct PackFile_ConstTable *self)>

Clear the C<PackFile_ConstTable> C<self>.

=cut

*/

void
PackFile_ConstTable_clear(Interp* interpreter, struct PackFile_ConstTable *self)
{
    opcode_t i;

    for (i = 0; i < self->const_count; i++) {
        PackFile_Constant_destroy(interpreter, self->constants[i]);
        self->constants[i] = NULL;
    }

    if (self->const_count) {
        mem_sys_free(self->constants);
    }

    self->constants = NULL;
    self->const_count = 0;

    return;
}

#if EXEC_CAPABLE
struct PackFile_Constant *exec_const_table;
#endif

/*

=item C<opcode_t *
PackFile_ConstTable_unpack(Interp *interpreter,
        struct PackFile_Segment *seg,
        opcode_t *cursor)>

Unpack a PackFile ConstTable from a block of memory. The format is:

  opcode_t const_count
  *  constants

Returns cursor if everything is OK, else zero (0).

=cut

*/

opcode_t *
PackFile_ConstTable_unpack(Interp *interpreter,
        struct PackFile_Segment *seg,
        opcode_t *cursor)
{
    opcode_t i;
    struct PackFile_ConstTable * const self = (struct PackFile_ConstTable *)seg;
    struct Parrot_PackFile * const pf = PMC_PackFile(seg->pf);
#if EXEC_CAPABLE
    extern int Parrot_exec_run;
#endif

    PackFile_ConstTable_clear(interpreter, self);

    self->const_count = PF_fetch_opcode(pf, &cursor);

#if TRACE_PACKFILE
    PIO_eprintf(interpreter,
            "PackFile_ConstTable_unpack: Unpacking %ld constants\n",
            self->const_count);
#endif

    if (self->const_count == 0) {
        return cursor;
    }

    self->constants = mem_sys_allocate_zeroed(self->const_count *
            sizeof(struct PackFile_Constant *));

    if (!self->constants) {
        PIO_eprintf(interpreter,
                "PackFile_ConstTable_unpack: Could not allocate "
                "memory for array!\n");
        self->const_count = 0;
        return 0;
    }

    for (i = 0; i < self->const_count; i++) {
#if TRACE_PACKFILE
        PIO_eprintf(interpreter,
                "PackFile_ConstTable_unpack(): Unpacking constant %ld\n", i);
#endif

#if EXEC_CAPABLE
        if (Parrot_exec_run)
            self->constants[i] = &exec_const_table[i];
        else
#endif
            self->constants[i] = PackFile_Constant_new(interpreter);

        cursor = PackFile_Constant_unpack(interpreter, self, self->constants[i],
                    cursor);
    }
    return cursor;
}

/*

=item C<static struct PackFile_Segment *
const_new(Interp*, PMC *pf, const char *name, int add)>

Returns a new C<PackFile_ConstTable> segment.

=cut

*/

static struct PackFile_Segment *
const_new (Interp* interpreter, PMC *pf, const char *name, int add)
{
    struct PackFile_ConstTable *const_table;

    const_table = mem_sys_allocate(sizeof(struct PackFile_ConstTable));

    const_table->const_count = 0;
    const_table->constants = NULL;

    return (struct PackFile_Segment *)const_table;
}

/*

=item C<static void
const_destroy(Interp*, struct PackFile_Segment *self)>

Destroys the C<PackFile_ConstTable> C<self>.

=cut

*/

static void
const_destroy (Interp* interpreter, struct PackFile_Segment *self)
{
    struct PackFile_ConstTable * const ct = (struct PackFile_ConstTable *)self;

    PackFile_ConstTable_clear (interpreter, ct);
}

/*

=back

=head2 PackFile Constant Structure Functions

=over 4

=item C<struct PackFile_Constant *
PackFile_Constant_new(Interp*)>

Allocate a new empty PackFile Constant.

This is only here so we can make a new one and then do an unpack.

=cut

*/

struct PackFile_Constant *
PackFile_Constant_new(Interp* interpreter)
{
    struct PackFile_Constant * const self =
        mem_sys_allocate_zeroed(sizeof(struct PackFile_Constant));

    self->type = PFC_NONE;

    return self;
}

/*

=item C<void
PackFile_Constant_destroy(Interp*, struct PackFile_Constant *self)>

Delete the C<PackFile_Constant> C<self>.

Don't delete C<PMC>s or C<STRING>s, they are destroyed via DOD/GC.

=cut

*/

void
PackFile_Constant_destroy(Interp* interpreter, struct PackFile_Constant *self)
{
    mem_sys_free(self);
}

/*

=item C<size_t
PackFile_Constant_pack_size(Interp*, struct PackFile_Constant *self)>

Determine the size of the buffer needed in order to pack the PackFile
Constant into a contiguous region of memory.

=cut

*/

size_t
PackFile_Constant_pack_size(Interp* interpreter, struct PackFile_Constant *self)
{
    size_t packed_size;
    PMC *component;
    STRING *image;

    switch (self->type) {

        case PFC_NUMBER:
            packed_size = PF_size_number();
            break;

        case PFC_STRING:
            packed_size = PF_size_string(self->u.string);
            break;

        case PFC_KEY:
            packed_size = 1;

            for (component = self->u.key; component;
                    component = PMC_data(component))
                packed_size += 2;
            break;

        case PFC_PMC:
            component = self->u.key; /* the pmc (Sub, ...) */

            /*
             * TODO create either
             * a) a frozen_size freeze entry or
             * b) change packout.c so that component size isn't needed
             */
            image = Parrot_freeze(interpreter, component);
            packed_size = PF_size_string(image);
            break;

        default:
            PIO_eprintf(NULL,
                    "Constant_packed_size: Unrecognized type '%c'!\n",
                    (char)self->type);
            return 0;
    }

    /* Tack on space for the initial type field */
    return packed_size + 1;
}

/*

=item C<opcode_t *
PackFile_Constant_unpack(Interp *interpreter,
                         struct PackFile_ConstTable *constt,
                         struct PackFile_Constant *self, opcode_t *cursor)>

Unpack a PackFile Constant from a block of memory. The format is:

  opcode_t type
  *  data

Returns cursor if everything is OK, else zero (0).

=cut

*/

opcode_t *
PackFile_Constant_unpack(Interp *interpreter,
                         struct PackFile_ConstTable *constt,
                         struct PackFile_Constant *self, opcode_t *cursor)
{
    struct Parrot_PackFile * const pf = PMC_PackFile(constt->base.pf);
    const opcode_t type = PF_fetch_opcode(pf, &cursor);

/* #define TRACE_PACKFILE 1 */
#if TRACE_PACKFILE
    PIO_eprintf(NULL, "PackFile_Constant_unpack(): Type is %ld ('%c')...\n",
            type, (char)type);
#endif

    switch (type) {
    case PFC_NUMBER:
        self->u.number = PF_fetch_number(pf, &cursor);
        self->type = PFC_NUMBER;
        break;

    case PFC_STRING:
        self->u.string = PF_fetch_string(interpreter, pf, &cursor);
        self->type = PFC_STRING;
        break;

    case PFC_KEY:
        cursor = PackFile_Constant_unpack_key(interpreter, constt,
                self, cursor);
        break;

    case PFC_PMC:
        cursor = PackFile_Constant_unpack_pmc(interpreter, constt,
                self, cursor);
        break;
    default:
        PIO_eprintf(NULL,
                "Constant_unpack: Unrecognized type '%c' during unpack!\n",
                (char)type);
        return 0;
    }
    return cursor;
}

/*

=item C<opcode_t *
PackFile_Constant_unpack_pmc(Interp *interpreter,
                         struct PackFile_ConstTable *constt,
                         struct PackFile_Constant *self,
                         opcode_t *cursor)>

Unpack a constant PMC.

=cut

*/

opcode_t *
PackFile_Constant_unpack_pmc(Interp *interpreter,
                         struct PackFile_ConstTable *constt,
                         struct PackFile_Constant *self,
                         opcode_t *cursor)
{
    struct Parrot_PackFile * const pf = PMC_PackFile(constt->base.pf);
    STRING *image, *_sub;
    PMC *pmc;

    /*
     * thawing the PMC needs the real packfile in place
     */
    struct PackFile_ByteCode * const cs_save = interpreter->code;
    interpreter->code = pf->cur_cs;

    image = PF_fetch_string(interpreter, pf, &cursor);
    /*
     * TODO use thaw_constants
     * current issue: a constant Sub with attached properties
     *                doesn't DOD mark the properties
     * for a constant PMC *all* contents have to be in the constant pools
     */
    pmc = Parrot_thaw(interpreter, image);
    /*
     * place item in const_table
     */
    self->type = PFC_PMC;
    self->u.key = pmc;

    _sub = const_string(interpreter, "Sub");    /* CONST_STRING */
    if (VTABLE_isa(interpreter, pmc, _sub)) {
        /*
         * finally place the sub into some namespace stash
         * XXX place this code in Sub.thaw ?
         */
        Parrot_store_sub_in_namespace(interpreter, pmc);
    }
    /*
     * restore code
     */
    interpreter->code = cs_save;
    return cursor;
}

/*

=item C<opcode_t *
PackFile_Constant_unpack_key(Interp *interpreter,
                             struct PackFile_ConstTable *constt,
                             struct PackFile_Constant *self,
                             opcode_t *cursor)>

Unpack a PackFile Constant from a block of memory. The format consists
of a sequence of key atoms, each with the following format:

  opcode_t type
  opcode_t value

Returns cursor if everything is OK, else zero (0).

=cut

*/

opcode_t *
PackFile_Constant_unpack_key(Interp *interpreter,
                             struct PackFile_ConstTable *constt,
                             struct PackFile_Constant *self,
                             opcode_t *cursor)
{
    PMC *head;
    PMC *tail;
    opcode_t type, op, slice_bits;
    struct Parrot_PackFile * const pf = PMC_PackFile(constt->base.pf);
    int pmc_enum = enum_class_Key;

    INTVAL components = (INTVAL)PF_fetch_opcode(pf, &cursor);
    head = tail = NULL;

    while (components-- > 0) {
        type = PF_fetch_opcode(pf, &cursor);
        slice_bits = type & PF_VT_SLICE_BITS;
        type &= ~PF_VT_SLICE_BITS;
        if (!head && slice_bits) {
            pmc_enum = enum_class_Slice;
        }
        if (tail) {
            PMC_data(tail)
                = constant_pmc_new_noinit(interpreter, pmc_enum);
            tail = PMC_data(tail);
        }
        else {
            head = tail = constant_pmc_new_noinit(interpreter, pmc_enum);
        }

        VTABLE_init(interpreter, tail);

        op = PF_fetch_opcode(pf, &cursor);
        switch (type) {
        case PARROT_ARG_IC:
            key_set_integer(interpreter, tail, op);
            break;
        case PARROT_ARG_NC:
            key_set_number(interpreter, tail, constt->constants[op]->u.number);
            break;
        case PARROT_ARG_SC:
            key_set_string(interpreter, tail, constt->constants[op]->u.string);
            break;
        case PARROT_ARG_I:
            key_set_register(interpreter, tail, op, KEY_integer_FLAG);
            break;
        case PARROT_ARG_N:
            key_set_register(interpreter, tail, op, KEY_number_FLAG);
            break;
        case PARROT_ARG_S:
            key_set_register(interpreter, tail, op, KEY_string_FLAG);
            break;
        case PARROT_ARG_P:
            key_set_register(interpreter, tail, op, KEY_pmc_FLAG);
            break;
        default:
            return 0;
        }
        if (slice_bits) {
            if (slice_bits & PF_VT_START_SLICE)
                PObj_get_FLAGS(tail) |= KEY_start_slice_FLAG;
            if (slice_bits & PF_VT_END_SLICE)
                PObj_get_FLAGS(tail) |= KEY_end_slice_FLAG;
            if (slice_bits & (PF_VT_START_ZERO | PF_VT_END_INF))
                PObj_get_FLAGS(tail) |= KEY_inf_slice_FLAG;
        }
    }

    self->type = PFC_KEY;
    self->u.key = head;

    return cursor;
}

/*

=item C<static PMC*
PackFile_append_pbc(Interp *interpreter, const char *filename)>

Read a PBC and append it to the current directory
Fixup sub addresses in newly loaded bytecode and run :load subs.

=cut

*/

static struct PMC*
PackFile_append_pbc(Interp *interpreter, const char *filename)
{
    PMC* pf = Parrot_readbc(interpreter, filename);
    if (!pf)
        return NULL;
    PackFile_add_segment(interpreter,
        PMC_PackFile(interpreter->initial_pf)->directory,
        PMC_PackFile(pf)->directory);
    do_sub_pragmas(interpreter, PMC_PackFile(pf)->cur_cs, PBC_LOADED, NULL);
    return pf;
}

/*

=item C<void
Parrot_load_bytecode(Interp *interpreter, STRING *filename)>

Load and append a bytecode, IMC or PASM file into interpreter.

Load some bytecode (PASM, PIR, PBC ...) and append it to the current
directory.

=cut

*/

/*
 * intermediate hook during changes
 */
/* XXX Declare this elsewhere */
void * IMCC_compile_file (Parrot_Interp interp, const char *s);

void
Parrot_load_bytecode(Interp *interpreter, STRING *file_str)
{
    char *filename;
    STRING *wo_ext, *ext, *pbc, *path;
    enum_runtime_ft file_type;
    PMC *is_loaded_hash;

    parrot_split_path_ext(interpreter, file_str, &wo_ext, &ext);
    /* check if wo_ext is loaded */
    is_loaded_hash = VTABLE_get_pmc_keyed_int(interpreter,
        interpreter->iglobals, IGLOBALS_PBC_LIBS);
    if (VTABLE_exists_keyed_str(interpreter, is_loaded_hash, wo_ext))
        return;
    pbc = const_string(interpreter, "pbc");
    if (string_equal(interpreter, ext, pbc) == 0)
        file_type = PARROT_RUNTIME_FT_PBC;
    else
        file_type = PARROT_RUNTIME_FT_SOURCE;

    path = Parrot_locate_runtime_file_str(interpreter, file_str, file_type);
    if (!path) {
        real_exception(interpreter, NULL, E_LibraryNotLoadedError,
                "Couldn't find file '%Ss'", file_str);
        return;
    }
    /* remember wo_ext => full_path mapping */
    VTABLE_set_string_keyed_str(interpreter, is_loaded_hash,
            wo_ext, path);
    filename = string_to_cstring(interpreter, path);
    if ( file_type == PARROT_RUNTIME_FT_PBC) {
        PackFile_append_pbc(interpreter, filename);
    }
    else {
        STRING *err;
        struct PackFile_ByteCode * const cs = IMCC_compile_file_s(interpreter,
                filename, &err);
        if (cs) {
            do_sub_pragmas(interpreter, cs, PBC_LOADED, NULL);
        }
        else
            real_exception(interpreter, NULL, E_LibraryNotLoadedError,
                "compiler returned NULL ByteCode '%Ss' - %Ss", file_str, err);
    }
    string_cstring_free(filename);
}

/*

=item C<void
PackFile_fixup_subs(Interp *interpreter, pbc_action_enum_t what, PMC *eval)>

Run :load or :immediate subroutines for the current code segment.
If C<eval> is given, set this is the owner of the subroutines.

=cut

*/

void
PackFile_fixup_subs(Interp *interpreter, pbc_action_enum_t what, PMC *eval)
{
    do_sub_pragmas(interpreter, interpreter->code, what, eval);
}

/*

=back

=head1 HISTORY

Rework by Melvin; new bytecode format, make bytecode portable. (Do
endian conversion and wordsize transforms on the fly.)

leo applied and modified Juergen Boemmels packfile patch giving an
extensible packfile format with directory reworked again, with common
chunks (C<default_*>).

2003.11.21 leo: moved low level item fetch routines to new
F<pf/pf_items.c>

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
