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
# And that leads to --verbose (but not to --verbose-step, because that
# specifies a particular step number as distinct from all others; here we only
# have one step).
# Probably should have a --help option distinct from that of Configure.pl.

my $parrot_version = Parrot::BuildUtil::parrot_version();
$| = 1; # $OUTPUT_AUTOFLUSH = 1;
my $args = process_options( {
    argv            => [ $ARGV[0] ],
    script          => $0,
    parrot_version  => $parrot_version,
    svnid           => '$Id$',
} );
exit(1) unless defined $args;

# To what extent do we need the next 3 lines?
# Why do we need a *new* Parrot::Configure object?
# After all, we're going to slurp in the results of processing the previous
# Parrot::Configure object.
my $conf = Parrot::Configure->new;
# Why would we need to add the full steps list?
$conf->add_steps(get_steps_list());
# Which options might make it this far and so possibly be set in the new P::C
# object?  (--ask and --verbose and perhaps --step)
$conf->options->set(%{$args});

# In this script, we would presumably know before this point whether or not
# $args->{step} existed or not.  So we can refactor this 'if' block.
if ( exists $args->{step} ) {
    # Study Parrot::Configure::Data::slurp() and slurp_temp() to see where
    # they write/overwrite data in the new P::C object with data from the old
    # one.
    $conf->data()->slurp();
    $conf->data()->slurp_temp()
        if $args->{step} =~ /gen::makefiles/;
    # To what extent *must* run_single_step be a P::C *method*.  Would it be
    # possible for it to be a function exported by some module and imported by
    # both P::C and whatever package the guts of this script will end up?
    $conf->run_single_step( $args->{step} );
    print "\n";
    exit(0);
}
# See above.  This warn-and-exit-failing should appear earlier, e.g., in the
# options processing.
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

