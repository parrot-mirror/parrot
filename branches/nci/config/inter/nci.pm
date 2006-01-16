# Copyright: 2001-2005 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

config/inter/nci.pm - Determine which NCI implementation to use

=head1 DESCRIPTION

Determines whether to use the builtin NCI implementation, or one provided
by ffcall or libffi.

The favoured order is ffcall, liffi, builtin.

=cut

package inter::nci;

use strict;
use vars qw($description $result @args);

use base qw(Parrot::Configure::Step::Base);

use Parrot::Configure::Step ':inter', ':auto';

$description = "Determining which NCI implementation to use...";

@args = qw(ask verbose);

sub runstep
{
    my ($self, $config) = @_;

    # TODO: Allow implementation to be selected through command-line flag

    my @nci_implementations = ('builtin');


    cc_gen('config/inter/nci/nci_libffi.in');

    eval { cc_build('', '-lffi'); };

    if (! $@) {
        my $test = cc_run ();

        unshift @nci_implementations, 'libffi'
            if $test eq "Received: It worked!\nGot back -24\n";
    }


    cc_gen('config/inter/nci/nci_ffcall.in');

    eval { cc_build('', '-lavcall -lcallback'); };

    if (! $@) {
        my $test = cc_run ();

        unshift @nci_implementations, 'ffcall'
            if $test eq "Received: It worked!\nGot back -24\n";
    }

    my $nci_implementation = $nci_implementations[0];

    my $ask = $config->options->get ('ask');

    if ($ask)
    {
    print <<'END';


    You can choose between a number of diffferent backend implementations
    for making calls to external libraries:

      * builtin: The original implementation which doesn't require
        additional libraries

      * ffcall: Requires the ffcall library, and is more functional

      * libffi: Requires the libffi library, and is more functional

END
        $nci_implementation = 
            prompt ("\nWhich NCI implementation shall I use? (" .
                    join (',', @nci_implementations) . ")",
                    $nci_implementation);

    $nci_implementation = $nci_implementations[0]
        unless grep { $_ eq $nci_implementation } @nci_implementations;
        
    }


    # XXX Override the probed value and use the builtin one
    $nci_implementation = "builtin";
    $result = $nci_implementation . " (overridden)";

    $config->data->set( nci_impl => $nci_implementation );

    # For now add all the flags for supported backends
    foreach (@nci_implementations)
    {
        if ($_ eq 'ffcall')
        {
            $config->data->add(' ', 'libs', '-lavcall -lcallback');

            $config->data->set( 'ffcall' => 1 );
        }

        if ($_ eq 'libffi')
        {
            $config->data->add(' ', 'libs', '-lffi');

            $config->data->set( 'libffi' => 1 );
        }

    }

}

1;
