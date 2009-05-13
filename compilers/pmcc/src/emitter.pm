# Copyright (C) 2009, Parrot Foundation.
# $Id$

# Main PMC Emitter.

class PMC::Emitter;

# Generate the .h file's contents for this pmc.
method generate_header($past) {
    my $res;

    my $name     := $past.name();
    my $filename := self.filename();

    # Get emitter for (specific) PMC.
    my $pmc_emitter := get_pmc_emitter($name, $past);

    $res :=
            # Generate header.
              dont_edit($filename)
            # PMC functions
            ~ $pmc_emitter.generate_header()
            # C code
            ~ c_code_coda();

    $res;
}

# Generate the .c file's contents for this pmc.
method generate_c_code($past) {
    my $res;

    my $name     := $past.name();
    my $filename := self.filename();

    # Get emitter for (specific) PMC.
    my $pmc_emitter := get_pmc_emitter($name, $past);

    $res :=
            # Generate header.
              dont_edit($filename)
            # PMC functions
            ~ $pmc_emitter.generate_c_code()
            # C code
            ~ c_code_coda();

    $res;
}

# Generate the contents of a .dump file for this pmc.
method generate_dump($past) {
    my $res;

    my $name     := $past.name();
    my $filename := self.filename();

    # Get emitter for (specific) PMC.
    my $pmc_emitter := get_pmc_emitter($name, $past);

    $pmc_emitter.generate_dump();
}

method filename() {
    our $?filename;
    $?filename;
}

method set_filename($name) {
    our $?filename := $name;
}


# Get (specific) PMC emitter
# Try to create specific emitter. In case of failure create generic one.
sub get_pmc_emitter($name, $past) {
PIR q<
    find_lex $P0, '$name'
    find_lex $P1, '$past'
    $S0 = $P0

    .local pmc ctor
    ctor = get_hll_global ['PMC';'Emitter';'PMC'], $S0
    push_eh not_found
    %r = ctor.'new'($P1)
    goto done

  not_found:
    pop_eh
    ctor = get_hll_global ['PMC';'Emitter'], 'PMC'
    %r = ctor.'new'($P1)
  done:
>;
}

# Generate don't edit warning
sub dont_edit($filename) {
     "/* ex: set ro ft=c:\n"
    ~" * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!\n"
    ~" *\n"
    ~" * This file is generated automatically from '" ~$filename ~"'\n"
    ~" * by Divine Intervention.\n"
    ~" *\n"
    ~" * Any changes made here will be lost!\n"
    ~" *\n"
    ~" */\n\n";
}

#=item C<c_code_coda()>
#
#Returns the Parrot C code coda
#
#=back
#
#=cut
sub c_code_coda() {
     "\n\n"
    ~"/*\n"
    ~" * Local variables:\n"
    ~" *   c-file-style: parrot\n"
    ~" * End:\n"
    ~" * vim: expandtab shiftwidth=4:\n"
    ~" */\n"
}

# Local Variables:
#   mode: perl6
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
