###
# [break]

.namespace [ "Tcl" ]

.sub "&break"
  .param pmc argv :slurpy

  .local int argc
  argc = argv

  if argc == 0 goto noargs

  .return(TCL_ERROR,"wrong # args: should be \"break\"")

noargs:
  .return (TCL_BREAK, "")

.end
