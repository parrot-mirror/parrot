#! /usr/bin/perl -w
#
# compile.pl - compile a Jako source file Parrot assembly file.
#
# Jako is a *very* simple language with just enough complexity to allow the
# implementation of little programs with while loops.
#
#   * Global data only
#   * No user subroutine definitions
#
# by Gregor N. Purdy <gregor@focusresearch.com>
#
# Copyright (C) 2001 Gregor N. Purdy. All rights reserved.
# This program is free software. It is subject to the same license
# as Perl itself.
#

use strict;


#
# Global variables:
#

my $line;    # Current source line number
my %ident;   # Identifiers
my %regs = ( # Registers
  I => [ undef ], # $regs{I}[0] reserved for integral  temporaries
  N => [ undef ], # $regs{N}[0] reserved for numeric   temporaries
  P => [ undef ], # $regs{P}[0] reserved for polytypic temporaries
  S => [ undef ], # $regs{S}[0] reserved for string    temporaries
);

my $block_count = 0;
my @block_stack = ();

my %void_functions = (

);

my %true_functions = (
  acos  => [ 'N', 1, '[IN]'],
  and   => [ 'I', 2, 'II'  ],
  asec  => [ 'N', 1, '[IN]' ],
  asin  => [ 'N', 1, '[IN]' ],
  atan  => [ 'N', 1, '[IN]' ],
  atan2 => [ 'N', 2, '[IN][IN]' ],
  cos   => [ 'N', 1, '[IN]' ],
  cosh  => [ 'N', 1, '[IN]' ],
  exp   => [ 'N', 1, '[IN]' ],
  ln    => [ 'N', 1, '[IN]' ],
  log10 => [ 'N', 1, '[IN]' ],
  log2  => [ 'N', 1, '[IN]' ],
  not   => [ 'I', 1, 'I' ],
  or    => [ 'I', 2, 'II' ],
  pow   => [ 'N', 2, '[IN][IN]' ],
  sec   => [ 'N', 1, '[IN]' ],
  sech  => [ 'N', 1, '[IN]' ],
  sin   => [ 'N', 1, '[IN]' ],
  sinh  => [ 'N', 1, '[IN]' ],
  tan   => [ 'N', 1, '[IN]' ],
  tanh  => [ 'N', 1, '[IN]' ],
  xor   => [ 'I', 2, 'II' ],
);


#
# declare_var()
#

sub declare_var
{
  my ($name, $type) = @_;

#  printf(STDERR "jako: debug: Declaring variable '%s' of type '%s'...\n", $name, $type);

  if ($ident{$name}) {
    printf STDERR "jako: Redeclaration of variable '%s' on line %d. Previous declaration on line %d.\n",
      $name, $line, $ident{$name}{LINE};
    return 0;
  } else {
    my $num = scalar @{$regs{$type}};

    $ident{$name}{LINE} = $line;
    $ident{$name}{TYPE} = $type;
    $ident{$name}{NUM}  = $num;
    $ident{$name}{REG}  = "$type$num";

    $regs{$type}[$num]{LINE} = $line;
    $regs{$type}[$num]{NAME} = $name;

    print "# $name: $type$num\n";

    return 1;
  }
}


#
# assign_var()
#

sub assign_var
{
  my ($name, $type, $value) = @_;

  if ($ident{$name}) {
    if ($type eq '*') {
      if ($ident{$value}) {
        printf "%-12s %-8s %s\n", '', 'set', "$ident{$name}{REG}, $ident{$value}{REG}";
      } else {
        printf(STDERR "jako: Assignment from undefined variable '%s' on line %d.\n",
          $value, $line);
      }
    } elsif ($ident{$name}{TYPE} eq $type) {
      printf "%-12s %-8s %s\n", '', 'set', "$ident{$name}{REG}, $value";
    } else {
      printf(STDERR "jako: Assignment of %s variable from %s value not allowed on line %d.\n", 
        $ident{$name}{TYPE}, $type, $line);
    }
  } else {
    printf(STDERR "jako: Assignment to undefined variable '%s' on line %d.\n",
      $name, $line);
  }
}


#
# map_args()
#

sub map_args
{
  my (@args) = @_;
  my @result;

  foreach my $arg (@args) {
    $arg =~ s/^\s+//;
    $arg =~ s/\s+$//;

    if ($ident{$arg}) {
      push @result, $ident{$arg}{REG};
    } elsif ($arg =~ m/^"/) {
      push @result, $arg;
    } elsif ($arg =~ m/^\d+(\.\d+)$/) {
      push @result, $arg;
    } else {
      printf(STDERR "jako: Unrecognized argument '%s' on line %d.\n", $arg, $line);
      push @result, "<err>";
    }
  }

  return @result;
}


#
# void_func()
#

sub void_func
{
  my ($name, @args) = @_;

  if ($name eq 'print') {
    @args = map_args(@args);
    foreach my $arg (@args) {
      printf "%-12s %-8s %s\n", '', $name, $arg;
    }
  } else {
    printf(STDERR "jako: Unrecognized function '$name' on line %d.\n", $name, $line);
  }
}


#
# assign_func()
#

sub assign_func
{
  my ($dest, $name, @args) = @_;

  if ($name eq 'mod') {
    @args = map_args($dest, @args);
    printf "%-12s %-8s %s\n", '', $name, join(", ", @args);
  } else {
    printf(STDERR "jako: Unrecognized function '$name' on line %d.\n", $name, $line);
  }
}


#
# begin_while_block()
#

sub begin_while_block
{
  my ($cond) = @_;

  $block_count++;
  my $prefix = "_W$block_count";
  push @block_stack, { TYPE => 'while', NEXT => $line, PREFIX => $prefix };

  #
  # TODO: Note that the assembler wasn't inferring the opcode qualifiers, so we had
  # to code them explicitly. We should remove the qualifiers as soon as the
  # assembler is fixed.
  #

  if ($cond =~ m/^(.*)\s*==\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "eq_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } elsif ($cond =~ m/^(.*)\s*!=\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "ne_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } elsif ($cond =~ m/^(.*)\s*<=\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "le_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } elsif ($cond =~ m/^(.*)\s*>=\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "ge_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } else {
    printf(STDERR "jako: Syntax error. Unrecognized condition in while on line %d.\n", $line);
  }
}


#
# begin_if_block()
#

sub begin_if_block
{
  my ($cond) = @_;

  $block_count++;
  my $prefix = "_I$block_count";
  push @block_stack, { TYPE => 'if', NEXT => $line, PREFIX => $prefix };

  #
  # TODO: Note that the assembler wasn't inferring the opcode qualifiers, so we had
  # to code them explicitly. We should remove the qualifiers as soon as the
  # assembler is fixed.
  #

  if ($cond =~ m/^(.*)\s*==\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "eq_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } elsif ($cond =~ m/^(.*)\s*!=\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "ne_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } elsif ($cond =~ m/^(.*)\s*<=\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "le_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } elsif ($cond =~ m/^(.*)\s*>=\s*(.*)$/) {
    my @args = map_args($1, $2);
    printf "%-12s %-8s %s\n", "${prefix}_NEXT:", "ge_i_ic", "$args[0], $args[1], ${prefix}_REDO, ${prefix}_LAST";
    printf "%s_REDO:\n", $prefix;
  } else {
    printf(STDERR "jako: Syntax error. Unrecognized condition in while on line %d.\n", $line);
  }
}


#
# end_block()
#

sub end_block
{
  unless (@block_stack) {
    printf(STDERR "jako: Syntax error. Closing brace without open block on line %d.\n", $line);
    return;
  }

  my $block  = pop @block_stack;
  my $prefix = $block->{PREFIX};

  #
  # TODO: Note that the assembler wasn't inferring the opcode qualifiers, so we had
  # to code them explicitly. We should remove the qualifiers as soon as the
  # assembler is fixed.
  #

  if ($block->{TYPE} eq 'while') {
    printf("%-12s %-8s %s\n", '', 'branch_ic', "${prefix}_NEXT", );
    # TODO: Is there a better unconditional jump (branch_ic)?
  }

  printf "%s_LAST:\n", $prefix;
}


#
# do_loop_control()
#

sub do_loop_control
{
  my $which = uc shift;

  #
  # TODO: Note that the assembler wasn't inferring the opcode qualifiers, so we had
  # to code them explicitly. We should remove the qualifiers as soon as the
  # assembler is fixed.
  #

  foreach (reverse @block_stack) {
    if ($_->{TYPE} eq 'while') {
      my $prefix = $_->{PREFIX};
      printf("%-12s %-8s %s\n", '', 'branch_ic', "${prefix}_$which", );
      last;
    }
  }
}


#
# do_add()
#

sub do_add
{
  my ($dest, $a, $b) = @_;

  printf("%-12s %-8s %s\n", '', 'add', join(", ", map_args($dest, $a, $b)));
}


#
# do_inc()
#

sub do_inc
{
  printf("%-12s %-8s %s\n", '', 'inc', join(", ", map_args(@_)));
}


#
# do_sub()
#

sub do_sub
{
  my ($dest, $a, $b) = @_;

  printf("%-12s %-8s %s\n", '', 'sub', join(", ", map_args($dest, $a, $b)));
}


#
# do_dec()
#

sub do_dec
{
  printf("%-12s %-8s %s\n", '', 'dec', join(", ", map_args(@_)));
}


#
# do_mul()
#

sub do_mul
{
  my ($dest, $a, $b) = @_;

  printf("%-12s %-8s %s\n", '', 'mul', join(", ", map_args($dest, $a, $b)));
}


#
# do_div()
#

sub do_div
{
  my ($dest, $a, $b) = @_;

  printf("%-12s %-8s %s\n", '', 'div', join(", ", map_args($dest, $a, $b)));
}


#
# do_mod()
#

sub do_mod
{
  my ($dest, $a, $b) = @_;

  printf("%-12s %-8s %s\n", '', 'mod', join(", ", map_args($dest, $a, $b)));
}


#
# do_shift()
#

sub do_shift
{
  my ($dir, $dest, $a, $amount) = @_;

  printf("%-12s %-8s %s\n", '', "sh$dir", join(", ", map_args($dest, $a, $amount)));
}


#
# parse_args()
#

sub parse_args
{
  my ($args) = @_;
  my @args;

  while ($args ne '') {
    $args =~ s/^\s+//;

    if ($args =~ m/^(\"[^\\\"]*(?:\\.[^\\\"]*)*\")\s*(,\s*(.*))?$/) {
      push @args, $1;
      $args = $3 || '';
    } elsif ($args =~ m/^([^,]+)\s*(,\s*(.*))?$/) {
      push @args, $1;
      $args = $3 || '';
    } else {
      printf(STDERR "jako: Syntax error. Cannot parse argument list '$args' on line %d.\n", $line);
      return ();
    }
  }

  return @args;
}


#
# MAIN PROGRAM:
#

print "# This file produced by the Jako Compiler\n";

while(<>) {
  $line++;

  if (m/^\s*#/) { print; next; } # Pass comment-only lines through intact.
  if (m/^\s*$/) { print; next; } # Pass whitespace-only lines through intact.

  chomp;                         # Trim trailing newline
  s/^\s*//;                      # Trim leading whitespace
  s/\s*$//;                      # Trim trailing whitespace
  last if (/^__END__$/);         # Done after __END__ token

  s/\s*;\s*$//; # Remove trailing semicolons

  #
  # Variable declarations:
  #
  # var int      foo;
  # var integer  foo;
  # var int      foo = 5;
  # var integer  foo = 5;
  #
  # var num      bar;
  # var number   bar;
  # var num      bar = 3.14;
  # var number   bar = 3.14;
  #
  # var str      splee;
  # var string   splee;
  # var str      splee = "Howdy";
  # var string   splee = "Howdy";
  #
  # var poly     quux;
  # var polytype quux;
  #

  if (m/^var\s+int(eger)?\s+([A-Za-z][A-Za-z0-9_]*)(\s*=\s*(\d+))?$/) {
    declare_var($2, 'I');
    assign_var($2, 'I', $4) if defined $4;
    next;
  }

  if (m/^var\s+num(ber)?\s+([A-Za-z][A-Za-z0-9_]*)(\s*=\s*(\d+(\.\d+)))$/) {
    declare_var($2, 'N');
    assign_var($2, 'N', $4) if defined $4;
    next;
  }

  if (m/^var\s+str(ing)?\s+([A-Za-z][A-Za-z0-9_]*)(\s*=\s*(\"[^\\\"]*(?:\\.[^\\\"]*)*\"))?$/) {
    declare_var($2, 'S');
    assign_var($2, 'S', $4) if defined $4;
    next;
  }

  if (m/^var\s+poly(type)?\s+([A-Za-z][A-Za-z0-9_]*)$/) {
    declare_var($2, 'P');
    next;
  }

  #
  # Variable Assignments:
  #
  # a = 5;
  # a = 3.14;
  # a = "Howdy";
  #
 
  if (m/^([A-Za-z][A-Za-z0-9_]*)\s*=\s*(\d+(\.\d+))$/) {
    assign_var($1, 'I', $2);
    next;
  }

  if (m/^([A-Za-z][A-Za-z0-9_]*)\s*=\s*(\"[^\\\"]*(?:\\.[^\\\"]*)*\")$/) {
    assign_var($1, 'S', $2);
    next;
  }

  if (m/^([A-Za-z][A-Za-z0-9_]*)\s*=\s*([A-Za-z][A-Za-z0-9_]*)$/) {
    assign_var($1, '*', $2);
    next;
  }

  #
  # Function Calls:
  #
  #     foo(...);
  # a = foo(...);
  #
 
  if (m/^([A-Za-z][A-Za-z0-9_]*)\((.*)\)$/) {
    void_func($1, parse_args($2));
    next;
  }

  if (m/^([A-Za-z][A-Za-z0-9_]*)\s*=\s*([A-Za-z][A-Za-z0-9_]*)\((.*)\)$/) {
    assign_func($1, $2, split(/\s*,\s*/, $3));
    next;
  }

  #
  # Loop Blocks:
  #
  # while (...) {
  #

  if (m/^while\s*\(\s*(.*)\s*\)\s*{$/) {
    begin_while_block($1);
    next;
  }

  #
  # Conditional Blocks:
  #
  # if (...) {
  #

  if (m/^if\s*\(\s*(.*)\s*\)\s*{$/) {
    begin_if_block($1);
    next;
  }

  #
  # Block Termination:
  #
  # }
  #

  if (m/^}$/) {
    end_block();
    next;
  }

  #
  # Loop Control Statements:
  #
  # next;
  # last;
  # redo;
  #

  if (m/^(next|last|redo)$/) {
    do_loop_control($1);
    next;
  }

  #
  # Additive Operators:
  #
  # a = b    + c;     # add_[in]
  # a = b    + 5;     # add_i_ic (psuedo-op)
  # a = b    + 3.14;  # add_n_nc (psuedo-op)
  # a = 5    + b;     # add_ic_i (pseudo-op)
  # a = 3.14 + b;     # add_nc_n (pseudo-op)
  # a = 5    + 2;     # set_i (COMPILE-TIME EVALUATION)
  # a = 3.14 + 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 5    + 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 3.14 + 2;     # set_n (COMPILE-TIME EVALUATION)
  #
  # a += b;           # add_[in]
  # a += 5;           # add_i_ic (pseudo-op)
  # a += 3.14;        # add_n_nc (pseudo-op)
  #
  # a++;              # inc_[in]
  #

  if (m/([A-Za-z][A-Za-z0-9]*)\s*=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))\s*[+]\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    if (defined $3 or defined $7) {
      do_add($1, $3, $7);
    } elsif (defined $3 and defined $8) {
      assign_var($1, (defined $5 or defined $9 ? 'N' : 'I'), $4 + $8);
    } else {
      printf(STDERR "jako: Syntax error in addition on line %d: '%s'\n", $line, $_);
    }
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9]*)\s*[+]=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    if (defined $3) {
      do_add($1, $1, $2);
    } else {
      do_inc($1, $2);
    }
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9_]*)\s*[+][+]$/) {
    do_inc($1);
    next;
  }

  #
  # Subtractive Operators:
  #
  # a = b    - c;     # sub_[in]
  # a = b    - 5;     # sub_i_ic (pseudo-op)
  # a = b    - 3.14;  # sub_n_nc (pseudo-op)
  # a = 5    - b;     # sub_ic_i (pseudo-op)
  # a = 3.14 - b;     # sub_nc_n (pseudo-op)
  # a = 5    - 2;     # set_i (COMPILE-TIME EVALUATION)
  # a = 3.14 - 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 5    - 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 3.14 - 2;     # set_n (COMPILE-TIME EVALUATION)
  #
  # a -= b;           # dec_{i_i,n_n} (pseudo-op)
  # a -= 5;           # sub_i_ic (pseudo-op)
  # a -= 3.14;        # sub_n_nc (pseudo-op)
  #
  # a--;              # dec_[in]
  #

  if (m/([A-Za-z][A-Za-z0-9]*)\s*=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))\s*[-]\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    if (defined $3 or defined $7) {
      do_sub($1, $3, $7);
    } elsif (defined $3 and defined $8) {
      assign_var($1, (defined $5 or defined $9 ? 'N' : 'I'), $4 - $8);
    } else {
      printf(STDERR "jako: Syntax error in subtraction on line %d: '%s'\n", $line, $_);
    }
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9]*)\s*[-]=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    if (defined $3) {
      do_sub($1, $1, $2);
    } else {
      do_dec($1, $2);
    }
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9_]*)\s*[-][-]$/) {
    do_dec($1, 1);
    next;
  }

  #
  # Multiplicative Operators:
  #
  # a = b    * c;     # mul_[in]
  # a = b    * 5;     # mul_i_ic (psuedo-op)
  # a = b    * 3.14;  # mul_n_nc (psuedo-op)
  # a = 5    * b;     # mul_ic_i (pseudo-op)
  # a = 3.14 * b;     # mul_nc_n (pseudo-op)
  # a = 5    * 2;     # set_i (COMPILE-TIME EVALUATION)
  # a = 3.14 * 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 5    * 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 3.14 * 2;     # set_n (COMPILE-TIME EVALUATION)
  #
  # a *= b;           # mul_[in]
  # a *= 5;           # mul_i_ic (pseudo-op)
  # a *= 3.14;        # mul_n_nc (pseudo-op)
  #

  if (m/([A-Za-z][A-Za-z0-9]*)\s*=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))\s*[*]\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    if (defined $3 or defined $7) {
      do_mul($1, $3, $7);
    } elsif (defined $3 and defined $8) {
      assign_var($1, (defined $5 or defined $9 ? 'N' : 'I'), $4 * $8);
    } else {
      printf(STDERR "jako: Syntax error in multiplication on line %d: '%s'\n", $line, $_);
    }
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9]*)\s*[*]=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    do_mul($1, $1, $2);
    next;
  }

  #
  # Divisive Operators:
  #
  # a = b    / c;     # div_[in]
  # a = b    / 5;     # div_i_ic (psuedo-op)
  # a = b    / 3.14;  # div_n_nc (psuedo-op)
  # a = 5    / b;     # div_ic_i (pseudo-op)
  # a = 3.14 / b;     # div_nc_n (pseudo-op)
  # a = 5    / 2;     # set_i (COMPILE-TIME EVALUATION)
  # a = 3.14 / 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 5    / 0.16;  # set_n (COMPILE-TIME EVALUATION)
  # a = 3.14 / 2;     # set_n (COMPILE-TIME EVALUATION)
  #
  # a /= b;           # div_[in]
  # a /= 5;           # div_i_ic (pseudo-op)
  # a /= 3.14;        # div_n_nc (pseudo-op)
  #

  if (m/([A-Za-z][A-Za-z0-9]*)\s*=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))\s*[\/]\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    if (defined $3 or defined $7) {
      do_div($1, $3, $7);
    } elsif (defined $3 and defined $8) {
      assign_var($1, (defined $5 or defined $9 ? 'N' : 'I'), $4 / $8);
    } else {
      printf(STDERR "jako: Syntax error in division on line %d: '%s'\n", $line, $_);
    }
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9]*)\s*[\/]=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+(\.\d+)))$/) {
    do_div($1, $1, $2);
    next;
  }

  #
  # Modular Arithmetic Operators:
  #
  # NOTE: No decimal numbers.
  #
  # a = b % c;
  # a = b % 4;
  # a = 9 % b;
  # a = 9 % 4;
  #
  # a %= b;
  # a %= 4;
  #

  if (m/([A-Za-z][A-Za-z0-9]*)\s*=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+))\s*[%]\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+))$/) {
    do_mod($1, $2, $5);
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9]*)\s*[%]=\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+))$/) {
    do_mod($1, $1, $2);
    next;
  }

  #
  # Bitwise Operators:
  #
  # a = b << 4;
  # a <<= 4;
  #
  # TODO: Can't really support shift amount as arg until sh[lr]_i_i ops are implemented.
  #

  if (m/([A-Za-z][A-Za-z0-9]*)\s*=\s*([A-Za-z][A-Za-z0-9_]*)\s*(<<|>>)\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+))$/) {
    do_shift($3 eq '<<' ? 'l' : 'r', $1, $2, $4);
    next;
  }

  if (m/([A-Za-z][A-Za-z0-9]*)\s*((<<|>>)=)\s*(([A-Za-z][A-Za-z0-9_]*)|(\d+))$/) {
    do_shift($4 eq '<<' ? 'l' : 'r', $1, $2, $5);
    next;
  }

  #
  # Miscellany:
  #

  if (m/^end$/) {
    printf "%-12s %-8s\n", '', 'end';
    next;
  }

  print STDERR "jako: Syntax error on line $line: '$_'.\n";
}

exit 0;

#
# End of file.
#
