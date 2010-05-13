#! perl
# Copyright (C) 2001-2008, Parrot Foundation.
# $Id$

warn 'ops2c.pl is deprecated. Use ops2c$(EXE) instead';
# Ignore "core"
shift @ARGV;
exec 'ops2c', @ARGV;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

