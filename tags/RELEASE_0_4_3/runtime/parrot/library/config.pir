=head1 TITLE

config.pir - Access Parrot configuration data

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  .sub _some
  ...
  # store the config data into $P0
  $P0 = _config()
  # Retrieve and print a key
  $P1 = $P0["cc"]
  print "Your C compiler is "
  print $P1
  print "\n"
  ...

 .end
 .include "library/config.pir"

=head1 DESCRIPTION

config.pir is a mechanism for accessing most of the data collected by
Configure.  It's roughly equivalent to Perl's C<Config.pm> module.

At the end of a successful C<make> of Parrot, a PASM file generated by
Configure is run to put a file, F<config.fpmc>, into the library with a
frozen Hash of the configuration data.  This library provides a
function, C<_config>, to unpack and return that file's data.

C<_config> does not take any parameters.  It returns a single Hash
containing the data.  Keys that were C<undef> in Configure contain a
C<None> PMC; otherwise they contain a C<PerlString>.

Note that the behavior of that hash when writing to any value (especially
undefined values) is undefined, and may be rather funky.

=cut

.pcc_sub _config
    .local pmc CONF
    # XXX: this works only if parrot is run from its root directory
    .const string conf_file = "runtime/parrot/include/config.fpmc"

    open CONF, conf_file, "<"
    $I0 = defined CONF
    if $I0 goto ok1
    printerr "Can't read '"
    printerr conf_file
    printerr "': "
    err $S0
    printerr $S0
    printerr "\n"
    exit 1

ok1:
    .local string image
    # If it gets above 64k, we've got bigger problems.
    read image, CONF, 60000
    close CONF
    .local pmc conf_hash
    thaw conf_hash, image
    # XXX hash should probably be marked read-only...
    .pcc_begin_return
    .return conf_hash
    .pcc_end_return
.end

=head1 AUTHOR

Brent Royal-Gordon E<lt>brent@brentdax.comE<gt> is the author and maintainer.
Please send patches and suggestions to the Perl 6 Internals mailing list.

=head1 COPYRIGHT

Copyright (c) 2004, the Perl Foundation.

=cut
