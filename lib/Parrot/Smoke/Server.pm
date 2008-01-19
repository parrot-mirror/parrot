# Copyright (C) 2001-2007, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Smoke::Server - Subroutines used in F<tools/util/smokeserve-server.pl>.

=head1 DESCRIPTION

=cut

package Parrot::Smoke::Server;

use strict;
use warnings;

use base qw( Exporter );
use Algorithm::TokenBucket;
use CGI;
use CGI::Carp qw<fatalsToBrowser>;
use Digest::MD5 qw<md5_hex>;
use Fcntl qw<:DEFAULT :flock>;
use HTML::Template;
use Storable qw<store_fd fd_retrieve freeze>;
use Time::Piece;
use Time::Seconds;
our @EXPORT    = ();
our @EXPORT_OK = qw(
    require_compression_modules
    process_upload
    process_list
);
our %EXPORT_TAGS = ();

#    BASEHTTPDIR                 => "/",  used both in script and subs
#
use constant {
    VERSION                     => 0.4,
    BASEHTTPDIR                 => "/",
    BUCKET                      => "bucket.dat",
    MAX_RATE                    => 1 / 30,                  # Allow a new smoke all 30s
    BURST                       => 5,                       # Set max burst to 5
    MAX_SMOKES_OF_SAME_CATEGORY => 5,
};

##### PUBLICLY AVAILABLE SUBROUTINES #####

sub require_compression_modules {
    no strict 'refs';
    eval { require Compress::Zlib }
        or *Compress::Zlib::memGunzip = sub { return };
    eval { require Compress::Bzip2 }
        or *Compress::Bzip2::memBunzip = sub { return };
}

sub process_upload {
    my $CGI = shift;

    print $CGI->header;

    limit_rate();
    validate_params($CGI);
    add_smoke($CGI);
    clean_obsolete_smokes();

    print "ok";
}

sub process_list {
    my $CGI = shift;
    my $t = shift;
    my $tmpl = HTML::Template->new( scalarref => \$t, die_on_bad_params => 0 );

    print $CGI->header;

    my $category = sub {
        return sprintf "%s / %s runcore on %s-%s-%s",
            $_[0]->{DEVEL} eq "devel" ? "repository snapshot" : "release",
            runcore2human( $_[0]->{runcore} ), $_[0]->{cpuarch}, $_[0]->{osname}, $_[0]->{cc},;
    };

    my @smokes = map { unpack_smoke($_) } glob "parrot-smoke-*.html";
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

##### INTERNAL SUBROUTINES #####

# Rate limiting
sub limit_rate {

    # Open the DB and lock it exclusively. See perldoc -q lock.
    sysopen my $fh, BUCKET, O_RDWR | O_CREAT
        or die "Couldn't open \"@{[ BUCKET ]}\": $!\n";
    flock $fh, LOCK_EX
        or die "Couldn't flock \"@{[ BUCKET ]}\": $!\n";

    my $data = eval { fd_retrieve $fh };
    $data ||= [ MAX_RATE, BURST ];
    my $bucket = Algorithm::TokenBucket->new(@$data);

    my $exit;
    unless ( $bucket->conform(1) ) {
        print "Rate limiting -- please wait a bit and try again, thanks.";
        $exit++;
    }
    $bucket->count(1);

    seek $fh, 0, 0 or die "Couldn't rewind \"@{[ BUCKET ]}\": $!\n";
    truncate $fh, 0 or die "Couldn't truncate \"@{[ BUCKET ]}\": $!\n";

    store_fd [ $bucket->state ] => $fh
        or die "Couldn't serialize bucket to \"@{[ BUCKET ]}\": $!\n";

    exit if $exit;
}

sub validate_params {
    my $CGI = shift;

    if ( not $CGI->param("version") or $CGI->param("version") != VERSION ) {
        print "Versions do not match!";
        exit;
    }

    if ( not $CGI->param("smoke") ) {
        print "No smoke given!";
        exit;
    }

    uncompress_smoke($CGI);
    unless ( $CGI->param("smoke") =~ /^<!DOCTYPE html/ ) {
        print "The submitted smoke does not look like a smoke!";
        exit;
    }
}

sub uncompress_smoke {
    my $CGI = shift;
    $CGI->param( "smoke",
        Compress::Zlib::memGunzip( $CGI->param("smoke") )
            || Compress::Bzip2::memBunzip( $CGI->param("smoke") )
            || $CGI->param("smoke") );
}

sub add_smoke {
    my $CGI  = shift;
    my $html = $CGI->param("smoke");

    my $id = md5_hex $html;
    if ( glob "parrot-smoke-*-$id.html" ) {
        print "The submitted smoke was already submitted!";
        exit;
    }

    my %smoke;
    $html =~ /revision: (\d+)/      and $smoke{revision}     = $1;
    $html =~ /duration: (\d+)/      and $smoke{duration}     = $1;
    $html =~ /VERSION: ([\d\.]+)/   and $smoke{VERSION}      = $1;
    $html =~ /branch: ([\w\-]+)/    and $smoke{branch}       = $1;
    $html =~ /cpuarch: ([\w\d]+)/   and $smoke{cpuarch}      = $1;
    $html =~ /osname: ([\w\d]+)/    and $smoke{osname}       = $1;
    $html =~ /cc: ([\w\d]+)/        and $smoke{cc}           = $1;
    $html =~ /DEVEL: -?(\w+)/       and $smoke{DEVEL}        = $1;
    $html =~ /harness_args: (.+)$/m and $smoke{harness_args} = $1;
    $html =~ /build_dir: (.+)$/m    and $smoke{build_dir}    = $1;
    $html =~
/summary="(\d+) test cases: (\d+) ok, (\d+) failed, (\d+) todo, (\d+) skipped and (\d+) unexpectedly succeeded"/
        and $smoke{summary} = {
        total    => $1,
        ok       => $2,
        failed   => $3,
        todo     => $4,
        skipped  => $5,
        unexpect => $6,
        };

    if ( grep { not $smoke{$_} } qw<harness_args revision> ) {
        print "The submitted smoke has an invalid format!";
        exit;
    }

    $smoke{runcore} = runcore_from_args( $smoke{harness_args} );
    $smoke{revision} ||= 0;
    $smoke{timestamp} = time;
    $smoke{id}        = $id;
    my $filename = pack_smoke(%smoke);

    open my $fh, ">", $filename
        or die "Couldn't open \"$filename\" for writing: $!\n";
    print $fh $html
        or die "Couldn't write to \"$filename\": $!\n";
    close $fh
        or die "Couldn't close \"$filename\": $!\n";
}

sub runcore_from_args {
    local $_ = shift;

    /\b-g\b/ and return "goto";
    /\b-j\b/ and return "jit";
    /\b-C\b/ and return "cgp";
    /\b-S\b/ and return "switch";
    /\b-f\b/ and return "fast";
    return "default";
}

sub pack_smoke {
    my %smoke = @_;

    my $summary = join( "-", map { $smoke{summary}{$_} }
        qw<total ok failed todo skipped unexpect> );
    my $args = unpack( "H*", $smoke{harness_args} );

#                           1       2          3        4         5        6         7      8           9        10          ...
    my $str =
"parrot-smoke-<VERSION>-<DEVEL>-r<revision>-<branch>--<cpuarch>-<osname>-<cc>-<runcore>--<timestamp>-<duration>--$summary--$args--<id>.html";

    $str =~ s/<(.+?)>/$smoke{$1}/g;

    $str;
}

sub clean_obsolete_smokes {
    my $category = sub {
        return join "-", ( map { $_[0]->{$_} }
            qw<branch cpuarch osname cc runcore harness_args> ),
            $_[0]->{DEVEL} eq "devel" ? "dev" : "release",;
    };

    my %cats;
    my @smokes = map { unpack_smoke($_) } glob "parrot-smoke-*.html";
    push @{ $cats{ $category->($_) } }, $_ for @smokes;

    $cats{$_} = [
        (
            sort { $b->{revision} <=> $a->{revision} || $b->{timestamp}[0] <=> $a->{timestamp}[0] }
                @{ $cats{$_} }
        )[ 0 .. MAX_SMOKES_OF_SAME_CATEGORY- 1 ]
        ]
        for keys %cats;

    my %delete = map { $_->{filename} => 1 } @smokes;
    for ( map { @$_ } values %cats ) {
        next unless $_;

        delete $delete{ $_->{filename} };
    }

    unlink keys %delete;
}

sub unpack_smoke {
    my $name = shift;

    /^parrot-smoke-([\d\.]+)    #  1 VERSION
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
   .html$/x
        and return {
        VERSION   => $1,
        DEVEL     => $2,
        revision  => $3,
        branch    => $4,
        cpuarch   => $5,
        osname    => $6,
        cc        => $7,
        runcore   => $8,
        timestamp => [
            $9,
            do {
                my $str = localtime($9)->strftime("%d %b %Y %H:%M %a");
                $str =~ s/ /&nbsp;/g;

                # hack, to make the timestamps not break so the 
                # smoke reports look good even on 640x480
                $str;
            },
        ],
        duration => sprintf( "%.02f",
            Time::Seconds->new($10)->minutes ) . "&nbsp;min",
        summary => [
            {
                total    => $11,
                ok       => $12,
                failed   => $13,
                todo     => $14,
                skipped  => $15,
                unexpect => $16,
            }
        ],
        percentage   => sprintf( "%.02f", $12 / ( $11 || 1 ) * 100 ),
        harness_args => pack( "H*", $17 ),
        id           => $18,
        filename     => $name,
        link         => BASEHTTPDIR . $name,
        };
    return ();
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

    $runcore{ $_[0] };
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

