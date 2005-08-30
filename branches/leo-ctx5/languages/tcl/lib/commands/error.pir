###
# [error]

# XXX only handles the one arg form of error right now.
# need global vars before setting errorInfo, and stack tracing isn't
# ready yet.
# (So, the usage statement lies)

.namespace [ "Tcl" ]

.sub "&error"
  .param pmc argv :slurpy

  .local int argc 
  argc = argv

  if argc != 1 goto badargs

  $P0 = argv[0]
  .return (TCL_ERROR, $P0)

badargs:
  .return (TCL_ERROR, "wrong # args: should be \"error message ?errorInfo? ?errorCode?\"")
 
.end
