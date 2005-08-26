###
# [unknown]

.namespace [ "Tcl" ]

.sub "&unknown"
  .param pmc argv :slurpy

  $S0 = join " ", argv
  $I1 = spawnw $S0

  $P1 = new String
  $P1 = ""
  .return(TCL_OK,$P1)
.end
