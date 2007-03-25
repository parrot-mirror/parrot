# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$
package Parrot::Configure::Step::List;
use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw( get_steps_list );

# EDIT HERE TO ADD NEW TESTS
my @steps = qw(
    init::manifest
    init::defaults
    init::install
    init::miniparrot
    init::hints
    init::headers
    inter::progs
    inter::make
    inter::lex
    inter::yacc
    auto::gcc
    auto::msvc
    init::optimize
    inter::shlibs
    inter::libparrot
    inter::charset
    inter::encoding
    inter::types
    inter::ops
    inter::pmc
    auto::alignptrs
    auto::headers
    auto::sizes
    auto::byteorder
    auto::va_ptr
    auto::pack
    auto::format
    auto::isreg
    auto::jit
    gen::cpu
    auto::funcptr
    auto::cgoto
    auto::inline
    auto::gc
    auto::memalign
    auto::signal
    auto::socklen_t
    auto::env
    auto::aio
    auto::gmp
    auto::readline
    auto::gdbm
    auto::snprintf
    auto::perldoc
    auto::python
    auto::bc
    auto::m4
    auto::cpu
    gen::icu
    gen::revision
    gen::config_h
    gen::core_pmcs
    gen::parrot_include
    gen::languages
    gen::makefiles
    gen::platform
    gen::config_pm
);

sub get_steps_list {return @steps;}

1;

#################### DOCUMENTATION ####################

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

=head1 SEE ALSO

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
