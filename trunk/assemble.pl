#! /usr/bin/perl -w
#
# assemble.pl - take a parrot assembly file and spit out a bytecode file

use strict;

my(%opcodes, %labels);
my ($output, $opt_c);
if (@ARGV and $ARGV[0] eq "-c") {
    shift @ARGV;
    $opt_c = 1;
}

my %pack_type;
%pack_type = (i => 'l',
	      n => 'd',
	  );
my $sizeof_packi = length(pack($pack_type{i},1024));

open GUTS, "interp_guts.h";
my $opcode;
while (<GUTS>) {
    next unless /\tx\[(\d+)\] = ([a-z_]+);/;
    $opcodes{$2}{CODE} = $1;
}

open OPCODES, "<opcode_table" or die "Can't get opcode table, $!/$^E";
while (<OPCODES>) {
    next if /^\s*#/;
    chomp;
    s/^\s+//;
    next unless $_;
    my ($name, $args, @types) = split /\s+/, $_;
    $opcodes{$name}{ARGS} = $args;
    $opcodes{$name}{TYPES} = [@types];
}

my $pc = 0;
my @code;
my %constants;
my @constants;

# First scan for labels and strings
while (<>) {
    next if /^\s?#/;
    s/^\s*//;
    if (s/^\s*([a-zA-Z_]\w+):\s*//) { $labels{$1} = $pc; }
    1 while s/\"([^\\\"]*(?:\\.[^\\\"]*)*)\"/constantize($1)/eg;
    my ($opcode, @args) = split /\s+/, $_;
    push @code, $_;
    $pc += 1+@args;
}

emit_magic();
emit_fixup_section();
emit_constants_section();

# Now assemble
$pc = 0;
my $line = 0;
while ($_ = shift @code) {
    $line++;
    chomp;
    s/,/ /g;

    my ($opcode, @args) = split /\s+/, $_;

    if (!exists $opcodes{lc $opcode}) {
	die "No opcode $opcode at line $line:\n  <$_>\n";
    }
    if (@args != $opcodes{$opcode}{ARGS}) {
	die "wrong arg count--got ". scalar @args. " needed " . $opcodes{$opcode}{ARGS};
    }

    $args[0] = fixup($args[0])
        if $opcode eq "branch_ic" and $args[0] =~ /[a-zA-Z]/;

#    if ($opcode eq "eq_i_ic" or $opcode eq "lt_i_ic") {
    if ($opcode =~ /^(eq|ne|lt|le|gt|ge)_i_ic$/) {
        $args[2] = fixup($args[2]) if $args[2] =~ /[a-zA-Z]/;
        $args[3] = fixup($args[3]) if $args[3] =~ /[a-zA-Z]/;
    }
    if ($opcode eq "if_i_ic") {
        $args[1] = fixup($args[1]) if $args[1] =~ /[a-zA-Z]/;
        $args[2] = fixup($args[2]) if $args[2] =~ /[a-zA-Z]/;
    }

    $output .= pack "l", $opcodes{$opcode}{CODE};
    foreach (0..$#args) {
	$args[$_] =~ s/^[INPS]?(\d+)$/$1/i;
	my $type = $pack_type{$opcodes{$opcode}{TYPES}[$_]};
	$output .= pack $type, $args[$_];
    }
    $pc += 1+@args;
}

print $output unless (defined $opt_c and $opt_c);

sub fixup {
    my $l = shift;
    die "Unknown label $l" unless exists $labels{$l};
    return $labels{$l} - $pc;
}

sub constantize {
    my $s = shift;
    return $constants{$s} if exists $constants{$s};
    push @constants, $s;
    return $constants{$s} = $#constants;
}

sub emit_magic { $output .= pack($pack_type{i}, 0x13155a1) }

# Dummy for now.
sub emit_fixup_section { $output .= pack($pack_type{i}, 0) }

sub emit_constants_section {
    # First, compute how big it's going to be.
    # The fields we'll need to fill in are: strlen, flags, encoding, type
    my $size =0 ;
    for (@constants) {
        $size += 4*$sizeof_packi;
        $size += length($_);
        $size += length($_) % $sizeof_packi; # Padding
    }

    $size += $sizeof_packi if @constants; # That's for the number of constants
    $output .= pack($pack_type{i}, $size);
    return unless @constants; # Zero means end of segment.

    # Then spit out how many constants there are, so we can allocate
    $output .= pack($pack_type{i}, scalar @constants);

    # Now emit each constant
    for (@constants) {
        $output .= pack($pack_type{i},0) x 3; # Flags, encoding, type
        $output .= pack($pack_type{i},length($_)); # Strlen followed by that many bytes.
        $output .= $_;
        $output .= "\0" x (length($_) % $sizeof_packi); # Padding;
    }
}
