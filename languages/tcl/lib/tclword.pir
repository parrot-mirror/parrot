.include "languages/tcl/lib/returncodes.pir"

.namespace [ "TclWord" ]

.HLL "Tcl", "tcl_group"

.cloneable()

=head1 Methods

TclWord defines the following methods:

=head2 __class_init

Define the attributes required for the class.

=cut

.sub __class_init :load
  $P0 = getclass "TclList"
  $P1 = subclass $P0, "TclWord"
.end

.sub compile :method
  .param int register_num

  .local int i, len
  i   = 0
  len = self
  
  .local string pir_code,temp_code
  pir_code = ""
  .local pmc compiled_args
  compiled_args = new .TclList

  .local pmc compiler
  compiler = find_global "_Tcl", "compile_dispatch"

loop:
  if i == len goto loop_done
   
  $P0 = self[i]

  (register_num,temp_code) = compiler($P0,register_num)
  pir_code .= temp_code
  push compiled_args, register_num
  inc register_num 
  inc i
  goto loop

loop_done:
  # now concat all these pieces together.
  i = 0 
  pir_code .= "$P"
  $S0 = register_num
  pir_code .= $S0
  pir_code .= "=new .TclString\n"
  pir_code .= "$P"
  pir_code .= $S0
  pir_code .= "=\"\"\n"

  .local string catenate
  catenate = "$P%i = $P%i . $P%i\n"
  $P1 = new .Array
  $P1 = 3
  $P1[0] = register_num
  $P1[1] = register_num

concat_loop:
  if i == len goto concat_loop_done

  $P0 = compiled_args[i]
  
  $P1[2] = $P0
  temp_code = sprintf catenate, $P1 
  pir_code .= temp_code
  inc i
  goto  concat_loop
  
concat_loop_done:
  .return(register_num,pir_code)

.end

# When we stringify, because we inherit from TclList, we would normally
# get wrapping {}'s, which breaks if we're actually using this result
# to compile code.

# XXX This is still a bit of hack, though. Someone should construct
#     more torturous tests that excercize our ability to parse code
#     at compile time. 

.sub __get_string :method

  $P1 = new .String

  .local int i, len, register_num, result_num
  i   = 0
  len = self
  
  .local string temp_code,pir_code

  .local pmc compiler, pir_compiler
  compiler = find_global "_Tcl", "compile_dispatch"
  pir_compiler = find_global "_Tcl", "pir_compiler" 
 
  register_num = 0
loop:
  if i == len goto loop_done
   
  $P0 = self[i]

  (result_num,temp_code) = compiler($P0,register_num)
  pir_code .= temp_code
  register_num  = result_num + 1
  inc i
  goto loop

loop_done:

  $P1 = pir_compiler(result_num,temp_code)
  $P2 = $P1() 
  .return ($P2)

.end
