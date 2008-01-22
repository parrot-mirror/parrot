/*
Copyright (C) 2001-2003, The Perl Foundation.
$Id$

=head1 NAME

pdump - Dump or convert Parrot bytecode (PBC) files

=head1 SYNOPSIS

 pdump [-tdh] [--terse|--disassemble|--header-only] file.pbc

 pdump -o converted.pbc file.pbc

=head1 DESCRIPTION

A program to dump pack files to human readable form.

=head2 Command-Line Options

=over 4

=item C<-d>

Disassemble bytecode segments.

=item C<-h>

Dump the bytecode header only.

=item C<-t>

Terse output.

=item C<-o converted.pbc>

Repacks a PBC file into the platform's native binary format for better
efficiency on reading non-native PBCs.

=back

=head2 Functions

=over 4

=cut

*/

#include "parrot/parrot.h"
#include "parrot/embed.h"
#include "parrot/oplib/ops.h"

/*

=item C<static void
const_dump(PARROT_INTERP, PackFile_Segment *segp)>

Dump the constant table.

=cut

*/

static void
const_dump(PARROT_INTERP, PackFile_Segment *segp)
{
    PIO_printf(interp, "%s => [\n", segp->name);
    PackFile_ConstTable_dump(interp, (PackFile_ConstTable *)segp);
    PIO_printf(interp, "],\n");
}

/*

=item C<static void
fixup_dump(PARROT_INTERP, PackFile_Segment *segp)>

Dump the fixup table.

=cut

*/

static void
fixup_dump(PARROT_INTERP, PackFile_Segment *segp)
{
    PIO_printf(interp, "%s => [\n", segp->name);
    PackFile_Fixup_dump(interp, (PackFile_FixupTable *)segp);
    PIO_printf(interp, "],\n");
}

/*

=item C<static void
disas_dump(PARROT_INTERP, PackFile_Segment *self)>

Disassemble and dump.

=cut

*/

static void
disas_dump(PARROT_INTERP, PackFile_Segment *self)
{
    opcode_t *pc;
    size_t i, n;
    PIO_printf(interp, "%s => [ # %d ops at offs 0x%x\n",
            self->name, (int)self->size, (int)self->file_offset + 4);
    pc = self->data;
    while (pc < self->data + self->size) {
        /* trace_op_dump(interp, self->pf->src, pc); */
        PIO_printf(interp, " %04x:  ", (int) (pc - self->data));
        n = (size_t)interp->op_info_table[*pc].op_count;
        for (i = 0; i < 6; i++)
            if (i < n)
                PIO_printf(interp, "%08lx ", (unsigned long) pc[i]);
            else
                PIO_printf(interp, "         ");
        PIO_printf(interp, "%s\n",
                interp->op_info_table[*pc].full_name);
        ADD_OP_VAR_PART(interp, interp->code, pc, n);
        pc += n;
    }
    PIO_printf(interp, "]\n");
}

/*

=item C<static void
PackFile_header_dump(PARROT_INTERP, PackFile *pf)>

Dump the header.

=cut

*/

static void
PackFile_header_dump(PARROT_INTERP, PackFile *pf)
{
    PIO_printf(interp, "HEADER => [\n");
    PIO_printf(interp, "\twordsize  = %d", pf->header->wordsize);
    PIO_printf(interp, "\t(interpreter's wordsize    = %d)\n",
            sizeof (opcode_t));
    PIO_printf(interp, "\t(interpreter's INTVAL size = %d)\n",
            sizeof (INTVAL));
    PIO_printf(interp, "\tbyteorder = %d", pf->header->byteorder);
    PIO_printf(interp, "\t(interpreter's byteorder   = %d)\n",
            PARROT_BIGENDIAN);
    PIO_printf(interp, "\tfloattype = %d", pf->header->floattype);
    PIO_printf(interp, "\t(interpreter's NUMVAL_SIZE = %d)\n", NUMVAL_SIZE);
    PIO_printf(interp, "\t%s endianize, %s opcode, %s numval transform\n",
            pf->need_endianize ? "**need**" : "no",
            pf->need_wordsize ? "**need**" : "no",
            pf->fetch_nv ? "**need**" : "no");
    PIO_printf(interp, "\tdirformat = %d\n", pf->header->dir_format);
    PIO_printf(interp, "]\n");
}

/*

=item C<static void help(void)>

Print out the user help info.

=cut

*/

static void help(void)
{
    printf("pdump - dump or convert parrot bytecode (PBC) files\n");
    printf("usage:\n");
    printf("pdump [-tdh] [--terse|--disassemble|--header-only] file.pbc\n");
    printf("pdump -o converted.pbc file.pbc\n\n");
    printf("\t-d ... disassemble bytecode segments\n");
    printf("\t-h ... dump header only\n");
    printf("\t-t ... terse output\n");
    printf("\n\t-o converted.pbc repacks a PBC file into "
           "the platform's native\n");
    printf("\t   binary format for better efficiency on reading "
           "non native PBCs\n");
    exit(EXIT_SUCCESS);
}

static struct longopt_opt_decl options[] = {
    { 'h', 'h', 0,       { "--header-only" } },
    { '?', '?', 0, { "--help" } },
    { 't', 't', 0, { "--terse" } },
    { 'd', 'd', 0, { "--disassemble" } },
    { 'o', 'o', OPTION_required_FLAG, { "--output" } }
};

/*

=item C<int
main(int argc, char **argv)>

The run loop. Process the command-line arguments and dump accordingly.

=cut

*/

int
main(int argc, char **argv)
{
    PackFile *pf;
    Interp *interp;
    int terse = 0;
    int disas = 0;
    int convert = 0;
    int header = 0;
    const char *file = NULL;
    struct longopt_opt_info opt = LONGOPT_OPT_INFO_INIT;
    int status;

    if (argc < 2) {
        help();
    }
    interp = Parrot_new(NULL);
    /* init and set top of stack */
    Parrot_init_stacktop(interp, &status);
    while ((status = longopt_get(interp,
                    argc, argv, options, &opt)) > 0) {
        switch (opt.opt_id) {
            case 'h':
                header = 1;
                break;
            case 't':
                terse = 1;
                break;
            case 'd':
                disas = 1;
                break;
            case 'o':
                file = opt.opt_arg;
                convert = 1;
                break;
            case '?':
                help();
                break;
        }
    }
    if (status == -1) {
        help();
    }
    argc -= opt.opt_index;
    argv += opt.opt_index;


    pf = Parrot_readbc(interp, *argv);

    if (!pf) {
        printf("Can't read PBC\n");
        return 1;
    }
    Parrot_loadbc(interp, pf);
    if (convert) {
        size_t size;
        opcode_t *pack;
        FILE *fp;

        size = PackFile_pack_size(interp,
                interp->code->base.pf) * sizeof (opcode_t);
        pack = (opcode_t*) mem_sys_allocate(size);
        if (!pack) {
            printf("out of mem\n");
            exit(EXIT_FAILURE);
        }
        PackFile_pack(interp, interp->code->base.pf, pack);
        if (STREQ(file, "-"))
            fp = stdout;
        else if ((fp = fopen(file, "wb")) == 0) {
            printf("Couldn't open %s\n", file);
            exit(EXIT_FAILURE);
        }

        if ((1 != fwrite(pack, size, 1, fp))) {
            printf("Couldn't write %s\n", file);
            exit(EXIT_FAILURE);
        }
        fclose(fp);
        mem_sys_free(pack);
        Parrot_exit(interp, 0);
    }

    PackFile_header_dump(interp, pf);
    if (header) {
        Parrot_exit(interp, 0);
    }
    /* install a dumper function */
    if (!terse) {
        pf->PackFuncs[PF_CONST_SEG].dump = const_dump;
        pf->PackFuncs[PF_FIXUP_SEG].dump = fixup_dump;
    }
    if (disas)
        pf->PackFuncs[PF_BYTEC_SEG].dump = disas_dump;
    /* do a directory dump, which dumps segs then */
    PackFile_Segment_dump(interp, &pf->directory.base);

    Parrot_exit(interp, 0);
}

/*

=back

=head1 SEE ALSO

F<src/packdump.c>.

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
