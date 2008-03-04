=head1 Config::JSON

Provides a simple wrapper to read and write JSON config files.

=cut

.namespace [ 'Config' ; 'JSON' ]

=head2 ReadConfig(filename)

Given a filename, parse the file containing valid JSON and return a 
PMC containing the data.

If the data is not valid, an exception will be thrown.

=cut

.sub 'ReadConfig'
    .param string filename

    # Slurp in the file
    .local string text
    .local pmc pio

    pio = open filename, '<'
    if pio goto slurp_file
    $P0 = new 'Exception'
    $S0 = concat "can't open file: ", filename
    $P0['_message'] = $S0
    throw $P0

  slurp_file:
    text = pio.'slurp'(filename)

    # convert the text to an object and return it.
    load_bytecode 'compilers/json/JSON.pbc'

    .local pmc JSON, config
    JSON = compreg "JSON"

    .return JSON(text)
.end

=head2 WriteConfig(config, filename, ?:compact)

Given a PMC and a filename, render the pmc as JSON and store the contents
into the named file, overwriting the existing contents.

Any exceptions generated by the conversion or writing to the file will
be passed through.

If a true value is passed for the optional named parameter 'compact', then
the rendered JSON will not be formatted. The default is false.

=cut

.sub 'WriteConfig'
    .param pmc    config
    .param string filename
    .param int    compact     :optional :named('compact')
    .param int    has_compact :opt_flag

    if has_compact goto done_options
    compact = 0

  done_options:
    .local int expanded
    expanded = not compact

    # render the object as a string.
    .local string output
    output = _json( config, expanded )

    # write out the file..
    $P1 = open filename, '>'
    print $P1, output
    close $P1

.end
.include 'library/JSON.pir'

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
