# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$

=head1 NAME

config/auto/icu.pm - Detect International Components for Unicode (ICU)

=head1 DESCRIPTION

Determines whether ICU is available.  If so, configures ICU and add
appropriate targets to the Makefile.

From the ICU home page (L<http://www.icu-project.org/>):  "ICU is a mature,
widely used set of C/C++ and Java libraries providing Unicode and
Globalization support for software applications."

=cut

=pod

CU Options:

   For using a system ICU, these options can be used:

   --icu-config=/path/to/icu-config
                        Location of the script used for ICU autodetection.
                        You just need to specify this option if icu-config
                        is not in your PATH.

   --icu-config=none    Can be used to disable the autodetection feature.
                        It will also be disabled if you specify any other
                        of the following ICU options.

   If you do not have a full ICU installation:

   --without-icu        Build parrot without ICU support
   --icuheaders=(path)  Location of ICU headers without /unicode
   --icushared=(flags)  Full linker command to create shared libraries
   --icudatadir=(path)  Directory to locate ICU's data file(s)

=cut

package auto::icu;

use strict;
use warnings;

use base qw(Parrot::Configure::Step);

use Cwd qw(cwd);
use File::Basename;
use Parrot::Configure::Utils qw(capture_output);


sub _init {
    my $self = shift;
    my %data;
    $data{description}          = q{Determining whether ICU is installed};
    $data{result}               = q{};
    $data{icuconfig_default}    = q{icu-config};
    $data{icu_headers}          = [ qw(ucnv.h utypes.h uchar.h) ];
    return \%data;
}

sub runstep {
    my ( $self, $conf ) = @_;

    my ( $verbose, $icushared_opt, $icuheaders_opt,
        $icuconfig_opt, $without_opt ) = $conf->options->get( qw|
            verbose
            icushared
            icuheaders
            icu-config
            without-icu
    | );

    # If we haven't provided the path to a specific ICU configuration program
    # on the command line, then we probe to see if the program 'icu-config' is
    # available.

    # From the icu-config(1) man page
    # (L<http://linux.die.net/man/1/icu-config>):

    # "icu-config simplifies the task of building and linking
    # against ICU as compared to manually configuring user
    # makefiles or equivalent. Because icu-config is an executable
    # script, it also solves the problem of locating the ICU
    # libraries and headers, by allowing the system PATH to locate
    # it."

    # $icuconfig is a string holding the name of an executable program.
    # So if it's not provided on the command line -- or if it's explicitly
    # ruled out by being provided with the value 'none' -- an empty string 
    # is its most appropriate value.

    my $icuconfig = $self->_handle_icuconfig_opt($icuconfig_opt);

    # Oooh, how I wish we had Perl 5.10's defined-or operator available!
    my $icushared = (defined $icushared_opt)
        ? $icushared_opt
        : undef;
    my $icuheaders = (defined $icuheaders_opt)
        ? $icuheaders_opt
        : undef;

    # $without_opt holds user's command-line value for --without-icu=?
    # If it's a true value, there's no point in going further.  We set the
    # values needed in the Parrot::Configure object, set the step result and
    # return.  If, however, it's a false value, then we're going to try to
    # configure with ICU and we proceed to probe for ICU.

    if ( $without_opt ) {
        $conf->data->set(
            has_icu    => 0,
            icu_shared => '',    # used for generating src/dynpmc/Makefile
            icu_dir    => '',
        );
        $self->set_result("no");
        return 1;
    }
    else {
        my $autodetect  =   ( ! defined($icushared)  )
                                &&
                            ( ! defined($icuheaders) );
    
        my $without = 0;
        ($icuconfig, $autodetect, $without) =
            _handle_autodetect( {
                icuconfig   => $icuconfig,
                autodetect  => $autodetect,
                without     => $without,
                verbose     => $verbose,
        } );

        if (
            ( ! $without )  &&
            $autodetect     &&
            $icuconfig
        ) {
            my $slash = $conf->data->get('slash');

            # ldflags
            $icushared = capture_output("$icuconfig --ldflags");
            if ( defined $icushared ) {
                chomp $icushared;
                $icushared =~ s/-licui18n\w*//;    # "-licui18n32" too
                if (length $icushared == 0) {
                    $without = 1;
                }
                else {
                    # do nothing
                }
            }
            else {
                # do nothing
            }

            # location of header files
            $icuheaders = capture_output("$icuconfig --prefix");
            if ( defined $icuheaders ) {
                chomp $icuheaders;
                if (! -d $icuheaders) {
                    $without = 1;
                }
                else {
                    # do nothing
                }
                $icuheaders .= "${slash}include";
                if (! -d $icuheaders) {
                    $without = 1;
                }
                else {
                    # do nothing
                }
            }
            else {
                # do nothing
            }

            if ($without) {
                $self->set_result("failed");
            }
            else {
                # do nothing
            }
        }
        else {
            # do nothing
        }
    
        if ($verbose) {
            print "icuconfig: $icuconfig\n"  if defined $icuconfig;
            print "icushared='$icushared'\n" if defined $icushared;
            print "headers='$icuheaders'\n"  if defined $icuheaders;
        }
    
        if ($without) {
            $conf->data->set(
                has_icu    => 0,
                icu_shared => '',    # used for generating src/dynpmc/Makefile
                icu_dir    => '',
            );
            if (! $self->result) {
                $self->set_result("no");
            }
            else {
                # do nothing
            }
            return 1;
        }
        else {
            my $ok = 1;
        
            if ( ! defined $icushared ) {
                warn "error: icushared not defined\n";
                $ok = 0;
            }
            else {
                # do nothing
            }
        
            if ( ! ( defined $icuheaders and -d $icuheaders ) ) {
                warn "error: icuheaders not defined or invalid\n";
                $ok = 0;
            }
            else {
                $icuheaders =~ s![\\/]$!!;
                foreach my $header ( @{ $self->{icu_headers} } ) {
                    $header = "$icuheaders/unicode/$header";
                    if  ( ! -e $header ) {
                        $ok = 0;
                        warn "error: ICU header '$header' not found\n";
                    }
                    else {
                        # do nothing
                    }
                }
            }
        
            if (! $ok) {
                die die_message();
            }
            else {
                # do nothing
            }
        
            my $icudir = dirname($icuheaders);
        
            $conf->data->set(
                has_icu    => 1,
                icu_shared => $icushared,
                icu_dir    => $icudir,
            );
        
            # Add -I $Icuheaders if necessary
            my $header = "unicode/ucnv.h";
            $conf->data->set( testheaders => "#include <$header>\n" );
            $conf->data->set( testheader  => "$header" );
            $conf->cc_gen('config/auto/headers/test_c.in');
        
            $conf->data->set( testheaders => undef );    # Clean up.
            $conf->data->set( testheader  => undef );
            eval { $conf->cc_build(); };
            if ( ! $@ && $conf->cc_run() =~ /^$header OK/ ) {
        
                # Ok, we don't need anything more.
                if ($verbose) {
                    print "Your compiler found the icu headers... good!\n";
                }
            }
            else {
                if ($verbose) {
                    print "Adding -I $icuheaders to ccflags for icu headers.\n";
                }
                $conf->data->add( ' ', ccflags => "-I $icuheaders" );
            }
            $conf->cc_clean();
        
            $self->set_result("yes");
        
            return 1;
        }
    }
}

sub _handle_icuconfig_opt {
    my ($self, $icuconfig_opt) = @_;
    my $icuconfig;
    if ( ( ! $icuconfig_opt ) or ( $icuconfig_opt eq q{none} ) ) {
        $icuconfig = q{};
    }
    elsif ( $icuconfig_opt eq '1' ) {
        $icuconfig = $self->{icuconfig_default};
    }
    else {
        $icuconfig = $icuconfig_opt;
    }
    return $icuconfig;
}

sub die_message {
    my $die = <<"HELP";
Something is wrong with your ICU installation!

   If you do not have a full ICU installation:

   --without-icu        Build parrot without ICU support
   --icu-config=(file)  Location of icu-config
   --icuheaders=(path)  Location of ICU headers without /unicode
   --icushared=(flags)  Full linker command to create shared libraries
HELP
    return $die;
}

sub _handle_search_for_icu_config {
    my $arg = shift;
    if (
        ( $arg->{ret} == -1 )
            ||
        ( ( $arg->{ret} >> 8 ) != 0 )
    ) {
        undef $arg->{icuconfig};
        $arg->{autodetect} = 0;
        $arg->{without}    = 1;
    }
    else {
        $arg->{icuconfig} = "icu-config";
        if ($arg->{verbose}) {
            print "icu-config found... good!\n";
        }
    }
    return ( $arg->{icuconfig}, $arg->{autodetect}, $arg->{without} );
}

sub _handle_autodetect {
    my $arg = shift;
    if ( $arg->{autodetect} ) {
        if ( ! $arg->{icuconfig} ) {

            my ( undef, undef, $ret ) =
                capture_output( "icu-config", "--exists" );

            ($arg->{icuconfig}, $arg->{autodetect}, $arg->{without}) =
                _handle_search_for_icu_config( {
                    icuconfig   => $arg->{icuconfig},
                    autodetect  => $arg->{autodetect},
                    without     => $arg->{without},
                    verbose     => $arg->{verbose},
                    ret         => $ret,
            } );
        }
        else {
            # do nothing
        }
    } # end $autodetect true
    else {
        if ($arg->{verbose}) {
            print "Specified an ICU config parameter,\n";
            print "ICU autodetection disabled.\n";
        }
    } # end $autodetect false
    return ( $arg->{icuconfig}, $arg->{autodetect}, $arg->{without} );
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
