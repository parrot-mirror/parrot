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
    SymReg * labels[HASH_SIZE];         /* label names */
    SymReg * bsrs[HASH_SIZE];           /* bsr, set_addr locations */
    struct subs *prev;
    struct subs *next;
};

/* subs are kept per code segment */
struct cs_t {
    struct PackFile_ByteCode *seg;      /* bytecode seg */
    struct subs *subs;                  /* current sub data */
    struct subs *first;                 /* first sub of code seg */
    struct cs_t *prev;                  /* prev cs */
};

static struct globals {
    SymReg * str_consts[HASH_SIZE];
    SymReg * num_consts[HASH_SIZE];
    SymReg * key_consts[HASH_SIZE];
    struct cs_t *cs;
} globals;


void imcc_globals_destroy(int ex, void *param);
void imcc_globals_destroy(int ex, void *param)
{
    struct cs_t *cs, *prev_cs;
    struct subs *s, *prev_s;

    UNUSED(ex);
    UNUSED(param);
    cs = globals.cs;
    while (cs) {
        s = cs->subs;
        while (s) {
            prev_s = s->prev;
            hash = s->labels;
            clear_tables();
            hash = s->bsrs;
            clear_tables();
            mem_sys_free(s);
            s = prev_s;
        }
        prev_cs = cs->prev;
        mem_sys_free(cs);
        cs = prev_cs;
    }
    hash = globals.str_consts;
    clear_tables();
    hash = globals.num_consts;
    clear_tables();
    hash = globals.key_consts;
    clear_tables();
    globals.cs = NULL;
}

int e_pbc_open(char *dummy) {
    struct cs_t *cs;
    /* make a new code segment
     */
    UNUSED(dummy);
    if (!globals.cs) {
        /* register cleanup code */
        Parrot_on_exit(imcc_globals_destroy, NULL);
    }
    cs = mem_sys_allocate(sizeof(struct cs_t));
    cs->prev = globals.cs;
    cs->subs = NULL;
    cs->first = NULL;
    cs->seg = interpreter->code->cur_cs;
    globals.cs = cs;
    return 0;
}

/* allocate a new globals.cs->subs structure */
static void make_new_sub(void)
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
}


/* get size/line of bytecode in ops till now */
static int get_old_size(int *ins_line)
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


static void store_sub_size(size_t size)
{
    globals.cs->subs->size = size;
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
    bsr->score = offset;        /* bsr = 1, addr I,x = 2 */
}

static void store_str_const(char * str, int idx)
{
    SymReg * c;
    c  = _mk_const(globals.str_consts, str_dup(str), 0);
    debug(2, "store_str #%d �%s�\n", idx, str);
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


/* store global labels and bsr for later fixup
 * return size in ops
 */
static int store_labels(void)
{
    Instruction * ins;
    int code_size;
    opcode_t pc;

    /* run through instructions,
     * 1. pass
     * - sanity check
     * - calc code size
     */
    make_new_sub();
    for (code_size = 0, ins = instructions; ins ; ins = ins->next) {
        if (ins->op && *ins->op) {
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
     * for fixup */
    for (pc = 0, ins = instructions; ins ; ins = ins->next) {
        if (ins->type & ITLABEL) {
            store_label(ins->r[0], pc);
            ins->r[0]->color = pc;
        }
        else if (!strcmp(ins->op, "bsr"))
            store_bsr(ins->r[0], pc, 1);
        else if (!strcmp(ins->op, "set_addr"))
            store_bsr(ins->r[1], pc, 2);
        pc += ins->opsize;
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
void fixup_bsrs()
{
    int i, pc, addr;
    SymReg * bsr, *lab;
    struct subs *s;
    int jumppc = 0;

    for (s = globals.cs->first; s; s = s->next) {
        for(i = 0; i < HASH_SIZE; i++) {
            for(bsr = s->bsrs[i]; bsr; bsr = bsr->next ) {
                lab = find_global_label(bsr->name, &pc);
                if (!lab)
                    fatal(1, "fixup_bsrs", "couldn't find addr of sub '%s'\n",
                            bsr->name);
                addr = jumppc + bsr->color;
                /* patch the bsr __ instruction */
                debug(1, "fixup %s pc %d fix %d\n",
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
add_const_str(char *str) {
    int k, l;
    SymReg * r;
    char *o;
    char *buf = o = str_dup(str);

    if (*buf == '"') {
        buf++;
        l = unescape(buf);
        buf[--l] = '\0';
    }
    else if (*buf == '\'') {
        buf++;
        l = strlen(buf);
        buf[--l] = '\0';
    }
    else {
        l = unescape(buf);
    }

    if ( (r = _get_sym(globals.str_consts, buf)) != 0) {
        free(o);
        return r->color;
    }
    k = PDB_extend_const_table(interpreter);
    interpreter->code->const_table->constants[k]->type =
        PFC_STRING;
    interpreter->code->const_table->constants[k]->u.string =
        string_make(interpreter, buf, (UINTVAL) l, NULL,
                PObj_constant_FLAG, NULL);
    store_str_const(buf, k);
    free(o);
    return k;
}

static int
add_const_num(char *buf) {
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

/* add constant key to constants */
static int
add_const_key(opcode_t key[], int size, char *s_key) {
    int k;
    SymReg *r;
    struct PackFile_Constant *pfc;
    int rc;

    if ( (r = _get_sym(globals.key_consts, s_key)) != 0)
        return r->color;
    pfc = malloc(sizeof(struct PackFile_Constant));
    rc = PackFile_Constant_unpack_key(interpreter,
            interpreter->code, pfc, key, size);
    if (!rc)
        fatal(1, "add_onst_key", "PackFile_Constant error\n");
    k = PDB_extend_const_table(interpreter);
    interpreter->code->const_table->constants[k]->type = PFC_KEY;
    interpreter->code->const_table->constants[k]->u.key = pfc->u.key;
    store_key_const(s_key, k);
    debug(1, "\t=> %s #%d size %d\n", s_key, k, size);
    debug(1, "\t %x /%x %x/ /%x %x/\n", key[0],key[1],key[2],key[3],key[4]);
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
build_key(SymReg *reg)
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
            case VTPASM:       /* P[S0] */
            case VTREG:        /* P[S0] */
                if (r->set == 'I')
                    *pc++ = PARROT_ARG_I;        /* register type */
                else if (r->set == 'S')
                    *pc++ = PARROT_ARG_S;
                else
                    fatal(1, "build_key", "wrong register set\n");
                *pc++ = r->color;
                sprintf(s+strlen(s), "%c%d", r->set, r->color);
                debug(1, " keypart reg %s %c%d\n",
                        r->name, r->set, r->color);
                break;
            case VTCONST:
                switch (r->set) {
                    case 'S':                       /* P["key"] */
                        *pc++ = PARROT_ARG_SC;      /* str constant */
                        *pc++ = r->color;       /* constant idx */
                        debug(1, " keypart SC %s #%d\n", r->name, r->color);
                        break;
                    case 'I':                       /* P[;42;..] */
                        *pc++ = PARROT_ARG_IC;      /* int constant */
                        *pc++ = r->color = atoi(r->name);   /* value */
                        debug(1, " keypart IC %s #%d\n", r->name, r->color);
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
    k =  add_const_key(key, size, s_key);
    return k;
}

static void add_1_const(SymReg *r)
{
    if (r->color >= 0)
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
            r->color = add_const_str(r->name);
            break;
        case 'N':
            r->color = add_const_num(r->name);
            break;
        case 'K':
            for (r = r->nextkey; r; r = r->nextkey)
                if (r->type & VTCONST)
                    add_1_const(r);
        default:
            break;
    }
    if (r /*&& r->set != 'I' */)
        debug(1,"const %s\tcolor %d\n", r->name, r->color);

}
/* store a constants idx for later reuse */
static void constant_folding(void)
{
    SymReg * r;
    int i;

    /* go through all consts of current sub */
    for(i = 0; i < HASH_SIZE; i++)
        for(r = ghash[i]; r; r = r->next) {
            if (r->type & VTCONST) {
                add_1_const(r);
            }

        }
}


/*
 * now let the fun begin, actually emit code for one ins
 */

int e_pbc_emit(Instruction * ins) {
    int ok = 0;
    static opcode_t * pc, npc;
    op_info_t *op_info;
    int op, i;
    static struct PackFile_Debug *debug_seg;
    static int ins_line;

    /* first instruction, do initialisation ... */
    if (ins == instructions) {
        int code_size = store_labels();
        int oldsize = get_old_size(&ins_line);
        int bytes;

        debug(1, "code_size(ops) %d  oldsize %d\n", code_size, oldsize);
        constant_folding();
        store_sub_size(code_size);
        bytes = (oldsize + code_size) * sizeof(opcode_t);
        interpreter->code->byte_code =
            mem_sys_realloc(interpreter->code->byte_code, bytes);
        interpreter->code->byte_code_size = bytes;
        interpreter->code->cur_cs->code = interpreter->code->byte_code;
        interpreter->code->cur_cs->base.byte_count = bytes;
        pc = (opcode_t*) interpreter->code->byte_code + oldsize;
        npc = 0;
        /* add debug if necessary */
        if (Interp_flags_TEST(interpreter, PARROT_DEBUG_FLAG)) {
            debug_seg = Parrot_new_debug_seg(interpreter,
                    interpreter->code->cur_cs, sourcefile);
        }
    }
    if (ins->op && *ins->op) {
        /* fixup local jumps */
        SymReg *addr, *r;
        if ((addr = get_branch_reg(ins)) != 0) {
            SymReg *label = _get_sym(globals.cs->subs->labels, addr->name);
            /* maybe global */
            if (label) {
                addr->color = label->color - npc;
                debug(1, "branch label %d jump %d %s %d\n",
                        npc, label->color, addr->name,addr->color);
            }
        }
        /* add debug line info */
        if (Interp_flags_TEST(interpreter, PARROT_DEBUG_FLAG)) {
            debug_seg->lines[ins_line++] = (opcode_t) ins->line;
        }
        /* Start generating the bytecode */
        *pc++ = op = (opcode_t)ins->opnum;
        /* Get the info for that opcode */
        op_info = &interpreter->op_info_table[op];
        debug(1, "%d %s", npc, op_info->full_name);
        for (i = 0; i < op_info->arg_count-1; i++) {
            switch (op_info->types[i+1]) {
                case PARROT_ARG_I:
                case PARROT_ARG_N:
                case PARROT_ARG_S:
                case PARROT_ARG_P:
                case PARROT_ARG_KI:
                case PARROT_ARG_KIC:
                case PARROT_ARG_IC:
                case PARROT_ARG_SC:
                case PARROT_ARG_NC:
                    r = ins->r[i];
                    if (r->type & (VT_REGP | VT_CONSTP))
                        r = r->reg;
                    *pc++ = (opcode_t) r->color;
                    debug(1," %d", r->color);
                    break;
                case PARROT_ARG_KC:
                    *pc++ = build_key(ins->r[i]);
                    debug(1," %d", pc[-1]);
                    break;
                default:
                    fatal(1, "e-pbc_emit", "unknwon argtype\n");
                    break;
            }
        }
        debug(1, "\t%s\n", ins_string(ins));
        npc += ins->opsize;
    }
    return ok;
}

int e_pbc_close(){

    fixup_bsrs();
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

