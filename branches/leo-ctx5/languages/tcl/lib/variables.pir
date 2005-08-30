.namespace [ "_Tcl" ]

=head2 _Tcl::__read

Read a variable from its name. It may be a scalar or an
array.

Use the call level to determine if we are referring to a 
global variable or a lexical variable - will no doubt
require further refinement later as we support namespaces
other than the default, and multiple interpreters.

=cut

.sub __read
  .param string name
  
  .local pmc variable
  .local int return_type
  return_type = TCL_OK

  # is this an array?
  # ends with )
  .local int char
  char = ord name, -1
  if char != 41 goto scalar
  # contains a (
  char = index name, "("
  if char == -1 goto scalar

array:
  .local string var
  var = substr name, 0, char
  
  .local string key
  .local int len
  len = length name
  len -= char
  len -= 2
  inc char
  key = substr name, char, len
  
  variable = __find_var(var)
  if_null variable, no_such_variable
  
  $I0 = does variable, "hash"
  unless $I0 goto cant_read_not_array

  #$P1 = new String
  #$P1 = key
  #$I0 = exists $I0variable, $P1
  #unless $I0 goto bad_index

  variable = variable[key]
  if_null variable, bad_index 
  .return(TCL_OK, variable)

bad_index:
  $S0 = "can't read \""
  $S0 .= name
  $S0 .= "\": no such element in array"
  .return (TCL_ERROR, $S0)

cant_read_not_array:
  $S0 =  "can't read \""
  $S0 .= name
  $S0 .= "\": variable isn't array"
  .return (TCL_ERROR, $S0)

scalar:
  variable = __find_var(name)
  if_null variable, no_such_variable
  
  $I0 = does variable, "hash"
  if $I0 goto cant_read_array
  .return(TCL_OK,variable)

cant_read_array:
  $S0 = "can't read \""
  $S0 .= name
  $S0 .= "\": variable is array"
  .return (TCL_ERROR, $S0)

no_such_variable:
  $S0 = "can't read \""
  $S0 .= name
  $S0 .= "\": no such variable"
  .return (TCL_ERROR, $S0)
.end

=head2 _Tcl::__set

Set a variable by its name. It may be a scalar or an array.

Use the call level to determine if we are referring to a 
global variable or a lexical variable - will no doubt
require further refinement later as we support namespaces
other than the default, and multiple interpreters.

=cut

.sub __set
  .param string name
  .param pmc value

  .local pmc variable
  .local int return_type
  return_type = TCL_OK

  # is this an array?
  # ends with )
  .local int char
  char = ord name, -1
  if char != 41 goto scalar
  # contains a (
  char = index name, "("
  if char == -1 goto scalar

find_array:
  .local string var
  var = substr name, 0, char
  
  .local string key
  .local int len
  len = length name
  len -= char
  len -= 2
  inc char
  key = substr name, char, len
  
  .local pmc array
  null array
  array = __find_var(var)
  if_null array, create_array

  $I0 = does array, "hash"
  unless $I0 goto cant_set_not_array
  # goto set_array

set_array:
  array[key] = value
  variable = clone value
  .return(TCL_OK,variable)

create_array:
  array = new TclArray
  array[key] = value
  __store_var(var, array)
  variable = clone value
  .return(TCL_OK,variable)

cant_set_not_array:
  $S0 =  "can't set \""
  $S0 .= name
  $S0 .= "\": variable isn't array"
  .return(TCL_ERROR,$S0)

scalar:
  __store_var(name, value)
  variable = clone value
  .return(return_type, variable)

.end

=head2 _Tcl::__find_var

Utility function used by __read and __set.

Gets the actual variable from memory and returns it.

=cut

.sub __find_var
  .param string name
  name = "$" . name
  
  .local pmc value

  push_eh done
  $S0 = substr name, 1, 2
  if $S0 == "::"     goto coloned
  
  .local int call_level
  $P1 = find_global "_Tcl", "call_level"
  call_level = $P1
  if call_level == 0 goto global_var
lexical_var:
  null value
  value = find_lex call_level, name
  goto found

coloned:
  substr name, 1, 2, ""
global_var:
  null value
  value = find_global "Tcl", name
  # goto found

found:
  clear_eh

done:
  .return(value)
.end

=head2 _Tcl::__store_var

Utility function used by __read and __set.

Sets the actual variable from memory.

=cut

.sub __store_var
  .param string name
  .param pmc value
  name = "$" . name

  $S0 = substr name, 1, 2
  if $S0 == "::"     goto coloned

  .local int call_level
  $P1 = find_global "_Tcl", "call_level"
  call_level = $P1
  if call_level == 0 goto global_var
lexical_var:
  store_lex call_level, name, value
  .return()

coloned:
  substr name, 1, 2, ""
global_var:
  store_global "Tcl", name, value

  .return()
.end
