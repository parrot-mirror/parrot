###
# [array]

.HLL 'Tcl', 'tcl_group'
.namespace

#
# similar to but not exactly like [string]'s subcommand dispatch
#   - we pass in a boolean (array or not), the array itself, and the name
#   - we know we need an array name for *all* args, so we test for it here.

.sub '&array'
  .param pmc argv :slurpy

  .local int argc
  argc = argv

  if argc < 2 goto few_args  # subcommand *and* array name

  .local string subcommand_name
  subcommand_name = shift argv
  .local pmc subcommand_proc
  null subcommand_proc

  .get_from_HLL(subcommand_proc, '_tcl'; 'helpers'; 'array', subcommand_name)
  if_null subcommand_proc, bad_args

  .local int is_array
  .local string array_name
  .local pmc the_array
  
  array_name = shift argv

  .local int call_level
  .get_from_HLL($P0, '_tcl', 'call_level')
  call_level = $P0
  null the_array

  .local pmc __find_var
  .get_from_HLL(__find_var, '_tcl', '__find_var')
  the_array = __find_var(array_name)

  if_null the_array, array_no

  $I99 = does the_array, 'hash'
  if $I99==0 goto array_no

  is_array = 1
  goto scommand

array_no:
  is_array = 0

scommand:
  .return subcommand_proc(is_array,the_array,array_name,argv)

bad_args:
  $S0  = 'bad option "'
  $S0 .= subcommand_name
  $S0 .= '": must be anymore, donesearch, exists, get, names, nextelement, set, size, startsearch, statistics, or unset'
  .throw($S0)

few_args:
  .throw('wrong # args: should be "array option arrayName ?arg ...?"')

.end

.HLL '_Tcl', ''

.namespace [ 'helpers' ; 'array' ]

.sub 'exists'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc goto bad_args

  .return (is_array)

bad_args:
  .throw ('wrong # args: should be "array exists arrayName"')
.end

.sub 'size'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc goto bad_args

  if is_array == 0 goto size_none
  $I0 = the_array
  .return ($I0)

size_none:
  .return (0)

bad_args:
  .throw ('wrong # args: should be "array size arrayName"')
.end

.sub 'set'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc != 1 goto bad_args

  .local pmc elems
  elems = argv[0]

  .local pmc __list
  .get_from_HLL(__list, '_tcl', '__list')
  elems = __list(elems)

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
  .get_from_HLL(set, '_tcl', '__set')

  if_null the_array, new_array # create a new array if no var
  goto set_loop

new_array:
  the_array = new .TclArray
  set(array_name,the_array) # create an empty named array...

set_loop:
  key = elems[loop]
  inc loop
  val = elems[loop]
  inc loop
  
  # Do this just as if were were calling each set manually, as tcl's
  # error messages indicate it seems to.

  # equals creates an alias, so use assign.
  .local string subvar
  subvar = '' # why is this necessary, if we're doing an assign ???
  assign subvar, array_name
  subvar .= '('
  subvar .= key
  subvar .= ')'
  set(subvar, val) 

  if loop < count goto set_loop

  .return ('')

bad_args:
 .throw ('wrong # args: should be array set arrayName list')

odd_args:
 .throw ('list must have an even number of elements')
.end


.include 'iterator.pasm'
.sub 'get'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc > 1 goto bad_args

  .local string match_str
  # ?pattern? defaults to matching everything.
  match_str = '*'

  # if it's there, get it from the arglist
  if argc == 0 goto no_args
  match_str = shift argv

no_args:
  if is_array == 0 goto not_array

  .local pmc retval

  .local pmc iter, val
  .local string str

  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Glob.pbc'
  .local pmc globber
  globber = compreg 'PGE::Glob'
  .local pmc rule
  rule = globber(match_str)

  iter = new .Iterator, the_array
  iter = .ITERATE_FROM_START

  retval = new .String

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
  retval .= ' '
skip_space:
  inc count
  retval .= str
  retval .= ' '
  val = the_array[str]
  retval .= val

  branch push_loop

push_end:
  .return (retval)

bad_args:
  .throw('wrong # args: should be "array get arrayName ?pattern?"')

not_array:
  .throw('')
.end

.sub 'unset'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = argv
  if argc > 1 goto bad_args


  .local string match_str
  # ?pattern? defaults to matching everything.
  match_str = '*'

  # if it's there, get it from the arglist
  if argc == 0 goto no_args
  match_str = shift argv

no_args:
  if is_array == 0 goto not_array

  .local pmc retval

  .local pmc iter, val
  .local string str

  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Glob.pbc'
  .local pmc globber
  globber = compreg 'PGE::Glob'
  .local pmc rule
  (rule, $P0, $P1) = globber(match_str)

  iter = new .Iterator, the_array
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
  .return ('')


bad_args:
  .throw('wrong # args: should be "array unset arrayName ?pattern?"')

not_array:
  .throw('')
.end

.sub 'names'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local pmc retval

  .local int argc
  argc = argv
  if argc > 2 goto bad_args

  .local string mode, pattern
  mode = '-glob'
  pattern = '*'
  if argc == 0 goto skip_args
  if argc == 1 goto skip_mode

  mode = shift argv
skip_mode:
  pattern = shift argv
skip_args:

  .local pmc match_proc
  null match_proc

  push_eh bad_mode
    match_proc = find_global [ 'helpers'; 'array'; 'names_helper' ], mode
  clear_eh
  if_null match_proc, bad_mode

  if is_array == 0 goto not_array

  .return match_proc(the_array, pattern)

bad_args:
  .throw ('wrong # args: should be "array names arrayName ?mode? ?pattern?"')

bad_mode:
  $S0 = 'bad option "'
  $S0 .= mode
  $S0 .= '": must be -exact, -glob, or -regexp'
  .throw ($S0)

not_array:
  .throw('')
.end

.namespace [ 'helpers' ; 'array'; 'names_helper' ]

.sub '-glob'
  .param pmc the_array
  .param string pattern

  .local pmc iter
  .local string name

  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Glob.pbc'
  .local pmc globber, retval
  globber = compreg 'PGE::Glob'
  .local pmc rule
  rule = globber(pattern)

  iter = new .Iterator, the_array
  iter = .ITERATE_FROM_START

  retval = new .String

  .local int count
  count = 0

check_loop:
  unless iter goto check_end
  name = shift iter
  $P0 = rule(name)
  unless $P0 goto check_loop

  unless count goto skip_space
  retval .= ' '
skip_space:
  inc count
  retval .= name

  branch check_loop
check_end:

  .return (retval)
.end

.sub '-exact'
  .param pmc the_array
  .param string match

  .local pmc iter, retval
  .local string name

  iter = new .Iterator, the_array
  iter = .ITERATE_FROM_START

  retval = new .String
  retval = ''

check_loop:
  unless iter goto check_end
  name = shift iter

  if name == match goto found_match
  branch check_loop
check_end:
  .return (retval)

found_match:
  retval = name
  .return (retval)
.end

.sub '-regexp'
  .param pmc the_array
  .param string pattern

  .local pmc iter
  .local string name

  load_bytecode 'PGE.pbc'
  .local pmc tclARE, retval
  tclARE = compreg 'PGE::P5Regex'
  .local pmc rule
  rule = tclARE(pattern)

  iter = new .Iterator, the_array
  iter = .ITERATE_FROM_START

  retval = new .String

  .local int count
  count = 0

check_loop:
  unless iter goto check_end
  name = shift iter
  $P0 = rule(name)
  unless $P0 goto check_loop

  unless count goto skip_space
  retval .= ' '
skip_space:
  inc count
  retval .= name

  branch check_loop
check_end:

  .return (retval)
.end
