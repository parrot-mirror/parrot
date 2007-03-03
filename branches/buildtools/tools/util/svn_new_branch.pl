#! perl
# Copyright (C) 2001-2004, The Perl Foundation.
# $Id$
use strict;
use warnings;
use lib ("lib");
use Parrot::Subversion::BranchManager qw( create_new_branch );

die "Must supply name of branch to be created as command-line argument"
    unless (@ARGV == 1);
    
my $branch = shift(@ARGV);

create_new_branch( {
    standard  => qq{https://svn.perl.org/parrot},
    branch    => $branch,
    verbose   => 1,
} );

exit 0;

################### DOCUMENTATION ###################

=head1 NAME

svn_new_branch.pl - Create new branch in Parrot repository

=head1 SYNOPSIS

From the top-level directory in your Parrot sandbox:

    perl tools/util/svn_new_branch.pl my_branch_name

=head1 DESCRIPTION

This program creates a new branch in the Parrot repository under
F<https://svn.perl.org/parrot/branches/>.  It also creates a new tag in the
Parrot repository under F<https://svn.perl.org/parrot/tags/>.  The tag is used
by a companion program F<tools/util/svn_synch.pl>.

The program takes one command-line argument:  the name you have chosen for
your new branch.  It then invokes 
F<Parrot::Subversion::BranchManager::create_new_branch()> to
create the new branch and corresponding tag.

=head2 Last Tag File

This program places a hidden file under your
home directory containing the revision number of the HEAD in the Parrot
repository at the time the branch was created.  Don't delete it, as its
companion program, F<svn_synch.pl>, needs to read and update that file 
to work properly.

=head1 REQUIREMENTS

Needless to say, you have to have Subversion installed on your system to use
this program.  Since it writes to the Parrot repository, you will need commit
privileges as well.

=head1 AUTHOR

James E Keenan (jkeenan@cpan.org)

=head1 SEE ALSO

F<tools/util/svn_synch.pl>.  Parrot::Subversion::BranchManager.
F<docs/svn_branching.pod>.

=cut
