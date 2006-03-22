package t::APL;

use Test::Base -Base;
use Parrot::Config;
use Parrot::Test;

our @EXPORT = qw(run_apl_is);

BEGIN {
  # APL *really* needs unicode to function, bail out if we don't have it.
  if (!$PConfig{has_icu}) {
    plan skip_all => "No unicode library available.";
    exit 0;
  }
}

filters {
  output => qw/ chomp /
};


# Note - we don't just use the special SKIP entry in the DATA stream because
# it doesn't actually output the skipped test in the TAP output. It just
# fails to run the test.

sub run_apl_is() {
  foreach my $block (blocks) {
    my $apl    = $block->APL;
    my $output = $block->out;
    my $skip   = $block->skip;
    SKIP: {
      skip($skip, 1) if $skip;
      Parrot::Test::language_output_is('APL', $apl, $output, $block->name);
    }
  }
}
