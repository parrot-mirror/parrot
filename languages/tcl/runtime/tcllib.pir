=head1 tcllib

This file contains all the PIR necessary to setup the basic C<Tcl>,
C<_Tcl>, and C<_TclWord> namespaces. These namespaces can then be used
by our own C<tcl.pir> to setup a tclsh-like interpreter, or to allow
other PIR programs to access procedures in our own namespaces, also
providing a compreg-compatible method.

=cut

.include 'languages/tcl/src/returncodes.pir'
.include 'languages/tcl/src/macros.pir'
.include 'cclass.pasm'

# don't pollute the global namespaces with our utility functions.

# setup some global constants (a bit TOO global, we should confine these
# to at least the _Tcl namespace)

# expression codes - we use TCL_OK there, so move these out high enough
# so there's no conflict.

  .const int OP      = 20
  .const int OPERAND = 11
 
  # Still not sure if these are going to be useful
  .const int BLOCK   = 14
  .const int COMMAND = 16


# Constants for operator/function lookup.

  .const int OPERATOR_AND    = 26
  .const int OPERATOR_OR     = 27
  .const int OPERATOR_EQ     = 28
  .const int OPERATOR_NE     = 29
  .const int OPERATOR_BITAND = 30
  .const int OPERATOR_BITOR  = 31
  .const int OPERATOR_BITXOR = 32
  .const int OPERATOR_DIV    = 33
  .const int OPERATOR_EQUAL  = 34
  .const int OPERATOR_GT     = 35
  .const int OPERATOR_GTE    = 36
  .const int OPERATOR_LT     = 37
  .const int OPERATOR_LTE    = 38
  .const int OPERATOR_MINUS  = 39
  .const int OPERATOR_MOD    = 40
  .const int OPERATOR_MUL    = 41
  .const int OPERATOR_PLUS   = 42
  .const int OPERATOR_SHL    = 43
  .const int OPERATOR_SHR    = 44
  .const int OPERATOR_UNEQUAL= 45

  .const int FUNCTION_ATAN2  = 46
  .const int FUNCTION_FMOD   = 47
  .const int FUNCTION_POW    = 48
  .const int OPERATOR_UMINUS = 49
  .const int OPERATOR_UPLUS  = 50
  .const int OPERATOR_BITNOT = 51
  .const int OPERATOR_LOGNOT = 52
  .const int FUNCTION_ABS    = 53
  .const int FUNCTION_ACOS   = 54
  .const int FUNCTION_ASIN   = 55
  .const int FUNCTION_ATAN   = 56
  .const int FUNCTION_COS    = 57
  .const int FUNCTION_COSH   = 58
  .const int FUNCTION_EXP    = 59
  .const int FUNCTION_LOG    = 60
  .const int FUNCTION_LOG10  = 61
  .const int FUNCTION_ROUND  = 62
  .const int FUNCTION_SIN    = 63
  .const int FUNCTION_SINH   = 64
  .const int FUNCTION_SQRT   = 65
  .const int FUNCTION_TAN    = 66
  .const int FUNCTION_TANH   = 67
  .const int FUNCTION_RAND   = 68

# all the builtin commands
.include 'languages/tcl/runtime/builtins.pir'

# library files
.include 'languages/tcl/runtime/conversions.pir'
.include 'languages/tcl/runtime/expression.pir'
.include 'languages/tcl/runtime/list.pir'
.include 'languages/tcl/runtime/list_to_string.pir'
.include 'languages/tcl/runtime/string.pir'
.include 'languages/tcl/runtime/string_to_list.pir'
.include 'languages/tcl/runtime/variables.pir'
.include 'languages/tcl/src/compiler.pir'
.include 'languages/tcl/src/parser.pir'

.HLL 'Tcl', 'tcl_group'
.HLL '_Tcl', ''

.sub __load_macros :load :anon
  $P0 = compreg 'PIR'
  $P0 = $P0(".sub main\n.include 'languages/tcl/src/macros.pir'\n.end")
  $P0()
.end

.sub __prepare_lib :load :anon

  # Load any dependant libraries.
  load_bytecode 'Getopt/Obj.pbc'
  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Util.pbc'

  #_load_grammar()

  # Expose Environment variables.
  .local pmc env,tcl_env,iterator
  env = new .Env
  tcl_env = new .TclArray
  
  iterator = new .Iterator, env
  iterator = 0

  .local string key,value
env_loop:
  unless iterator goto env_loop_done
  key = shift iterator
  value = env[key]
  tcl_env[key] = value

  goto env_loop

env_loop_done:
  .set_in_HLL('tcl', '$env', tcl_env)

  # keep track of names of file types.
  .local pmc filetypes
  filetypes = new .TclArray
  filetypes[0o060000] = 'blockSpecial'
  filetypes[0o020000] = 'characterSpecial'
  filetypes[0o040000] = 'directory'
  filetypes[0o010000] = 'fifo'
  filetypes[0o100000] = 'file'
  filetypes[0o120000] = 'link'
  filetypes[0o140000] = 'socket'

   store_global 'filetypes', filetypes

   .local pmc binary_types
   binary_types = new .TclArray
   binary_types['a'] = 1
   binary_types['A'] = 1
   binary_types['b'] = 1
   binary_types['B'] = 1
   binary_types['h'] = 1
   binary_types['H'] = 1
   binary_types['c'] = 1
   binary_types['s'] = 1
   binary_types['S'] = 1
   binary_types['i'] = 1
   binary_types['I'] = 1
   binary_types['w'] = 1
   binary_types['W'] = 1
   binary_types['f'] = 1
   binary_types['d'] = 1
   binary_types['x'] = 1
   binary_types['X'] = 1
   binary_types['@'] = 1

   store_global 'binary_types', binary_types

  .local pmc operators
  .local pmc math_funcs
  .local pmc precedence

  # XXX Should track how many args are needed for each of these.

  # Keep track of math functions
  math_funcs = new .TclArray

  math_funcs['abs']   = FUNCTION_ABS
  math_funcs['acos']  = FUNCTION_ACOS
  math_funcs['asin']  = FUNCTION_ASIN
  math_funcs['atan']  = FUNCTION_ATAN
  math_funcs['cos']   = FUNCTION_COS
  math_funcs['cosh']  = FUNCTION_COSH
  math_funcs['exp']   = FUNCTION_EXP
  math_funcs['log']   = FUNCTION_LOG
  math_funcs['log10'] = FUNCTION_LOG10
  math_funcs['sin']   = FUNCTION_SIN
  math_funcs['sinh']  = FUNCTION_SINH
  math_funcs['sqrt']  = FUNCTION_SQRT
  math_funcs['tan']   = FUNCTION_TAN
  math_funcs['tanh']  = FUNCTION_TANH

  operators = new .TclArray
  precedence = new .TclArray

  # XXX This precedence check should be shoved into [expr]. There's no need
  # to make it this generic. 

  operators['*'] = OPERATOR_MUL
  precedence['*'] = 1 
  operators['/'] = OPERATOR_DIV
  precedence['/'] = 1 
  operators['%'] = OPERATOR_MOD
  precedence['%'] = 1 
  operators['+'] = OPERATOR_PLUS
  precedence['+'] = 2
  operators['-'] = OPERATOR_MINUS
  precedence['-'] = 2 
  operators['<<'] = OPERATOR_SHL
  precedence['<<'] = 3 
  operators['>>'] = OPERATOR_SHR
  precedence['>>'] = 3 
  operators['<'] = OPERATOR_LT
  precedence['<'] = 4
  operators['>'] = OPERATOR_GT
  precedence['>'] = 4
  operators['<='] = OPERATOR_LTE
  precedence['<='] = 4 
  operators['>='] = OPERATOR_GTE
  precedence['>='] = 4
  operators['=='] = OPERATOR_EQUAL
  precedence['=='] = 5
  operators['!='] = OPERATOR_UNEQUAL
  precedence['!='] = 5
  operators['ne'] = OPERATOR_NE
  precedence['ne'] = 6
  operators['eq'] = OPERATOR_EQ 
  precedence['eq'] = 6
  operators['&'] = OPERATOR_BITAND
  precedence['&'] = 7
  operators['^'] = OPERATOR_BITXOR
  precedence['^'] =  8
  operators['|'] = OPERATOR_BITOR
  precedence['|'] = 9
  operators['&&'] = OPERATOR_AND
  precedence['&&'] = 10
  operators['||'] = OPERATOR_OR
  precedence['||'] = 11

  store_global 'operators', operators
  store_global 'functions', math_funcs
  store_global 'precedence', precedence

  # Eventually, we'll need to register MMD for the various Tcl PMCs
  # (Presuming we don't do this from the .pmc definitions.)

  $P1 = new .TclArray
  store_global 'proc_body', $P1

  $P1 = new .TclArray
  store_global 'proc_args', $P1

  # Global variable initialization

   #version info
  $P0 = new .String
  $P0 = '0.1'
  .set_in_HLL('tcl', '$tcl_patchLevel', $P0)
  $P0 = new .String
  $P0 = '0.1'
  .set_in_HLL('tcl', '$tcl_version', $P0)
   
  #error information
  $P0 = new .TclString
  $P0 = 'NONE'
  .set_in_HLL('tcl', '$errorCode', $P0)
  $P0 = new .TclString
  $P0 = ''
  .set_in_HLL('tcl', '$errorInfo', $P0)

  # Setup the default channelIds
  $P1 = new .TclArray
  $P2 = getstdin
  $P1['stdin'] = $P2
  $P2 = getstdout
  $P1['stdout'] = $P2
  $P2 = getstderr
  $P1['stderr'] = $P2
  store_global 'channels', $P1
  
  # Setup the id # for channels..
  $P1 = new .Integer
  $P1 = 1
  store_global 'next_channel_id', $P1

  # calling level (for upvar, uplevel, globals vs. lex)
  $P1 = new .Integer
  $P1 = 0
  store_global 'call_level', $P1

  # Change counter: when something is compiled, it is compared to
  # This counter: if the counter hasn't changed since it was compiled,
  # it's safe to use the inline version (if available)
  # Otherwise fallback to the interpreted version.
  $P1 = new .Integer
  $P1 = 0
  store_global 'epoch', $P1

  # register the TCL compiler.
  $P1 = find_global '_tcl_compile'
  compreg 'TCL', $P1
  
  # Setup a global to keep a unique id for compiled subs.
  $P1 = new .Integer
  $P1 = 0
  store_global 'compiled_num', $P1

.end

.sub _tcl_compile
  .param string tcl_code

  .local pmc compiled_num
  compiled_num = find_global 'compiled_num'
  inc compiled_num

  .local pmc compiler,pir_compiler
  compiler = find_global 'compile'
  pir_compiler = find_global 'pir_compiler'

  ($I0,$S0) = compiler(0,tcl_code)
  .return pir_compiler($I0,$S0)
.end
