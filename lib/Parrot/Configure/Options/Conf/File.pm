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
use Data::Dumper;$Data::Dumper::Indent = 1;
use File::Spec;
use lib qw( lib );
use Parrot::BuildUtil;
use Parrot::Configure::Options::Conf qw(
    $script
    $parrot_version
    $svnid
    print_help
    print_version
);
use Parrot::Configure::Options::Conf::Shared qw(
    @shared_valid_options
);

our @valid_options = qw{
    help
    file
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
    my %valid_step_options = map {$_ => 1} @shared_valid_options;
    my $file_str = Parrot::BuildUtil::slurp_file($data->{file});
    my $steps_list_ref;
    if ($file_str =~ m/==variables\s*?\n
        (.*?)
        \s*\n
        ==general\s*?\n
        (.*?)
        \s*\n
        ==steps\s*?\n
        (.*?)
        \s*\n
        ==cut
        /sx ) {
        my ($variables, $general, $steps) = ($1,$2,$3);
        my $substitutions = _get_substitutions($variables);
        $data = _set_general($data, $substitutions, $general,
            \%valid_step_options);
        ($data, $steps_list_ref) =
            _set_steps($data, $steps, \%valid_step_options);
    }
    else {
        die "Configuration file $data->{file} did not parse correctly: $!";
    }
    return ($data, $steps_list_ref);;
}

sub _get_substitutions {
    my $variables = shift;
    my @variables = split /\n/, $variables;
    my %substitutions;
    foreach my $v (@variables) {
        next unless $v =~ m/^(\w+)=([^=]+)$/;
        my ($k, $v) = ($1, $2);
        $substitutions{$k} = $v;
    }
    return \%substitutions;
}

sub _set_general {
    my ($data, $substitutions, $general, $optsref) = @_;
    my @general = split /\n/, $general;
    foreach my $g (@general) {
        next unless $g =~ m/^(\w+)=(\$?[^\s\$]+)$/;
        my ($k, $v, $prov, $var);
        ($k, $prov) = ($1, $2);
        if ($prov =~ m/^\$(.+)/) {
            $var = $1;
            if ($substitutions->{$var}) {
                $v = $substitutions->{$var};
            }
            else {
                die "Bad variable substitution in $data->{file}: $!";
            }
        }
        else {
            $v = $prov;
        }
        if (! $optsref->{$k}) {
            die "Invalid general option $k in $data->{file}: $!";
        }
        else {
            $data->{$k} = $v;
        }
    }
    return $data;
}

sub _set_steps {
    my ($data, $steps, $optsref) = @_;;
    my @steplines = split /\n/, $steps;
    my @steps_list = ();
    LINE: foreach my $line (@steplines) {
        next unless ($line =~ /^(\w+::\w+)(?:\s+(\S+\s+)*(\S+))?$/);
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
                die "Unable to process key $key in step $step in configuration data file $data->{file}: $!"
            }
            unless ( $optsref->{$key} ) {
                die qq/Invalid option "$key". See "perl Configure.pl --help" for options valid within a configuration file\n/;
            }
            # This will have to be fixed to allow for possibility that >1 step
            # might be declared a verbose-step or a fatal-step.
            $value = $step if $key eq 'verbose-step';
            $value = $step if $key eq 'fatal-step';
            $value = 1 unless defined $value;
            $data->{$key} = $value;
        }
    }
    return ($data, \@steps_list);
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
