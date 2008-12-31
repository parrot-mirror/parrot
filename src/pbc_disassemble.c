/*
Copyright (C) 2001-2003, The Perl Foundation.
$Id$

=head1 NAME

pbc_disassemble - Parrot disassembler

=head1 SYNOPSIS

    pbc_disassemble file.pbc

=head1 DESCRIPTION

This uses the C<Parrot_disassemble()> function from F<src/embed.c>,
which in turn uses the C<PDB_disassemble()> function from
F<src/debug.c>.

=head2 Functions

=over 4

=cut

*/

#include <parrot/parrot.h>
#include "parrot/embed.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

static void do_dis(Parrot_Interp);

/*

=item C<int main(int argc, char *argv[])>

The run-loop. Starts up an interpreter, loads the bytecode from the
command-line and disassembles it.

=cut

*/

int
main(int argc, char *argv[])
{
    Parrot_Interp interp;
    char *filename;
    Parrot_PackFile pf;

    interp = Parrot_new(NULL);

    if (!interp) {
        return 1;
    }

    /* set the top of the stack so GC can trace it for GC-able pointers
     * see trace_system_areas() in src/cpu_dep.c */
    interp->lo_var_ptr = &interp;

    if (argc != 2) {
        fprintf(stderr, "Usage: pbc_disassemble programfile \n");
        Parrot_exit(interp, 1);
    }

    filename = argv[1];

    pf = Parrot_readbc(interp, filename);

    if (!pf) {
        return 1;
    }

    Parrot_loadbc(interp, pf);

    do_dis(interp);

    Parrot_exit(interp, 0);
}

/*

=item C<static void do_dis(Parrot_Interp interp)>

Do the disassembling.

=cut

*/

static void
do_dis(Parrot_Interp interp)
{
    Parrot_disassemble(interp);
}

/*

=back

=head1 SEE ALSO

F<src/embed.c> and F<src/debug.c>.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
