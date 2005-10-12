# Copyright (C) 2001-2005 The Perl Foundation.  All rights reserved.
# $Id$

=head1 NAME

examples/pir/pcre.imc - Perl compatible regular expressions

=head1 SYNOPSIS

    % ./parrot examples/pir/pcre.pir string pattern

=head1 DESCRIPTION

Experimental string matching with PCRE, L<http://www.pcre.org/>.
Note that PCRE must be installed for this to work.

=head1 AUTHORS

Original code by Leo Toetsch, updated by Jerry Gay 
E<lt>jerry dot gay at gmail dot com<gt>

=cut


.include 'library/pcre.imc'


.sub main :main
    .param pmc argv

    .local int argc
    argc= argv
    if argc != 3 goto USAGE

    .local pmc func
    .local pmc lib

    func= find_global 'PCRE', 'init'
    lib= func()

    .local string s
    s= argv[1]
    .local string pat
    pat= argv[2]

    print s
    print " =~ /"
    print pat
    print "/\n"

    .local pmc regex
    .local string error
    .local int errptr

    func= find_global 'PCRE', 'compile'
    ( regex, error, errptr )= func( pat, 0 )

    .local int is_regex_defined
    is_regex_defined= defined regex
    unless is_regex_defined goto MATCH_ERR

    .local int ok
    .local pmc result
    
    func= find_global 'PCRE', 'match'
    ( ok, result )= func( regex, s, 0, 0 )

    if ok < 0 goto NOMATCH
    print ok
    print " match(es):\n"
    .local int i
    i= 0
    .local string match

LP: 
    func= find_global 'PCRE', 'dollar'
    match= func( s, ok, result, i )
    print match
    print "\n"
    inc i
    if i < ok goto LP
    end

NOMATCH:
    print "no match\n"
    end

MATCH_ERR:
    print "error in regex: "
    print "at: '"
    .local int pat_errloc
    length pat_errloc, pat
    pat_errloc = pat_errloc - errptr

    .local string pattern_error
    substr pattern_error, pat, errptr, pat_errloc
    print pattern_error
    print "'\n"
    exit 1

USAGE:
    .local string prog
    prog= argv[0]
    print 'usage: '
    print prog
    print " string pattern\n"
    exit 1
.end

