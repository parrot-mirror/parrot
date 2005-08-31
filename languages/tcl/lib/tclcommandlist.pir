.namespace [ "TclCommandList" ]

.HLL "Tcl", "tcl_group"

.include "languages/tcl/lib/returncodes.pir"

.sub __class_init @LOAD
  $P0 = getclass "TclList"
  $P0 = subclass $P0, "TclCommandList"
.end

.sub interpret method
  .local pmc retval
  .local int i, elems, return_type
  elems = self
  i     = 0

loop:
  if i == elems goto done
  $P0 = self[i]
  .local pmc interpret
  interpret = find_global "_Tcl", "interpret"
  (return_type, retval) = interpret($P0)
  inc i
  if return_type != TCL_OK goto done
  goto loop

done:
  .return(return_type, retval)
.end
