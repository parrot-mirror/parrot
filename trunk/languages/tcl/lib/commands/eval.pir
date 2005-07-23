###
# [eval]

#
# eval arg [... arg arg]

.namespace [ "Tcl" ]

.sub "&eval"
  .local pmc argv
  argv = foldup  
 
  .local string expr
  .local int argc
  argc = argv
  unless argc goto no_args
 
  .local int looper
 
  .local pmc parser
  .local pmc interpret 
  parser = find_global "_Tcl", "parser"  
  interpret = find_global "_Tcl", "__interpret"

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
  $P1 = parser."parse"(expr,0,0)
  register $P1

  .return interpret($P1) 

no_args:
  $P1 = new String
  $P1 = "wrong # args: should be \"eval arg ?arg ...?\""
  .return(TCL_ERROR, $P1)

.end
