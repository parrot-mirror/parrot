# Copyright (C) 2007, The Perl Foundation.
# $Id$
package Parrot::Subversion::BranchManager;
use strict;
our (@ISA, @EXPORT_OK);
@ISA = qw( Exporter );
@EXPORT_OK = qw( create_new_branch synch_branch_to_trunk );
use Carp;
use LWP::Simple qw(get);
use File::Save::Home qw( get_home_directory );

=head1 NAME

Parrot::Subversion::BranchManager - tools for best use of Subversion branches

=head1 SYNOPSIS

    use lib ("lib");
    use Parrot::Subversion::BranchManager qw(
        create_new_branch
        synch_branch_to_trunk
    );

    create_new_branch( {
        standard  => qq{https://svn.perl.org/parrot},
        branch    => q{my_new_branch},
        verbose   => 1,
    } );

    synch_branch_to_trunk( {
    } );

=head1 EXPORTED SUBROUTINES

=head2 C<create_new_branch()>

=over 4

=item * B<Purpose:>

Create a new branch in the Parrot repository, the create a new tag in the
repository to facilitate later synchronization of that branch with the trunk.

=item * B<Arguments:>  Reference to has with the following key-value pairs:

=over 4

=item *  C<standard>

String hard-coded to C<https://svn.perl.org/parrot>.

(Key is called C<standard> to indicate that this is a repository structured in
the standard Subversion manner, I<i.e.>, with directories called F<trunk/>,
F<branches>, and F<tags> underneath the top-level directory.  In the future a
more generalized version of this package will handle repositories structured
in a non-standard manner.)

=item *  C<branch>

String holding the name you have selected for your new branch.

=item *  C<verbose>

C<print>s useful statements to F<STDOUT> as subroutine runs.  Optional, but
recommended.

=back

=item * B<Return Value:>

Returns C<1> upon success.  If it fails at any internal point, will C<croak>
with appropriate error message.

=item * B<Comments:>  

=over 4

=item * 

Called by F<tools/util/svn_new_branch.pl> with C<verbose> turned on.

=item * 

The subroutine checks to make sure that the repository currently has no 
branch by that name.

=item * 

The subroutine also creates a tag in the Parrot repository whose name combines
the name you selected for the branch and the revision number of the
repository's HEAD at the time of creation.  Example:  If you select C<kelvin>
as the name for your branch and the HEAD at the time of creation is at
revision C<17261>, you will create a tag called F<kelvin-17261>.  This tag
will be used by subroutine F<synch_branch_to_trunk()>.

=back

=back

=cut

sub create_new_branch {
    my $argsref = shift;
    my $repository = $argsref->{standard};
    my $branch = $argsref->{branch};
    my $verbose = $argsref->{verbose};
    my %repos;
    foreach my $d ( qw| trunk branches tags |) {
        $repos{$d} = qq{$repository/$d};
    }

    # Prior to creating a new branch, I want to make sure that:
    # (a) a branch of that name does not already exist in the repository;
    # (b) I don't have a hidden tagfile in my home directory named after 
    # that branch.

    # (a)
    croak "Branch $branch already exists in $repos{branches}: $!"
        if defined(get(qq{$repos{branches}/$branch/}));

    # (b)
    my $tagfile = qq{.$branch.tag};
    my $homedir = get_home_directory();
    my $tagfilepath = qq{$homedir/$tagfile};
    croak "You already have a hidden file named $tagfile in directory $homedir: $!"
        if -f $tagfilepath;

    my $HEAD = get_HEAD_number(qq{$repository/});

    print "HEAD in trunk is now:  $HEAD\n" if $verbose;

    my $msg = qq{Creating $branch in $repos{branches}};

    system(qq{svn copy "$repos{trunk}" "$repos{branches}/$branch" --message "$msg"} )
        and croak "Unable to create new branch $branch: $!"; #"

    print "$branch branch has been created in $repos{branches}\n" if $verbose;

    $msg =
        qq{Tagging trunk at r$HEAD so that the $branch can later be synched to it.};

    system(qq{svn copy "$repos{trunk}" "$repos{tags}/$branch-$HEAD" --message "$msg"})
         and croak "Unable to create tag for r$HEAD: $!"; #"

    print "$branch-$HEAD tag has been created\n"
        if $verbose;

    update_tagfile($tagfilepath, $HEAD);

    print "Finished\n" if $verbose;
    return 1;
}

=head2 C<synch_branch_to_trunk()>

=over 4

=item * B<Purpose:>

=item * B<Arguments:>

=over 4

=item *  C<standard>

String hard-coded to C<https://svn.perl.org/parrot>.

=item *  C<branch>

String holding the name of the branch you are managing in the Parrot
repository.

=item * C<sandbox>

String holding the absolute path to the directory on your system which you are
using for ongoing development of the branch.

=item *  C<verbose>

C<print>s useful statements to F<STDOUT> as subroutine runs.  Optional, but
recommended.

=back

=item * B<Return Value:>

Returns C<1> upon success.  If it fails at any internal point, will C<croak>
with appropriate error message.

=item * B<Comment:>

=back

=cut

sub synch_branch_to_trunk {
    my $argsref = shift;
    my $repository = $argsref->{standard};
    my $branch = $argsref->{branch};
    my $verbose = $argsref->{verbose};
    my $sandbox = $argsref->{sandbox};

    my %repos;
    foreach my $d ( qw| trunk branches tags |) {
        $repos{$d} = qq{$repository/$d};
    }
    my $tagfile = qq{.$branch.tag};
    my $homedir = get_home_directory();
    my $tagfilepath = qq{$homedir/$tagfile};
    croak "Cannot locate a hidden file named $tagfile in your home directory"
        unless -f $tagfilepath;

    chdir $sandbox or croak "Unable to change to $sandbox";

    open my $IN, $tagfilepath
        or croak "Unable to open $tagfilepath for reading: $!";
    my $lasttag;
    chomp($lasttag = <$IN>);
    close $IN or croak "Unable to close $tagfilepath after reading: $!";

    print "Last tag I recorded:  $lasttag\n" if $verbose;

    croak "Cannot locate tag $repos{tags}/$branch-$lasttag/: $!"
        unless defined(get(qq{$repos{tags}/$branch-$lasttag/}));

    my $HEAD = get_HEAD_number(qq{$repository/});
    print "HEAD in trunk is now:  $HEAD\n" if $verbose;

    my $msg =
        qq{Tagging trunk at r$HEAD so that the $branch can be synched to it.};

    system(qq{svn copy "$repos{trunk}" "$repos{tags}/$branch-$HEAD" --message "$msg"})
         and croak "Unable to create tag for r$HEAD: $!"; #"

    print "$branch-$HEAD tag has been created\n" if $verbose;

    system(qq{svn merge $repos{tags}/$branch-$lasttag $repos{tags}/$branch-$HEAD $sandbox})
        and croak "Unable to create tag for r$HEAD: $!";

    print "Sandbox for $branch branch has been updated by merging in head of trunk\n"
        if $verbose;

    $msg = qq{Deleting superfluous tag $branch-$lasttag};

    system(qq{svn delete "$repos{tags}/$branch-$lasttag" --message "$msg"})
        and croak "Unable to delete superfluous tag $branch-$lasttag"; #"

    print "$branch-$lasttag tag has been deleted from Parrot repository.\n"
        if $verbose;

    update_tagfile($tagfilepath, $HEAD);

    print "Finished\n" if $verbose;
    return 1;
}

################### AUXILIARY SUBROUTINES  ###################

sub get_HEAD_number {
    my $URL = shift;
    my $HEAD;
    my @headlog = `svn log --revision HEAD $URL`;
    foreach my $l (@headlog) {
        next unless ($l =~ /^r(\d+)\b/);
        $HEAD = $1;
        last;
    }
    return $HEAD;
}

sub update_tagfile {
    my ($tagfilepath, $HEAD) = @_;
    open my $OUT, ">$tagfilepath"
        or croak "Unable to open $tagfilepath for writing: $!";
    print $OUT $HEAD;
    close $OUT or croak "Unable to close $tagfilepath after writing: $!";
}

=head1 PREREQUISITES

=head2 CPAN Modules

Carp.  LWP::Simple.  File::Save::Home.

=head2 Outside Programs

Subversion.

=head2 Permissions

Commit privileges to F<https://svn.perl.org/parrot/>.

=head1 BUGS AND LIMITATIONS

This module does not yet have its own unit tests.  To write those tests, I'd
first have to test for the presence of Subversion on a user's system.  That's
also the reason I haven't yet submitted this module to CPAN.  However, I have
used it to manage actual branches in the Parrot repository.

This module is a hack which uses various F<svn> commands to get information
about the Parrot repository, such as the revision number of the HEAD.  There
are probably better ways to do this.  Patches welcome.

=head1 AUTHOR

James E Keenan (jkeenan@cpan.org).

=head1 SEE ALSO

F<tools/util/svn_new_branch.pl>.
F<tools/util/svn_synch.pl>.
F<docs/svn_branching.pod>.

=cut

1;
