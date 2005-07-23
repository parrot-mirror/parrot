###
# [array]

.namespace [ "Tcl" ]

.sub "&array"
  .local pmc argv
  argv = foldup

  .local int argc
  argc = argv

  .local int return_type
  return_type = TCL_OK
  .local pmc retval

  if argc < 2 goto error
  .local string array_name
  .local pmc the_array
  .local int is_array

  array_name = argv[1]

  .local int call_level
  $P0 = find_global "_Tcl", "call_level"
  call_level = $P0

  push_eh catch
    if call_level goto find_lexical
    the_array = find_global "Tcl", array_name
    goto resume
find_lexical:
    the_array = find_lex call_level, array_name
resume:
  clear_eh
  catch:

  isnull the_array, array_no
  $I99 = does the_array, "hash"
  if $I99==0 goto array_no

  is_array = 1
  goto scommand

array_no:
  is_array = 0

scommand:

  .local string subcommand
  subcommand = argv[0]

  #if subcommand == "anymore" goto NOTDONEYET
  #if subcommand == "donesearch" goto NOTDONEYET
  if subcommand == "exists" goto exists
  #if subcommand == "get" goto NOTDONEYET
  #if subcommand == "names" goto NOTDONEYET
  #if subcommand == "nextelement" goto NOTDONEYET
  if subcommand == "set" goto set_it
  if subcommand == "size" goto size
  #if subcommand == "startsearch" goto NOTDONEYET
  #if subcommand == "statistics" goto NOTDONEYET
  #if subcommand == "unset" goto NOTDONEYET

  goto error

# Is this really an array?
exists:
  retval = new Integer
  retval = is_array
  goto done

size:
  retval = new Integer
  if is_array == 0 goto size_none
  $I0 = the_array
  retval = $I0
  goto done
size_none:
  retval = 0
  goto done

set_it:
  # array_name is getting stomped on here
  # print "array name: '"
  # print array_name
  # print "'\n"
  if argc != 3 goto set_bad_args

  .local pmc elems
  elems = argv[2]

  .local pmc __list
  __list = find_global "_Tcl", "__list"
  (return_type, retval) = __list(elems)
  if return_type == TCL_ERROR goto done
  elems = retval

set_pre_loop:
  .local int count
  count = elems
  $I0 = count % 2
  if $I0 == 1 goto set_odd_args

  # pull out all the key/value pairs and set them.
  .local int loop
  loop = 0
  .local string key
  .local string val

  # see if there's an existing array with this name to add to
  # and if not create a new array
  push_eh set_new_array
    if call_level goto get_lex
    the_array = find_global "Tcl", array_name
    goto set_has_array
  get_lex:
    the_array = find_lex call_level, array_name
set_has_array:
  clear_eh
  goto set_loop

set_new_array:
  the_array = new TclArray

set_loop:
  key = elems[loop]
  inc loop
  val = elems[loop]
  inc loop
  the_array[key] = val
  if loop < count goto set_loop

  # set the actual variable
  .local pmc set
  set = find_global  "_Tcl", "__set"
  (return_type, retval) = set(array_name, the_array)
  if return_type == TCL_ERROR goto done

  retval = new String
  retval = ""
  goto done


set_bad_args:
 return_type = TCL_ERROR
 retval = new String
 retval = "wrong # args: should be array set arrayName list"
 goto done

set_odd_args:
 return_type = TCL_ERROR
 retval = new String
 retval = "list must have an even number of elements"
 goto done

error:
  # XXX - this isn't the right error message.
  print "Bad call to array: \n"
  goto done

done:
  .return(return_type,retval)

.end
