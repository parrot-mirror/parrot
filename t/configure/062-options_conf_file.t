#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 062-options_conf_file.t

use strict;
use warnings;
use Test::More tests =>  11;
use lib qw( lib );
use Parrot::Configure::Options ();
use Parrot::Configure::Options::Conf::File qw(
    @valid_options
    $script
    %options_components
    $parrot_version
    $svnid
);
use Parrot::Configure::Options::Conf::Shared qw(
    @shared_valid_options
);

my ($variables, $general, $substitutions);
my $data = {};;
my %valid_step_options;
my ($steps, $steps_list_ref);
my $cc;

$variables = <<END;
CC=/usr/bin/gcc
#CX=/usr/bin/g++

ABC=abc
END

$substitutions =
    Parrot::Configure::Options::Conf::File::_get_substitutions($variables);
is_deeply($substitutions,
    { CC => '/usr/bin/gcc', ABC => 'abc' },
    "Got expected substitutions"
);

$general = <<END;
cc=\$CC
this=will not=work
#abc=abc

verbose
verbose-step=init::hints
configure_trace
END

$data->{debugging} = 1;
$data->{maintainer} = undef;
%valid_step_options = map {$_ => 1} @shared_valid_options;
$data = Parrot::Configure::Options::Conf::File::_set_general(
    $data, $substitutions, $general, \%valid_step_options
);
$cc = q{/usr/bin/gcc};
is_deeply($data,
    {
        debugging       => 1,
        maintainer      => undef,
        cc              => $cc,
        verbose         => 1,
        configure_trace => 1,
        'verbose-step'  => 'init::hints',
    },
    "Got expected return value for _set_general()"
);

$steps = <<END;

init::manifest nomanicheck
init::defaults
auto::icu without-icu fatal-step

#auto::perldoc
END

($data, $steps_list_ref) = Parrot::Configure::Options::Conf::File::_set_steps(
    $data, $steps, \%valid_step_options);
is_deeply($data,
    {
        debugging       => 1,
        maintainer      => undef,
        cc              => $cc,
        verbose         => 1,
        configure_trace => 1,
        'verbose-step'  => 'init::hints',
        nomanicheck     => 1,
        'without-icu'   => 1,
        'fatal-step'    => 'auto::icu',
    },
    "Got expected return value for 'data' from _set_steps()"
);
is_deeply($steps_list_ref,
    [ qw( 
        init::manifest
        init::defaults
        auto::icu
    ) ],
    "Got expected list of configuration steps"
);

##### Test of bad variable for substitution

$variables = <<END;
#CC=/usr/bin/gcc
#CX=/usr/bin/g++

ABC=abc
END

$substitutions =
    Parrot::Configure::Options::Conf::File::_get_substitutions($variables);
$general = <<END;
cc=\$CC
this=will not=work
#abc=abc

verbose
verbose-step=init::hints
configure_trace
END

undef $data;
$data->{debugging} = 1;
$data->{maintainer} = undef;
$data->{file} = q{Configure.pl};
%valid_step_options = map {$_ => 1} @shared_valid_options;
eval { $data = Parrot::Configure::Options::Conf::File::_set_general(
    $data, $substitutions, $general, \%valid_step_options
); };
like($@, qr/Bad variable substitution in $data->{file}/,
    "Got expected message when _set_general() died:  bad substitution");
$data = {};

##### Test of bad entry in 'general' section

$variables = <<END;
CC=/usr/bin/gcc
#CX=/usr/bin/g++

ABC=abc
END

$substitutions =
    Parrot::Configure::Options::Conf::File::_get_substitutions($variables);
$general = <<END;
cc=\$CC
this=will not=work
#abc=abc

verbose
verbose-step=init::hints
configure_trace
dizzy
END

$data->{debugging} = 1;
$data->{maintainer} = undef;
$data->{file} = q{Configure.pl};
%valid_step_options = map {$_ => 1} @shared_valid_options;
eval {
    $data = Parrot::Configure::Options::Conf::File::_set_general(
        $data, $substitutions, $general, \%valid_step_options
    );
};
like($@, qr/Invalid general option dizzy in $data->{file}/,
    "Got expected message when _set_general() died:  bad 'general' entry");

##### Test of bad option

$variables = <<END;
CC=/usr/bin/gcc
#CX=/usr/bin/g++

ABC=abc
END

$substitutions =
    Parrot::Configure::Options::Conf::File::_get_substitutions($variables);
$general = <<END;
cc=\$CC
this=will not=work
#abc=abc

verbose
verbose-step=init::hints
configure_trace
END

$data->{debugging} = 1;
$data->{maintainer} = undef;
$data->{file} = q{Configure.pl};
%valid_step_options = map {$_ => 1} @shared_valid_options;
$data = Parrot::Configure::Options::Conf::File::_set_general(
    $data, $substitutions, $general, \%valid_step_options
);

$steps = <<END;

init::manifest nomanicheck
init::defaults
auto::icu without-icu fatal-step
auto::gmp dizzy=like-a-fox

#auto::perldoc
END

eval {
    ($data, $steps_list_ref) =
        Parrot::Configure::Options::Conf::File::_set_steps(
            $data, $steps, \%valid_step_options);
};
like($@, qr/dizzy/, "Invalid option correctly detected during _set_steps()");

########## Overall tests of conditional_assignments() ##########

{
    # hisfoobar expected to fail due to lack of ==cut 
    my $args = {
        mode => 'file',
        argv => [ q{--file=t/configure/testlib/hisfoobar} ],
    };
    my ($options_components, $script);
    ($args, $options_components, $script) =
        Parrot::Configure::Options::_process_options_components($args);
    
    my ($data, $short_circuits_seen_ref) =
        Parrot::Configure::Options::_initial_pass(
            $args, $options_components, $script
        );
   
    my $steps_list_ref;
    eval {
        ($data, $steps_list_ref) =
            &{ $options_components->{conditionals} }($data);
    };
    like($@, qr/Configuration file $data->{file} did not parse correctly/,
        "Got expected die message for options_components()");
}

{
    # herfoobar expected to succeed
    my $args = {
        mode => 'file',
        argv => [ q{--file=t/configure/testlib/herfoobar} ],
    };
    my ($options_components, $script);
    ($args, $options_components, $script) =
        Parrot::Configure::Options::_process_options_components($args);
    
    my ($data, $short_circuits_seen_ref) =
        Parrot::Configure::Options::_initial_pass(
            $args, $options_components, $script
        );
   
    my $steps_list_ref;
    ($data, $steps_list_ref) =
        &{ $options_components->{conditionals} }($data);
    is_deeply($data, {
        'link' => '/usr/bin/g++',
        'maintainer' => undef,
        'cxx' => '/usr/bin/g++',
        'nomanicheck' => 1,
        'file' => 't/configure/testlib/herfoobar',
        'debugging' => 1,
        'cc' => '/usr/bin/gcc',
        'verbose-step' => 'init::hints',
        'ld' => '/usr/bin/g++'
      }, "Got expected configuration data");

    is(scalar(@{ $steps_list_ref }), 66,
        "Got expected number of configuration steps");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

062-options_conf_file.t - test Parrot::Configure::Options::Test

=head1 SYNOPSIS

    % prove t/configure/062-options_conf_file.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test Parrot::Configure::Options::Conf::File
subroutines.

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, Parrot::Configure::Options::Conf::File,
F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
