##
# [list]

.namespace [ "Tcl" ]

.sub "&llength"
  .param pmc argv :slurpy
  .local int argc
   argc = argv

  .local pmc listval
  if argc != 1 goto bad_args
  listval = argv[0]

  .local pmc retval
  .local int return_type

  .local pmc __list
  __list = find_global "_Tcl", "__list"

  (return_type, retval) = __list(listval)
  if return_type == TCL_ERROR goto done

list_like:
  $I0 = retval
  .return (TCL_OK, $I0)

done:
  .return(return_type,retval)

bad_args:
  .return(TCL_ERROR, "wrong # args: should be \"llength list\"")
.end
