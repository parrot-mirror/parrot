# Copyright (C) 2006-2009, Parrot Foundation.
# $Id$

.sub 'get_hellos'
    $P0 = new ['ResizableStringArray']
    push $P0, "hello"
    push $P0, unicode:"hello"
    push $P0, utf8:unicode:"hello"
    push $P0, utf16:unicode:"hello"
    push $P0, ucs2:unicode:"hello"
    .return ($P0)
.end

.sub 'get_empties'
    $P0 = new ['ResizableStringArray']
    push $P0, ""
    push $P0, unicode:""
    push $P0, utf8:unicode:""
    push $P0, utf16:unicode:""
    push $P0, ucs2:unicode:""
    .return ($P0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

