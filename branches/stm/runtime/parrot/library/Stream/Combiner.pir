# $Id$

=head1 TITLE

Stream::Combiner - combines different streams to a single stream.

=head1 VERSION

version 0.1

=head1 SYNOPSIS

Please have a look at the examples
F<examples/streams/Combiner.pir> and
F<examples/streams/FileLines.pir>.

=head1 DESCRIPTION

TBD

=head1 METHODS

=over 4

=cut

.sub onload :load, :anon
    .local int i
    .local pmc base
    .local pmc comb

    find_type i, "Stream::Combiner"
    if i > 1 goto END

    load_bytecode "library/Stream/Base.pir"

    getclass base, "Stream::Base"
    subclass comb, base, "Stream::Combiner"

    addattribute comb, "combiner"
END:
.end

.sub _default_combiner
    .param pmc args
    .local string ret

    join ret, "", args

    .return(ret)
.end

.include "iterator.pasm"

.namespace ["Stream::Combiner"]

.sub __init :method

    .const .Sub temp = "_default_combiner"
    self."combiner"( temp )

    temp = new .ResizablePMCArray
    self."setSource"( temp )
.end

=item combiner = stream."combiner"( sub )

Sets (or just returns) the combiner sub.

=cut

.sub combiner :method
    .param pmc _combiner :optional
    .param int has_combiner :opt_flag
    .local pmc ret

    classoffset $I0, self, "Stream::Combiner"
    unless has_combiner goto GET
    setattribute self, $I0, _combiner
    ret = _combiner
    branch END
GET:
    getattribute ret, self, $I0
END:
    .return(ret)
.end

=item assign stream, source

Assign a source to this stream.
You can call assign several times to assign several sources to the stream.

=cut

.sub __set_pmc :method
    .param pmc arg
    .local pmc source

    source = self."source"()
    push source, arg
.end

=item is = stream."connected"()

Returns 1 if all assigned sources are connected, 0 otherwise.

=cut

.sub connected :method
    .local pmc sources
    .local pmc source
    .local int i

    # get the sources
    sources = self."source"()

    # check if at least one sources is defined
    i = sources
    if i == 0 goto NOT_CONNECTED

    # create an iterator for the sources
    new sources, .Iterator, sources
    set sources, .ITERATE_FROM_START

LOOP:
    # stream is connected if no sources are left
    unless sources goto IS_CONNECTED

    # check the next source
    source = shift sources
    i = source."connected"()

    # proceed with the next source if connected
    if i goto LOOP

NOT_CONNECTED:
    .return(0)

IS_CONNECTED:
    .return(1)
.end

=item source."rawRead"() (B<internal>)

Reads from all assigned sources and calls the combiner.

=cut

.sub rawRead :method
    .local pmc sources
    .local pmc source
    .local pmc combiner
    .local pmc args
    .local string str
    .local string ret
    .local int i

    # get the sources
    sources = self."source"()

    # check if at least one sources is defined
    i = sources
    if i == 0 goto END_OF_STREAM

    # create an iterator for the sources
    new sources, .Iterator, sources
    set sources, .ITERATE_FROM_START

    # create the string array
    new args, .ResizableStringArray

READ_LOOP:
    unless sources goto CALL

    # read from next stream
    source = shift sources
    str = source."read"()

    # end of stream?
    if_null str, END_OF_STREAM

    # push onto array
    push args, str
    branch READ_LOOP

CALL:
    classoffset i, self, "Stream::Combiner"
    getattribute combiner, self, i

    ret = combiner( args )
    .return(ret)

END_OF_STREAM:
    self."close"()
    null ret
    .return(ret)
.end

=back

=head1 AUTHOR

Jens Rieks E<lt>parrot at jensbeimsurfen dot deE<gt> is the author
and maintainer.
Please send patches and suggestions to the Perl 6 Internals mailing list.

=head1 COPYRIGHT

Copyright (c) 2004, the Perl Foundation.

=cut
