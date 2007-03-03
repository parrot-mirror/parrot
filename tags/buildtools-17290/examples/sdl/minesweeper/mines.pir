=head1 TITLE

mines.pir - a minesweeper clone for parrot (with parrot's SDL bindings)

=head1 SYNOPSIS

To run this game, be in the Parrot directory and run the following command:

        $ parrot examples/sdl/minesweeper/mines.pir
        $

=head1 FUNCTIONS

=over 4

=item _main

The main function.

=cut

.sub _main :main
    .param pmc args
    .local pmc field
    .local pmc screen
    .local int debug

    # the debug mode is activated if you pass in any argument    
    debug = args
    dec debug
    
    load_bytecode "library/SDL/App.pir"
    load_bytecode "library/SDL/Event.pir"
    load_bytecode "library/SDL/EventHandler.pir"
    load_bytecode "library/SDL/Rect.pir"
    load_bytecode "library/SDL/Surface.pir"
    load_bytecode "library/SDL/Color.pir"
    load_bytecode "library/SDL/Image.pir"
    load_bytecode "examples/sdl/minesweeper/field.pir"
    
    # setup the screen properties
    $P0 = new .Hash
    $P0["height"] = 480
    $P0["width"]  = 640
    $P0["bpp"]    =  32
    $P0["flags"]  =   5

    # create the SDL object
    find_type $I0, "SDL::App"
    $P0 = new $I0, $P0
    screen = $P0."surface"()
    
    # choose a "random" field
    $I0 = time
    
    # setup field properties
    $P0 = new .Hash
    $P0['width']  = 40
    $P0['height'] = 28
    $P0['mines']  = 0.1075
#    $P0['mines']  = 0.0075
    $P0['level']  = $I0
    $P0['screen'] = screen
    $P0['debug']  = debug
    
    # create the field
    $I0 = find_type "Mines::Field"
    field = new $I0, $P0

    # draw the field
    field.'draw'()
            
    # runloop
    find_type $I0, "SDL::Event"
    $P0 = new $I0
    find_type $I0, "Mines::EventHandler"
    $P1 = new $I0
    $P0."process_events"( 0.1, $P1, field )

    end
.end

=back

=head1 CREDITS

The graphics were taken from KMines L<http://kmines.sf.net/> screenshots.

=head1 AUTHOR

Jens Rieks E<lt>parrot at jensbeimsurfen dot deE<gt> is the author
and maintainer.
Please send patches and suggestions to the Perl 6 Internals mailing list.

=head1 COPYRIGHT

Copyright (C) 2004, The Perl Foundation.

=cut
