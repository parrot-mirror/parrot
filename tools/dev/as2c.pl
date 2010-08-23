#! perl

# Copyright (C) 2004-2007, Parrot Foundation.

# $Id$

=head1 NAME

as2c.pl - convert GNU Assembler listing to i386 code array

=head1 DESCRIPTION

The plan behind of F<as2c.pl> is to create compiler independent
machine code for an architecture. Code in, I<e.g.,> MASM, GAS, NASM syntax
doesn't fit all compilers. Therefore F<as2c.pl> translates GAS syntax to a
bytestring, which is then used as the asm code.

F<as2c.pl> is used very rarely. Once the code is generated and
checked in, there's usually no need to change it later.

=cut

use strict;
use warnings;

my $src = $ARGV[0];
my $cmd = "cc -c $src.c -Wall -O3 -fomit-frame-pointer -DNDEBUG -Wa,-a > $src.s";
my ($func);

print_header($src);
create_s($cmd);
parse_s("$src.s");
add_glue("$src.c");
print_coda();

sub print_header {
    my $s = shift;
    print <<EOT;
/*
 * DO NOT EDIT THIS FILE
 *
 * Generated from $s.c via $s.s
 * by '$0 $s'
 */

EOT
}

sub print_coda {
    print <<EOT;
/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
*/
EOT
}

sub create_s {
    my $cmd = shift;
    my $r   = system($cmd);
    if ($r) {
        die "$cmd failed: $r";
    }
}

sub parse_s {
    my $s = shift;
    open my $IN, "<", "$s" or die "Can't read '$s': $1";
    my ($in_comment);
    $in_comment = 1;
    print "/*\n";
    while (<$IN>) {
        next if (/^\f/);             # FF
        next if (/#(?:NO_)?APP/);    # APP, NO_APP
        chomp;
        if (/^\s*\d+\s[\da-fA-F]{4}\s([\dA-F]{2,8})\s+(.*)/) {
            if ($in_comment) {
                print " */\n";
            }
            my ( $bytes, $src ) = ( $1, $2 );
            $src =~ s/\t/ /g;
            my $len = length($bytes);
            my @pairs = ( $bytes =~ m/../g );
            print "    " . join '', map { "0x$_, " } @pairs;
            print " " x ( 3 * ( 8 - $len ) );
            print "    /* $src */\n";
        }
        elsif (/\.type\s+(\w+)\s*,\s*\@function/) {
            $in_comment = 0;
            $func       = $1;
            print " *\n */\n";
            print "static const char ${func}_code[] = {\n";
        }
        elsif (/^\s*\d+\s+(\w+):/) {
            print " " x 26, " /* $1: */\n";
        }
        elsif ($in_comment) {
            s/\s+//g;
            print " * $_\n";
        }
    }
    print "    0x00\n";
    print "};\n";
    close $IN;
}

sub add_glue {
    my $s = shift;
    open $IN, "<", "$s" or die "Can't read '$s': $1";
    while (<$IN>) {
        if (/\/\*INTERFACE/) {
            my $text = "";
            while (<$IN>) {
                last if (/INTERFACE\*\//);
                $text .= $_;
            }
            $text =~ s/\@FUNC\@/$func/g;
            $text =~ s!\@\*!/*!g;
            $text =~ s!\*\@!*/!g;
            print $text;
        }
    }
    close $IN;
}

=head1 REFERENCES

GNU Assembler: (GAS) L<http://en.wikipedia.org/wiki/GNU_Assembler>

Microsoft Macro Assembler (MASM): L<http://en.wikipedia.org/wiki/Microsoft_Macro_Assembler>

Netwide Assembler (NASM) L<http://en.wikipedia.org/wiki/Netwide_Assembler>

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
