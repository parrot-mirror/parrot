###
# [uplevel]

# Pretty much a copy of 'eval' except for the call_level...
# needs argument checking.

.HLL 'Tcl', 'tcl_group'
.namespace

.sub '&uplevel'
  .param pmc argv :slurpy
 
  .local int argc
  argc = elements argv
  if argc == 0 goto bad_args
  
  .local string expr
  .local int looper
 
  .local pmc compiler, pir_compiler, __call_level
  .get_from_HLL(compiler, '_tcl', 'compile')
  .get_from_HLL(pir_compiler, '_tcl', 'pir_compiler')
  .get_from_HLL(__call_level, '_tcl', '__call_level')

  # save the old call level
  .local pmc call_level, old_call_level
  .get_from_HLL(call_level, '_tcl', 'call_level')
  old_call_level = clone call_level

  .local pmc new_call_level
  new_call_level = argv[0]
 
  .local int defaulted 
  (new_call_level,defaulted) = __call_level(new_call_level)
  if defaulted == 1 goto skip

  $P1 = shift argv # pop the call level argument 
skip:

  expr = ''
  looper = 1
  argc = argv

loop:
  if looper == argc goto loop_done
  $S0 = argv[looper]
  concat expr, $S0
  inc looper
  if looper == argc goto loop_done
  concat expr,' '

  goto loop

loop_done:

  # Set the new level 
  assign call_level, new_call_level

  ($I0,$P0) = compiler(0,expr)
  $P1 = pir_compiler($I0,$P0)

  # can't quite tailcall this at the moment due to the hackish call_level
  $P0 = $P1()

  #restore the old level
  assign call_level, old_call_level

done:
  .return($P0)

bad_args:
  .throw('wrong # args: should be "uplevel ?level? command ?arg ...?"')
.end

