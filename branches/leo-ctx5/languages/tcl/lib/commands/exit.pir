###
# [exit]

.namespace [ "Tcl" ]

.sub "&exit"
  .param pmc argv :slurpy

  .local int argc
  argc = argv

  .local int exit_code
  exit_code = 0

  if argc > 2 goto badargs
  if argc == 0 goto done

  exit_code = argv[0]

done:
  exit exit_code

badargs:
  $P1 = new String
  $P1 = "wrong # args: should be \"exit ?returnCode?\"\n"
  .return(TCL_ERROR,$P1)
.end
