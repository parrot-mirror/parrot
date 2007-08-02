#! perl
use 5.008_000;
use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use lib 'lib';

use Parrot::Configure;

# So far, I'm only permitting one option:  --step=some::step
# What other options should be permitted?
# Well, one obvious choice is --ask, because without it you can't get any of
# the inter::* steps to stop and prompt you for an answer.
# And that leads to --verbose (but not to --verbose-step, because that
# specifies a particular step number as distinct from all others; here we only
# have one step).
# Probably should have a --help option distinct from that of Configure.pl.
# What about --debugging and --maintainer:  how should we handle them?
# What about --lex and --yacc, which imply a particular value for
# --maintainer?
# particle has pointed out the instances in which he and others re-run
# configuration steps.  (a) These would imply changes in
# config/gen/makefile/root.in and other root.in files.  (b) Re-running
# gen::makefiles is used both overall and in conjunction with specific
# langueages:  --step=gen::makefiles --languages=perl6 or --languages=nqp

$| = 1; # $OUTPUT_AUTOFLUSH = 1;
my $args = process_options( {
    argv            => [ @ARGV ],
    script          => $0,
} );
exit(1) unless (defined $args and defined $args->{step});

my $conf = Parrot::Configure->new;
$conf->add_step($args->{step});
$conf->options->set(%{$args});

# The result of slurp() is that the parameters in %Parrot::Config::PConfig
# are assigned to the {c} attribute in $conf.
$conf->data()->slurp();
# The result of slurp_temp() is that the parameters in
# %Parrot::Config::PConfig_Temp
# are assigned to the {c}{$_} attribute in $conf.
if ($args->{step} =~ /gen::makefiles/) {
    $conf->data()->slurp_temp();
}
$conf->run_single_step( $args->{step} );
print "\n";
exit(0);

sub get_valid_options {
    return qw(
        ask
        debugging
        help
        languages
        lex
        maintainer
        step
        verbose
        yacc
    );
}

sub process_options {
    my $optionsref = shift;
    $optionsref->{argv} = []
        unless defined $optionsref->{argv};
    $optionsref->{script} = q{tools/dev/reconfigure.pl}
        unless defined $optionsref->{script};
    my @valid_opts = get_valid_options();
    my %args;
    for ( @{ $optionsref->{argv} } ) {
        my ( $key, $value ) = m/--([-\w]+)(?:=(.*))?/;
        $key   = 'help' unless defined $key;
        $value = 1      unless defined $value;

        unless ( grep $key eq $_, @valid_opts ) {
            die qq/Invalid option "$key". See "perl $optionsref->{script} --help" for valid options\n/;
        }

        for ($key) {
            if ( $key =~ m/help/ ) {
                print_help($optionsref);
                return;
            }
            $args{$key} = $value;
        }
    }

    $args{debugging} = 1
        unless ( ( exists $args{debugging} ) && !$args{debugging} );
    $args{maintainer} = 1 if defined $args{lex} or defined $args{yacc};
    return \%args;
}

sub print_help {
    my $argsref = shift;
    print <<"EOT";
$argsref->{script}

General Options:

   --help               Show this text
   --verbose            Output extra information
   --step=(gen::languages)
                        Execute a single configure step
   --languages="list of languages"
                        Specify a list of languages to process

   --ask                Have Configure ask for commonly-changed info

Compile Options:

   --debugging=0        Disable debugging, default = 1
   --lex=(lexer)        Use the given lexical analyzer generator
   --yacc=(parser)      Use the given parser generator
EOT
    return 1;
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
