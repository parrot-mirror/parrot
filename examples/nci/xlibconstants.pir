# Copyright (C) 2008, The Perl Foundation.
# $Id$

=head1 TITLE

xlibconstants.pir - Test NCI with libX11

=head1 SYNOPSIS

Constants for xlib.pir

=cut

# event masks

.const int KeyPressMask = 1
.const int KeyReleaseMask = 2
.const int ButtonPressMask = 4
.const int ButtonReleaseMask = 8
.const int EnterWindowMask = 16
.const int LeaveWindowMask = 32
.const int PointerMotionMask = 64

# event types
.const int KeyPress = 2
.const int KeyRelease = 3
.const int ButtonPress = 4
.const int ButtonRelease = 5
.const int MotionNotify = 6

#-----------------------------------------------------------------------
# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
