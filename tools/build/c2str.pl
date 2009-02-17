#! perl
# $Id$

# Copyright (C) 2004-2008, Parrot Foundation.

=head1 NAME

tools/build/c2str.pl - constant string support

=cut

use warnings;
use strict;
use lib 'lib';

use Fcntl qw( :DEFAULT :flock );
use Text::Balanced qw(extract_delimited);
use Math::BigInt ();
use Getopt::Long ();
use IO::File ();

my $outfile          = 'all_cstring.str';
my $string_private_h = 'src/string/private_cstring.h';

# add read/write permissions even if we don't read/write the file
# for example, Solaris requires write permissions for exclusive locks
my $ALL = IO::File->new($outfile, O_CREAT | O_RDWR)
    or die "Can't open '$outfile': $!\n";

flock( $ALL, LOCK_EX ) or die "Can't lock '$outfile': $!\n";

$ALL->seek(2, 0); # in case its been appended to while we waited for the lock

my ( $result, $do_all, $do_init, $file );
$result = Getopt::Long::GetOptions(
    "all"  => \$do_all,
    "init" => \$do_init,
);

$do_all and do {
    read_all();
    create_c_include();
    exit;
};
$do_init and do {
    close $ALL;
    unlink $outfile;
    exit;
};

$file = shift @ARGV;
$file =~ s/\.c$//;
my $infile = $file . '.c';
die "$0: $infile: $!" unless -e $infile;

my %known_strings;
my @all_strings;

read_all();
process_cfile();

# the literal length of the string in source code is NOT its length in C terms
sub get_length {
    my $s = shift;
    $s    =~ s{\\x\d+}{.}g;
    $s    =~ s{\\.}{.}g;

    return length $s;
}

sub hash_val {
    my $h = Math::BigInt->new('+0');
    my $s = shift;
    for ( my $i = 0 ; $i < length($s) ; ++$i ) {
        $h += $h << 5;
        $h &= 0xffffffff;
        $h += ord substr( $s, $i, 1 );
        $h &= 0xffffffff;
    }
    return sprintf( "0x%x", $h );
}

sub read_all {
    $ALL->seek(0, 0);
    while (<$ALL>) {

        # len hashval "string"
        if (/(\d+)\s+(0x[\da-hA-H]+)\s+"(.*)"/) {
            push @all_strings, [ $1, $2, $3 ];
            $known_strings{$3} = @all_strings;
        }
    }
    return;
}

sub process_cfile {
    open my $IN, '<', $infile or die "Can't read '$infile': $!";

    my $line = 0;
    print <<"HEADER";
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$infile'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

#define CONCAT(a,b) a##b
#define _CONST_STRING(i, l) (i)->const_cstring_table[CONCAT(_CONST_STRING_, l)]
#define CONST_STRING(i, s) _CONST_STRING(i, __LINE__)
#define CONST_STRING_GEN(i, s) _CONST_STRING_GEN(i, __LINE__)
#define _CONST_STRING_GEN(i, l) \\
    (i)->const_cstring_table[CONCAT(_CONST_STRING_GEN_, l)]

HEADER
    print $ALL "# $infile\n";
    my %this_file_seen;

    # NOTE: when CONST_STRING gets used it and any macro invocations
    # that it is used in *should not* be split across more than one
    # line, because some compilers generate line numbers in such cases
    # differently from the way gcc does this (a case in point is
    # Intel's C compiler, icc) and hence the #defined CONST_STRING
    # won't be found by the compiler.

    # There is a chance that the same __LINE__ will reoccur if #line directives
    # are used.
    my $prev_line;
    my %lines_seen;

    while (<$IN>) {
        if (m/^\s*#\s*line\s+(\d+)/) {

            # #line directive
            $line = $1 - 1;
            $prev_line = $_;
            next;
        }
        $line++;
        # otherwise ignore preprocessor

        do { $prev_line = $_; next } if m/^\s*#/;
        do { $prev_line = $_; next }
            unless s/.*\bCONST_STRING(_GEN)?\s*\(\w+\s*,//;

        my $const_string = defined $1 ? 'CONST_STRING_GEN' : 'CONST_STRING';

        if ( $lines_seen{"$line:$const_string"}++ ) {
            die "Seen line $line before in $infile - can't continue";
        }

        # semicolons, blank lines, opening braces, closing parens, #directives
        # comments, labels, else keyword
        if ($prev_line !~ /([{});:]|\*\/|\w+:|else)$/
        &&  $prev_line !~ /^\s*(#.*)?$/) {
            die "CONST_STRING split across lines at $line in $infile\n";
        }

        my $str = extract_delimited;    # $_, '"';
        $str    = substr $str, 1, -1;
        ## print STDERR "** '$str' $line\n";
        my $n;
        if ( $n = $known_strings{$str} ) {
            if ( $this_file_seen{"$const_string:$str"} ) {
                print "#define _${const_string}_$line _${const_string}_",
                    $this_file_seen{"$const_string:$str"}, "\n";
            }
            else {
                print "#define _${const_string}_$line $n\n";
            }
            $this_file_seen{"$const_string:$str"} = $line;
            $prev_line = $_;
            next;
        }

        my $len               = get_length($str);
        my $hashval           = hash_val($str);
        push @all_strings, [ $len, $hashval, $str ];

        $n                    = @all_strings;
        $known_strings{$str}  = $n;
        $this_file_seen{"$const_string:$str"} = $line;
        print "#define _${const_string}_$line $n\n";
        print $ALL qq!$len\t$hashval\t"$str"\n!;
    }
    close($IN);
    return;
}

sub create_c_include {
    open my $OUT, '>', $string_private_h
        or die "Can't write '$string_private_h': $!";
    print $OUT <<"HEADER";
/* ex: set ro:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically from '$outfile'
 * by $0.
 *
 * Any changes made here will be lost!
 *
 */

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

#ifndef PARROT_SRC_STRING_PRIVATE_CSTRING_H_GUARD
#define PARROT_SRC_STRING_PRIVATE_CSTRING_H_GUARD

static const struct _cstrings {
    UINTVAL len;
    Parrot_UInt4 hash_val;
    const char *string;
} parrot_cstrings[] = {
    { 0, 0, "" },
HEADER
    my @all;
    for my $s (@all_strings) {
        push @all, qq!    {$s->[0], $s->[1], "$s->[2]"}!;
    }
    print $OUT join( ",\n", @all );
    print $OUT <<HEADER;

};

HEADER

    # append the C code coda
    print $OUT <<HEADER;

#endif /* PARROT_SRC_STRING_PRIVATE_CSTRING_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 *   buffer-read-only: t
 * End:
 * vim: expandtab shiftwidth=4:
 */
HEADER

    close $OUT;
    return;
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
