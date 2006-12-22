=head1 [proc]

Create a PIR sub on the fly for this user defined proc.

=cut

.HLL 'Tcl', 'tcl_group'
.namespace

.sub "&proc"
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv

  if argc != 3 goto error

  .local string full_name
  .local pmc args, body
  full_name = argv[0]
  args      = argv[1]
  body      = argv[2]

  .local pmc pir_compiler, __script, __list, __namespace
  pir_compiler = compreg "PIR"
  __script     = get_root_global ['_tcl'], '__script'
  __list       = get_root_global ['_tcl'], '__list'
  __namespace  = get_root_global ['_tcl'], '__namespace'
 
  .local pmc code, args_code, defaults
  .local string namespace
  code      = new 'PGE::CodeString'
  args_code = new 'PGE::CodeString'
  defaults  = new 'PGE::CodeString'
  namespace = ""

  .local pmc ns
  .local string name
  ns   = new .ResizablePMCArray
  name = ""

  if full_name == "" goto create
  
  ns   = __namespace(full_name, 1)
  $I0  = elements ns
  if $I0 == 0 goto create
  name = pop ns

  if $I0 == 1 goto root
  $P0 = get_hll_namespace ns
  if null $P0 goto unknown_namespace
  
  namespace = join "'; '", ns
  namespace = "['" . namespace
  namespace .= "']"
  goto create

root:
  # check to see if this is inlinable
  # if it is, we need to update the epoch
  $S0 = name
  $P1 = get_root_global ['_tcl'; 'builtins'], $S0
  if null $P1 goto create
  
  .local pmc epoch
  epoch = get_root_global ['_tcl'], 'epoch'
  inc epoch

  # now we need to delete the helper sub
  # so we don't try to inline anything else
  $P1 = get_root_namespace ['_tcl'; 'builtins']
  delete $P1[$S0]

create:
  code.emit(<<'END_PIR', namespace, name)
.HLL 'tcl', 'tcl_group'
.namespace %0
.sub '&%1'
  .param pmc args :slurpy
  .include 'languages/tcl/src/returncodes.pir'
  .local pmc epoch, colons, split, unk, interactive :unique_reg
  epoch  = get_root_global ['_tcl'], 'epoch'
  colons = get_root_global ['_tcl'], 'colons'
  split  = get_root_global ['parrot'; 'PGE::Util'], 'split'
  interactive = get_root_global ['tcl'], '$tcl_interactive'

  .local pmc call_chain, lexpad
  call_chain = get_root_global ['_tcl'], 'call_chain'
  lexpad = new .Hash
  push call_chain, lexpad
END_PIR

  .local string args_usage, args_info
  .local int i, elems, min, max, is_slurpy
  .local pmc arg
  args_usage = ""
  args_info  = ""
  args  = __list(args)
  i     = 0
  elems = elements args
  min   = 0
  max   = elems
  is_slurpy = 0
  if elems == 0 goto args_loop_done
  $I0 = elems - 1
  $S0 = args[$I0]
  if $S0 != "args" goto args_loop
  is_slurpy = 1
  dec elems
args_loop:
  if i == elems goto args_loop_done
  arg = args[i]
  arg = __list(arg)
  
  $S0 = arg[0]
  args_info .= $S0
  args_info .= " "
  
  $I0 = elements arg
  if $I0 > 2 goto too_many_fields
  if $I0 == 2 goto default_arg
  
  min = i + 1
  args_code.emit("  $P1 = shift args")
  args_code.emit("  lexpad['$%0'] = $P1", $S0)
  
  args_usage .= " "
  args_usage .= $S0
  goto args_next

default_arg:
    args_code.emit(<<'END_PIR', i, $S0, $S1)
  unless args goto default_%0
  $P1 = shift args
  lexpad['$%1'] = $P1
END_PIR

   $P1 = get_root_global ['_tcl'], 'proc_defaults'
   $P2 = $P1[full_name]
   if_null $P2, vivify_key
   goto got_default_key
vivify_key:
   $P2 = new .TclDict
   $P1[full_name] = $P2
got_default_key:
   $S0 = arg[0]
   $S1 = arg[1]
   $P2[$S0] = $S1

    defaults.emit(<<'END_PIR', i, $S0, $S1)
default_%0:
  $P1 = new TclString
  $P1 = '%2'
  lexpad['$%1'] = $P1
END_PIR

  args_usage .= " ?"
  args_usage .= $S0
  args_usage .= "?"

args_next:
  inc i
  goto args_loop

args_loop_done:
  chopn args_info,  1

  unless is_slurpy goto store_info
  args_usage .= " ..."
  args_info  .= " args"

store_info:
  # Save the args for the proc for [info args]
  # RT#40750: When dealing with defaults, this will have to be updated.
  $P1 = get_root_global ['_tcl'], 'proc_args'
  $P1[full_name] = args_info

    code .= <<'END_PIR'
  .local int argc
  argc = elements args
END_PIR

  code.emit("  if argc < %0 goto BAD_ARGS", min)
  if is_slurpy goto emit_args
  code.emit("  if argc > %0 goto BAD_ARGS", max)

emit_args:
  code .= args_code
  
  # Convert the remaining elements returned by foldup into a TclList
  # RT#40751: This code lifted from Tcl::&list - eventually factor this out.
  code.emit(<<"END_PIR")
  unless args goto NO_SLURPY_ARGS
  .local pmc arg_list
  arg_list = new .TclList
SLURPY_LOOP:
  unless args goto DONE
  $P0 = shift args
  push arg_list, $P0
  goto SLURPY_LOOP
NO_SLURPY_ARGS:
  arg_list=new .TclString
  arg_list=''
DONE:
  lexpad['args'] = arg_list
END_PIR

done_args:
  code.emit("  goto ARGS_OK")
  code .= defaults
  code.emit(<<"END_PIR", name, args_usage)
  goto ARGS_OK
BAD_ARGS:
  $P0 = pop call_chain
  tcl_error 'wrong # args: should be \"%0%1\"'
ARGS_OK:
  push_eh is_return
END_PIR

  # Save the parsed body.
  .local string parsed_body, body_reg
  (parsed_body, body_reg) = __script(body, 'pir_only'=>1)

  # Save the code for the proc for [info body]
  $P1 = get_hll_global ns, 'proc_body'
  unless null $P1 goto save_body
  $P1 = new .Hash
  set_hll_global ns, 'proc_body', $P1
save_body:
  $P1[name] = body

  code .= parsed_body
  
  code.emit(<<"END_PIR", body_reg)
  clear_eh
was_ok:
  $P0 = pop call_chain
  .return(%0)
END_PIR

  code .= <<"END_PIR"
is_return:
  .catch()
  .get_return_code($I0)
  $P0 = pop call_chain
  if $I0 == TCL_CONTINUE goto bad_continue
  if $I0 == TCL_BREAK    goto bad_break
  if $I0 != TCL_RETURN goto not_return_nor_ok
  .get_message($P0)
  .return ($P0)
bad_continue:
  tcl_error 'invoked "continue" outside of a loop'
bad_break:
  tcl_error 'invoked "break" outside of a loop'
not_return_nor_ok:
  .rethrow()
.end
END_PIR

  .local pmc pir_compiler
  pir_compiler = compreg "PIR"

  # (see note on trans_charset in lib/parser.pir) RT#40752:
  $S0 = code
  $I0 = find_charset 'ascii'
  $S0 = trans_charset $I0
  $P0 = pir_compiler($S0)

  .return ("")

unknown_namespace:
  $S0 = "can't create procedure \""
  $S0 .= full_name
  $S0 .= '": unknown namespace'
  tcl_error $S0

too_many_fields:
  $S0 = arg
  $S1 = 'too many fields in argument specifier "'
  $S1 .= $S0
  $S1 .= '"'
  tcl_error $S1
  
error:
  tcl_error 'wrong # args: should be "proc name args body"'
.end
