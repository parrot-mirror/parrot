# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Smoke::Server - Subroutines used in F<tools/util/smokeserve-server.pl>.

=head1 DESCRIPTION

=cut

package Parrot::Smoke::Server;
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use HTML::Template;
use Time::Piece;
use Time::Seconds;
# use Data::Dumper;

sub new {
    my $class = shift;
    my $servconfigref = shift;
    my %data = %{ $servconfigref };
    # disable file uploads; module default was 0 (mouse, p 87)
    $CGI::DISABLE_UPLOADS = $data{DISABLE_UPLOADS};
    
    # limit size of a POSTing; module default was -1 (mouse, p 87)
    $CGI::POST_MAX = $data{POST_MAX};  # 100 KB
    
    # output an HTTP header only once per CGI object (mouse, p 117)
    $CGI::HEADERS_ONCE = $data{HEADERS_ONCE};
    
    $CGI::POST_MAX = $data{MAX_SIZE};

    chdir $data{BASEDIR} or die "Couldn't chdir into $data{BASEDIR}: $!";

    $SIG{PIPE} = "IGNORE";
    $data{q} = new CGI;
    
    return  bless \%data, $class;
}

sub print_header {
    my $self = shift;
    print $self->{q}->header( -type => "text/html" );
}

sub process_list {
    my $self = shift;
    my $t = shift;
    my $tmpl = HTML::Template->new( scalarref => \$t, die_on_bad_params => 0 );
    my $category = sub {
        return sprintf "%s / %s runcore on %s-%s-%s",
            $_[0]->{DEVEL} eq "devel" ? "repository snapshot" : "release",
            runcore2human( $_[0]->{runcore} ), $_[0]->{cpuarch}, $_[0]->{osname}, $_[0]->{cc},;
    };

    my @smokes = map { $self->unpack_smoke($_) } glob "parrot-smoke-*.html";

    my %branches;
    push @{ $branches{ $_->{branch} }{ $category->($_) } }, $_ for @smokes;

    foreach my $branch ( keys %branches ) {
        foreach my $cat ( keys %{ $branches{$branch} } ) {
            $branches{$branch}{$cat} = [
                map {
                    { %$_, timestamp => $_->{timestamp}[1] }
                    }
                    sort {
                    $b->{revision} <=> $a->{revision}
                        || lc $a->{osname} cmp lc $b->{osname}
                        || $b->{timestamp}[0] <=> $a->{timestamp}[0]
                    } @{ $branches{$branch}{$cat} }
            ];
        }

        $branches{$branch} = [
            map { { catname => $_, smokes => $branches{$branch}{$_}, } }
                sort { lc $a cmp lc $b } keys %{ $branches{$branch} }
        ];
    }

    $tmpl->param(
        branches => my $p = [
            map { { name => $_, categories => $branches{$_}, } }
                sort { ( $a eq "trunk" ? -1 : 0 ) || ( $b eq "trunk" ? 1 : 0 ) || ( $a cmp $b ) }
                keys %branches
            ]
    );

    print $tmpl->output;
}

sub unpack_smoke {
    my $self = shift;
    my $name = shift;

    my $unpackref = {};
    if ($name =~ /
        ^parrot-smoke-([\d\.]+)    #  1 VERSION
        -(\w+)          #  2 DEVEL
        -r(\d+)         #  3 revision
        -([\w\-]+)      #  4 branch
       --([\w\d]+)      #  5 cpuarch
        -([\w\d]+)      #  6 osname
        -([\w\d]+)      #  7 cc
        -(\w+)          #  8 runcore
       --(\d+)          #  9 timestamp
        -(\d+)          # 10 duration
       --(\d+)          # 11 total
        -(\d+)          # 12 ok
        -(\d+)          # 13 failed
        -(\d+)          # 14 todo
        -(\d+)          # 15 skipped
        -(\d+)          # 16 unexpected
       --([a-f0-9]+)    # 17 harness_args
       --([a-f0-9]+)    # 18 id
    .html$/x) {
        $unpackref = {
            VERSION   => $1,
            DEVEL     => $2,
            revision  => $3,
            branch    => $4,
            cpuarch   => $5,
            osname    => $6,
            cc        => $7,
            runcore   => $8,
        };
        my ($timestamp, $duration, $total, $ok, $failed, $todo, $skipped,
            $unexpected, $harness_args, $id) =
                ($9, $10, $11, $12, $13, $14, $15, $16, $17, $18);
        $unpackref->{timestamp} = [
            $timestamp,
            do {
                my $str = gmtime($timestamp)->strftime("%d %b %Y %H:%M %a");
                $str =~ s/ /&nbsp;/g;

                # hack, to make the timestamps not break so the 
                # smoke reports look good even on 640x480
                $str;
            },
        ];
        $unpackref->{duration} = sprintf( "%.02f",
                Time::Seconds->new($duration)->minutes ) . "&nbsp;min";
        $unpackref->{summary} = [ {
            total    => $total,
            ok       => $ok,
            failed   => $failed,
            todo     => $todo,
            skipped  => $skipped,
            unexpect => $unexpected,
        } ];  # Why a hashref as sole element inside array is not clear, but
        # we get a fatal HTML::Template error otherwise.
        $unpackref->{percentage} =
            sprintf( "%.02f", $ok / ( $total || 1 ) * 100 );
        $unpackref->{harness_args} = pack( "H*", $harness_args );
        $unpackref->{id}          = $id;
        $unpackref->{filename}    = $name;
        $unpackref->{link}        = $self->{BASEHTTPDIR} . $name;
        return $unpackref;
    } else {
        return ();
    }
}

sub runcore2human {
    my %runcore = (
        goto    => "computed goto",
        jit     => "JIT",
        cgp     => "CGP",
        switch  => "switch",
        fast    => "fast",
        default => "default",
    );
    return $runcore{ $_[0] };
}

1;

