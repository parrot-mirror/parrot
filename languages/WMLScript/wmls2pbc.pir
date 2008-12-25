# Copyright (C) 2006-2008, The Perl Foundation.
# $Id$

=head1 NAME

wmls2pbc - WMLScript bytecode to Parrot PBC Translator

=head1 SYNOPSYS

 parrot wmls2pbc.pir file.wmlsc

=head1 DESCRIPTION

B<wmls2pbc> translates a WMLScript bytecode file to Parrot PBC.

=head1 SEE ALSO

wmlsd, wmls2pir, wmlsi

=cut

.HLL 'wmlscript'
.loadlib 'wmls_group'
.loadlib 'wmls_ops'

.sub 'main' :main
    .param pmc argv
    load_bytecode 'languages/WMLScript/src/WMLScript.pbc'
    .local int argc
    .local string progname
    .local string filename
    .local string content
    argc = elements argv
    if argc != 2 goto USAGE
    progname = shift argv
    filename = shift argv
    content = load_script(filename)
    unless content goto L1
    .local pmc loader
    .local pmc script
    new loader, 'WmlsBytecode'
    push_eh _handler
    script = loader.'load'(content)
    script['filename'] = filename
    .local string gen_pir
    gen_pir = script.'translate'()
    .local pmc pir_comp
    .local pmc pbc_out
    pir_comp = compreg 'PIR'
    pbc_out = pir_comp(gen_pir)
    save_pbc(pbc_out, filename)
    pop_eh
  L1:
    end
  USAGE:
    printerr "Usage: parrot wmls2pir.pbc filename\n"
    exit -1
  _handler:
    .local pmc e
    .local string msg
    .get_results (e)
    msg = e
    say msg
    end
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
