#! perl -w
################################################################################
# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$
################################################################################

=head1 NAME

build_tools/build_nativecall.pl - Build up the native call routines

=head1 SYNOPSIS

    % perl build_tools/build_nativecall.pl call_list.txt

=head1 DESCRIPTION

This script creates the Native Call Interface file F<src/nci.c>. It
parses a file of function signatures of the form:

    <return-type-specifier><whitespace><parameter-type-specifiers>
    ...

The types specifiers are documented in F<src/call_list.txt>.

=head1 SEE ALSO

F<src/call_list.txt>.

=cut

################################################################################

my %ret_count;
%ret_count = (p => [0,0,0,1,0],        # Returning a pointer that we PMC stuff
              P => [0,0,0,1,0],	       # PMC
	      i => [0,1,0,0,0],        # Returning an int
	      3 => [0,1,0,0,0],        # Returning an int pointer
	      l => [0,1,0,0,0],        # Returning a long
	      c => [0,1,0,0,0],        # returning a char
	      s => [0,1,0,0,0],        # returning a short
	      f => [0,0,0,0,1],        # returning a float
	      d => [0,0,0,0,1],        # returning a double
	      t => [0,0,1,0,0],        # returning a string
	      v => [0,0,0,0,0],        # void return
#	      b => [0,0,1,0,0],        # Returns a buffer
#	      B => [0,0,1,0,0],        # Returns a buffer
	     );

my $tempcounter = 0;
my @extra_preamble = ();
my $extra_preamble;
my @extra_postamble = ();
my $extra_postamble;


my (%ret_type) = (p => "void *",
		  i => "int",
		  3 => "int *",
		  l => "long",
		  4 => "long *",
		  c => "char",
		  s => "short",
                  2 => "short *",
                  f => "float",
                  d => "double",
                  t => "char *",
		  v => "void",
#		  b => "void *",
#		  B => "void **",
		  P => "void *",
                 );

my (%proto_type) = (p => "void *",
		    i => "int",
		    3 => "int *",
		    l => "long",
		    4 => "long *",
		    c => "char",
		    s => "short",
                    2 => "short *",
		    f => "float",
		    d => "double",
		    t => "char *",
		    v => "void",
		    I => "struct Parrot_Interp *",
		    P => "PMC *",
		    b => "void *",
		    B => "void **",
		    L => "long *",
		    T => "char **",
		   );

my (%other_decl) = (p => "PMC *final_destination = pmc_new(interpreter, enum_class_UnManagedStruct);",
		    t => "STRING *final_destination;"
#		    b => "Buffer *final_destination = new_buffer_header(interpreter);\nPObj_external_SET(final_destination)",
#		    B => "Buffer *final_destination = new_buffer_header(interpreter);\nPObj_external_SET(final_destination)",
		   );

my (%ret_type_decl) = (p => "void *",
		       i => "int",
		       3 => "int *",
		       l => "long",
		       4 => "long *",
		       c => "char",
		       s => "short",
                       2 => "short *",
                       f => "float",
                       d => "double",
                       t => "char *",
		       v => "void *",
#		       b => "void *",
#		       B => "void **",
		       P => "void *",
                     );

my (%ret_assign) = (p => "PMC_data(final_destination) = return_data;\nREG_PMC(5) = final_destination;",
		    i => "REG_INT(5) = return_data;",
		    3 => "REG_INT(5) = *return_data;",
		    l => "REG_INT(5) = return_data;",
		    4 => "REG_INT(5) = *return_data;",
		    c => "REG_INT(5) = return_data;",
                    2 => "REG_INT(5) = *return_data;",
                    f => "REG_NUM(5) = return_data;",
                    d => "REG_NUM(5) = return_data;",
                    P => "REG_PMC(5) = return_data;",
		    v => "",
		    t => "final_destination = string_from_cstring(interpreter, return_data, 0);\nREG_STR(5) = final_destination;",
#		    b => "PObj_bufstart(final_destination) = return_data;\nREG_STR(5) = final_destination",
#		    B => "PObj_bufstart(final_destination) = *return_data;\nREG_STR(5) = final_destination",
		    s => "REG_INT(5) = return_data;",
                   );

my (%func_call_assign) = (p => "return_data = ",
			  i => "return_data = ",
			  3 => "return_data = ",
			  2 => "return_data = ",
			  4 => "return_data = ",
			  l => "return_data = ",
			  c => "return_data = ",
			  s => "return_data = ",
                          f => "return_data = ",
                          d => "return_data = ",
			  b => "return_data = ",
			  t => "return_data = ",
			  P => "return_data = ",
#			  B => "return_data = ",
		          v => "",
                          );

open NCI, ">src/nci.c" or die "Can't open nci.c!";

print NCI <<'HEAD';
/*
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically by build_nativecall.pl.
 *
 * Any changes made here will be lost!
 *
 */

/* nci.c
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Native Call Interface routines. The code needed to build a
 *     parrot to C call frame is in here
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */
#include "parrot/parrot.h"

/*
 * if the architecture can build some or all of these signatures
 * enable the define below
 * - the JITed function will be called first
 * - if it returns NULL, the hardcoded version will do the job
 */

#if defined(HAS_JIT) && defined(I386)
#  include "parrot/exec.h"
#  include "parrot/jit.h"
#  define CAN_BUILD_CALL_FRAMES
#endif

/* All our static functions that call in various ways. Yes, terribly
   hackish, but that's just fine */

static void
set_return_val(struct Parrot_Interp *interpreter, int stack, int ints,
               int strings, int pmcs, int nums) {
    REG_INT(0) = stack;
    REG_INT(1) = ints;
    REG_INT(2) = strings;
    REG_INT(3) = pmcs;
    REG_INT(4) = nums;
}

HEAD

# '
while (<>) {
    s/#.*$//;
    s/^\s*//;
    s/\s*$//;
    next unless $_;
    @extra_preamble = ();
    @extra_postamble = ();
    my ($ret, $args) = split /\s+/, $_;
    my @arg;
    my %reg_count;
    @reg_count{qw(p i s n)} = (5, 5, 5, 5);
    if (defined $args and not $args =~ m/^\s*$/ ) {
      foreach (split //, $args) {
	push @arg, make_arg($_, \%reg_count);
      }
    }

    # Header
    generate_func_header($ret, $args, (join ",", @arg), $ret_type{$ret},
			 $ret_type_decl{$ret}, $func_call_assign{$ret},
			 $other_decl{$ret},  $ret_assign{$ret});

    # Body

    # Footer
    set_return_count(@{$ret_count{$ret}});
}

$icky_global_bit = join("\n", @icky_global_variable);

print NCI <<TAIL;


/* This function serves a single purpose. It takes the function
   signature for a C function we want to call and returns a pointer
   to a function that can call it. */
void *
build_call_func(struct Parrot_Interp *interpreter, PMC *pmc_nci,
                STRING *signature)
{
    STRING *ns;
    STRING *message;
    char   *c;
    void   *result = NULL;
#if defined(CAN_BUILD_CALL_FRAMES)

    /* Try if JIT code can build that signature,
     * if yes, we are done
     */

     result = Parrot_jit_build_call_func(interpreter, pmc_nci, signature);

#endif
    if (result)
        return result;
    /* And in here is the platform-independent way. Which is to say
       "here there be hacks" */
    UNUSED(pmc_nci);
    if (0 == string_length(signature)) return F2DPTR(pcf_v_v);
    $icky_global_bit


    /*
      These three lines have been added to aid debugging. I want to be able to
      see which signature has an unknown type. I am sure someone can come up
      with a neater way to do this.
     */
    ns = string_make(interpreter, " is an unknown signature type", 30, NULL, 0, NULL);
    message = string_concat(interpreter, signature, ns, 0);

    /*
     * I think there may be memory issues with this but if we get to here we are
     * aborting.
     */
    c = string_to_cstring(interpreter, message);
    PANIC(c);
    return NULL;
}

TAIL

close NCI;


sub make_arg {
    my ($argtype, $reg_ref) = @_;
    /p/ && do {my $regnum = $reg_ref->{p}++;
	       return "PMC_data(REG_PMC($regnum))";
              };
    /i/ && do {my $regnum = $reg_ref->{i}++;
	       return "(int)REG_INT($regnum)";
              };
    /3/ && do {my $regnum = $reg_ref->{i}++;
	       return "(int*)&REG_INT($regnum)";
              };
    /l/ && do {my $regnum = $reg_ref->{i}++;
	       return "(long)REG_INT($regnum)";
              };
    /4/ && do {my $regnum = $reg_ref->{i}++;
	       return "(long*)&REG_INT($regnum)";
              };
    /s/ && do {my $regnum = $reg_ref->{i}++;
	       return "(short)REG_INT($regnum)";
              };
    /c/ && do {my $regnum = $reg_ref->{i}++;
	       return "(char)REG_INT($regnum)";
              };
    /2/ && do {my $regnum = $reg_ref->{i}++;
	       return "(short*)&REG_INT($regnum)";
              };
    /f/ && do {my $regnum = $reg_ref->{n}++;
	       return "(float)REG_NUM($regnum)";
              };
    /d/ && do {my $regnum = $reg_ref->{n}++;
	       return "(double)REG_NUM($regnum)";
              };
    /t/ && do {my $regnum = $reg_ref->{s}++;
	       return "string_to_cstring(interpreter, REG_STR($regnum))";
              };
    /b/ && do {my $regnum = $reg_ref->{s}++;
	       return "PObj_bufstart(REG_STR($regnum))";
              };
    /B/ && do {my $regnum = $reg_ref->{s}++;
	       return "(&PObj_bufstart(REG_STR($regnum)))";
              };
    /I/ && do {
	       return "interpreter";
              };
    /P/ && do {my $regnum = $reg_ref->{p}++;
               return "REG_PMC($regnum) == PMCNULL ? NULL : REG_PMC($regnum)";
              };
    /L/ && do {my $regnum = $reg_ref->{p}++;
	       my $tempnum = $tempcounter++;
	       push @extra_preamble, "long *tempvar$tempnum = Parrot_make_la(interpreter, REG_PMC($regnum));\n";
	       push @extra_postamble, "Parrot_destroy_la(tempvar$tempnum);\n";
	       return "tempvar$tempnum";
              };
    /T/ && do {my $regnum = $reg_ref->{p}++;
	       my $tempnum = $tempcounter++;
	       push @extra_preamble, "char **tempvar$tempnum = Parrot_make_cpa(interpreter, REG_PMC($regnum));\n";
	       push @extra_postamble, "Parrot_destroy_cpa(tempvar$tempnum);\n";
	       return "tempvar$tempnum";

              };
}

sub set_return_count {
    my ($stack, $int, $string, $pmc, $num) = @_;

    my $pmc_string;

    if( $pmc ) { $pmc_string = "return_data ? $pmc : 0" }
    else { $pmc_string = 0 }

    print NCI <<FOOTER;
    set_return_val(interpreter, $stack, $int, $string, $pmc_string, $num);
    return;
}


FOOTER
}

sub generate_func_header {
    my ($return, $params, $call_params, $ret_type, $ret_type_decl,
	$return_assign, $other_decl, $final_assign) = @_;
    $other_decl ||= "";

    if (defined $params) {
    my $proto = join ', ', map { $proto_type{$_} } split '', $params;
    $extra_preamble = join("", @extra_preamble);
    $extra_postamble = join("", @extra_postamble);
    print NCI <<HEADER;
static void
pcf_${return}_$params(struct Parrot_Interp *interpreter, PMC *self)
{
    typedef $ret_type (*func_t)($proto);
    func_t pointer;
    $ret_type_decl return_data;
    $other_decl
    $extra_preamble

    pointer =  (func_t)D2FPTR(PMC_struct_val(self));
    $return_assign ($ret_type)(*pointer)($call_params);
    $final_assign
    $extra_postamble
HEADER
  }
  else {
    print NCI <<HEADER;
static void
pcf_${return}(struct Parrot_Interp *interpreter, PMC *self)
{
    $ret_type (*pointer)(void);
    $ret_type_decl return_data;
    $other_decl
    $extra_preamble

    pointer =  ($ret_type (*)(void))D2FPTR(PMC_struct_val(self));
    $return_assign ($ret_type)(*pointer)();
    $final_assign
    $extra_postamble
HEADER
  }

  if (defined $params) {
  push @icky_global_variable, <<CALL;
    if (!string_compare(interpreter, signature,
      string_from_cstring(interpreter, "$return$params", 0)))
          return F2DPTR(pcf_${return}_$params);
CALL
  }
  else {
  push @icky_global_variable, <<CALL;
    if (!string_compare(interpreter, signature,
      string_from_cstring(interpreter, "$return", 0)))
          return F2DPTR(pcf_${return});
CALL
  }

}


=begin comment

This is the template thing

static void pcf_$funcname(struct Parrot_Interp *interpreter, PMC *self) {
    $ret_type (*pointer)();
    $ret_type return_data;

    pointer = PMC_struct_val(self);
    return_data = ($ret_type)(*pointer)($params);
    $ret_reg  = return_data;
    REG_INT(0) = $stack_returns;
    REG_INT(1) = $int_returns;
    REG_INT(2) = $string_returns;
    REG_INT(3) = $pmc_returns;
    REG_INT(4) = $num_returns;
    return;
}
EOR

}

=end comment
