# Copyright (C) 2007-2008, The Perl Foundation.
# $Id$
package Parrot::Configure::Options::Conf::CLI;

use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw(
    @valid_options
    $script
    %options_components
    $parrot_version
    $svnid
);
use lib qw( lib );
use Parrot::Configure::Options::Conf qw(
    $script
    $parrot_version
    $svnid
    print_help
    print_version
);

our @valid_options = qw{
    ask
    bindir
    cage
    cc
    ccflags
    ccwarn
    cgoto
    configure_trace
    cxx
    datadir
    debugging
    define
    exec-prefix
    execcapable
    fatal
    fatal-step
    floatval
    gc
    help
    icu-config
    icuheaders
    icushared
    includedir
    infodir
    inline
    intval
    jitcapable
    languages
    ld
    ldflags
    lex
    libdir
    libexecdir
    libs
    link
    linkflags
    localstatedir
    m
    make
    maintainer
    mandir
    miniparrot
    nomanicheck
    oldincludedir
    opcode
    ops
    optimize
    parrot_is_shared
    pmc
    prefix
    profile
    sbindir
    sharedstatedir
    silent
    sysconfdir
    test
    verbose
    verbose-step
    version
    without-gdbm
    without-opengl
    without-pcre
    without-crypto
    without-gettext
    without-gmp
    without-icu
    yacc
};

my %short_circuits = (
    help    => \&print_help,
    version => \&print_version,
);

our %options_components = (
    'valid_options'  => \@valid_options,
    'script'         => $script,
    'short_circuits' => \%short_circuits,
    'conditionals'   => \&conditional_assignments,
);

sub conditional_assignments {
    my $argsref = shift;
    $argsref->{debugging} = 1
        unless ( ( exists $argsref->{debugging} ) && !$argsref->{debugging} );
    $argsref->{maintainer} = 1
        if defined $argsref->{lex}
            or defined $argsref->{yacc};
    return $argsref;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
