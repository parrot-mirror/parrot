#include "imc.h"
#include "pbc.h"
#include "parrot/packfile.h"

/*
 * pbc.c
 *
 * emit imcc instructions into parrot interpreter
 *
 * the e_pbc_emit function is called per instruction
 *
 * Notes:
 *
 * I' using existing data structure here (SymReg*) to store
 * various global items e.g. bsr fixups and constants.
 * The index in the constant table is in SymReg* ->color
 * data member. This looks odd, but the register number
 * from imc.c:allocate is also there for variables,
 * so it's a little bit consistent at least.
 *
 * So when reading color here it's either a constant table idx
 * or a parrot register number, depending on data type.
 *
 * More weird, in global fixup reg->score is used for the opcode offset
 * into the instruction.
 *
 * TODO memory clean up
 *
 * And finally: there might be some issues on 64bit systems with
 * my mixing of int and opcode_t, which will be looked at, when this
 * is in CVS
 *
 * -lt
 *
 */

/* globals store the state between individual e_pbc_emit calls
 *
 */

struct subs {
    size_t size;                        /* code size in ops */
    int ins_line;                       /* line# for debug */
    int n_basic_blocks;                 /* block count */
    SymReg * labels[HASH_SIZE];         /* label names */
    SymReg * bsrs[HASH_SIZE];           /* bsr, set_addr locations */
    struct subs *prev;
    struct subs *next;
};

/* subs are kept per code segment */
struct cs_t {
    struct PackFile_ByteCode *seg;      /* bytecode seg */
    struct PackFile_Segment *jit_info;  /* bblocks, register usage */
    struct subs *subs;                  /* current sub data */
    struct subs *first;                 /* first sub of code seg */
    struct cs_t *prev;                  /* prev cs */
    struct cs_t *next;                  /* next cs */
};

static struct globals {
    SymReg * str_consts[HASH_SIZE];
    SymReg * num_consts[HASH_SIZE];
    SymReg * key_consts[HASH_SIZE];
    struct cs_t *cs;                     /* current cs */
    struct cs_t *first;                  /* first cs */
    int inter_seg_n;
} globals;


static int add_const_str(struct Parrot_Interp *, char *str, int dup_sym);

static void imcc_globals_destroy(int ex, void *param);

static void imcc_globals_destroy(int ex, void *param)
{
    struct cs_t *cs, *prev_cs;
    struct subs *s, *prev_s;
    struct Parrot_Interp *interpreter = (struct Parrot_Interp *)param;
    SymReg **h;

    UNUSED(ex);
    UNUSED(param);
    cs = globals.cs;
    while (cs) {
        s = cs->subs;
        while (s) {
            prev_s = s->prev;
            h = s->labels;
            clear_tables(interpreter, h);
            h = s->bsrs;
            clear_tables(interpreter, h);
            mem_sys_free(s);
            s = prev_s;
        }
        prev_cs = cs->prev;
        mem_sys_free(cs);
        cs = prev_cs;
    }
    h = globals.str_consts;
    clear_tables(interpreter, h);
    h = globals.num_consts;
    clear_tables(interpreter, h);
    h = globals.key_consts;
    clear_tables(interpreter, h);
    globals.cs = NULL;
}

static struct PackFile_Segment *
create_seg(struct PackFile_Directory *dir, pack_file_types t, const char *name)
{
    char *buf;
    struct PackFile_Segment *seg;
    size_t len;

    len = strlen(name) + strlen(sourcefile) + 2;
    buf = malloc(len);
    sprintf(buf, "%s_%s", name, sourcefile);
    seg = PackFile_Segment_new_seg(dir, t, buf, 1);
    free(buf);
    return seg;
}

static struct PackFile_ByteCode *
create_default_segs(Parrot_Interp interpreter)
{
    struct PackFile_Segment *seg;
    struct PackFile *pf = interpreter->code;
    struct PackFile_ByteCode *cur_cs;

    seg = create_seg(&pf->directory, PF_BYTEC_SEG, BYTE_CODE_SEGMENT_NAME);
    cur_cs = pf->cur_cs = (struct PackFile_ByteCode*)seg;

    seg = create_seg(&pf->directory, PF_FIXUP_SEG, FIXUP_TABLE_SEGMENT_NAME);
    cur_cs->fixups = (struct PackFile_FixupTable *)seg;
    cur_cs->fixups->code = cur_cs;

    seg = create_seg(&pf->directory, PF_CONST_SEG, CONSTANT_SEGMENT_NAME);
    cur_cs->consts = pf->const_table = (struct PackFile_ConstTable*) seg;
    cur_cs->consts->code = cur_cs;

    return cur_cs;
}

int e_pbc_open(void *param) {
    struct cs_t *cs;
    struct Parrot_Interp *interpreter = (struct Parrot_Interp *)param;

    /* make a new code segment
     */
    if (!globals.cs) {
        /* register cleanup code */
        Parrot_on_exit(imcc_globals_destroy, interpreter);
    }
    cs = mem_sys_allocate(sizeof(struct cs_t));
    cs->prev = globals.cs;
    cs->next = NULL;
    cs->subs = NULL;
    cs->first = NULL;
    cs->jit_info = NULL;
    if (!globals.first)
        globals.first = cs;
    else
        cs->prev->next = cs;
    /*
     * we need some segments
     */
    if (!interpreter->code->cur_cs) {
        cs->seg = create_default_segs(interpreter);
    }
    globals.cs = cs;
    return 0;
}

#ifdef HAS_JIT
/* get size/line of bytecode in ops till now */
static int
old_blocks(void)
{
    size_t size;
    struct subs *s;

    size = 0;
    for (s = globals.cs->subs; s; s = s->prev) {
        size += s->n_basic_blocks;
    }
    return size;
}

opcode_t *
make_jit_info(struct Parrot_Interp *interpreter)
{
    char *name;
    size_t size, old;

    if (!globals.cs->jit_info) {
        name = malloc(strlen(globals.cs->seg->base.name) + 5);
        sprintf(name, "%s_JIT", globals.cs->seg->base.name);
        globals.cs->jit_info =
            PackFile_Segment_new_seg(&interpreter->code->directory,
                    PF_UNKNOWN_SEG, name, 1);
        free(name);
    }
    size = IMCC_INFO(interpreter)->n_basic_blocks + (old = old_blocks());
    /* store current size */
    globals.cs->subs->n_basic_blocks = IMCC_INFO(interpreter)->n_basic_blocks;
    /* offset of block start and end, 4 * registers_used */
    globals.cs->jit_info->data = realloc(globals.cs->jit_info->data,
            size * sizeof(opcode_t) * 6);
    globals.cs->jit_info->size = size * 6;
    return globals.cs->jit_info->data + old * 6;
}
#endif

/* allocate a new globals.cs->subs structure */
static void
make_new_sub(struct Parrot_Interp *interpreter)
{
    struct subs *s = mem_sys_allocate_zeroed(sizeof(struct subs));
    if (!s)
        fatal(1, "get_old_size", "Out of mem");
    s->prev = globals.cs->subs;
    s->next = NULL;
    if (globals.cs->subs)
        globals.cs->subs->next = s;
    if (!globals.cs->first)
        globals.cs->first = s;
    globals.cs->subs = s;
#ifdef HAS_JIT
    if ((optimizer_level & OPT_J)) {
        allocate_jit(interpreter);
    }
#else
    UNUSED(interpreter);
#endif
}


/* get size/line of bytecode in ops till now */
static int
get_old_size(struct Parrot_Interp *interpreter, int *ins_line)
{
    size_t size;
    struct subs *s;

    size = *ins_line = 0;
    if (!globals.cs || interpreter->code->byte_code == NULL)
        return 0;
    for (s = globals.cs->subs; s; s = s->prev) {
        size += s->size;
        *ins_line += s->ins_line;
    }
    return size;
}


static void store_sub_size(size_t size, size_t ins_line)
{
    globals.cs->subs->size = size;
    globals.cs->subs->ins_line = ins_line;
}

static void store_label(SymReg * r, int pc)
{
    SymReg * label;
    label = _mk_address(globals.cs->subs->labels, str_dup(r->name),
            U_add_uniq_label);
    label->color = pc;
}

static void store_bsr(SymReg * r, int pc, int offset)
{
    SymReg * bsr;
    bsr = _mk_address(globals.cs->subs->bsrs, str_dup(r->name), U_add_all);
    bsr->color = pc;
    bsr->score = offset;        /* bsr = 1, set_addr I,x = 2, newsub = 3 */
}

static void
store_str_const(Parrot_Interp interpreter, char * str, int idx)
{
    SymReg * c;
    c  = _mk_const(globals.str_consts, str_dup(str), 0);
    debug(interpreter, DEBUG_PBC_CONST, "store_str #%d �%s�\n", idx, str);
    c->color = idx;
}

static void store_num_const(char * str, int idx)
{
    SymReg * c;
    c  = _mk_const(globals.num_consts, str_dup(str), 0);
    c->color = idx;
}

static void store_key_const(char * str, int idx)
{
    SymReg * c;
    c  = _mk_const(globals.key_consts, str_dup(str), 0);
    c->color = idx;
}

/* find a label in interpreters fixup table
 */
static int
find_label_cs(struct Parrot_Interp *interpreter, char *name)
{
    struct PackFile_FixupEntry *fe =
        PackFile_find_fixup_entry(interpreter, enum_fixup_label, name);
    return fe != NULL;
}
/* store global labels and bsr for later fixup
 * return size in ops
 */
static int
store_labels(struct Parrot_Interp *interpreter, int *src_lines, int oldsize)
{
    Instruction * ins;
    int code_size;
    opcode_t pc;

    /* run through instructions,
     * 1. pass
     * - sanity check
     * - calc code size
     * - calc nr of src lines for debug info
     */
    *src_lines = 0;
    for (code_size = 0, ins = instructions; ins ; ins = ins->next) {
        if (ins->op && *ins->op) {
            (*src_lines)++;
            if (ins->opnum < 0)
                fatal(1, "e_pbc_emit", "no opnum ins#%d %s\n",
                        ins->index, ins_string(ins));
            code_size += ins->opsize;
        }
        else if (ins->opsize)
            fatal(1, "fixup_jumps", "non instruction with size found\n");
    }

    /* 2. pass
     * remember subroutine calls (bsr, addr (closures)) and labels
     * for fixup
     * */
    for (pc = 0, ins = instructions; ins ; ins = ins->next) {
        if (ins->type & ITLABEL) {
            store_label(ins->r[0], pc);
            ins->r[0]->color = pc;
        }
        else if (ins->type & ITBRANCH) {
            if (!strcmp(ins->op, "bsr")) {
                if (!(ins->r[0]->type & VTREGISTER))
                    store_bsr(ins->r[0], pc, 1);
            }
            else if (!strcmp(ins->op, "set_addr"))
                store_bsr(ins->r[1], pc, 2);
            else if (!strcmp(ins->op, "newsub"))
                store_bsr(ins->r[2], pc, 3);
        }
        pc += ins->opsize;
    }

    /* 3. pass, look for intersegment jumps
     * if found, rewrite code:
     *
     *   if x, non_local1
     *
     *   if x, #ics_NN
     *   ...
     *   end/ret # after instructions apppend:
     *   #ics_NN:
     *     branch_cs fixup_entry_nr
     *
     * if a compile command was found, write global fixup records
     * for all local labels
     * and write fixup records for global _labels.
     */
    for (ins = instructions; ins ; ins = ins->next) {
        SymReg *addr, *label;
        if ((ins->type & ITLABEL) &&
                (has_compile || *ins->r[0]->name == '_')) {
            /* XXX labels should be mangled with current subroutine name
             * they should only be reachable from eval's in current sub
             */
            debug(interpreter, DEBUG_PBC_FIXUP, "write fixup '%s' offs %d\n",
                    ins->r[0]->name, ins->r[0]->color + oldsize);
            PackFile_FixupTable_new_entry(interpreter,
                    ins->r[0]->name, enum_fixup_label,
                    ins->r[0]->color + oldsize);
        }
        if (!ins->op || !*ins->op)
            continue;
        /* if no jump */
        if ((addr = get_branch_reg(ins)) == 0)
            continue;
        /* it's kind of a register */
        if (addr->type & VTREGISTER)
            continue;
        /* branch found */
        label = _get_sym(globals.cs->subs->labels, addr->name);
        /* maybe global */
        if (label)
            continue;
        if (strcmp(ins->op, "bsr") && strcmp(ins->op, "set_addr") &&
                strcmp(ins->op, "branch_cs") && strcmp(ins->op, "newsub")) {
            char buf[64];
            SymReg *r[IMCC_MAX_REGS];
            char *glabel;

            debug(interpreter, DEBUG_PBC_FIXUP, "inter_cs found for '%s'\n", addr->name);
            /* find symbol */
            if (!find_label_cs(interpreter, addr->name))
                debug(interpreter, DEBUG_PBC_FIXUP,
                        "store_labels", "inter_cs label '%s' not found\n",
                        addr->name);
            glabel = addr->name;
            /* append inter_cs jump */
            sprintf(buf, "#isc_%d", globals.inter_seg_n++);
            addr->name = str_dup(buf);
            INS_LABEL(addr, 1);
            /* this is the new location */
            store_label(addr, code_size);
            /* increase code_size by 2 ops */
            code_size += 2;
            /* add inter_segment jump */
            r[0] = mk_const(glabel, 'S');
            r[0]->color = add_const_str(interpreter, glabel, 1);
            INS(interpreter, "branch_cs", "", r, 1, 0, 1);
        }
    }
    /* return code size */
    return code_size;
}


/* get a globale label, return the pc (absolute) */
static SymReg * find_global_label(char *name, int *pc)
{
    SymReg * r;
    struct subs *s;
    *pc = 0;
    for (s = globals.cs->first; s; s = s->next) {
        if ( (r = _get_sym(s->labels, name)) ) {
            *pc += r->color;    /* here pc was stored */
            return r;
        }
        *pc += s->size;
    }
    return 0;
}

/* fix global branches */
void fixup_bsrs(struct Parrot_Interp *interpreter)
{
    int i, pc, addr;
    SymReg * bsr, *lab;
    struct subs *s;
    int jumppc = 0;

    for (s = globals.cs->first; s; s = s->next) {
        for(i = 0; i < HASH_SIZE; i++) {
            for(bsr = s->bsrs[i]; bsr; bsr = bsr->next ) {
                if (*bsr->name != '_')
                    continue;
                lab = find_global_label(bsr->name, &pc);
                if (!lab) {
                    /* TODO continue; */
                    /* do fixup at runtime */
                    fatal(1, "fixup_bsrs", "couldn't find addr of sub '%s'\n",
                            bsr->name);
                }
                addr = jumppc + bsr->color;
                /* patch the bsr __ instruction */
                debug(interpreter, DEBUG_PBC_FIXUP, "fixup %s pc %d fix %d\n",
                        bsr->name, addr, pc - addr);
                interpreter->code->byte_code[addr+bsr->score] = pc - addr;
            }
        }
        jumppc += s->size;
    }
}

static int unescape(char *string)
{
    char *start, *p;
    char hexdigits[] = "0123456789abcdef";

    for (start = p = string ; *string; string++) {
        if (*string == '\\' && string[1]) {
            switch (*++string) {
                case 'n':
                    *p++ = '\n';
                    break;
                case 'r':
                    *p++ = '\r';
                    break;
                case 't':
                    *p++ = '\t';
                    break;
                case 'a':
                    *p++ = '\a';
                    break;
                case 'f':
                    *p++ = '\f';
                    break;
                case 'e':
                    *p++ = '\033';
                    break;
                case '\\':
                    *p++ = '\\';
                    break;
                case 'x':       /* XXX encoding??? */
                    {
                        int c1 = tolower(*++string);
                        char *p1 = strchr(hexdigits, c1);
                        char *p2;
                        if (p1) {
                            int c2 = tolower(*++string);
                            p2 = strchr(hexdigits, c2);
                            if (p2)
                                *p++ = ((p1-hexdigits) << 4) | (p2-hexdigits);
                            else {
                                --string;
                                *p++ = (p1-hexdigits);
                            }
                        }
                        else {
                            /* XXX warning? */
                            *p++ = *--string;
                        }
                    }
                    break;
                default:
                    *p++ = *string;
                    break;
            }
        }
        else
            *p++ = *string;
    }
    *p = 0;
    return p - start;
}

/* add constant string to constants */
static int
add_const_str(struct Parrot_Interp *interpreter, char *str, int dup_sym) {
    int k, l;
    SymReg * r;
    char *o;
    char *buf = o = str_dup(str);

    if (*buf == '"') {
        buf++;
        l = unescape(buf);
        if (l)
        buf[--l] = '\0';
    }
    else if (*buf == '\'') {
        buf++;
        l = strlen(buf);
        if (l)
            buf[--l] = '\0';
    }
    else {
        l = unescape(buf);
    }

    if (!dup_sym) {
        if ( (r = _get_sym(globals.str_consts, buf)) != 0) {
            free(o);
            return r->color;
        }
    }
    k = PDB_extend_const_table(interpreter);
    interpreter->code->const_table->constants[k]->type =
        PFC_STRING;
    interpreter->code->const_table->constants[k]->u.string =
        string_make(interpreter, buf, (UINTVAL) l, NULL,
                PObj_constant_FLAG, NULL);
    store_str_const(interpreter, buf, k);
    free(o);
    return k;
}

static int
add_const_num(struct Parrot_Interp *interpreter, char *buf) {
    int k;
    SymReg * r;

    if ( (r = _get_sym(globals.num_consts, buf)) != 0)
        return r->color;
    k = PDB_extend_const_table(interpreter);

    interpreter->code->const_table->constants[k]->type =
        PFC_NUMBER;
    interpreter->code->const_table->constants[k]->u.number =
        (FLOATVAL)atof(buf);
    store_num_const(buf, k);
    return k;
}

static int
add_const_pmc_sub(struct Parrot_Interp *interpreter, SymReg *r,
        int offs, int len) {
    int k;
#if 1
    /* N/Y */
    char buf[256];
    opcode_t *rc;
    struct PackFile_Constant *pfc;

    debug(interpreter, DEBUG_PBC_CONST, "add_const_pmc_sub '%s'\n", r->name);
    /*
     * TODO use serialize api if that is done
     *      for now:
     * "Class name offs end"
     */
    sprintf(buf, "%s %s %d %d", "Sub", r->name, offs, len);
    pfc = malloc(sizeof(struct PackFile_Constant));

    interpreter->code->const_table->base.pf->header->wordsize =
        sizeof(opcode_t);
    rc = PackFile_Constant_unpack_pmc(interpreter,
            interpreter->code->const_table, pfc, (opcode_t*)buf);
    if (!rc)
        fatal(1, "add_const_pmc", "PackFile_Constant error\n");

    k = PDB_extend_const_table(interpreter);
    interpreter->code->const_table->constants[k]->type = PFC_PMC;
    interpreter->code->const_table->constants[k]->u.key = pfc->u.key;
    /*
     * create entry in our fixup (=symbol) table
     * the offset is the index in the constant table of this Sub
     */
    PackFile_FixupTable_new_entry(interpreter, r->name, enum_fixup_sub, k);
#endif
    return k;
}
/* add constant key to constants */

static int
add_const_key(struct Parrot_Interp *interpreter, opcode_t key[],
        int size, char *s_key) {
    int k;
    SymReg *r;
    struct PackFile_Constant *pfc;
    opcode_t *rc;

    if ( (r = _get_sym(globals.key_consts, s_key)) != 0)
        return r->color;
    pfc = malloc(sizeof(struct PackFile_Constant));
    rc = PackFile_Constant_unpack_key(interpreter,
            interpreter->code->const_table, pfc, key);
    if (!rc)
        fatal(1, "add_onst_key", "PackFile_Constant error\n");
    k = PDB_extend_const_table(interpreter);
    interpreter->code->const_table->constants[k]->type = PFC_KEY;
    interpreter->code->const_table->constants[k]->u.key = pfc->u.key;
    store_key_const(s_key, k);
    debug(interpreter, DEBUG_PBC_CONST, "\t=> %s #%d size %d\n", s_key, k, size);
    debug(interpreter, DEBUG_PBC_CONST, "\t %x /%x %x/ /%x %x/\n",
            key[0],key[1],key[2],key[3],key[4]);
    return k;
}

/*
 * color is a parrot register number
 *       or a constant table index
 *
 * for the rest, please consult PDD08_KEYS(1)
 *
 * additionaly I build a string representation of the key,
 * which get's cached in the globals.keys
 *
 */

static opcode_t
build_key(struct Parrot_Interp *interpreter, SymReg *reg)
{
#define KEYLEN 21
    opcode_t key[KEYLEN], *pc, size;
    char s_key[KEYLEN*10];
    int key_length;     /* P0["hi;there"; S0; 2] has length 3 */
    char *s;
    int k;
    SymReg * r;

    pc = key + 1;       /* 0 is length */
    s = s_key;          /* stringified key */
    *s = 0;
    if (reg->set == 'K')
        reg = reg->nextkey;

    for (key_length = 0; reg ; reg = reg->nextkey, key_length++) {
        if ((pc - key - 2) >= KEYLEN)
            fatal(1, "build_key", "key too complex increase KEYLEN\n");
        r = reg;
        /* if key is a register, the original sym is in r->reg */
        if (r->reg)
            r = r->reg;
        switch (r->type) {
            case VTIDENTIFIER:       /* P[S0] */
            case VTPASM:       /* P[S0] */
            case VTREG:        /* P[S0] */
                if (r->set == 'I')
                    *pc++ = PARROT_ARG_I;        /* register type */
                else if (r->set == 'S')
                    *pc++ = PARROT_ARG_S;
                else
                    fatal(1, "build_key", "wrong register set\n");
                /* don't emit mapped regs in key parts */
                if (r->color < 0)
                    *pc++ = -1 - r->color;
                else
                    *pc++ = r->color;
                sprintf(s+strlen(s), "%c%d", r->set, r->color);
                debug(interpreter, DEBUG_PBC_CONST, " keypart reg %s %c%d\n",
                        r->name, r->set, r->color);
                break;
            case VTCONST:
                switch (r->set) {
                    case 'S':                       /* P["key"] */
                        *pc++ = PARROT_ARG_SC;      /* str constant */
                        *pc++ = r->color;       /* constant idx */
                        debug(interpreter, DEBUG_PBC_CONST,
                                " keypart SC %s #%d\n", r->name, r->color);
                        break;
                    case 'I':                       /* P[;42;..] */
                        *pc++ = PARROT_ARG_IC;      /* int constant */
                        *pc++ = r->color = atoi(r->name);   /* value */
                        debug(interpreter, DEBUG_PBC_CONST, " keypart IC %s #%d\n", r->name, r->color);
                        break;
                    default:
                        fatal(1,"build_key", "unknown set\n");
                }
                sprintf(s+strlen(s), "%cc%d", r->set, r->color);
                break;
            default:
                fatal(1,"build_key", "unknown type 0x%x on %s\n",
                        r->type, r->name);
        }
    }
    key[0] = key_length;
    size = pc - key;
    /* now we have a packed key, which packfile can work on */
    /* XXX endianess? probably no, we pack/unpack on the very
     * same computer */
    k =  add_const_key(interpreter, key, size, s_key);
    return k;
}

static void add_1_const(struct Parrot_Interp *interpreter, SymReg *r)
{
    if (r->color >= 0)
        return;
    if (r->use_count <= 0)
        return;
    switch (r->set) {
        case 'I':
            if (r->name[0] == '0' && r->name[1] == 'x')
                r->color = strtoul(r->name+2, 0, 16);
            else if (r->name[0] == '0' && r->name[1] == 'b')
                r->color = strtoul(r->name+2, 0, 2);
            else
                r->color = atoi(r->name);
            break;
        case 'S':
            r->color = add_const_str(interpreter, r->name, 0);
            break;
        case 'N':
            r->color = add_const_num(interpreter, r->name);
            break;
        case 'K':
            for (r = r->nextkey; r; r = r->nextkey)
                if (r->type & VTCONST)
                    add_1_const(interpreter, r);
        default:
            break;
    }
    if (r /*&& r->set != 'I' */)
        debug(interpreter, DEBUG_PBC_CONST,"const %s\tcolor %d use_count %d\n",
                r->name, r->color, r->use_count);

}
/* store a constants idx for later reuse */
static void
constant_folding(struct Parrot_Interp *interpreter)
{
    SymReg * r;
    int i;

    /* go through all consts of current sub */
    for(i = 0; i < HASH_SIZE; i++) {
        /* normally constants are in ghash ... */
        for(r = ghash[i]; r; r = r->next) {
            if (r->type & VTCONST) {
                add_1_const(interpreter, r);
            }
        }
        /* ... but keychains 'K' are in hash, they may contain
         * variables and constants
         */
        for(r = hash[i]; r; r = r->next) {
            if (r->type & VTCONST) {
                add_1_const(interpreter, r);
            }
        }
    }
}

int
e_pbc_new_sub(void *param)
{
    struct Parrot_Interp *interpreter = (struct Parrot_Interp *)param;

    if (!instructions)
        return 0;
    make_new_sub(interpreter);     /* we start a new compilation unit */
    return 0;
}

/*
 * now let the fun begin, actually emit code for one ins
 */

int
e_pbc_emit(void *param, Instruction * ins)
{
    struct Parrot_Interp *interpreter = (struct Parrot_Interp *)param;
    int ok = 0;
    static opcode_t * pc, npc;
    op_info_t *op_info;
    int op, i;
    static struct PackFile_Debug *debug_seg;
    static int ins_line;

    /* first instruction, do initialisation ... */
    if (ins == instructions) {
        int code_size, ins_size;
        int oldsize;
        int bytes;

        oldsize = get_old_size(interpreter, &ins_line);
        code_size = store_labels(interpreter, &ins_size, oldsize);
        debug(interpreter, DEBUG_PBC, "code_size(ops) %d  oldsize %d\n", code_size, oldsize);
        constant_folding(interpreter);
        store_sub_size(code_size, ins_size);
        bytes = (oldsize + code_size) * sizeof(opcode_t);
        interpreter->code->byte_code =
            mem_sys_realloc(interpreter->code->byte_code, bytes);
        interpreter->code->cur_cs->base.size = oldsize + code_size;
        interpreter->code->cur_cs->base.data = interpreter->code->byte_code;
        pc = (opcode_t*) interpreter->code->byte_code + oldsize;
        npc = 0;
        /* add debug if necessary */
        if (Interp_flags_TEST(interpreter, PARROT_DEBUG_FLAG) ||
            PARROT_WARNINGS_test(interpreter, PARROT_WARNINGS_ALL_FLAG)) {
            /* FIXME length and multiple subs */
            debug_seg = Parrot_new_debug_seg(interpreter,
                    interpreter->code->cur_cs, sourcefile,
                    (size_t) ins_line+ins_size);
        }
        /* if item is a PCC_SUB entry then store it constants */
        if (ins->r[1] && ins->r[1]->pcc_sub) {
            add_const_pmc_sub(interpreter, ins->r[1], oldsize,
                    oldsize+code_size);
        }
    }
    if (ins->op && *ins->op) {
        /* fixup local jumps */
        SymReg *addr, *r;
        if ((addr = get_branch_reg(ins)) != 0 && !(addr->type & VTREGISTER)) {
            SymReg *label = _get_sym(globals.cs->subs->labels, addr->name);
            /* maybe global */
            if (label) {
                addr->color = label->color - npc;
                debug(interpreter, DEBUG_PBC_FIXUP, "branch label %d jump %d %s %d\n",
                        npc, label->color, addr->name,addr->color);
            }
            else if (strcmp(ins->op, "bsr") && strcmp(ins->op, "set_addr") &&
                    strcmp(ins->op, "newsub")) {
                /* TODO make intersegment branch */
                fatal(1, "e_pbc_emit", "label not found for '%s'\n",
                        addr->name);
            }
            if (ins->opsize == 5 && !strcmp(ins->op, "newsub")) {
                /* this only fixes local branches,
                 * TODO globals
                 */
                addr = ins->r[2];
                label = _get_sym(globals.cs->subs->labels, addr->name);
                /* maybe global */
                if (label) {
                    addr->color = label->color - npc;
                    debug(interpreter, DEBUG_PBC_FIXUP, "branch label %d jump %d %s %d\n",
                            npc, label->color, addr->name,addr->color);
                }
            }
        }
        /* add debug line info */
        if (debug_seg) {
            debug_seg->base.data[ins_line++] = (opcode_t) ins->line;
        }
        /* Start generating the bytecode */
        *pc++ = op = (opcode_t)ins->opnum;
        /* Get the info for that opcode */
        op_info = &interpreter->op_info_table[op];
        debug(interpreter, DEBUG_PBC, "%d %s", npc, op_info->full_name);
        for (i = 0; i < op_info->arg_count-1; i++) {
            switch (op_info->types[i+1]) {
                case PARROT_ARG_I:
                case PARROT_ARG_N:
                case PARROT_ARG_S:
                case PARROT_ARG_P:
                case PARROT_ARG_K:
                case PARROT_ARG_KI:
                case PARROT_ARG_KIC:
                case PARROT_ARG_IC:
                case PARROT_ARG_SC:
                case PARROT_ARG_NC:
                    r = ins->r[i];
                    if (r->type & (VT_REGP | VT_CONSTP))
                        r = r->reg;
                    *pc++ = (opcode_t) r->color;
                    debug(interpreter, DEBUG_PBC," %d", r->color);
                    break;
                case PARROT_ARG_KC:
                    *pc++ = build_key(interpreter, ins->r[i]);
                    debug(interpreter, DEBUG_PBC," %d", pc[-1]);
                    break;
                default:
                    fatal(1, "e-pbc_emit", "unknwon argtype\n");
                    break;
            }
        }
        debug(interpreter, DEBUG_PBC, "\t%s\n", ins_string(ins));
        npc += ins->opsize;
    }
    return ok;
}

int e_pbc_close(void *param){
    struct Parrot_Interp *interpreter = (struct Parrot_Interp *)param;

    fixup_bsrs(interpreter);
    clear_tables(interpreter, ghash);
    return 0;
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

