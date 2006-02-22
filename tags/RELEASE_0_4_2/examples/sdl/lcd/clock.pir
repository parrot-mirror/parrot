=head1 NAME

clock.pir - LCD clock

=head1 SYNOPSIS

    ./parrot examples/sdl/lcd/clock.pir

=head1 DESCRIPTION

This example demonstrates the SDL::LCD object. It shows a simple clock.

=head1 FUNCTIONS

=over 4

=cut

.include "tm.pasm"
.include "timer.pasm"

=item _main

The main function.

=cut

.sub _main :main
    load_bytecode "library/SDL/App.pir"
    load_bytecode "library/SDL/Event.pir"
    load_bytecode "library/SDL/EventHandler.pir"
    load_bytecode "library/SDL/LCD.pir"
    
    # set some screen properties
    $P0 = new PerlHash
    $P0["height"] = 21
    $P0["width"]  = 94
    $P0["bpp"]    = 16
    $P0["flags"]  =  5
    
    # create the SDL application object
    $I0 = find_type "SDL::App"
    $P0 = new $I0, $P0
    $P0 = $P0."surface"()
    global "screen" = $P0
    
    # create the LCD
    $I0 = find_type "SDL::LCD"
    $P0 = new $I0
    global "LCD" = $P0

    # draw the watch
    drawWatch()
    
    # create the timer
    $P1 = global "drawWatch"
    $P0 = new .Timer
    $P0[.PARROT_TIMER_NSEC] = 0.5
    $P0[.PARROT_TIMER_HANDLER] = $P1
    $P0[.PARROT_TIMER_REPEAT] = -1
    $P0[.PARROT_TIMER_RUNNING] = 1
    # store the timer somewhere, it will be
    # collected and destroyed otherwise
    global "timer" = $P0
    
    #
    # event loop
    #
    .local pmc eh
    .local pmc loop

    find_type $I0, "SDL::EventHandler"
    eh = new $I0
    find_type $I0, "SDL::Event"
    loop = new $I0
    loop."process_events"( 0.1, eh )
.end

=item drawWatch

Creates, sets and redraws the LCD display content.

=cut

.sub drawWatch
    # decode the current time
    $N0 = time
    $I0 = $N0
    $P0 = decodelocaltime $I0

    # use a dot or a space?
    $N0 -= $I0
    $S2 = ":"
    if $N0 < 0.5 goto USE_DOTS
    $S2 = " "
USE_DOTS:
    
    # hours
    $I0 = $P0[.TM_HOUR]
    $I0 /= 10
    if $I0 > 0 goto NO_SPACE
    $S0 = ' '
    branch HOUR
NO_SPACE:
    $S0 = $I0
HOUR:
    $I0 = $P0[.TM_HOUR]
    cmod $I0, $I0, 10
    $S1 = $I0
    concat $S0, $S1

    # minutes
    concat $S0, $S2
    $I0 = $P0[.TM_MIN]
    $I0 /= 10
    $S1 = $I0
    concat $S0, $S1
    $I0 = $P0[.TM_MIN]
    cmod $I0, $I0, 10
    $S1 = $I0
    concat $S0, $S1

    # seconds
    concat $S0, $S2
    $I0 = $P0[.TM_SEC]
    $I0 /= 10
    $S1 = $I0
    concat $S0, $S1
    $I0 = $P0[.TM_SEC]
    cmod $I0, $I0, 10
    $S1 = $I0
    concat $S0, $S1

    # set the time
    $P0 = global "LCD"
    $P0 = $S0

    # redraw the LCD
    $P1 = global "screen"
    $P0.'draw'( $P1 )
.end

=back

=head1 AUTHOR

Jens Rieks E<lt>parrot at jensbeimsurfen dot deE<gt> is the author
and maintainer.
Please send patches and suggestions to the Perl 6 Internals mailing list.

=head1 COPYRIGHT

Copyright (c) 2004, The Perl Foundation.

=cut
