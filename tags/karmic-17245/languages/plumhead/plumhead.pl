#! perl

# $Id$

# A workaround for run-tests.php

use strict;
use warnings;

exec './parrot', 'languages/plumhead/plumhead.pbc', @ARGV;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
