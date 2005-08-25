###
# [eval]

#
# eval arg [... arg arg]

.namespace [ "Tcl" ]

.sub "eval"
  .param pmc argv :slurpy
 
  .local string expr
  .local int argc
  argc = argv
  unless argc goto no_args
 
  .local int looper
 
  .local pmc parse 
  parse = find_global "_Tcl", "parse"

  expr = ""
  looper = 0

loop:
  if looper == argc goto loop_done
  $S0 = argv[looper]
  concat expr, $S0
  inc looper
  if looper == argc goto loop_done
  concat expr," "

  goto loop

loop_done:
  $P1 = parse(expr)
  register $P1

  .return $P1."interpret"() 

no_args:
  $P1 = new String
  $P1 = "wrong # args: should be \"eval arg ?arg ...?\""
  .return(TCL_ERROR, $P1)

.end
