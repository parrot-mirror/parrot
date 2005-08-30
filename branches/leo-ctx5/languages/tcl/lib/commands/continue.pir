###
# [continue]

.namespace [ "Tcl" ]

.sub "&continue"
  .param pmc argv :slurpy
 
  .local int argc
  argc = argv

  if argc == 0 goto noargs

  .return(TCL_ERROR, "wrong # args: should be \"continue\"\n")

noargs:
  .return(TCL_CONTINUE, "")
.end
