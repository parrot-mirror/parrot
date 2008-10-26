#! perl
# Copyright (C) 2007, The Perl Foundation.
# $Id$
# 001-options.t

use strict;
use warnings;

BEGIN {
    use FindBin qw($Bin);
    use Cwd qw(cwd realpath);
    our $topdir = realpath($Bin) . "/../..";
    unshift @INC, qq{$topdir/lib};
}
use Test::More tests => 70;
use Carp;
use Parrot::Configure::Options qw| process_options |;
use Parrot::Configure::Options::Conf::CLI ();
use Parrot::Configure::Options::Conf::File ();
use Parrot::Configure::Options::Reconf ();
use IO::CaptureOutput qw| capture |;

my %valid;
my $badoption = q{samsonanddelilah};

no warnings 'once';
%valid = map { $_, 1 } @Parrot::Configure::Options::Conf::CLI::valid_options;
use warnings;
ok( scalar keys %valid,          "non-zero quantity of valid options found" );
ok( defined $valid{debugging},   "debugging option found" );
ok( defined $valid{maintainer},  "maintainer option found" );
ok( defined $valid{help},        "help option found" );
ok( defined $valid{version},     "version option found" );
ok( defined $valid{verbose},     "verbose option found" );
ok( !defined $valid{$badoption}, "invalid option not found" );
ok( !defined $valid{step},       "invalid 'step' option not found" );
ok( !defined $valid{target},     "invalid 'target' option not found" );

open my $FH, '<', "$main::topdir/Configure.pl"
    or croak "Unable to open handle to $main::topdir/Configure.pl:  $!";
my $bigstr;
{
    local $/ = undef;
    $bigstr = <$FH>;
}
close $FH or croak "Unable to close handle to Configure.pl:  $!";

# Ignore any POD I have moved to an __END__ block.
$bigstr =~ s/__END__.*//s;
my ( @lines, @possible_methods );
@lines = grep { /^=item/ } ( split /\n/, $bigstr );
foreach my $l (@lines) {
    my $method;
    if ( $l =~ /^=item C<--([-_\w]+)(?:[=>])/ ) {
        $method = $1;
        push @possible_methods, $method;
    }
}
my $invalid = 0;
foreach my $m (@possible_methods) {
    unless ( defined $valid{$m} ) {
        carp "Possibly invalid method: $m";
        $invalid++;
    }
}
ok( !$invalid, "No invalid methods described in POD" );

my ($args, $step_list_ref);
($args, $step_list_ref) = process_options(
    {
        argv => [],
        mode => q{configure},
    }
);
ok( defined $args, "process_options() returned successfully" );
ok( $args->{debugging}, "debugging turned on by default" );

eval { ($args, $step_list_ref) = process_options( { argv => [] } ); };
like(
    $@,
    qr/'mode' argument not provided to process_options\(\)/,
    "process_options() failed due to lack of argument 'mode'"
);

eval { ($args, $step_list_ref) = process_options( { argv => [], mode => 'foobar' } ); };
like(
    $@,
    qr/Invalid value for 'mode' argument to process_options\(\)/,
    "process_options() failed due to invalid 'mode' argument"
);

($args, $step_list_ref) = process_options(
    {
        mode => q{configure},
        ,
    }
);
ok( defined $args,
    "process_options() returned successfully even though no explicit 'argv' key was provided" );

my $CC = "/usr/bin/gcc-3.3";
my $CX = "/usr/bin/g++-3.3";
($args, $step_list_ref) = process_options(
    {
        argv => [
            q{--cc=$CC},      q{--cxx=$CX}, q{--link=$CX}, q{--ld=$CX},
            q{--without-icu}, q{--without-gmp},
        ],
        mode => q{configure},
    }
);
ok( defined $args,
    "process_options() returned successfully when options were specified" );

eval { ($args, $step_list_ref) = process_options( { argv => [qq<--${badoption}=72>], mode => q{configure}, } ); };
like(
    $@,
    qr/^Invalid option.*$badoption/,
    "process_options() failed due to bad option '$badoption'"
);

$badoption = q{step};
eval { ($args, $step_list_ref) = process_options( { argv => [qq<--${badoption}>], mode => q{configure}, } ); };
like(
    $@,
    qr/^Invalid option.*$badoption/,
    "process_options() failed due to bad option '$badoption'"
);

$badoption = q{target};
eval { ($args, $step_list_ref) = process_options( { argv => [qq<--${badoption}>], mode => q{configure}, } ); };
like(
    $@,
    qr/^Invalid option.*$badoption/,
    "process_options() failed due to bad option '$badoption'"
);

{
    my $stdout;
    $args = capture( sub { process_options(
        {
            argv => [q{--help}],
            mode => q{configure},
        }
    ) } , \$stdout);
    ok( !defined $args,
        "process_options() returned undef after 'help' option" );
    like( $stdout, qr/--help/i, "got correct message after 'help' option" );
}

{
    my $stdout;
    $args = capture( sub { process_options(
        {
            argv => [q{--}],
            mode => q{configure},
        }
    ) } , \$stdout);
    ok( !defined $args,
        "process_options() returned undef after '--' option triggered help message" );
    like( $stdout, qr/--help/i, "got help message as expected" );
}

{
    my $stdout;
    $args = capture( sub { process_options(
        {
            argv => [q{--version}],
            mode => q{configure},
        }
    ) } , \$stdout);
    ok( !defined $args,
        "process_options() returned undef after 'version' option" );
    like( $stdout, qr/Parrot Version/i,
        "got correct message after 'version' option" );
}

($args, $step_list_ref) = process_options(
    {
        argv => [ q{--lex}, ],
        mode => q{configure},
    }
);
ok( defined $args,
    "process_options() returned successfully after 'lex' option" );
ok( $args->{maintainer}, "'maintainer' attribute is true after 'lex' option" );

($args, $step_list_ref) = process_options(
    {
        argv => [ q{--yacc}, ],
        mode => q{configure},
    }
);
ok( defined $args,
    "process_options() returned successfully after 'yacc' option" );
ok( $args->{maintainer}, "'maintainer' attribute is true after 'yacc' option" );

($args, $step_list_ref) = process_options(
    {
        argv => [q{--debugging=1}],
        mode => q{configure},
    }
);
ok( defined $args, "process_options() returned successfully" );
ok( $args->{debugging}, "debugging turned on explicitly" );

($args, $step_list_ref) = process_options(
    {
        argv => [q{--debugging=0}],
        mode => q{configure},
    }
);
ok( defined $args, "process_options() returned successfully" );
ok( !$args->{debugging}, "debugging explicitly turned off" );

######### Parrot::Configure::Options internal subroutines #########

my ($options_components, $script);

$args = { argv => [], mode => 'configure' };
($args, $options_components, $script) =
    Parrot::Configure::Options::_process_options_components($args);
is_deeply($args->{argv}, [], "Got expected value for 'argv' element");
is_deeply($options_components,
    { %Parrot::Configure::Options::Conf::CLI::options_components },
    "Got expected value for options components");
is($script, q{Configure.pl}, "Got expected value for script");

$args = { argv => [], mode => 'reconfigure' };
($args, $options_components, $script) =
    Parrot::Configure::Options::_process_options_components($args);
is_deeply($args->{argv}, [], "Got expected value for 'argv' element");
is_deeply($options_components,
    { %Parrot::Configure::Options::Reconf::options_components },
    "Got expected value for options components");
is($script, q{tools/dev/reconfigure.pl}, "Got expected value for script");

$args = { argv => [], mode => 'file' };
($args, $options_components, $script) =
    Parrot::Configure::Options::_process_options_components($args);
is_deeply($args->{argv}, [], "Got expected value for 'argv' element");
is_deeply($options_components,
    { %Parrot::Configure::Options::Conf::File::options_components },
    "Got expected value for options components");
is($script, q{Configure.pl}, "Got expected value for script");

my $cc = q{/usr/bin/gcc};
$args = {
    argv => [ q{--verbose}, q{--help}, qq{--cc=$cc} ],
    mode => 'configure',
};
($args, $options_components, $script) =
    Parrot::Configure::Options::_process_options_components($args);
my ($data, $short_circuits_ref) =
    Parrot::Configure::Options::_initial_pass(
        $args, $options_components, $script);
is($data->{verbose}, 1, "Got expected value for verbose");
is($data->{help}, 1, "Got expected value for help");
is($data->{cc}, $cc, "Got expected value for cc");
is_deeply($short_circuits_ref, [ q{help} ],
    "Got expected short circuits");

$args = {
    argv => [ q{--verbose}, qq{--cc=$cc} ],
    mode => 'configure',
};
($args, $options_components, $script) =
    Parrot::Configure::Options::_process_options_components($args);
($data, $short_circuits_ref) =
    Parrot::Configure::Options::_initial_pass(
        $args, $options_components, $script);
is($data->{verbose}, 1, "Got expected value for verbose");
ok(! defined $data->{help}, "Got expected value for help");
is($data->{cc}, $cc, "Got expected value for cc");
is_deeply($short_circuits_ref, [ ],
    "Got expected short circuits");

{
    my $configfile = q{xconf/samples/testfoobar};
    local @ARGV = ( qq{--file=$configfile} );
    my ($args, $steps_list_ref) = process_options(
        {
            mode => (defined $ARGV[0]  and $ARGV[0] =~ /^--file=/)
                        ? 'file'
                        : 'configure',
            argv => [@ARGV],
        }
    );
    ok(! defined $args->{maintainer}, 
        "Configuring from testfoobar: 'maintainer' not defined, as expected");
    is($args->{'verbose-step'}, 'init::hints',
        "Configuring from testfoobar: 'init::hints' is verbose step");
    ok($args->{nomanicheck}, 
        "Configuring from testfoobar: will omit check of MANIFEST");
    is($args->{file}, $configfile,
        "Configuring from testfoobar: config file correctly stored");
    ok($args->{debugging}, 
        "Configuring from testfoobar: debugging turned on");
    my %steps_seen = map {$_ => 1} @{ $steps_list_ref };
    ok(exists $steps_seen{'init::manifest'},
        "Configuring from testfoobar: init::manifest is in list even though it will be skipped");
    ok(! exists $steps_seen{'auto::perldoc'},
        "Configuring from testfoobar: auto::perldoc not in list");
}

{
    my $configfile = q{xconf/samples/yourfoobar};
    local @ARGV = ( qq{--file=$configfile} );
    my ($args, $steps_list_ref) = process_options(
        {
            mode => (defined $ARGV[0]  and $ARGV[0] =~ /^--file=/)
                        ? 'file'
                        : 'configure',
            argv => [@ARGV],
        }
    );
    
    my $c_compiler = '/usr/bin/gcc';
    my $cplusplus_compiler = '/usr/bin/g++';
    ok(! defined $args->{maintainer}, 
        "Configuring from yourfoobar: 'maintainer' not defined as expected");
    is($args->{'verbose-step'}, 'init::hints',
        "Configuring from yourfoobar: 'init::hints' is verbose step");
    ok($args->{nomanicheck}, 
        "Configuring from yourfoobar: will omit check of MANIFEST");
    is($args->{file}, $configfile,
        "Configuring from yourfoobar: config file correctly stored");
    ok($args->{debugging}, 
        "Configuring from yourfoobar: debugging turned on");
    is($args->{cc}, $c_compiler,
        "Configuring from yourfoobar: C compiler is $c_compiler");
    is($args->{cxx}, $cplusplus_compiler,
        "Configuring from yourfoobar: C++ compiler is $cplusplus_compiler");
    is($args->{link}, $cplusplus_compiler,
        "Configuring from yourfoobar: linker is $cplusplus_compiler");
    is($args->{ld}, $cplusplus_compiler,
        "Configuring from yourfoobar: shared library loader is $cplusplus_compiler");

    my %steps_seen = map {$_ => 1} @{ $steps_list_ref };

    ok(exists $steps_seen{'init::manifest'},
        "Configuring from yourfoobar: init::manifest is in list even though it will be skipped");
    ok(! exists $steps_seen{'auto::perldoc'},
        "Configuring from yourfoobar: auto::perldoc not in list");
}

{
    my $configfile = q{xconf/samples/defectivefoobar};
    local @ARGV = ( qq{--file=$configfile} );
    eval {
        my ($args, $steps_list_ref) = process_options(
            {
                mode => (defined $ARGV[0]  and $ARGV[0] =~ /^--file=/)
                            ? 'file'
                            : 'configure',
                argv => [@ARGV],
            }
        );
    };
    like($@, qr/Configuration file $configfile did not parse correctly/,
        "Got expected failure message after defective configuration file");
}

pass("Completed all tests in $0");

################### DOCUMENTATION ###################

=head1 NAME

001-options.t - test Parrot::Configure::Options as used in Configure.pl

=head1 SYNOPSIS

    % prove t/configure/001-options.t

=head1 DESCRIPTION

The files in this directory test functionality used by F<Configure.pl>.

The tests in this file test subroutines exported by
Parrot::Configure::Options as it is used in F<Configure.pl>, I<i.e.>, with
C<mode => configure>..

=head1 AUTHOR

James E Keenan

=head1 SEE ALSO

Parrot::Configure::Options, Parrot::Configure::Options::Conf,
Parrot::Configure::Options::Conf::CLI, F<Configure.pl>.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
