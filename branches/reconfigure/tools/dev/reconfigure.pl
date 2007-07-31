#! perl
use 5.008_000;
use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Indent = 1;
use lib 'lib';

use Parrot::BuildUtil;
use Parrot::Configure;
use Parrot::Configure::Options qw( process_options );
use Parrot::Configure::Step::List qw( get_steps_list );

# So far, I'm only permitting one option:  --step=some::step
# What other options should be permitted?
# Well, one obvious choice is --ask, because without it you can't get any of
# the inter::* steps to stop and prompt you for an answer.
# And that leads to --verbose and --verbose-step.

my $parrot_version = Parrot::BuildUtil::parrot_version();
$| = 1; # $OUTPUT_AUTOFLUSH = 1;
my $args = process_options( {
    argv            => [ $ARGV[0] ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );
exit(1) unless defined $args;

my $conf = Parrot::Configure->new;
$conf->add_steps(get_steps_list());
$conf->options->set(%{$args});

if ( exists $args->{step} ) {
    $conf->data()->slurp();
    $conf->data()->slurp_temp()
        if $args->{step} =~ /gen::makefiles/;
    $conf->run_single_step( $args->{step} );
    print "\n";
    exit(0);
}
else {
    warn "tools/dev/reconfigure.pl only handles re-running of configuration steps (--step option)";
    exit(1)
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

