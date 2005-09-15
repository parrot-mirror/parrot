###
# [global]

.namespace [ "Tcl" ]

.sub "&global"
  .param pmc argv :slurpy

  .local int argc 
  argc = argv

  if argc == 0 goto badargs

  .local int call_level
  $P0 = find_global "_Tcl", "call_level"
  call_level = $P0
  unless call_level goto done # global doesn't work when already global.

  .local int ii
  ii = 0
  .local string varname
  .local string sigil_varname

loop:
  if ii == argc goto done
  varname = argv[ii]
  sigil_varname = "$" . varname

  push_eh no_such_var
    $P1 = find_global "Tcl", sigil_varname
  clear_eh

  store_lex call_level, sigil_varname, $P1

  inc ii
  goto loop
  
done:
  .return("")

no_such_var:
  $S0 = "can't read \""
  $S0 .= varname
  $S0 .= "\": no such variable"
  .throw($S0)

badargs:
  .throw("wrong # args: should be \"global varName ?varName ...?\"")

.end
