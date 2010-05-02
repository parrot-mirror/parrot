#! perl
# Copyright (C) 2010, Parrot Foundation.
# $Id$
#
# perl script that writes modified POD files to the directory
# 'build/modified_pod'. Then this script generates a latex file from
# this POD.
#

use strict;
use warnings;

# prototype
sub write_mod($);


use Getopt::Long ();
use Pod::PseudoPod::LaTeX;

my $item_list_ref = [ ['intro.pod', 'Introduction to Parrot'],
                      ['overview.pod', 'Overview'],
                      ['submissions.pod', 'Submitting bug reports and patches'],
                    ];

my $lang = @$item_list_ref;
my $MOD_BUILD_PATH='build/modified_pod/';

my ( $result, $give_out );

$result = Getopt::Long::GetOptions (
    "print" => \$give_out,
);

if ($give_out)  {
    for ( my $i=0; $i<$lang; $i++ )
        { print $$item_list_ref[$i][0], "\n" }
    exit;
};


for ( my $i=0; $i<$lang; $i++ ) {
    write_mod( $i );
}


open( TEX_FH, '>build/parrot-book.tex');

print TEX_FH <<'HEADER';
\documentclass[11pt,a4paper,oneside]{report}
\usepackage{graphics,graphicx}
\usepackage{colortbl}

\begin{document}
\tableofcontents
HEADER

for ( my $i=0; $i<$lang; $i++ ) {
    my $parser = Pod::PseudoPod::LaTeX->new();
    $parser->output_fh( *TEX_FH );
    $parser->parse_file( "${MOD_BUILD_PATH}$$item_list_ref[$i][0]" );
}

print TEX_FH <<'FOOTER';
\end{document}
FOOTER

close( TEX_FH );


sub write_mod( $ ) {
    my $icnt;

    open( IN_FH, "<$$item_list_ref[$_[0]][0]" ) ||
        die( "$0: can't open $$item_list_ref[$_[0]][0] for reading ($!)\n" );
    open( OUT_FH, ">${MOD_BUILD_PATH}$$item_list_ref[$_[0]][0]" );

    # do the same as: sed -e '4,6c\=head0 $$item_list_ref[$i][1]'
    while( <IN_FH> ) {
        if ( $icnt = (4..6) ) {
            if ( $icnt =~ /E0$/ ) {
                print( OUT_FH "=head0 $$item_list_ref[$_[0]][1]\n");
            }
        }
        else { print( OUT_FH ); }
    }

    close( IN_FH );
    close( OUT_FH );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
