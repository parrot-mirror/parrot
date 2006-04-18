.include 'languages/tcl/src/returncodes.pir'
.include 'languages/tcl/src/macros.pir'

.HLL 'parrot', ''
.namespace [ 'TclBinaryOp' ]

.cloneable()

  .const int OPERATOR_AND    = 26
  .const int OPERATOR_OR     = 27
  .const int OPERATOR_EQ     = 28
  .const int OPERATOR_NE     = 29
  .const int OPERATOR_BITAND = 30
  .const int OPERATOR_BITOR  = 31
  .const int OPERATOR_BITXOR = 32
  .const int OPERATOR_DIV    = 33
  .const int OPERATOR_EQUAL  = 34
  .const int OPERATOR_GT     = 35
  .const int OPERATOR_GTE    = 36
  .const int OPERATOR_LT     = 37
  .const int OPERATOR_LTE    = 38
  .const int OPERATOR_MINUS  = 39
  .const int OPERATOR_MOD    = 40
  .const int OPERATOR_MUL    = 41
  .const int OPERATOR_PLUS   = 42
  .const int OPERATOR_SHL    = 43
  .const int OPERATOR_SHR    = 44
  .const int OPERATOR_UNEQUAL= 45 

.macro binary_op(FORMAT)
  .sprintf3(op_code,.FORMAT,register_num,l_reg,r_reg)
  pir_code = l_code . r_code
  pir_code .= op_code
  goto done
.endm 

.macro binary_op2(FORMAT)
  .sprintf6(op_code, .FORMAT, register_num, l_reg, r_reg, register_num, register_num, register_num)

  pir_code = l_code . r_code

  pir_code .= op_code
  goto done
.endm

.macro binary_op3(FORMAT)
  .sprintf10(op_code,.FORMAT, l_reg, l_reg, r_reg, r_reg, register_num, l_reg, r_reg, register_num, register_num, register_num)

  pir_code = l_code . r_code
  pir_code .= op_code
  goto done
.endm 

=head2 __class_init

Define the attributes required for the class.

=cut

.sub __class_init :load
  $P0 = newclass "TclBinaryOp"
  addattribute $P0, "type"
  addattribute $P0, "l_operand"
  addattribute $P0, "r_operand"
.end

=head2 __init

Initialize the attributes for an instance of the class

=cut

.sub __init :method
  $P0 = new 'TclInt'
  setattribute self, "TclBinaryOp\x00type", $P0
  $P0 = new 'TclInt'
  setattribute self, "TclBinaryOp\x00l_operand", $P0
  $P0 = new 'TclInt'
  setattribute self, "TclBinaryOp\x00r_operand", $P0
.end

.sub compile :method
  .param int register_num

  .local string pir_code
  pir_code="# src/class/tclbinaryops.pir :: compile (1)\n"

  .local pmc retval
  retval = new 'TclInt'
  
  .local pmc op,l_operand, r_operand, compile
  op  = getattribute self, "TclBinaryOp\x00type"
  l_operand = getattribute self, "TclBinaryOp\x00l_operand"
  r_operand = getattribute self, "TclBinaryOp\x00r_operand"

  .get_from_HLL(compile,'_tcl','compile_dispatch')

  .local string l_code,r_code,op_code
  .local int l_reg,r_reg
  (l_reg,l_code) = compile(register_num, l_operand)
  register_num = l_reg + 1
  (r_reg,r_code) = compile(register_num, r_operand)
  register_num = r_reg + 1


  # Operands have a chance to be treated numerically. 
  # XXX This is overkill, as it tries to numerify things that
  #     we just declared as constants: more logic needs to go
  #     in here to only do this if we know it's of a certain 
  #     type.
  .local string temp_code
  temp_code = <<"END_PIR"
# src/class/tclbinaryops.pir :: compile (2)
  .local pmc __number
  .get_from_HLL(__number,'_tcl', '__number')
push_eh l_code_check_%s
  $P%s = __number($P%s)
clear_eh
l_code_check_%s:
END_PIR

  .sprintf4($S0, temp_code, l_reg, l_reg, l_reg, l_reg)
  l_code .= $S0

  temp_code = <<"END_PIR"
# src/class/tclbinaryops.pir :: compile (3)
push_eh r_code_check_%s
  $P%s = __number($P%s)
clear_eh
r_code_check_%s:
END_PIR
  .sprintf4($S0, temp_code, r_reg, r_reg, r_reg, r_reg)
  r_code .= $S0

  ## end numeric_check

  if op == OPERATOR_MUL goto op_mul
  if op == OPERATOR_DIV goto op_div
  if op == OPERATOR_MOD goto op_mod
  if op == OPERATOR_PLUS goto op_plus
  if op == OPERATOR_MINUS goto op_minus
  if op == OPERATOR_SHL goto op_shl
  if op == OPERATOR_SHR goto op_shr
  if op == OPERATOR_LT goto op_lt
  if op == OPERATOR_GT goto op_gt
  if op == OPERATOR_LTE goto op_lte
  if op == OPERATOR_GTE goto op_gte
  if op == OPERATOR_EQUAL goto op_equal
  if op == OPERATOR_UNEQUAL goto op_unequal
  if op == OPERATOR_BITAND goto op_bitand
  if op == OPERATOR_BITXOR goto op_bitxor
  if op == OPERATOR_BITOR goto op_bitor
  if op == OPERATOR_NE goto op_ne
  if op == OPERATOR_EQ goto op_eq
  if op == OPERATOR_AND goto op_and
  if op == OPERATOR_OR goto op_or

op_mul:
  .binary_op("$P%i = mul $P%i, $P%i\n")
op_div:
  .binary_op("$P%i = div $P%i, $P%i\n")
op_mod:
  .binary_op("$P%i = mod $P%i, $P%i\n")
op_plus:
  .binary_op("$P%i = $P%i + $P%i\n")
op_minus:
  .binary_op("$P%i = $P%i - $P%i\n")
op_shl:
  .binary_op("$P%i = shl $P%i, $P%i\n")
op_shr:
  .binary_op("$P%i = shr $P%i, $P%i\n")
op_lt:

  $S0 = <<"END_PIR"
$I%i=islt $P%i,$P%i
$P%i=new .TclInt
$P%i= $I%i
END_PIR

  .binary_op2($S0)
op_gt:

  $S0 = <<"END_PIR"
$I%i=isgt $P%i,$P%i
$P%i=new .TclInt
$P%i= $I%i
END_PIR

  .binary_op2($S0)
op_lte:

  $S0 = <<"END_PIR"
$I%i=isle $P%i,$P%i
$P%i=new .TclInt
$P%i= $I%i
END_PIR

  .binary_op2($S0)
op_gte:

  $S0 = <<"END_PIR"
$I%i=isge $P%i,$P%i
$P%i=new .TclInt
$P%i= $I%i
END_PIR

  .binary_op2($S0)
op_equal:

  $S0 = <<"END_PIR"
$I%i=iseq $P%i,$P%i
$P%i=new .TclInt
$P%i= $I%i
END_PIR

  .binary_op2($S0)
op_unequal:

  $S0 = <<"END_PIR"
$I%i=isne $P%i,$P%i
$P%i=new .TclInt
$P%i= $I%i
END_PIR

  .binary_op2($S0)
op_bitand:
  .binary_op("$P%i = band $P%i, $P%i\n")
op_bitxor:
  .binary_op("$P%i = bxor $P%i, $P%i\n")
op_bitor:
  .binary_op("$P%i = bor $P%i, $P%i\n")
op_ne:

   $S0 = <<"END_PIR"
$S%i=$P%i
$S%i=$P%i
$I%i=isne $S%i,$S%i
$P%i=new .TclInt
$P%i=$I%i
END_PIR

  .binary_op3($S0)
op_eq:

   $S0 = <<"END_PIR"
$S%i=$P%i
$S%i=$P%i
$I%i=iseq $S%i,$S%i
$P%i=new .TclInt
$P%i=$I%i
END_PIR

  .binary_op3($S0)
op_and:
  inc register_num 
  .local int jump_label 
  jump_label = register_num
  inc register_num

   $S0 = <<"END_PIR"
%s
unless $P%i goto false%i
%s
unless $P%i goto false%i
true%i:
$P%i=new .TclInt
$P%i=1
goto done%i
false%i:
$P%i=new .TclInt
$P%i=0
done%i:
END_PIR

  .sprintf14($S1, $S0, l_code, l_reg, jump_label, r_code, r_reg, jump_label, jump_label, register_num, register_num, jump_label, jump_label, register_num, register_num, jump_label)

  pir_code .= $S1

  goto done
op_or:
  inc register_num 
  .local int jump_label 
  jump_label = register_num
  inc register_num


  $S0 =<<"END_PIR"
%s
if $P%i goto true%i
%s
if $P%i goto true%i
false%i:
$P%i=new .TclInt
$P%i=0
goto done%i
true%i:
$P%i=new .TclInt
$P%i=1
done%i:
END_PIR

  .sprintf14($S1, $S0, l_code, l_reg, jump_label, r_code, r_reg, jump_label, jump_label, register_num, register_num, jump_label, jump_label, register_num, register_num, jump_label)

  pir_code .= $S1

done:
  .return(register_num, pir_code)

.end
