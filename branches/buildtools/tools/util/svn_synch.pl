#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
use strict;
use warnings;
use Getopt::Long;
use lib ("lib");
use Parrot::VersionControl::Subversion::BranchManager qw(
    synch_branch_to_trunk
);

my ($branch, $sandbox);

GetOptions(
    "branch=s" => \$branch,
    "sandbox=s" => \$sandbox,
);
die "Must supply name of branch you are working with to '--branch' option"
    unless $branch;
die "Must supply absolute path to your sandbox directory to '--sandbox' option"
    unless $sandbox;

synch_branch_to_trunk( {
    standard    => qq{https://svn.perl.org/parrot},
    branch      => $branch,
    sandbox     => $sandbox,
    verbose     => 1,
} );

exit 0;

################### DOCUMENTATION ###################

=head1 NAME

svn_synch.pl - Synchronize Parrot branch to trunk

=head1 SYNOPSIS

From the top-level directory in your Parrot sandbox:

    perl tools/util/svn_synch.pl \
        --branch=my_branch \
        --sandbox=/home/username/path/to/parrot/sandbox

Then:  resolve any conflicts and commit:

    svn resolved fileA
    svn resolved fileB

    svn commit

=head1 DESCRIPTION

Use this program if you are managing development in a new branch in the Parrot 
repository which you created with its companion program
F<tools/util/svn_new_branch.pl>.

In addition to creating a new branch in the Parrot repository,
F<svn_new_branch.pl> creates a tag whose name follows the pattern
C<my_branch-NNNNN>, where C<NNNNN> is the Subversion revision number at
the point where the branch was created.

This program, F<svn_synch.pl>, makes use of the presence of that tag to help
you keep your branch in synch with the Parrot trunk.  You develop in a branch
to make sure your development doesn't break anything in trunk -- but from
time-to-time you also want to make sure that your branch gets the latest
versions of files recently committed to trunk.  F<svn_synch.pl> updates your
local sandbox directory for the branch with those updated files.  It is then
up to you to resolve conflicts and do an F<svn commit> to actually update the
branch in the Parrot repository.

=head2 Arguments

Two command-line arguments specified in long-option format:

=over 4

=item * C<--branch>

The name of the branch in the Parrot repository you created with
F<svn_new_branch.pl>.

=item * C<--sandbox>

The absolute path to the directory on your system which you are using for your
ongoing development of the branch.

=back

=head2 Last Tag File

The companion program, F<svn_new_branch.pl>, places a hidden file under your
home directory containing the revision number of the HEAD in the Parrot
repository at the time the branch was created.  Don't delete it, as this
program needs to read and update that file to work properly.

=head1 REQUIREMENTS

Needless to say, you have to have Subversion installed on your system to use
this program.  Since it writes to the Parrot repository, you will need commit
privileges as well.

=head1 AUTHOR

James E Keenan (jkeenan@cpan.org)

=head1 SEE ALSO

F<tools/util/svn_new_branch.pl>.  
Parrot::VersionControl::Subversion::BranchManager.
F<docs/svn_branching.pod>.

=cut
