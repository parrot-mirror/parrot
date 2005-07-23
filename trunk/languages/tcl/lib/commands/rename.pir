###
# [rename]

.namespace [ "Tcl" ]

.sub "&rename"
  .param pmc old_p
  .param pmc new_p

  if I3 != 2 goto error

  .local int return_type
  .local pmc retval
  retval = new String 

  return_type = TCL_OK
  retval = ""

  .local string oldName
  .local string newName
  .local pmc commands
 
  oldName = old_p
  oldName = "&" . oldName
  newName = new_p
  newName = "&" . newName

  .local pmc theSub

  # If newName is empty, then just delete
  if newName == "" goto delete

add:
  # Grab the original sub 
  theSub = find_global "Tcl", oldName
  # Create the new sub
  store_global "Tcl", newName, theSub

delete:
  null theSub 
  store_global "Tcl", oldName, theSub

  goto done 

error:
  return_type = TCL_ERROR
  retval = "wrong # args: should be \"rename oldName newName\""

done:

  store_global "commands", commands

  .return(return_type,retval)
.end
