package Configure::Step;

use strict;
use vars qw($description @args);
use Parrot::Configure::Step ':auto';
use Config;

$description="Probing for C headers...";

@args=qw(miniparrot);

sub runstep {
    my ($miniparrot) = @_;

    if ($miniparrot) {
        foreach (qw(assert complex ctype errno locale math setjmp signal stdarg
                    stdio stdlib string time)) {
            Configure::Data->set("i_$_" => 1);
        }
	return;
    }

    # perl5's Configure system doesn't call this by its full name, which may
    # confuse use later, particularly once we break free and start doing all
    # probing ourselves
    my %mapping =
      (
       i_niin => "i_netinetin",
      );

    for (keys %Config) {
	next unless /^i_/;
	Configure::Data->set($mapping{$_}||$_, $Config{$_});
    }

    # some headers may not be probed-for by perl 5, or might not be
    # properly reflected in %Config (i_fcntl seems to be wrong on my machine,
    # for instance).
    my @extra_headers = qw(malloc.h fcntl.h setjmp.h pthread.h signal.h arpa/inet.h sysexit.h sys/socket.h);

    foreach my $header (@extra_headers) {
        my $flag = "i_$header";
        $flag =~ s/\.h$//g; $flag =~ s/\///g;

        Configure::Data->set(testheader => $header);
        cc_gen('config/auto/headers/test_c.in');
        Configure::Data->set(testheader => undef);

        my $build_ok = 1;
        eval { cc_build(); };
        $build_ok = 0 if $@;

        if ($build_ok && (cc_run() =~ /^$header OK$/)) {
            Configure::Data->set($flag, 'define');
        } else {
            Configure::Data->set($flag, undef);
        }
        cc_clean();
    }

}

1;
