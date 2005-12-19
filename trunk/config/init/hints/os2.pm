# Copyright: 2005 The Perl Foundation.  All Rights Reserved.
# $Id$

package init::hints::os2;

use strict;

# This hints file is very specific to a particular os/2 configuration.
# A more general one would be appreciated, should anyone actually be
# using OS/2
Parrot::Configure::Data->set(
  libs => "-lm -lsocket -lcExt -lbsd",
  iv => "long",
  nv => "double",
  opcode_t =>"long",
  ccflags => "-I. -fno-strict-aliasing -mieee-fp -I./include",
  ldflags => "-Zexe",
  perl => "perl" # avoids case-mangling in make
);

1;
