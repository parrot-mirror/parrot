#! /usr/bin/perl -w
#
# disassemble.pl
#
# Turn a parrot bytecode file into text.
#
# Copyright (C) 2001 The Parrot Team. All rights reserved.
# This program is free software. It is subject to the same license
# as the Parrot interpreter.
#
# $Id$
#

use strict;

use Parrot::Config;
use Parrot::Opcode;
use Parrot::Types;
use Parrot::PackFile;
use Parrot::PackFile::ConstTable;
use Parrot::String;

use Data::Dumper;
$Data::Dumper::Useqq  = 1;
$Data::Dumper::Terse  = 1;
$Data::Dumper::Indent = 0;


#
# GLOBAL VARIABLES:
#

my %opcodes            = Parrot::Opcode::read_ops();
my $opcode_fingerprint = Parrot::Opcode::fingerprint();
my @opcodes;
for my $name (keys %opcodes) {
    $opcodes[$opcodes{$name}{CODE}] = { NAME => $name,
					%{$opcodes{$name}} };
}


#
# dump_const_table()
#

sub dump_const_table {
    my ($pf) = @_;

    #
    # Check for the opcode table fingerprint:
    #
    # TODO: This is a really poor way to do this. Consider having a 'properties' table
    # as part of the file format. Then we can have whatever properties we want. Probably
    # these can be pairs of IVs as indexes into the constants table. Then we can have
    # a 'fingerprint' property if we want.
    #

    my $count = $pf->const_table->const_count;
    if ($count < 1) {
	warn "Disassembling without opcode table fingerprint (no constants)!";
	return;
    }

=no
    my $type = $pf->const_table->constant(0)->type;
    if ($type ne Parrot::PackFile::Constant->type_code('PFC_STRING')) {
        $type = Parrot::PackFile::Constant->type_name($type);
        warn "Disassembling without opcode table fingerprint (first constant isn't a string; type = '$type')!";
    }

    my $ref = ref $pf->const_table->constant(0)->value;
    if ($ref ne 'Parrot::String') {
        warn "Cannot disassemble (malformed string as first constant; type = '$ref'!";
    }

    my $data = ref $pf->const_table->constant(0)->value->data;
    if ($data ne $opcode_fingerprint) {
        warn "Cannot disassemble (differing opcode table; data = '$data')!";
    }
=cut

    #
    # Dump the constant table:
    #

    print "#\n";
    print "# Constant  Type          Data\n"; 
    print "# --------  ------------  ------------------------------\n"; 

    my $constant_num = 0;

    foreach ($pf->const_table->constants) {
      my $value;
      my $type  = Parrot::PackFile::Constant->type_name($_->type + 0);

      if ($type eq 'PFC_STRING') {
        $value = Dumper($_->value->data);
      } else {
        $value = Dumper($_->value);
      }

      printf("# %8ld  %-12s  %-30s\n", $constant_num, $type, $value);

      $constant_num++;
    }

    print "#\n";
}


#
# disassemble_byte_code()
#

sub disassemble_byte_code {
    my ($pf) = @_;

    my $cursor = 0;

    my $offset=0;
    my $bytecode = defined $pf->byte_code ? $pf->byte_code : '';
    my $length = length($bytecode);

    my $label_counter = 0;

    my %pasm;

    #
    # Scan the byte code, storing the disasembled ops and linking
    # branch destinations to autogenerated labels.
    #

    while ($offset < $length) {
	my $op_start = $offset;
	my $op_code = shift_op($bytecode);
	$offset += sizeof("op");

        if (!defined $op_code) {
            warn "$0: Unable to get next opcode at offset $op_start!\n";
            last;
        }

        if (!defined $opcodes[$op_code]) {
            warn "$0: Unrecognized opcode '$op_code' at offset $op_start!\n";
            next;
        }

        if (exists $pasm{$op_start}) {
            $pasm{$op_start} = [ $pasm{$op_start}[0], [ $op_code ], $opcodes[$op_code]{NAME}, [ ] ];
        } else {
            $pasm{$op_start} = [ undef,               [ $op_code ], $opcodes[$op_code]{NAME}, [ ] ];
        }

	my $arg_count = $opcodes[$op_code]{ARGS};
	my @args = ();

	foreach (0 .. $arg_count - 1) {
	    my $type        = $opcodes[$op_code]{TYPES}[$_];
	    my $unpack_size = sizeof($type);

	    if (($offset + $unpack_size) > $length) {
	        warn "$0: Premature end of bytecode in argument.\n";
	        last;
            }

	    my $arg = shift_arg($type, $bytecode);

            push @{$pasm{$op_start}[1]}, $arg;

	    $offset += $unpack_size;

	    if($type =~ m/^[INPS]$/) { # Register
		push @{$pasm{$op_start}[3]}, $type . $arg;
	    } elsif($type eq "D") { # destination address
                my $dest = $op_start + sizeof('op') * $arg;
                if (!exists $pasm{$dest}) {
                    $pasm{$dest}    = [ "L" . $label_counter++, [ ], undef, [ ] ];
                } elsif (!defined $pasm{$dest}[0]) {
                    $pasm{$dest}[0] = "L" . $label_counter++;
                }
		push @{$pasm{$op_start}[3]}, $pasm{$dest}[0];
	    } elsif($type eq "n") { # number constant
		push @{$pasm{$op_start}[3]}, sprintf("[nc:$arg]");
	    } elsif($type eq "s") { # string constant
		push @{$pasm{$op_start}[3]}, sprintf("[sc:$arg]");
	    } else { # constant
		push @{$pasm{$op_start}[3]}, $arg;
	    }
	}
    }

    #
    # Print out the code:
    #

    printf "# WORD     BYTE         BYTE CODE                                         LABEL   OPERATION        ARGUMENTS\n";
    printf "# -------- ----------   ------------------------------------------------  ------  ---------------  --------------------\n";

    foreach my $pc (sort { $a <=> $b } keys %pasm) {
        my ($label, $code, $op_name, $args) = @{$pasm{$pc}};
        $label = defined $label ? "$label:" : '';
	printf "  %08x [%08x]:  %-48s  %-6s  %-15s  ", $pc / 4, $pc,
 	    join('  ', map { sprintf "%08x", $_ } @$code), $label, $op_name;
	print join(", ", @$args), "\n";
    }
}


#
# disassemble_file()
#

sub disassemble_file {
    my ($file_name) = @_;

    my $pf = Parrot::PackFile->new;
    $pf->unpack_file($file_name);

    printf "#\n";
    printf "# Disassembly of Parrot Byte Code from '%s'\n", $_;
    printf "#\n";
    printf "# Segments:\n";
    printf "#\n";
    printf "#   * Magic Number: %8d bytes\n", sizeof('iv');
    printf "#   * Fixup Table:  %8d bytes\n", $pf->fixup_table->packed_size;
    printf "#   * Const Table:  %8d bytes\n", $pf->const_table->packed_size;
    printf "#   * Byte Code:    %8d bytes (%d IVs)\n", length($pf->byte_code), length($pf->byte_code) / sizeof('iv');

    dump_const_table($pf);
    disassemble_byte_code($pf);
 
    undef $pf;

    return;
}


#
# MAIN PROGRAM:
#

@ARGV = qw(-) unless @ARGV;

foreach (@ARGV) {
    disassemble_file($_)
}

exit 0;

__END__

=head1 NAME

disassemble.pl - disassemble the byte code from Parrot Pack Files

=head1 SYNOPSIS

  perl disassemble.pl FILE

=head1 DESCRIPTION

Disassembles the Parrot Pack Files listed on the command line, or
from standard input if no file is named.

=head1 COPYRIGHT

Copyright (C) 2001 The Parrot Team. All rights reserved.

=head1 LICENSE

This program is free software. It is subject to the same license
as the Parrot interpreter.

