=head1 tcllib

This file contains all the PIR necessary to setup the basic C<Tcl>,
C<_Tcl>, and C<_TclWord> namespaces. These namespaces can then be used
by our own C<tcl.pir> to setup a tclsh-like interpreter, or to allow
other PIR programs to access procedures in our own namespaces, also
providing a compreg-compatible method.

=cut

# RT#40775: It would be nice to be able to reduce the # of times we call
# .HLL here and in the .included files to a minimum.

.HLL 'parrot', ''

.loadlib 'tcl_ops'
.include 'languages/tcl/src/macros.pir'
.include 'cclass.pasm'

.namespace [ 'TclExpr::PAST::Grammar' ]
.include 'languages/tcl/src/grammar/expr/pge2past.pir'

.namespace [ 'TclExpr::PIR::Grammar' ]
.include 'languages/tcl/src/grammar/expr/past2pir.pir'

.include 'languages/tcl/src/grammar/expr/past.pir'

# all the builtin commands (HLL: Tcl - loads 'tcl_group')
.include 'languages/tcl/runtime/builtins.pir'

# library files (HLL: _Tcl)
.include 'languages/tcl/runtime/conversions.pir'
.include 'languages/tcl/runtime/list_to_string.pir'
.include 'languages/tcl/runtime/string_to_list.pir'
.include 'languages/tcl/runtime/variables.pir'
.include 'languages/tcl/runtime/options.pir'

# class files (HLL: _Tcl)
.include 'languages/tcl/src/class/tclconst.pir'

# create the 'tcl' namespace -- see RT #39852
# http://rt.perl.org/rt3/Ticket/Display.html?id=39852
.HLL 'Tcl', ''
.namespace ['tcl']
.sub foo
  .return()
.end

.HLL '_Tcl', ''
.namespace

.sub __load_macros :load :anon
  $P0 = compreg 'PIR'
  $P0 = $P0(".sub main\n.include 'languages/tcl/src/macros.pir'\n.end")
  $P0()
.end

.sub __prepare_lib :load :anon

  # Load any dependant libraries.
  load_bytecode 'Getopt/Obj.pbc'
  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Glob.pbc'
  load_bytecode 'PGE/Text.pbc'                                                                                                                                  
  load_bytecode 'PGE/Util.pbc'
  load_bytecode 'TGE.pbc'

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
  set_root_global ['tcl'], '$env', tcl_env

  # set tcl_interactive
  push_eh non_interactive
    $P1 = get_root_global ['tcl'], '$tcl_interactive'
  clear_eh
  goto set_tcl_library 
 non_interactive:
  $P1 = new .TclInt
  $P1 = 0
  set_root_global ['tcl'], '$tcl_interactive', $P1

 set_tcl_library:
  # Set tcl_library:
  .local pmc    interp, config
  .local string slash
  interp = getinterp
  .include "iglobals.pasm"

  config = interp[.IGLOBALS_CONFIG_HASH]
  $S0 = config['build_dir']
  slash = config['slash']
  $S0 .= slash
  $S0 .= 'languages' 
  $S0 .= slash
  $S0 .= 'tcl' 
  $S0 .= slash
  $S0 .= 'library' 
  .local pmc tcl_library
  tcl_library = new 'TclString'
  tcl_library = $S0
  set_root_global ['tcl'], '$tcl_library', tcl_library

  # set tcl_platform
  $P1 = new 'TclArray'
  $P1['platform'] = 'parrot'
  set_root_global ['tcl'], '$tcl_platform', $P1
  $I1 = config['bigendian']
  if $I1 goto big_endian
  $P1['byteOrder'] = 'littleEndian'
  goto done_endian
 big_endian:
  $P1['byteOrder'] = 'bigEndian'

 done_endian: 
  $I1 = config['intsize']
  $P1['wordSize'] = $I1

  $S1 = config['osname']
  $P1['os'] = $S1

  # Set default precision.
  $P1 = new 'TclInt'
  $P1 = 0
  set_root_global ['tcl'], '$tcl_precision', $P1

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

  # Eventually, we'll need to register MMD for the various Tcl PMCs
  # (Presuming we don't do this from the .pmc definitions.)

  $P1 = new .TclArray
  store_global 'proc_args', $P1

  $P1 = new .TclDict
  store_global 'proc_defaults', $P1

  # Global variable initialization

   #version info
  $P0 = new .String
  $P0 = '0.1'
  set_root_global ['tcl'], '$tcl_patchLevel', $P0
  $P0 = new .String
  $P0 = '0.1'
  set_root_global ['tcl'], '$tcl_version', $P0
   
  #error information
  $P0 = new .TclString
  $P0 = 'NONE'
  set_root_global ['tcl'], '$errorCode', $P0
  $P0 = new .TclString
  $P0 = ''
  set_root_global ['tcl'], '$errorInfo', $P0

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

  # call chain of lex pads (for upvar and uplevel)
  $P1 = new .ResizablePMCArray
  store_global 'call_chain', $P1

  # Change counter: when something is compiled, it is compared to
  # This counter: if the counter hasn't changed since it was compiled,
  # it's safe to use the inline version (if available)
  # Otherwise fallback to the interpreted version.
  $P1 = new .Integer
  $P1 = 0
  store_global 'epoch', $P1

  # the regex used for namespaces
  .local pmc p6rule, colons
  p6rule = compreg "PGE::P6Regex"
  colons = p6rule('\:\:+')
  set_hll_global 'colons', colons

  # register the TCL compiler.
  $P1 = get_root_global ['_tcl'], '__script'
  compreg 'TCL', $P1
  
  # Setup a global to keep a unique id for compiled subs.
  $P1 = new .Integer
  $P1 = 0
  store_global 'compiled_num', $P1

.end

.HLL 'parrot', ''
.include 'languages/tcl/src/grammar/expr/expression.pir'
.include 'languages/tcl/src/grammar/expr/parse.pir'
.include 'languages/tcl/src/grammar/expr/functions.pir'
.include 'languages/tcl/src/grammar/expr/operators.pir'

# Load the standard library
.HLL 'Tcl', ''
.namespace

.sub __load_stdlib :load :anon
  .include "iglobals.pasm"
  .local pmc interp
  interp = getinterp
  $P1 = interp[.IGLOBALS_CONFIG_HASH]

  .local string slash
  slash = $P1['slash']

  .local pmc tcl_library
  tcl_library = get_global '$tcl_library'

  $S0 = tcl_library
  $S0 .= slash
  $S0 .= 'parray.tcl'

  .local pmc io, script
  io = getclass 'ParrotIO'
  $S0 = io.'slurp'($S0)

  script = get_root_global ['_tcl'], '__script'
  $P1 = script($S0)
  $P1()
.end
