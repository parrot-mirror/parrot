#
# [inline <language> { code }]
#
# a partcl only command that should probably live in a loadable lib.
#
# Like eval, except that you must specify a registered compiler.

.namespace [ "Tcl" ]

.sub "&inline"
  .param pmc argv :slurpy

  .local int argc 
  argc = argv

  .local string language,code

  language = argv[0]
  code     = argv[1]

  $P1 = compreg language
  $I1 = typeof $P1
  if $I1 == .None goto fail
  $P0 = compile $P1, code
  $P0()

  # XXX Should catch exceptions in the code and return the error message
  .return (TCL_OK,"")

fail:
  $P1 = new String
  $P1 = "invalid language \""
  $P1 .= $S1
  $P1 .= "\" specified"
  .return (TCL_ERROR, $P1)
.end
