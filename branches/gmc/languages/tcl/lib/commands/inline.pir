#
# [inline <language> { code }]
#
# a partcl only command that should probably live in a loadable lib.
#
# Like eval, except that you must specify a registered compiler.

.namespace [ "Tcl" ]

.sub "&inline"
  .param pmc language
  .param pmc code

  $S1 = language
  $S2 = code
  $P1 = compreg $S1
  $I1 = typeof $P1
  if $I1 == .None goto fail
  $P0 = compile $P1, $S2
  $P0()

  .return (TCL_OK,"")

fail:
  $P1 = new String
  $P1 = "invalid language \""
  $P1 .= $S1
  $P1 .= "\" specified"
  .return (TCL_ERROR, $P1)
.end
