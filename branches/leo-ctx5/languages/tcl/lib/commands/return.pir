###
# [return]

.namespace [ "Tcl" ]

.sub "&return"
   .param pmc argv :slurpy
 
  .local int argc 
  argc = argv

  if argc == 0 goto noargs
  if argc == 1 goto onearg

  # XXX use TCL_ERROR here...
  .return (TCL_ERROR, "XXX: bad call to return")

onearg:
  $P0 = argv[0]
  .return (TCL_RETURN, $P0)

noargs:
  .return (TCL_RETURN, "")

.end
