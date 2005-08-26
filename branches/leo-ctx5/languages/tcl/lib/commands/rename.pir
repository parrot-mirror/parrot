###
# [rename]

.namespace [ "Tcl" ]

.sub "rename"
  .param pmc argv :slurpy

  .local int argc
  argc = argv

  if argc != 2 goto error
  .local string old_s
  old_s = argv[0]
  .local string new_s
  new_s = argv[1]

  .local int return_type
  .local pmc retval
  retval = new String

  return_type = TCL_OK
  retval = ""

  .local string old_proc,new_proc
  old_proc = "&" . old_s
  new_proc = "&" . new_s

  .local pmc theSub
  # If newName is empty, then just delete
  if new_s == "" goto delete

add:
  # Grab the original sub
  push_eh doesnt_exist
    theSub = find_global "Tcl", old_proc
  clear_eh
  # Create the new sub
  store_global "Tcl", new_proc, theSub

delete:
  null theSub
  store_global "Tcl", old_proc, theSub
  goto done

doesnt_exist:
  return_type = TCL_ERROR
  retval = "can't rename \""
  retval .= old_s
  retval .= "\": command doesn't exist"
  goto done

error:
  return_type = TCL_ERROR
  retval = "wrong # args: should be \"rename oldName newName\""

done:
  .return(return_type,retval)

.end
