#! perl -w
# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

config/gen/platform.pl - Platform Files

=head1 DESCRIPTION

Moves the various platform-specific files into place.

=cut

package Configure::Step;

use strict;
use vars qw($description @args);
use Parrot::Configure::Step qw(copy_if_diff);

$description="Moving platform files into place...";

@args=qw(miniparrot);

sub runstep {
  my $platform=lc $^O;
  $platform =~ s/^ms//;

  $platform="ansi" if defined($_[0]);
  $platform="generic" unless -d "config/gen/platform/$platform";

  # headers are merged into platform.h
  my @headers = qw/
    io.h
    misc.h
    dl.h
    signal.h
    threads.h
  /;

  open PLATFORM_H, "> include/parrot/platform.h"
      or die "Can't open include/parrot/platform.h: $!";
  print " platform='$platform' ";

  print PLATFORM_H <<HERE;
#if !defined(PARROT_PLATFORM_H_GUARD)
#define PARROT_PLATFORM_H_GUARD

/*
** platform.h [$platform version]
**
** DO NOT EDIT THIS FILE
**
** Generated by config/gen/platform.pl
*/

HERE

  for ( @headers ) {
      my $header_file = "config/gen/platform/generic/$_";
      if ( -e "config/gen/platform/$platform/$_" ) {
          $header_file = "config/gen/platform/$platform/$_";
      }

      if ( -e $header_file ) {
          local $/ = undef;
          open IN_H, "< $header_file" or die "Can't open $header_file: $!";
          print PLATFORM_H <<HERE;
/*
** $header_file:
*/

HERE
          print PLATFORM_H <IN_H>, "\n\n";
          close IN_H;
      }

      # just fall through if file is missing; means neither this platform nor
      # generic has anything to contribute for this feature.  this might not
      # be desirable if porters don't see the appropriate file in generic/ and
      # shoehorn their function into the wrong file rather than creating the
      # correct one from the above list in their $platform/ dir (e.g. misc.c).
  }

  print PLATFORM_H <<HERE;
#endif
HERE

  close PLATFORM_H;

  # implementation files are merged into platform.c
  my @impls = qw/
    time.c
    env.c
    dl.c
    memalign.c
    signal.c
    itimer.c
    memexec.c
    exec.c
    misc.c
  /;

  open PLATFORM_C, "> src/platform.c" or die "Can't open src/platform.c: $!";

  print PLATFORM_C <<HERE;
/*
** platform.c [$platform version]
**
** DO NOT EDIT THIS FILE
**
** Generated by config/gen/platform.pl
*/
HERE

  # We need to put things from begin.c before the parrot.h include.
  if ( -e "config/gen/platform/$platform/begin.c" ) {
      local $/ = undef;
      open IN_C, "< config/gen/platform/$platform/begin.c" or die "Can't open begin.c: $!";
      print PLATFORM_C <<HERE;
/*
** begin.c
*/

HERE
      print PLATFORM_C <IN_C>, "\n\n";
      close IN_C;
  }

  # Copy the rest.
print PLATFORM_C <<HERE;
#include "parrot/parrot.h"

HERE

  for ( @impls ) {
      my $impl_file = "config/gen/platform/generic/$_";
      if ( -e "config/gen/platform/$platform/$_" ) {
          $impl_file = "config/gen/platform/$platform/$_";
      }

      if ( -e $impl_file ) {
          local $/ = undef;
          open IN_C, "< $impl_file" or die "Can't open $impl_file: $!";
          print PLATFORM_C <<HERE;
/*
** $impl_file:
*/

HERE
          print PLATFORM_C <IN_C>, "\n\n";
          close IN_C;
      }
  }
  close PLATFORM_C;

  if ( Configure::Data->get( 'platform_asm' ) ) {
      my $asm_file = "config/gen/platform/$platform/asm.s";
      if ( -e $asm_file ) {
          copy_if_diff( $asm_file, "src/platform_asm.s" );
      }
  }

  # interface is the same for all platforms
  copy_if_diff( "config/gen/platform/platform_interface.h",
		  "include/parrot/platform_interface.h" );
}

1;
