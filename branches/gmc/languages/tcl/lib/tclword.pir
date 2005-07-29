=head1 TclWord

This object holds the result of parsing a tcl command. Internally,
It represents a word as discrete chunks, which are either finalized
or require interpolation. Each chunk is marked as such. When the
word is I<used> (at interpretation or at execution time), the required
interpolation occurs (either variable or command)

=head1 Attributes

Each TclWord has the following attributes:

=head2 chunks

an array of pairs of (type, content), where type/content is

=over 4

=item CONST 

a string

=item VARIABLE

an array suitable for passing to C<_Tcl::_get_var>

=item COMMAND

the result of a the parse step for a [] command, i.e.
a TclList of TclWords. 

=back

=head2 constant

An Integer PMC flag representing whether or not the value we hold is
constant. I<Used as a hint at compile time.>

=cut

.namespace [ "TclWord" ]

.HLL "Tcl", "tcl_group"

=head1 Methods

TclWord defines the following methods:

=head2 __class_init

Define the attributes required for the class.

=cut

.sub __class_init @LOAD
  newclass $P1, "TclWord"
  addattribute $P1, "chunks"
  addattribute $P1, "constant"
.end

=head2 __init

Initialize the attributes for an instance of the class

=cut

.sub __init method
  .local pmc emptyArray
  .local pmc constant

  emptyArray = new TclList

  setattribute self, "TclWord\x00chunks", emptyArray
  constant = new Integer
  constant = 1
  setattribute self, "TclWord\x00constant", constant
.end

=head2 clone

Clone a TclWord object.

=cut

.sub __clone method
  .local pmc chunks
  .local pmc constant
  
  chunks   = getattribute self, "TclWord\x00chunks"
  constant = getattribute self, "TclWord\x00constant"
  
  chunks   = clone chunks
  constant = clone constant
  
  .local pmc value
  $I0 = typeof self
  value = new $I0
  setattribute value, "TclWord\x00chunks", chunks
  setattribute value, "TclWord\x00constant", constant
  
  .return(value)
.end

=head2 concat_words

Given an array of words, append the chunks of a given word to the existing word 

=cut

.sub concat_words method
  .param pmc words

  .local pmc word
  .local pmc chunk

  .local pmc these_chunks,this_constant
  these_chunks = getattribute self, "TclWord\x00chunks" 
  this_constant = getattribute self, "TclWord\x00constant"

  .local pmc those_chunks,that_constant

  .local int num_words
  .local int word_num

  .local int num_chunks
  .local int chunk_num

  num_words = words
  word_num = 0
outer_loop:
  if word_num == num_words goto outer_loop_done 

  word = words[word_num]
  those_chunks = getattribute word, "TclWord\x00chunks"
  that_constant = getattribute word, "TclWord\x00constant"

  num_chunks = those_chunks
  chunk_num = 0

  if that_constant goto inner_loop
  this_constant = 0

inner_loop:   
  if chunk_num == num_chunks goto inner_loop_done

  chunk = those_chunks[chunk_num]
  push these_chunks, chunk
  inc chunk_num

  goto inner_loop

inner_loop_done:
  inc word_num

outer_loop_done:

  

.end

=head2 concat_char

Add a constant character to a TclWord

=cut

.sub concat_char method
  .param int arg

  .local pmc chunk
  .local pmc chunks
  .local string str
  
  str = chr arg

  chunk = new FixedPMCArray
  chunk = 2
  chunk[0] = 0
  chunk[1] = str

  chunks = getattribute self, "TclWord\x00chunks"
  push chunks, chunk
.end

=head2 concat_const

Add a constant string to a TclWord

=cut

.sub concat_const method
  .param string arg

  .local pmc chunk
  .local pmc chunks

  if arg == "" goto end
  chunk = new FixedPMCArray
  chunk = 2
  chunk[0] = 0
  chunk[1] = arg

  chunks = getattribute self, "TclWord\x00chunks"
  push chunks, chunk
end:
.end


=head2 concat_variable

Add the name of a variable to be interpolated to a TclWord. Takes the name
of the var, and an optional index for array variables.

=cut

.sub concat_variable method
  .param string var
  .param string idx

  .local pmc chunk
  .local pmc chunks
  .local pmc constant

  chunk = new ResizablePMCArray
  chunk[0] = 1
  chunk[1] = var

  # I2 == # string params.
  if I2 == 1 goto no_index
  chunk[2] = idx

no_index:
  chunks = getattribute self, "TclWord\x00chunks"
  constant = getattribute self, "TclWord\x00constant"
  constant = 0
  push chunks, chunk
.end

=head2 concat_command

Add a command to be interpolated to a TclWord. Takes the
text of the command, and stores the parsed version for
later interpretation.

=cut

.sub concat_command method
  .param string cmd

  .local pmc chunk,chunks,parsed_cmd,constant

  .local pmc parser 
  parser = find_global "_Tcl", "parser"
  parsed_cmd  = parser."parse"(cmd,0,0)
  register parsed_cmd

  chunk = new FixedPMCArray
  chunk = 2
  chunk[0] = 2
  chunk[1] = parsed_cmd

  chunks   = getattribute self, "TclWord\x00chunks"
  constant = getattribute self, "TclWord\x00constant"
  constant = 0
  push chunks, chunk
.end

=head2 __get_pmc

Return a PMC that contains the value of our word. If we're just a command,
evaluate the command and return the resulting PMC. If we're just a variable,
return the PMC associated with that variable. In any other case, concat
the results and return a Stringy PMC.

=cut

.sub __get_pmc method

  .local pmc chunks
  chunks = getattribute self, "TclWord\x00chunks"
 
  .local int count
  count = chunks 

  if count == 1 goto justpmc
  ($I0,$S0) = self.__get_string()
  $P0 = new String
  $P0 = $S0
  .return($I0,$P0)

justpmc:
  .local pmc chunk
  chunk = chunks[0]
  .local int chunk_type
  chunk_type = chunk[0]
  .local pmc chunk_value
  chunk_value = chunk[1]

  if chunk_type == 0 goto constant
  if chunk_type == 1 goto variable

command:
  .local pmc interpret
  interpret = find_global "_Tcl", "__interpret"
  ($I0,$P0) = interpret(chunk_value)
  .return($I0,$P0)

constant:
  # 0 == TCL_OK
  .return(0,chunk_value) 

variable:
  .local pmc read
  read = find_global "_Tcl", "__read"
  .local pmc get_var
  get_var = find_global "_Tcl", "__get_var"
  .local int return_type
  $S1 = chunk_value
  $S2 = chunk[2]
  if $S2 == "" goto get_variable
  .return get_var($S1,$S2)
get_variable:
  .return read($S1)
.end

=head2 __get_string

Stringify - In our case, we take the individual chunks of the words and
evaluate them  - so if we have a TclWord that came from a string like:

	"$a + $b = [expr $a + $b]"

We have split it up internally to look like:

	VAR:     a
	CONST:   " + "
	VAR:     b
	CONST:   " = "
	COMMAND:
		WORD:
			CONST: "expr"
		WORD:
			VAR: a
		WORD:
			CONST: "+"
		WORD:
			VAR: b

And, when we ask for the string representation, the two variable interpolations
are performed, and the command containing "expr" is also evaluated. The
resulting string, (assuming values of 1 and 2 for a and b, respectively) is

	"1 + 2 = 3"

NB: This isn't quite the normal C<__get_string> method, and should probably be
renamed - it is returning a tcl exit code in addition to the normal string
result.

=cut

.sub __get_string method

  .local int return_type

  return_type = 0

  .local pmc chunks
  chunks = getattribute self, "TclWord\x00chunks"

  .local pmc interpret 
  .local pmc get_var

  interpret = find_global "_Tcl", "__interpret"
  get_var = find_global "_Tcl", "__get_var"

  .local string retval
  retval = ""

  $I1 = chunks
  $P11 = new Integer  
  $P11 = 0 # XXX If we don't use a PMC, this value is discarded because of 
           # a method call below.
loop:
  $I0 = $P11
  if $I0 == $I1 goto loop_done
  $P0 = chunks[$I0]
  $I2 = $P0[0]

  if $I2 == 0 goto constant
  if $I2 == 1 goto variable
  if $I2 == 2 goto command

command:
  $P1 = $P0[1]
  $S1 = typeof $P1
  ($I0, $P9) = interpret( $P1 )
  $S0 = $P9
  if $I0 == 0 goto loop_next
  # else, an exception value was returned. abort.
  return_type = $I0
  goto loop_done

variable:
  $S1 = $P0[1]
  $S2 = $P0[2]
  if $S2 == "" goto get_variable
  ($I2,$P9) = get_var($S1,$S2)
  goto got_variable

get_variable:
  ($I2,$P9) = get_var($S1)
  $S0 = $P9

got_variable:
  if $I2 == 0 goto loop_next 
  return_type = $I2
  retval = $S0
  goto loop_done 

constant:
  $S0 = $P0[1]
  # goto loop_next 

loop_next:
  retval .= $S0
  $P11 = $P11 + 1
  goto loop

loop_done:  
  .return(return_type,retval)
.end

=head2 __dump

Allow us to be rendered by Data::Dumper 

Not tested, uses pmcPerlArray dumper method because of the way Dumper is written.
Shouldn't have to.

=cut

.sub __dump method
  .param pmc dumper
  .param string name

  .local string subindent
  .local string indent
  (subindent, indent) = dumper."newIndent"()

  .local pmc chunks 
  chunks = getattribute self, "TclWord\x00chunks"

  .local int num_chunks
  num_chunks = chunks
  .local int chunk_num
  chunk_num = 0

  print "(size:"
  print num_chunks
  print ") {\n"
 
loop:
  if chunk_num >= num_chunks goto loop_done
  if chunk_num == 0 goto skip
  print ",\n"
skip:

  $P0 = chunks[chunk_num]
  $I0 = $P0[0]

  print subindent  

  if $I0 == 2 goto command
  if $I0 == 1 goto var

  $S0 = $P0[1]
  print "\""
  print $S0
  print "\""
  goto loop_next

command:
  $P1 = $P0[1]
  # XXX This will need to change.
  dumper.pmcPerlArray($P1) 
  goto loop_next

var:
  $S0 = $P0[1]
  $S1 = $P0[2]
  if $S1 != "" goto array_var
  print "[ set "
  print $S0   
  print " ]"
  goto loop_next

array_var:
  print "[ set "
  print $S0
  print " ("
  print $S1
  print ") ]"

loop_next: 
  inc chunk_num
  goto loop

loop_done:
  print "\n"

  print indent
  print "}"

  dumper."deleteIndent"()
.end

=head2 __get_integer

Return the number of chunks in this tclword.

=cut

.sub __get_integer method
  
  .local pmc chunks 
  chunks = getattribute self, "TclWord\x00chunks"
  .local int size
  size = chunks 

  .return(size)
.end

=head2 XXX __freeze

Not implemented yet, pending delegation of C<freeze> to objects.
(Necessary anymore?)

=head2 XXX __thaw

Not implemented yet, pending delegation of C<thaw> to objects.
(Necessary anymore?)

=cut

=head2 __is_const

Returns an integer, C<1> if this word is constant, C<0> if it requires
interpolation.

=cut

.sub __is_const method
  .local pmc constant
  constant = getattribute self, "TclWord\x00constant"
  .local int result
  result = constant
  .return(result)
.end
