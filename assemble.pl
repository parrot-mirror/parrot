#! /usr/bin/perl -w
#
# assemble.pl - take a parrot assembly file and spit out a bytecode file
#   This is based heavily on assemble.pl by Dan Sugalski
# Brian Wheeler (bdwheele@indiana.edu)

use strict;
use Digest::MD5 qw(&md5_hex);
use Getopt::Long;

my %options;
GetOptions(\%options,('checksyntax',
		      'help',
		      'version',
		      'verbose',
		      'output=s',
		      'listing=s'));

if($options{'version'}) {
    print $0,'Version $Id$ ',"\n";
    exit;
}

if($options{'help'}) {
    print "$0 - Parrot Assembler
Options:
   --checksyntax        Check assembler syntax only, no output
   --help               This text
   --listing            Dump assembly listing to file
   --output             File to dump bytecode into
   --verbose            Show what's going on
   --version            Show assembler version
";
    exit;
}

if(exists($options{'output'}) && $options{'output'} eq "") {
    print STDERR "You must provide a file with --output flag!\n";
    exit;
}

if(exists($options{'listing'}) && $options{'listing'} eq "") {
    print STDERR "You must provide a file with --listing flag!\n";
    exit;
}

# define data types
my(%pack_type)=('i'=>'l','n'=>'d');
my(%real_type)=('I'=>'i','i'=>'i',
                'N'=>'i','n'=>'n',
                'S'=>'i','s'=>'i',
                'D'=>'i');

# compute sizes
my(%sizeof);
foreach (keys(%real_type)) {
    $sizeof{$_}=length(pack($pack_type{$real_type{$_}},0));
}
                

# get opcodes from guts.
open(GUTS, "<interp_guts.h") or
  open(GUTS, "<../interp_guts.h") or
  die "Can't get opcodes from guts, $!/$^E";
my %opcodes;
while (<GUTS>) {
    next unless /\tx\[(\d+)\] = ([a-z0-9_]+);/;
    $opcodes{$2}{CODE} = $1;
}
close GUTS;

# get opcodes and their arg lists
open(OPCODES, "<opcode_table") or
  open(OPCODES, "<../opcode_table") or
  die "Can't get opcode table, $!/$^E";
my $opcode_table;
while (<OPCODES>) {
    $opcode_table .= $_;
    next if /^\s*#/;
    chomp;
    s/^\s+//;
    next unless $_;
    my ($name, $args, @types) = split /\s+/, $_;
    my @rtypes=@types;
    @types=map { $_ = $real_type{$_}} @types;
    $opcodes{$name}{ARGS} = $args;
    $opcodes{$name}{TYPES} = [@types];
    $opcodes{$name}{RTYPES}=[@rtypes];
}
close OPCODES;
my $opcode_fingerprint = md5_hex($opcode_table);
constantize($opcode_fingerprint); # Make it constant zero.

my $listing="PARROT ASSEMBLY LISTING - ".scalar(localtime)."\n\n";



# read source and assemble
my $pc=0; my $op_pc=0;
my ($bytecode,%label,%fixup,%constants,@constants);
my $line=0;
while(<>) {
    $line++;
    chomp;
    my $sline=$_;
    s/^\s*//;
    s/\s*$//;
    if(/^\#/ || $_ eq "") {
	if($options{'listing'}) {
	    $listing.=sprintf("%4d %08x %-44s %s\n", $line, $op_pc, '',$sline);
	}
	next;
    }
    if(m/^((\S+):)?\s*(.+)?/) {
        my($label,$code)=($2,$3);
        if(defined($label) && $label ne "") {
            if(exists($label{$label})) {
                error("'$label' already defined!");
            }
            if(exists($fixup{$label})) {
                # backpatch everything with this PC.
                while(scalar(@{$fixup{$label}})) {
                    my $op_pc=shift(@{$fixup{$label}});
                    my $offset=shift(@{$fixup{$label}});
                    substr($bytecode,$offset,4)=pack('l',($pc-$op_pc)/4);
                }
                delete($fixup{$label});  
            }
            $label{$label}=$pc; # store it.
        }
        next if(!defined($code));
        1 while $code=~s/\"([^\\\"]*(?:\\.[^\\\"]*)*)\"/constantize($1)/eg;
        $code=~s/,/ /g;
        my($opcode,@args)=split(/\s+/,$code);
	$opcode=lc($opcode);
        if (!exists $opcodes{$opcode}) {
	    # try to determine _real_ opcode.
	    my @arg_t=();
	    foreach (@args) {
		if(m/^([INPS])\d+$/) {
		    # a register.
		    push @arg_t,lc($1);
		} else {
		    # a constant of some sort
		    if(m/^\[(\d+)\]$/) {
			# string
			push @arg_t,'sc';
		    } elsif(m/^((-?\d+)|(0b[01]+)|(0x[0-9a-f]+))$/i) {
			# integer
			push @arg_t,'ic';
		    } elsif(m/^[a-z][\w]*$/i) {
			# label
			push @arg_t,'ic';
		    } else {
			# numeric
			push @arg_t,'nc';
		    }
		}
	    }
	    my $test;
	    my($first,$last)=($arg_t[0],$arg_t[-1]);
	    if($first ne $last) {
		$test="${opcode}_${first}_$last";
	    } else {
		$test="${opcode}_$first";
	    }
	    my($found_op)=0;
	    foreach my $op (grep($_=~/^$opcode/,keys(%opcodes))) {
		if($op eq $test) {
		    log_message("substituting $op for $opcode");
		    $opcode=$op;
		    $found_op=1;
		    last;
		}
	    }
            error("No opcode $opcode in <$_>") if(!$found_op);
        }
        if (@args != $opcodes{$opcode}{ARGS}) {
            error("Wrong arg count--got ".scalar(@args)." needed ".$opcodes{$opcode}{ARGS});
        }
        $bytecode .= pack "l", $opcodes{$opcode}{CODE};
        $op_pc=$pc;
        $pc+=4;

        foreach (0..$#args) {
            my($rtype)=$opcodes{$opcode}{RTYPES}[$_];
            my($type)=$opcodes{$opcode}{TYPES}[$_];
            if($rtype eq "I" || $rtype eq "N" || $rtype eq "P" || $rtype eq "S") {
                # its a register argument
                $args[$_]=~s/^[INPS](\d+)$/$1/i;
                $pc+=$sizeof{$rtype}
            } elsif($rtype eq "D") {
                # a destination
                if(!exists($label{$args[$_]})) {
                    # we have not seen it yet...put it on the fixup list
                    push(@{$fixup{$args[$_]}},$op_pc,$pc);
                    $args[$_]=0xffffffff;
                } else {                    
                    $args[$_]=($label{$args[$_]}-$op_pc)/4;
                }
                $pc+=$sizeof{$rtype};
	    } elsif($rtype eq 's') {
		$args[$_]=~s/[\[\]]//g;
		$pc+=$sizeof{$rtype};           
            } else {
                $args[$_]=oct($args[$_]) if($args[$_]=~/^0/);
                $pc+=$sizeof{$rtype};           
            }
            $bytecode .= pack $type, $args[$_];
        }
	if($options{'listing'}) {
	    # add line to listing.
	    my $odata;
	    foreach (unpack('l*',substr($bytecode,$op_pc))) {
		$odata.=sprintf("%08x ",$_);
	    }
	    $listing.=sprintf("%4d %08x %-44s %s\n", $line, $op_pc, $odata,$sline);
	}
    }
}
$listing.="\n" if($options{'listing'});

my $output;

# build file in memory

# MAGIC COOKIE
$output=pack($pack_type{i},0x13155a1);


# FIXUP (also, dump listing symbols)
if($options{'listing'}) {
    $listing.="DEFINED SYMBOLS:\n";
    foreach (sort(keys(%label))) {
	$listing.=sprintf("\t%08x   %s\n",$label{$_},$_);
    }
}

if(keys(%fixup)) {
    print STDERR "SQUAWK!  These symbols were referenced but not
defined:\n";
    foreach (sort(keys(%fixup))) {
        print STDERR "\t$_ at pc: ";
        foreach my $pc (@{$fixup{$_}}) {
            print STDERR sprintf("%08x ",$pc);
        }
        print STDERR "\n";
    }
    $listing.="\nUNDEFINED SYMBOLS:\n";
    foreach (sort(keys(%fixup))) {
	$listing.="\t$_\n";
    }
    exit;  # some day, unresolved symbols won't be an error!
} else {
    # dump empty header
    $output.=pack($pack_type{i},0);
}

# CONSTANTS
if(@constants) {
    my($const);
    # Then spit out how many constants there are, so we can allocate
    $const .= pack($pack_type{i}, scalar @constants);

    if($options{'listing'}) {
	$listing.="\nSTRING CONSTANTS\n";
    }
    # Now emit each constant
    my $counter=0;
    for (@constants) {
        $const .= pack($pack_type{i},0) x 3; # Flags, encoding, type
        $const .= pack($pack_type{i},length($_)); # Strlen followed by that many bytes.
        $const .= $_;
        my $pad=(length($_) % $sizeof{i});
        if($pad) {
            $const .= "\0" x ($sizeof{i}-(length($_) % $sizeof{i})); # Padding;
	}
	$listing.=sprintf("\t%04x %08x [[%s]]\n",$counter,length($_),$_) 
	    if($options{'listing'});
	$counter++;
    }

    $output.=pack($pack_type{i},length($const));
    $output.=$const;
} else {
    # no constants, dump empty header.
    $output.=pack($pack_type{i},0);
}

## BYTECODE
$output.=$bytecode;

if(!$options{'checksyntax'}) {
    if(defined $options{'output'} and $options{'output'} ne "") {
	open O,">$options{'output'}" || die $!;
	print O $output;
	close O;
    } else {
	print $output;
    }
}


if($options{'listing'}) {
    open L,">$options{'listing'}" || die $!;
    print L $listing;
    close L;
}

sub error {
    my($message)=@_;
    print STDERR "Error ($line): $message\n";
    exit;
}

sub log_message {
    my($message)=@_;
    if($options{'verbose'}) {
	print STDERR "INFO ($line): $message\n";
    }
}


sub constantize {
    my $s = shift;
    # handle \ characters in the constant
    my %escape = ('a'=>"\a",'n'=>"\n",'r'=>"\r",'t'=>"\t",'\\'=>'\\',);
    $s=~s/\\([anrt\\])/$escape{$1}/g;
    if(!exists($constants{$s})) {
	push(@constants,$s);
	$constants{$s}=$#constants;
    }
    return "[".$constants{$s}."]";
}

