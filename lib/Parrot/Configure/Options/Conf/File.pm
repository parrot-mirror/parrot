# Copyright (C) 2007-2008, The Perl Foundation.
# $Id$
package Parrot::Configure::Options::Conf::File;

use strict;
use warnings;
use base qw( Exporter );
our @EXPORT_OK = qw(
    @valid_options
    $script
    %options_components
    $parrot_version
    $svnid
);
use lib qw( lib );
use Parrot::Configure::Options::Conf qw(
    $script
    $parrot_version
    $svnid
    print_help
    print_version
);

our @valid_options = qw{
    help
    script
    test
    version
};

my %short_circuits = (
    help    => \&print_help,
    version => \&print_version,
);

our %options_components = (
    'valid_options'  => \@valid_options,
    'script'         => $script,
    'short_circuits' => \%short_circuits,
    'conditionals'   => \&conditional_assignments,
);

sub conditional_assignments {
    my $data = shift;
    $data->{debugging} = 1;
    $data->{maintainer} = undef;
#print STDERR $data->{script}, "\n";
    open my $IN, '<', $data->{script}
        or die "Unable to open configuration data file $data->{script} for reading: $!";
    my @steps_list = ();
    LINE: while ( my $line = <$IN> ) {
        chomp $line;
        next if $line =~ /^(\s*$|#)/o;
        if ($line =~ /^(\w+::\w+)(?:\s+(\S+\s+)*(\S+))?$/) {
            my $step = $1;
            push @steps_list, $step;
            next LINE unless $3;
            my $opts_string = $2 ? qq{$2$3} : $3;
            my @opts = split /\s+/, $opts_string;
            foreach my $el (@opts) {
                my ( $key, $value );
                if ($el =~ m/([-\w]+)(?:=(.*))?/) {
                    ( $key, $value ) = ($1, $2);
                }
                if (! defined $key) {
                    die "Unable to process key $key in step $step in configuration data file $data->{script}: $!"
                }
                # We'll have to check here for valid options, which now more
                # closely resemble those in Conf::CLI.
#        unless ( $valid_opts{$key} ) {
#            die qq/Invalid option "$key". See "perl $script --help" for valid options\n/;
#        }
                $value = 1 unless defined $value;
                $data->{$key} = $value;
            }
        }
    }
    close $IN
        or die "Unable to close configuration data file $data->{script} after reading: $!";
    return ($data, \@steps_list);;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
