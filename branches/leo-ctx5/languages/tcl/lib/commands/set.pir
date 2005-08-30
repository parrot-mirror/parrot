###
# [set]

.namespace [ "Tcl" ]

.sub "&set"
  .param pmc argv :slurpy

  .local int len, argc  
  argc = argv

  .local pmc retval
  .local int return_type
  return_type = TCL_OK
 
  if argc == 0 goto error
  if argc > 2 goto error

  .local string name
  name = argv[0] 
  if argc == 2 goto setting
  if argc == 1 goto getting

getting:
  .local pmc read
  read = find_global "_Tcl", "__read"
  .return read(name)

setting:
  .local pmc set
  set = find_global "_Tcl", "__set"

  .local pmc value
  value = argv[1]
  .return set(name,value)

error:
  .return (TCL_ERROR, "wrong # args: should be \"set varName ?newValue?\"")

catch:
  goto resume
.end
