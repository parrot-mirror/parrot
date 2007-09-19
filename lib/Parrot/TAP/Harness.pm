package Parrot::TAP::Harness;

use warnings;
use strict;

=head1 NAME

Parrot::TAP::Harness - a TAP::Harness subclass

=head1 USAGE

  runtests --harness Parrot::TAP::Harness -r t languages/

Actually, it is called 'prove' now, but you'll probably want a runtests
symlink until things settle-down a bit.

=head1 ABOUT

This is a first-crack with input from Colin Kuskie and Allison Randal.
Many things still need to happen on both the TAP::Harness and parrot
fronts.

Contact Eric Wilhelm and/or the TAP::Parser mailing list with questions.

=head1 TAP::Harness/Test::Harness

TAP::Harness is replacing Test::Harness.  At this point, simply using
the new version of Test::Harness may not work, so download the tree,
delete lib/Test/Harness.pm, rename bin/prove to bin/runtests, then
install.

=for staleness guard
  Mon Sep 03, 2007

=begin Overview

=head1 How to run the tests?

Answer:  shebang line

=head1 What tests to run?

The logic of which tests to run is quite spread-out at the moment.
Further, it is not clear whether a no-run test is omitted because of a
limitation of the harness or a genuine (too slow, not done, etc) reason.

Still needs an implementation detail.  Might involve something like
calling each harness with --files argument (though that seems to not
work from the root atm.)

Ultimately, parrot should work toward organizing tests in such a way
that collecting information on what to run/not-run is unnecessary.

=head1 What *not* to run?

The --files scheme is a whitelist, should there be a blacklist?

=head1 Where am I?

The "current directory" thing is an issue for parrot in general, but
currently a trouble spot for this .pm file in particular.

=end Overview

=begin observations

=head1 t/harness files

=head2 multiple vs single harness/summary

Each t/harness wants to be the one to call runtests().  This makes it
difficult to run all of the tests at once (and impossible (sort of) to
mix parrot/perl5 exec.)

Aside:  The perl 5 interpreter will run whatever is on the shebang line,
but this just leads to "unrecognized argument" when it tries to pass -I
and etc.  This is tempting, but unworkable in the long run.

=head3 spooling

A possible answer to the multiple-harnesses issue is the
PERL_TEST_HARNESS_DUMP_TAP environment variable.  We could run all of
the tests with each t/harness, then re-aggregate them all together from
the raw tap in the spool directory.

With the Test::Harness 2.99_01 code, this will work with no
modifications.

=head2 --files arguments

That might still be useful, and should maybe be supported everywhere
(plus without too much $PWD assumption.)

E.g. t/harness

  my $print_files = grep { $_ eq '--files' } @ARGV;
  @ARGV = grep { $_ ne '--files' } @ARGV;
  ...
  if($print_files) {
      print join("\n", @tests), "\n";
      exit;
  }

=head2 languages/t/harness

This does not use Parrot::Test::Harness::runtests(), and therefore
cannot run multiple interpreters.

=head2 --gc-debug

TEST_PROG_ARGS is not HARNESS_PERL_SWITCHES.  This means subprocess
parrot runs see the --gc-debug, but not *.t files which are run as
`parrot ... foo.t`.

=end observations

=begin notes

=head1 Caveats

=head2 @INC for --harness

This file has to live in './Parrot/TAP/Harness.pm'.  Parrot should
probably just have their own runtests file, but the TAP::Harness 'prove'
is not subclassable (yet.)

=head2 --archive option not working

That is a TAP::Harness API bug.  TAP::Harness::Archive also wants to be
a TAP::Harness subclass (well, *the* TAP::Harness subclass.)  We also
want to be that subclass.  This ends in @ISA jealousy, spite, etc.

=head2 what tests?

Unless every .t file is 'ok to test', straight '-r t' usage will break.

One possibile workaround, but kind of ugly:

  prove --harness Parrot::TAP::Harness \
    $(perl t/harness --files) \
    $(perl languages/t/harness --files) \
    $(perl languages/perl6/t/harness --files)

=head2 Shebang .pbc

This allows sloppy shebang lines, and probably should not.

=end notes

=begin recommendations

Here's roughly what we decided parrot should work toward.  It is of
course weighted by "what Eric thinks" and "what Eric does not know yet."

=head1 Consistent Shebang Lines

The shebang should always be "#!parrot" for pir, and the bare pbc name
for any hosted language (e.g. "#!perl6".)

Aside: this forces the issue of how 'parrot' switches (-G) are ferried
across from the compiler.

=head1 Organized Tests

Either all of the tests (recursively) in any t/ are always run or
something declarative should be extracted from the --files thing (or
the --files thing should be made more robust and consistent.)

Secondary and 'meta' tests should probably just find a home in
xt/standards, xt/exhaustive, etc.  Adding flags to a custom prove could
easily support this (see also:  TAP::Parser is probably heading this
direction anyway.)

=head1 Solve $PWD Issues

These need to be solved both on the TAP::Harness front (WRT subclassing)
and in the parrot .t files.

=end recommendations

=cut

use base 'TAP::Harness';

my $parrot = './parrot'; # TODO pick a parrot

# This gets called just before running each test.  The return value gets
# handed to a TAP::Parser->new().  Private -- yeah...whatever.
sub _get_parser_args {
  my ( $self, $test ) = @_;
  
  open(my $fh, '<', $test) or die "cannot read '$test' $!";
  chomp(my $shebang = <$fh>);
  $shebang =~ s/^#!\s*//;
  my @shparts = split(/\s+/, $shebang);

  my $args = $self->SUPER::_get_parser_args($test);

  unless($shparts[0] eq 'perl') {
    warn "shebang @shparts\n";
    # the compiler is either a pbc (currently with or without the .pbc)
    # or just parrot -- straight pir
    my $compiler = shift(@shparts);
    if($compiler !~ m#(?:.*/)?parrot#) {
      $compiler =~ s/(?:\.pbc)?$/.pbc/;
      unshift(@shparts, $compiler);
    }

    #warn "shebang @shparts";
    # TODO interpreter-specific and/or parrot specific options
    $args->{exec} = [$parrot, @shparts, $test];
    delete($args->{source});
  }

  return($args);
}

# vim:ts=2:sw=2:et:sta
