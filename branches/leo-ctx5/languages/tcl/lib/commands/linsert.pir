#
# [linsert]
#

.namespace [ "Tcl" ]

.sub "&linsert"
  .param pmc argv :slurpy  

    
  # make sure we have the right # of args
  .local int argc
  argc = argv
  if argc < 3 goto wrong_args

  .local int return_type
  .local pmc __list,retval
  __list = find_global "_Tcl", "__list"
  
  .local pmc the_list
  the_list = shift argv
  (return_type, retval) = __list(the_list)
  if return_type == TCL_ERROR goto error
  the_list = retval 
 
  .local pmc position
  position = shift argv

  .local pmc list_index
  list_index = find_global "_Tcl", "_list_index"

  (return_type,retval,$I2) = list_index(the_list,position)
  if return_type != TCL_OK goto error
  #linsert treats "end" differently
  if $I2 == 0 goto next
  inc retval

next: 
  .local int the_index
  the_index = retval

  # XXX workaround, splice doesn't work on TclList <-> TclList.
  # Until that's fixed, splice Arrays, then post-covert to a TclList
  # This is a hideous hack.

  .local int cnt
  cnt = 0
  $I1 = the_list
  .local pmc argv_list
  argv_list = new Array
  argv_list = $I1
LOOP:
  if cnt >= $I1 goto DONE
  $P1 = the_list[cnt]
  argv_list[cnt] = $P1
  inc cnt
  goto LOOP
DONE:
  argv_list = splice argv_list, the_index, 0

  .local pmc retval
  retval = new TclList

  .local int cnt
  cnt = 0

  .local int argc
  argc = argv_list
LOOP2:
  if cnt >= argc goto DONE2
  retval = argv_list[cnt]
  retval[cnt] = retval
  inc cnt
  goto LOOP2
DONE2:
  .return (TCL_OK,retval)

wrong_args:
  .return (TCL_ERROR, "wrong # args: should be \"linsert list index element ?element ...?\"")

error:
  .return(return_type,retval)
.end
