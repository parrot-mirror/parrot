# $Id$
# Copyright (C) 2001-2007, The Perl Foundation.

package Scheme::Test;

# pragmata
use strict;
use warnings;
use 5.008;

use Parrot::Config;

require Exporter;
require Parrot::Test;

our @EXPORT = ( qw(output_is output_like output_isnt), @Test::More::EXPORT );
our @ISA = qw(Exporter Test::More);

sub import {
    my ( $class, $plan, @args ) = @_;

    Test::More->import( $plan, @args );

    __PACKAGE__->_export_to_level( 2, __PACKAGE__ );
}

my $count;

foreach my $meth ( qw(is isnt like) ) {
    no strict 'refs';

    *{"Scheme::Test::output_$meth"} = sub ($$;$) {
        my ( $lang_code, $output, $desc ) = @_;

        ++$count;
        my ( $lang_f, $pasm_f, $out_f ) = map {
            my $t = $0;
            $t =~ s/\.t$/_$count\.$_/;
            $t
        } qw(scheme pasm out); 

        # STDERR is written into same output file
        open LANG, '>', $lang_f or die "Unable to open '$lang_f':$!"; 
        binmode LANG;
        print LANG $lang_code;
        close LANG;

        Parrot::Test::run_command(
            "$PConfig{perl} languages/scheme/schemec languages/$lang_f",
            CD     => '..',                                             # $self->{relpath},
            STDOUT => $pasm_f,
            STDERR => $pasm_f,
        );
        Parrot::Test::run_command(
            "./parrot languages/$pasm_f",
            CD     => '..',                                             # $self->{relpath},
            STDOUT => $out_f,
            STDERR => $out_f,
        );
        my $prog_output = Parrot::Test::slurp_file($out_f);

        @_ = ( $prog_output, $output, $desc );

        my $ok = &{"Test::More::$meth"}(@_);
    }
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
