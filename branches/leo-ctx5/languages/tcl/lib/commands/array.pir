###
# [array]

.namespace [ "Tcl" ]

#
# similar to but not exactly like [string]'s subcommand dispatch
#   - we pass in a boolean (array or not), the array itself, and the name
#   - we know we need an array name for *all* args, so we test for it here.

.sub "&array"
  .param pmc argv_slurpy :slurpy
  .local pmc argv
  argv = argv_slurpy

  .local int argc
  argc = argv

  if argc < 2 goto few_args  # subcommand *and* array name

  .local string subcommand_name
  subcommand_name = shift argv
  .local pmc subcommand_proc
  null subcommand_proc

  push_eh catch
    subcommand_proc = find_global "_Tcl\0builtins\0array", subcommand_name
resume:
  clear_eh
  if_null subcommand_proc, bad_args

  .local int is_array
  .local string array_name, sigil_array_name
  .local pmc the_array

  array_name = shift argv
  sigil_array_name = "$" . array_name

  .local int call_level
  $P0 = find_global "_Tcl", "call_level"
  call_level = $P0
  null the_array

  push_eh catch_var
    if call_level goto find_lexical
    the_array = find_global "Tcl", sigil_array_name
    goto resume_var
find_lexical:
    the_array = find_lex call_level, sigil_array_name
resume_var:
  clear_eh

  catch_var:

  if_null the_array, array_no
  $I99 = does the_array, "hash"
  if $I99==0 goto array_no

  is_array = 1
  goto scommand

array_no:
  is_array = 0

scommand:
  .return subcommand_proc(is_array,the_array,array_name,argv)

catch:
  goto resume

bad_args:
  $S0  = "bad option \""
  $S0 .= subcommand_name
  $S0 .= "\": must be anymore, donesearch, exists, get, names, nextelement, set, size, startsearch, statistics, or unset"

  .return(TCL_ERROR,$S0)

few_args:
  .return (TCL_ERROR, "wrong # args: should be \"array option arrayName ?arg ...?\"")

.end

.namespace [ "_Tcl\0builtins\0array" ]

.sub "exists"
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc goto bad_args

  .return (TCL_OK, is_array) 

bad_args:
  .return (TCL_ERROR, "wrong # args: should be \"array exists arrayName\"")
.end

.sub "size"
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc goto bad_args

  if is_array == 0 goto size_none
  $I0 = the_array
  .return (TCL_OK, $I0)

size_none:
  .return (TCL_OK, 0)

bad_args:
  .return (TCL_ERROR,"wrong # args: should be \"array size arrayName\"")
.end

.sub "set"
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc != 1 goto bad_args

  .local int return_type
  .local pmc retval

  .local pmc elems
  elems = argv[0]

  .local pmc __list
  __list = find_global "_Tcl", "__list"
  (return_type, retval) = __list(elems)
  if return_type == TCL_ERROR goto done
  elems = retval

pre_loop:
  .local int count
  count = elems
  $I0 = count % 2
  if $I0 == 1 goto odd_args

  # pull out all the key/value pairs and set them.
  .local int loop
  loop = 0
  .local string key
  .local pmc    val

  .local pmc set
  set = find_global  "_Tcl", "__set"

  if_null the_array, new_array
  goto set_loop

new_array:
  the_array = new .TclArray

set_loop:
  key = elems[loop]
  inc loop
  val = elems[loop]
  inc loop

  # = makes an alias :-(
  assign $S0, array_name
  $S0 .= "("
  $S0 .= key
  $S0 .= ")"
  (return_type, retval) = set($S0, val)
  if return_type == TCL_ERROR goto done

  if loop < count goto set_loop

  .return (TCL_OK, "")

bad_args:
 .return (TCL_ERROR, "wrong # args: should be array set arrayName list")

odd_args:
 .return (TCL_ERROR, "list must have an even number of elements")

done:
  .return (return_type,retval)

.end


.include "iterator.pasm"
.sub "get"
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc > 1 goto bad_args


  .local string match_str
  # ?pattern? defaults to matching everything.
  match_str = "*"

  # if it's there, get it from the arglist
  if argc == 0 goto no_args
  match_str = shift argv

no_args:
  if is_array == 0 goto not_array

  .local pmc retval

  .local pmc iter, val
  .local string str

  .local pmc globber

  globber = find_global "PGE", "glob"
  .local pmc rule
  (rule, $P0, $P1) = globber(match_str)

  iter = new Iterator, the_array
  iter = .ITERATE_FROM_START

  retval = new String


  .local int count
  count = 0

push_loop:
  unless iter goto push_end
  str = shift iter

  # check for match
  $P2 = rule(str)
  unless $P2 goto push_loop

  # if it's the first, we don't want to print a separating space
  unless count goto skip_space
  retval .= " "
skip_space:
  inc count
  retval .= str
  retval .= " "
  val = the_array[str]
  retval .= val

  branch push_loop

push_end:
  .return (TCL_OK, retval)

bad_args:
  .return(TCL_ERROR, "wrong # args: should be \"array get arrayName ?pattern?\"")

not_array:
  .return(TCL_ERROR, "")
.end

.sub "unset"
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  trace 1
  .local int argc
  argc = argv
  if argc > 1 goto bad_args


  .local string match_str
  # ?pattern? defaults to matching everything.
  match_str = "*"

  # if it's there, get it from the arglist
  if argc == 0 goto no_args
  match_str = shift argv

no_args:
  if is_array == 0 goto not_array

  .local pmc retval

  .local pmc iter, val
  .local string str

  .local pmc globber

  globber = find_global "PGE", "glob"
  .local pmc rule
  (rule, $P0, $P1) = globber(match_str)

  iter = new Iterator, the_array
  iter = .ITERATE_FROM_START

push_loop:
  unless iter goto push_end
  str = shift iter

 # check for match
  $P2 = rule(str)
  unless $P2 goto push_loop

  delete the_array[str]

  branch push_loop
push_end:
  .return (TCL_OK, "")


bad_args:
  .return(TCL_ERROR, "wrong # args: should be \"array unset arrayName ?pattern?\"")

not_array:
  .return(TCL_ERROR, "")
.end
