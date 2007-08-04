
# $Id$

=head1 NAME

SDL::App - Parrot extension for SDL Applications

=head1 SYNOPSIS

    # load this library
    load_bytecode 'library/SDL/App.pir'

    # create a new SDL::App object
    .local pmc app
    .local int app_type

    find_type app_type, 'SDL::App'
    app = new app_type

    # set the app's arguments
    .local pmc app_args
    app_args = new 'Hash'
    app_args[ 'height' ] = 480
    app_args[ 'width'  ] = 640
    app_args[ 'bpp'    ] =   0
    app_args[ 'flags'  ] =   1

    # initialize the object and get the main surface
    .local pmc main_surface
    main_surface = app.'BUILD'( app_args )

    # go to town filling, blitting, and updating the app
    # for example:
    main_surface.update()

    ...

    # then, shut down cleanly
    app.'quit'()

=head1 DESCRIPTION

SDL::App is the entry point for all SDL Applications.  It handles most of the
other setup for you.  Trust me, there's a little bit -- if you care, it will
initialize the SDL library.

This object represents the main window and the associated drawing surface.
There should only be one of those per program.  As this represents an
L<SDL::Surface> object, you can call any method of that class on objects of
this class.

B<Note:> It's not yet complete.  Please let me know if you have added or would
like someone to add missing features.

=head1 METHODS

The SDL::App object has the following methods:

=over 4

=cut

.namespace [ 'SDL::App' ]

.sub _initialize :load

    .include 'datatypes.pasm'
    load_bytecode 'library/SDL.pir'
    load_bytecode 'library/SDL/Surface.pir'
    load_bytecode 'library/SDL/Constants.pir'

    .local pmc app_class

    newclass     app_class, 'SDL::App'
    addattribute app_class, 'height'
    addattribute app_class, 'width'
    addattribute app_class, 'bpp'
    addattribute app_class, 'flags'
    addattribute app_class, 'surface'

    .return()
.end

=item init( [ width => xxx ], [ height => xxx ], [ bpp => xx ], [ flags => xx ])

Initialize the new object with the necessary arguments.  The named arguments
areas follows:

=over 4

=item C<width>

the width of the main window, in pixels

=item C<height>

the height of the main window, in pixels

=item C<bpp>

the ideal bit depth of the screen to create.  Note that you may receive a
screen of different (possibly lesser) capabilities, as that's what SDL does.
If you pass C<0> here, you'll receive the recommended bit depth.

=item C<flags>

an integer value representing the proper SDL constants from C<SDL::Constants>.
See that module for ideas on what to pass here, or give me a better suggestion
about the interface here.

=back

=cut

.sub 'init' :method
    .param int width  :named('width')
    .param int height :named('height')
    .param int bpp    :named('bpp')
    .param int flags  :named('flags')

    .local pmc SetVideoMode
    SetVideoMode = find_global 'SDL::NCI', 'SetVideoMode'

    .local pmc screen
    screen = SetVideoMode( width, height, bpp, flags )
    # XXX - need to check this here somehow
    # defined $I0, screen

    .local int surface_type
    .local pmc main_surface

    find_type surface_type, 'SDL::Surface'
    new main_surface, surface_type

    main_surface.'wrap_surface'( screen )

    .local int offset
    .local pmc intvalue

    # set all other offsets in self
    classoffset offset, self, 'SDL::App'

    intvalue = new 'Integer'
    set intvalue, height
    setattribute self, offset, intvalue

    intvalue = new 'Integer'
    set intvalue, width
    inc offset
    setattribute self, offset, intvalue

    intvalue = new 'Integer'
    set intvalue, bpp
    inc offset
    setattribute self, offset, intvalue

    intvalue = new 'Integer'
    set intvalue, flags
    inc offset
    setattribute self, offset, intvalue

    inc offset
    setattribute self, offset, main_surface

    .return()
.end

=item surface()

Returns the main surface.  This is an L<SDL::Surface>.

=cut

.sub surface :method
    .local pmc surface
    .local int offset

    classoffset offset, self, 'SDL::App'
    add offset, 4
    getattribute surface, self, offset

    .return( surface )
.end

=item quit()

Quits the main window and shuts down SDL.  You probably only have one shot at
this.

=cut

.sub quit :method
    .local pmc SDL_Quit
    SDL_Quit = find_global 'SDL::NCI', 'Quit'
    SDL_Quit()
.end

=item height()

Returns the height of the main window, in pixels.  This will likely move to
L<SDL::Surface>.

=cut

.sub height :method
    .local pmc height
    .local int offset
    .local int result

    classoffset offset, self, 'SDL::App'
    getattribute height, self, offset
    set result, height

    .return( result )
.end

=item width()

Returns the width of the main window, in pixels.  This will likely move to
L<SDL::Surface>.

=cut

.sub width :method
    .local pmc width
    .local int offset
    .local int result

    classoffset offset, self, 'SDL::App'
    add offset, 1
    getattribute width, self, offset
    set result, width

    .return( result )
.end

=item bpp()

Returns the bit depth of the main window, in pixels.

=cut

.sub bpp :method
    .local pmc bpp
    .local int offset
    .local int result

    classoffset offset, self, 'SDL::App'
    add offset, 3
    getattribute bpp, self, offset
    set result, bpp

    .return( result )
.end

=back

=head1 AUTHOR

Written and maintained by chromatic, E<lt>chromatic at wgz dot orgE<gt>, with
suggestions from Jens Rieks.  Please send patches, feedback, and suggestions to
the Perl 6 Internals mailing list.

=head1 COPYRIGHT

Copyright (C) 2004-2006, The Perl Foundation.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
