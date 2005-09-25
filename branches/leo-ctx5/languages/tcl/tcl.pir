#
# _main
#
# Setup the information the interpreter needs to run,
# then parse and interpret the tcl code we were passed.

.HLL "Tcl", "tcl_group"

.include "languages/tcl/lib/returncodes.pir"

.sub _main @MAIN
  .param pmc argv

  load_bytecode "languages/tcl/lib/tcllib.pbc"

  .local pmc retval,source
  .local string mode,chunk,contents,filename
  .local int argc,retcode

  # start with a new pad...
  new_pad 0

  source = find_global "Tcl", "&source"

  .local pmc tcl_interactive
  tcl_interactive = new TclInt
  store_global "Tcl", "$tcl_interactive", tcl_interactive

  argc = argv
  if argc > 1 goto open_file

  tcl_interactive = 1

  # If no file was specified, read from stdin.

  .local string input_line
  .local pmc STDIN,STDOUT
  STDIN = getstdin
  STDOUT = getstdout

  .local pmc parse
  parse = find_global "_Tcl", "parse"
  input_line = ""

  print "% " # XXX Doesn't respect a set tcl_prompt1
  STDOUT."flush"()
input_loop:
  $S0 = readline STDIN
  input_line .= $S0
  unless STDIN goto done
  push_eh loop_error
    $P1 = parse(input_line)
    retval = $P1."interpret"()
  clear_eh
  # print out the result of the evaluation.
  if_null retval, input_loop_continue
  if retval == "" goto input_loop_continue
  print retval
  print "\n"
  goto input_loop_continue

loop_error:
  # Are we just missing a close-foo? XXX probably not the best way to check.
  $P0 = P5[0] # message
  $S0 = $P0
  if $S0 == "missing close-brace" goto input_loop
  if $S0 == "missing quote"       goto input_loop
  
loop_error_real:
  .get_stacktrace(P5,$S0)
  print $S0
  print "\n"
  goto input_loop_continue

input_loop_continue:
  print "% " # XXX Doesn't respect a set tcl_prompt1
  STDOUT."flush"()
  input_line = ""
  goto input_loop

open_file: 
  tcl_interactive = 0
  filename = argv[1]
  push_eh file_error
    source(filename)
  clear_eh

done:
  end

file_error:
  .include "except_severity.pasm"
  $I0 = P5[2]  # _severity
  if $I0 == .EXCEPT_EXIT goto exit_exception
  .get_stacktrace(P5,$S0)
  print $S0
  end 

exit_exception:
  .rethrow() 
.end
