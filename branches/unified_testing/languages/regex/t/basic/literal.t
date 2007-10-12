# $Id$

use strict;
use FindBin;
use lib qw{ lib ../../lib };

use Parrot::Test::Regex;
use Regex;
use Regex::Driver;

use Test::More;

Parrot::Test::Regex::run_spec( \*DATA );


__END__
abc
INPUT:
ababc
OUTPUT:
Match found
0: 2..4
