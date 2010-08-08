#! perl
# Copyright (C) 2006-2010, Parrot Foundation.
# $Id$

use strict;
use warnings;

use lib qw( . lib ../lib ../../lib );
use Test::More;
use Parrot::Config qw(%PConfig);
use Parrot::Distribution;
use Parrot::Headerizer;
use Data::Dumper;$Data::Dumper::Indent=1;

=head1 NAME

t/codingstd/pmc_docs.t - checks for missing function documentation

=head1 SYNOPSIS

    # test all files
    % prove t/codingstd/pmc_docs.t

    # test specific files
    % perl t/codingstd/pmc_docs.t src/foo.pmc src/bar.pmc

=head1 DESCRIPTION

Checks that all PMC source files have documentation for each function
declared.

=cut

my $DIST = Parrot::Distribution->new;
my $headerizer = Parrot::Headerizer->new;

my @files = @ARGV ? @ARGV :
    map {s/^$PConfig{build_dir}\///; $_}
    map {s/\\/\//g; $_}
    map {$_->path} $DIST->pmc_source_files();

#print STDERR Dumper \@files;
#print STDERR "Found ", scalar @files, " .pmc files\n";

plan tests => scalar @files;

my %todos;
while (<DATA>) {
    next if /^#/;
    next if /^\s*$/;
    chomp;
    $todos{$_} = 1;
}

foreach my $path (@files) {
    my $buf = $DIST->slurp($path);
    my @function_decls = $headerizer->extract_function_declarations($buf);
    my @missing_docs;

    for my $function_decl (@function_decls) {

        my $escaped_decl = $headerizer->generate_documentation_signature($function_decl);

        my $missing = '';
        if ( $buf =~ m/^\Q$escaped_decl\E$(.*?)^=cut/sm ) {
            my $docs = $1;
            $docs =~ s/\s//g;
            if ($docs eq '') {
                $missing = 'boilerplate only';
            }
            # else:  docs!
        }
        else {
            $missing = 'missing';
        }
        if ($missing) {
            if ($missing eq 'boilerplate only') {
                push @missing_docs, "$path ($missing)\nIn:\n$escaped_decl\n";
            }
            else {
                push @missing_docs, "$path ($missing)\n$function_decl\nWant:\n$escaped_decl\n";
            }
        }
    }

    TODO: {
        local $TODO = 'Missing function docs' if $todos{$path};

    ok ( ! @missing_docs, $path)
        or diag( @missing_docs
            . " function(s) lacking documentation:\n"
            . join ("\n", @missing_docs, "\n"));
    }
}

__DATA__
src/dynpmc/rational.pmc
src/pmc/bigint.pmc
src/pmc/bignum.pmc
src/pmc/callcontext.pmc
src/pmc/class.pmc
src/pmc/complex.pmc
src/pmc/coroutine.pmc
src/pmc/eval.pmc
src/pmc/fixedintegerarray.pmc
src/pmc/hashiterator.pmc
src/pmc/imageio.pmc
src/pmc/imageiosize.pmc
src/pmc/integer.pmc
src/pmc/namespace.pmc
src/pmc/nci.pmc
src/pmc/null.pmc
src/pmc/object.pmc
src/pmc/orderedhash.pmc
src/pmc/packfile.pmc
src/pmc/role.pmc
src/pmc/sub.pmc
src/pmc/threadinterpreter.pmc
src/pmc/unmanagedstruct.pmc

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
