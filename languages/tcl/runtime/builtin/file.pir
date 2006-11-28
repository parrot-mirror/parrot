.HLL 'Tcl', 'tcl_group'
.namespace

.sub '&file'
  .param pmc argv :slurpy
  
  .local int argc
  argc = argv

  if argc == 0 goto few_args

  .local string subcommand_name
  subcommand_name = shift argv

  .local pmc options
  options = new .ResizablePMCArray
  push options, 'atime'
  push options, 'attributes'
  push options, 'channels'
  push options, 'copy'
  push options, 'delete'
  push options, 'dirname'
  push options, 'executable'
  push options, 'exists'
  push options, 'extension'
  push options, 'isdirectory'
  push options, 'isfile'
  push options, 'join'
  push options, 'link'
  push options, 'lstat'
  push options, 'mtime'
  push options, 'mkdir'
  push options, 'nativename'
  push options, 'normalize'
  push options, 'owned'
  push options, 'pathtype'
  push options, 'readable'
  push options, 'readlink'
  push options, 'rename'
  push options, 'rootname'
  push options, 'separator'
  push options, 'size'
  push options, 'split'
  push options, 'stat'
  push options, 'system'
  push options, 'tail'
  push options, 'type'
  push options, 'volumes'
  push options, 'writable'

  .local pmc select_option
  select_option  = get_root_global ['_tcl'], 'select_option'
  .local string canonical_subcommand
  canonical_subcommand = select_option(options, subcommand_name)

  .local pmc subcommand_proc

  subcommand_proc = get_root_global ['_tcl';'helpers';'file'], canonical_subcommand
  if_null subcommand_proc, bad_args

  .return subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...

few_args:
  tcl_error 'wrong # args: should be "file option ?arg ...?"'

.end

.HLL '_Tcl', ''
.namespace [ 'helpers'; 'file' ]

.sub 'normalize' # RT#40721: Stub for testing
  .param pmc argv
  $P0 = argv[0]
  .return ($P0)
.end

.sub 'join'
  .param pmc argv
  
  .local int argc
  argc = argv
  if argc == 0 goto bad_args

  .local string dirsep
  dirsep = '/' # RT#40730: should pull from parrot config.

  .local string result
  result = ''
  .local int ii
  ii = 0

name_loop:
  if ii == argc goto name_loop_done 

  .local string name,char
  name = argv[ii]

  char = substr name, 0, 1
  if char == dirsep goto absolute
  result .= name
  goto name_loop_next

absolute:
  result = name
 
name_loop_next:
  inc ii
  if ii == argc goto name_loop_done
  result .= dirsep
  goto name_loop

name_loop_done:
  .return(result)

bad_args:
  tcl_error 'wrong # args: should be "file join name ?name ...?"'
.end

.sub 'stat' 
  .param pmc argv
  
  .local int argc
  argc = argv

  if argc != 2 goto bad_args

  .local string file,varname
  file = shift argv
  varname = shift argv 

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh

  .local pmc __set
  __set = find_global '__set' 

  $P3 = new .TclArray
  $P1 = $P2[8]
  $P3['atime'] = $P1
  $P1 = $P2[10]
  $P3['ctime'] = $P1
  $P1 = $P2[0]
  $P3['dev'] = $P1
  $P1 = $P2[5]
  $P3['gid'] = $P1
  $P1 = $P2[1]
  $P3['ino'] = $P1
  $P1 = $P2[2]
  $P3['mode'] = $P1
  $P1 = $P2[9]
  $P3['mtime'] = $P1
  $P1 = $P2[3]
  $P3['nlink'] = $P1
  $P1 = $P2[7]
  $P3['size'] = $P1

  $I1 = $P2[2]
  $I2 = 0o170000   #S_IFMT
  $I3 = $I1 & $I2

  $P4 = find_global 'filetypes'  
  $S1 = $P4[$I3]
  $P3['type'] = $S1


  $P1 = $P2[4]
  $P3['uid'] = $P1

  __set(varname, $P3)

  .return('')

# RT#40731: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file state name varName"'
.end

.sub 'isdirectory'
  .param pmc argv
  
  .local int argc
  argc = argv

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh

  $I1 = $P2[2]
  $I3 = $I1 & 0o170000 #S_IFMT

  if $I3 == 0o040000 goto true # directory mask

  .return(0)

true:
  .return(1)

# RT#40732: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file isdirectory name"'

.end

.sub 'isfile'
  .param pmc argv
 
  .local int argc
  argc = argv

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh

  $I1 = $P2[2]
  $I3 = $I1 & 0o170000   #S_IFMT
  
  if $I3 == 0o100000 goto true # file mask
  
  .return(0)

true:
  .return(1)

# RT#40733: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file isfile name"'

.end

.sub 'type'
  .param pmc argv
  
  .local int argc
  argc = argv

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh

  $I1 = $P2[2]
  $I2 = 0o170000   #S_IFMT
  $I3 = $I1 & $I2

  $P4 = find_global 'filetypes'  
  $S1 = $P4[$I3]
  .return ($S1)

# RT#40734: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file type name"'
.end

.sub 'size'
  .param pmc argv
  
  .local int argc
  argc = argv

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh
  $I1 = $P2[7]
  .return ($I1)

# RT#40735: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file size name"'
.end

.sub 'atime'
  .param pmc argv
  
  .local int argc
  argc = argv

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh
  $I1 = $P2[8]
  .return ($I1)

# RT#40736: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file atime name"'
.end

.sub 'mtime'
  .param pmc argv
  
  .local int argc
  argc = argv

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new .OS
  push_eh no_file
    $P2 = $P1.'stat'(file)
  clear_eh
  $I1 = $P2[9]
  .return ($I1)

# RT#40737: should be more discriminating about the error messages .OS generates
no_file:
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  tcl_error $S0
bad_args:
  tcl_error 'wrong # args: should be "file mtime name"'
.end

# RT#40722: Stub for test parsing
.sub 'dirname'
  .param pmc argv
  .return(0)
.end

# RT#40723: Stub for test parsing
.sub 'tail'
  .param pmc argv
  .return(0)
.end

# RT#40724: Stub for test parsing
.sub 'readable'
  .param pmc argv
  .return(0)
.end

# RT#40725: Stub for test parsing
.sub 'delete'
  .param pmc argv
  .return(0)
.end

.sub 'exists'
    .param pmc argv

    .local int argc
    argc = elements argv
    if argc != 1 goto badargs

    .local pmc os
    os = new .OS
    $S0 = argv[0]
    push_eh false
      $P0 = os.'stat'($S0)
    clear_eh

    .return(1)

false:
    .return(0)

badargs:
    tcl_error 'wrong # args: should be "file exists name"'
.end

# RT#40727: Stub for test parsing
.sub 'copy'
  .param pmc argv
  .return(0)
.end

# RT#40728: Stub for test parsing
.sub 'rootname'
  .param pmc argv
  .return(0)
.end

.sub 'extension'
    .param pmc argv
    .local int argc

    # check if filename arg exists
    argc = elements argv
    if argc != 1 goto bad_args

    # get our filename
    $S0 = argv[0]

    # test if filename has dots
    $I0 = index $S0, '.'
    if $I0 == -1 goto no_dot

    # calculate file extension
    $P0 = split '.', $S0
    $S1 = pop $P0
    # include dot
    $S1 = '.' . $S1

    .return($S1)

  no_dot:
    .return('')

  bad_args:
    tcl_error 'wrong # args: should be "file ext name"'
.end

# XXX: Stub
.sub 'owned'
  .param pmc argv
  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args
  .return(0)
bad_args:
  tcl_error 'wrong # args: should be "file owned name"'
.end
