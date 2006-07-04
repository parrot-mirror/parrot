#! perl
# Copyright (C) 2001-2006, The Perl Foundation.
# $Id: pmc2c.pl 12524 2006-05-05 21:50:26Z petdance $

use strict;
use warnings;

=head1 NAME

tools/build/headerizer.pl - Generates the function header parts of .h files from .c files

=head1 SYNOPSIS

Update the headers in F<include/parrot> with the function declarations in
the F<*.pmc> or F<*.c> files that correspond to the F<*.o> files passed
on the command line.

    % perl tools/build/headerizer.pl OBJFILES

=head1 DESCRIPTION

=head1 TODO

* Tell if there are funcs without docs

* Generate docs from funcs

* Test the POD of the stuff we're parsing.

=head1 NOTES

* the .c files MUST have a /* HEADER: foo/bar.h */ directive in them

* Support for multiple .c files pointing at the same .h file

* Does NOT remove all blocks in the .h file, so if a .c file disappears, it's block is "orphaned" and will remain there.

=head1 COMMAND-LINE OPTIONS

=over 4

=item C<--verbose>

Verbose status along the way.

=back

=head1 COMMAND-LINE ARGUMENTS

=over 4

=item C<OBJFILES>

One or more object file names.

=back

=cut

use Data::Dumper;
use Getopt::Long;
use lib qw( lib );
use Parrot::Config;

my %opt;

main();

=head1 FUNCTIONS

=cut

sub open_file {
    my $direction = shift;
    my $filename = shift;

    my %actions = (
        "<" => "Reading",
        ">" => "Writing",
        ">>" => "Appending",
    );

    my $action = $actions{$direction} or die "Invalid direction '$direction'";
    print "$action $filename\n" if $opt{verbose};
    open my $fh, $direction, $filename or die "$action $filename: $!\n";
    return $fh;
}


sub extract_functions {
    my $text = shift;

    return if $text =~ /DO NOT EDIT THIS FILE/;

    # Strip blocks of comments
    $text =~ s[^/\*.*?\*/][]mxsg;

    # Strip # compiler directives (Thanks, Audrey!)
    $text =~ s[^#(\\\n|.)*][]mg;

    # Strip code blocks
    $text =~ s[^{.+?^}][]msg;

    # Split on paragraphs
    my @funcs = split /\n{2,}/, $text;

    # If it doesn't start in the left column, it's not a func
    @funcs = grep /^\S/, @funcs;

    # Typedefs and structs are no good
    @funcs = grep !/^(typedef|struct|enum|extern)/, @funcs;

    # Variables are of no use to us
    @funcs = grep !/=/, @funcs;

    # Get rid of any blocks at the end
    s/\s*{.*//s for @funcs;

    # Toast anything non-whitespace
    @funcs = grep /\S/, @funcs;

    # If it's got a semicolon, it's not a function header
    @funcs = grep !/;/, @funcs;

    chomp @funcs;

    return @funcs;
}

sub function_components {
    my $proto = shift;

    my @parts = split( /\n/, $proto, 2 );
    my $returntype = $parts[0];
    my $parms = $parts[1];

    $parms =~ s/\s+/ /g;
    $parms =~ s/([^(]+)\s*\((.+)\);?/$2/ or die "Couldn't handle $proto";
    my $funcname = $1;
    $parms = $2;
    my @parms = split( /\s*,\s*/, $parms );
    for ( @parms ) {
        /\S+\s+\S+/ || ($_ eq "...") || ($_ eq "void") || /theINTERP/ or die "Bad parms in $proto";
    }

    my $static;
    $returntype =~ s/^((static)\s+)?//i;
    $static = $2 || "";

    return [$static, $returntype, $funcname, @parms];
}


sub main {
    GetOptions(
        "verbose"   => \$opt{verbose},
    ) or exit(1);

    my $nfuncs = 0;
    my @ofiles = @ARGV;
    my %files;
    for my $ofile ( @ofiles ) {
        next if $ofile =~ m/^\Qsrc$PConfig{slash}ops\E/;

        my $cfile = $ofile;
        $cfile =~ s/\Q$PConfig{o}\E$/.c/;

        my $pmcfile = $ofile;
        $pmcfile =~ s/\Q$PConfig{o}\E$/.pmc/;

        my $sourcefile = -f $pmcfile ? $pmcfile : $cfile;

        my $fh = open_file( "<", $cfile );
        my $source = do { local $/; <$fh> };
        close $fh;

        print "\n=== $cfile ===\n";

        die "can't find HEADER directive in '$cfile'" unless $source =~ m#/\*\s+HEADER:\s+([^*]+?)\s+\*/#s;
        my $hfile = $1;
        die "'$hfile' not found (referenced from '$cfile')" unless -f $hfile;

        my @funcs = extract_functions( $source );

        for my $func ( @funcs ) {
            push( @{$files{$hfile}->{$cfile}}, function_components( $func ) );
            ++$nfuncs;
        }
    } # for @cfiles
    my $nfiles = scalar keys %files;
    print Dumper( \%files ) if $opt{verbose};
    print "$nfuncs funcs in $nfiles files\n";

    for my $hfile ( sort keys %files ) {
        my $cfiles = $files{$hfile};

        open FILE, '<', $hfile or die "couldn't read '$hfile': $!";
        my $header = do {local $/=undef; <FILE>};  # slurp
        close FILE;

        for my $cfile ( sort keys %$cfiles ) {
            my $funcs = $cfiles->{$cfile};

            my $function_defs = "";
            foreach my $func ( @$funcs ){
                $function_defs .= sprintf "%s%s %s( %s );\n",
                $func->[0] ? $func->[0]." " : '',  # static
                $func->[1],                        # returntype
                $func->[2],                        # funcname
                # CHOOSE one of these two methods (or config item??):
                #          join(",", @{$func}[3..$#$func]), # params -- all on one line
                $#$func < 3 ? '' : join(",", map { "\n\t$_" } @{$func}[3..$#$func]) . "\n", # params -- formatted one per line & indented
                ;
            }
            my ($START_TXT, $END_TXT) = (qq#/* HEADERIZER BEGIN: $cfile */\n#, qq#/* HEADERIZER END: $cfile */\n#);
            my ($START_RE, $END_RE);
            ($START_RE = $START_TXT) =~ s/\*/\\*/g;
            ($END_RE   = $END_TXT)   =~ s/\*/\\*/g;
            $header =~ s#($START_RE)(?:.*?)($END_RE)#$1$function_defs$2#s or do {
                $header .= $START_TXT . $function_defs . $END_TXT;
            };
        }
        open FILE, '>', $hfile or die "couldn't write '$hfile': $!";
        print FILE $header;
        close FILE;
        print "Wrote '$hfile'\n";
    } # while % files
}

# vim: expandtab shiftwidth=4:
