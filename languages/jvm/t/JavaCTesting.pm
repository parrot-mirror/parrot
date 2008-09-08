# Some utility subs for aiding the test process.
# ##############################################

# Copyright (C) 2006, The Perl Foundation.
# $Id$

package JavaCTesting;

use strict;
use warnings;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(compile_java translate run_pir);

use File::Spec;

use Parrot::Test ();
require "config/J2PConfig.pm";

# globals
my $path_to_parrot = Parrot::Test::path_to_parrot();
my $parrot = File::Spec->catfile( $path_to_parrot, 'parrot' );

# This compiles java code to a class.
# ####################################
sub compile_java {
    my $file_name = shift;
    my $java_code = shift;
    my $opt       = shift;
    $opt ||= '';

    # Write file.
    my $fh;
    open $fh, ">", "$file_name.java" or die "$!\n";
    print $fh $java_code;
    close $fh;

    # Attempt to compile.
    #my $kind = $file_name =~ /\.class$/ ? '-target:library' : '';
    my $output = `javac -warn:0 -out:$file_name $kind $opt $file_name.java`;
    if ($output) {
        print "compile_java failed:\n$output";
        return 0;
    }

    # Clean up file.
    unlink "$file_name.java";
    return 1;
}

# This translates a Java class file to a PBC.
# ###########################################
sub translate($$) {
    my $net_name = shift;
    my $out_name = shift;

    # Attempt to translate.
    my $blib_path = File::Spec->catfile( $path_to_parrot, 'blib', 'lib' );
    if ($^O eq 'cygwin') {
        $ENV{PATH} = $blib_path . ':' . $ENV{PATH};
    } 
    elsif ($^O eq 'MSWin32') {
        $ENV{PATH} = $blib_path . ';' . $ENV{PATH};
    }
    else {
        $ENV{LD_RUN_PATH} = $blib_path;
    }
    my $output =
        `$parrot $path_to_parrot/languages/jvm/class2pbc.pbc -q -s -p $net_name > $out_name.pir`;
    if ($output) {
        print "translate failed:\n$output";
        return 0;
    }
    $output = `$parrot -o $out_name $out_name.pir`;
    unlink "$out_name.pir";
    if ($output) {
        print "translate failed:\n$output";
        return 0;
    }
    return 1;
}

# This takes some PIR, saves it to a file then runs it.
# #####################################################
sub run_pir($) {
    my $pir_code = shift;

    # Write.
    my $fh;
    open $fh, ">", "__temp__.pir" or die "$!\n";
    print $fh $pir_code;
    close $fh;

    # Run and get output.
    my $output = `$parrot __temp__.pir`;

    # Clean up file and return output.
    unlink "__temp__.pir";
    return $output;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
