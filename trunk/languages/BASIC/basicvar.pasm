# Basic variable and code storage management
#
# Global Resources:
#   S20
#   S21
#   S22  Numeric/String/Code variable storage formatted as:
#         8 bytes (name).  Terminates with "#"  Line number for Code
#	  3 bytes (width)  N=12
#     width bytes (value)
#
# Subscripted variables are stored independently of each other as:
#   varname|subscr,subscr   (the subscripts will be reversed)
#   The limit to subscripting is:
#     (Length of variable name)[+1+subscriptlen+1+[subscriptlen+1]...
#     So that FOO(56,1) will occupy FOO|1,56 an 8-byte slot
#
# $Id$
# $Log$
# Revision 1.3  2002/05/22 17:22:22  clintp
# Uses PerlHash for speed
#
# Revision 1.2  2002/04/29 01:10:04  clintp
# Speed changes, new language features
#
# Revision 1.14  2002/04/28 01:09:36  Clinton
# Added speedups by using set Ix, Sx and avoiding a lot of
# STRIPSPACE calls.  Compensated for weird read-data bug.
#
# Revision 1.12  2002/04/21 22:58:57  Clinton
# Made Eliza compatable
#
# Revision 1.1  2002/04/11 01:25:59  jgoff
# Adding clintp's BASIC interpreter.
#
# Revision 1.8  2002/04/09 03:14:31  Clinton
# Optimized line lookups by using I18 and I19 as a line number
# cache and pointer
#
# Revision 1.7  2002/04/07 00:52:31  Clinton
# Fixed accidental STRIPSPACE on string storage
#
# Revision 1.6  2002/04/06 21:24:53  Clinton
# Added advanced string handling.  String vars are created automagically now
#
# Revision 1.5  2002/04/06 19:58:52  Clinton
# Before allowing undimensioned strings.
# Added VDESTROY capability
#
# Revision 1.4  2002/04/01 22:16:54  Clinton
# Changed load sequence a bit
#
# Revision 1.3  2002/03/31 05:15:31  Clinton
# Adjusted
#
# Revision 1.2  2002/03/31 05:13:48  Clinton
# Id Keywords
#

.const NTYPE 0
.const STYPE 1
.const CTYPE 2
.const NAMEWIDTH 15
.const VARWIDTH 3
.const TERMINATOR "-"
.const STRINGMINW 10

# (internal) Find variable
#  Inputs: variable name (or code line number)
#          type
# Outputs: offset, -1 if unknown
VFIND:  pushi
	pushs
	restore I5
	restore S5
	length I0, S5
	gt I0, NAMEWIDTH, VFINDTOOLONG

	set S15, S20  # Assume Ints
	eq I5, NTYPE, VSEARCH
	set S15, S21  # Strings?
	eq I5, STYPE, VSEARCH
	set S15, S22  # Code then
	save S5
	bsr ATOI
	restore I6    # Line numbers are numeric

VSEARCH:
	set I0, -1
	set I1, 0

VFINDL:
	set S2, ""
	substr S2, S15, I1, NAMEWIDTH
	save S2
	bsr STRIPSPACE
	restore S2	       # Var name/line #
	eq S2, S5, VFOUND     # Exact match
	eq S2, "#", VFINDEND  # Exhausted
	ne I5, CTYPE, VNOTFOUND
	save S2
	bsr ATOI
	restore I2
	ge I2, I6, VFOUND
VNOTFOUND:
	add I1, I1, NAMEWIDTH
	set S2, ""
	substr S2, S15, I1, VARWIDTH
	set I2, S2
	add I1, I1, VARWIDTH
	add I1, I1, I2
	branch VFINDL
VFOUND:
	set I0, I1
VFINDEND:
	save I0
	popi
	pops  # Read-only no S20 restore needed
	ret
VFINDTOOLONG:
	print "SYMBOL NAME TOO LONG: "
	print S5
	print "\n"
	end
VFINDERR:
	print "(internal) Cached line position exceeds length\n"
	end

# Create a variable  UNINITIALIZED
#  Inputs: Variable name
#          type
#          width
# Outputs: none
VCREATE:
	pushi
	pushs
	restore I6  # Width
	restore I5  # Type
	restore S0  # The variable name

	set S15, S20  # Assume Ints
	eq I5, NTYPE, VCSTART
	set S15, S21  # Strings?
	eq I5, STYPE, VCSTART
	set S15, S22  # Code then
VCSTART:
	save "#"
	save I5
	bsr VFIND  # Find the end
	restore I0

	# Assemble the new
	save S0
	save NAMEWIDTH
	bsr PAD
	restore S9
	concat S10, S9

	save I6
	bsr ITOA
	save VARWIDTH
	bsr PAD
	restore S9
	concat S10, S9

	repeat S9, " ", I6
	concat S10, S9

	save S15
	save S10
	save I0
	bsr STRINSERT  # New is on stack

VCREND: save I5
	popi
	pops
	restore I5
	ne I5, NTYPE, VCNOTNUM
	restore S20
	branch VCBAIL
VCNOTNUM:
	ne I5, STYPE, VCNOTSTR
	restore S21
	branch VCBAIL
VCNOTSTR:
	restore S22 # Code
VCBAIL: ret

# Set variables
# (We assume they exist already, a runtime error occurs otherwise)
#  Inputs: Value is on the stack
#	   Name is on the stack
#          Width is on the stack
# Outputs: (none)
VSTORE:
	pushi
	pushs
	restore S5  # Value (I will space pad)
	restore I6  # width
	restore I5  # type
	restore S0  # Variable name

	save S0
	save I5
	bsr VFIND
	restore I0  # Location
	eq I0, -1, VSTOREERR

	set S15, S20  # Assume Ints
	eq I5, NTYPE, VSSTART
	set S15, S21  # Strings?
	eq I5, STYPE, VSSTART
	set S15, S22  # Code then
VSSTART:
	add I0, I0, NAMEWIDTH

	length I2, S15
	gt I0, I2, VSTOREERR_SNH

	substr S1, S15, I0, VARWIDTH
	set I1, S1
	ne I1, I6, VSTOREERR2

	add I0, I0, VARWIDTH
	save S5
	save I1
	bsr PAD
	restore S5
	save S15
	save S5
	save I1
	save I0
	bsr STRREPLACE

	save I5
        popi
	pops
	restore I5
	ne I5, NTYPE, VSNOTNUM
	restore S20
	branch VSBAIL
VSNOTNUM:
	ne I5, STYPE, VSNOTSTR
	restore S21
	branch VSBAIL
VSNOTSTR:
	restore S22 # Code
VSBAIL: ret


VSTOREERR:
	print "NOVAR for STORE\n"
	end
VSTOREERR2:
	print "WIDTH MISMATCH for STORE\n"
	end
VSTOREERR_SNH:
	print "VSTORE ERROR, substring exceeds length\n"
	print S15
	print "\n"
	print "Start "
	print I0
	print " length "
	print VARWIDTH
	print "\n"
	end



# Fetch variables
#  Inputs: Name is on the stack
#          Type is on the stack
# Outputs: The value on the stack (AS A STRING)
VFETCH:
	pushi
	pushs
	restore I5  # type
	restore S0  # Variable name

	save S0
	save I5
	bsr VFIND
	restore I0  # Location
	eq I0, -1, VFETCHERR

	set S15, S20  # Assume Ints
	eq I5, NTYPE, VFSTART
	set S15, S21  # Strings?
	eq I5, STYPE, VFSTART
	set S15, S22  # Code then
VFSTART:
	add I0, I0, NAMEWIDTH
	substr S1, S15, I0, VARWIDTH
	set I1, S1
	add I0, I0, VARWIDTH
	substr S1, S15, I0, I1
	save S1
	popi
	pops
	ret

VFETCHERR:
	print "NOT DEFINED on FETCH\n"
	end

# Destroy a variable
# Should only be called by the string stuff when a variable has exceeded maximum 
# length and needs to be killed.
#  Inputs: Name on stack
#          Type on stack
# Outputs: N/A
VDESTROY:
	pushi
	pushs

	restore I5    # Type
	save I5

	bsr VFIND
	restore I0
	eq I0, -1, VDESTROYEND

	set S15, S20  # Assume Ints
	eq I5, NTYPE, VDSTART
	set S15, S21  # Strings?
	eq I5, STYPE, VDSTART
	set S15, S22  # Code then

VDSTART:
	add I1, I0, NAMEWIDTH
	substr S1, S15, I1, VARWIDTH
	set I2, S1

	add I2, I2, NAMEWIDTH
	add I2, I2, VARWIDTH

	save S15
	save ""
	save I2
	save I0
	bsr STRREPLACE
	restore S15

	save S15
	eq I5, NTYPE, VDNUM
	eq I5, STYPE, VDSTRING
	eq I5, CTYPE, VDCODE
	branch VDFATAL

VDNUM:  restore S20
	branch VDESTROYEND
VDSTRING:
	restore S21
	branch VDESTROYEND
VDCODE:
	restore S22
	branch VDESTROYEND

VDESTROYEND:	
	save S21
	save S22
	popi
	pops
	restore S22
	restore S21
	ret
VDFATAL:
	print "Unknown type in DESTROY"
	end


# All of these routines use, misuse and abuse I0, I1, S0, S1, S2
#    Should be saved/restored okay though.

# Numeric variable handling
#   NSTORE
#   NFETCH
#
# For all of these the general pattern is:
#    push the name
#    push the value (if needed)
#    call
#
# Store numerics
NSTORE: 
	pushi
	pushs
	restore I1   # Value
	restore S0   # Name
	set_keyed P20, S0, I1
	popi
	pops
	ret

# Fetch Numerics
NFETCH: 
	pushi
	pushs
	restore S0   # Name
	get_keyed I1, P20, S0
	save I1
	popi
	pops
	ret

# String variable handling
#   SSTORE
#   SFETCH
# Strings are \n terminated internally
#
# For all of these the general pattern is:
#    push the name
#    push the value (if needed)
#    call
#
# Create String 
# DIMENSION is now a no-op.
#
# Strings are a little smarter now.  They work *exactly* like
# numeric variables, except that if the store size exceeds the 
# allocated storage we destroy the existing variable and create a new one.
#
SSTORE: pushs
	restore S1  # Value
	restore S0  # Name
	set_keyed P21, S0, S1
	pops
	ret
	
# Fetch a string
# If the string wasn't previously dimensioned then
# we return the empty string
SFETCH: pushs
	restore S0  # Name
	get_keyed S1, P21, S0
	save S1
	pops
	ret

# Code Storage and Retrieval
#  This...is...insane.  Takes arguments as though strings
#
#  CSTORE -- store a code line, overwriting existing lines.
#  CFETCH -- fetch a code line.  NOTE: you'll get the line
#            specified or *higher*

# Fetch a line to be decoded.
#   Inputs: Integer line number (on stack)
#  Outputs: The line number (integer) found (-1 if none)
# 	    The corresponding line or *the next higher*
#
# Line lookups now *start* where the last one left off.  For forward
#   jumps, this means that only backwards jumps are O(n)
#  
CFETCH: pushi
        pushs
        restore I0            # Line number to fetch.
        set I2, I0
        eq I0, -1, CFETCHSTART
        get_keyed S0, P22, I0
        ne S0, "", CFETCHEND

        # Not found.  Let's see if this is a +1
        dec I0
        get_keyed S0, P22, I0
        ne S0, "", CFETCHNEXT
        branch CNOTFOUND

CFETCHNEXT:
        get_keyed I1, P23, I0  # Okay, got the line before
        inc I1
        gt I1, I28, COVERFLOW
        get_keyed I0, P24, I1  # Next line number is...
        eq I0, 0, COVERFLOW
        get_keyed S0, P22, I0  # Fetch it.
        ne S0, "", CFETCHEND
        branch CNOTFOUND       # This is a should-not-happen, I think.

CFETCHSTART:
        set I6, 0    # Line position to fetch
        gt I6, I28, COVERFLOW
        get_keyed I0, P24, I6
        eq I0, 0, COVERFLOW
        get_keyed S0, P22, I0  # Fetch line
        ne S0, "", CFETCHEND
        branch CNOTFOUND       # This is a should-not-happen, I think.

CFETCHEND:
        save S0
        save I0

CFETCHEND2:
        popi
        pops
        ret
COVERFLOW:
        save -1
        branch CFETCHEND2
CNOTFOUND:
        print "LINE "
        print I2
        print " NOT FOUND\n"
        save -1
        branch CFETCHEND2

# CSTORE
#  Inputs: A code line on the stack.  Must be formatted like this:
#                  \d+\s
# Outputs: Nothing
CSTORE: pushi
	pushs
	set I8, 0   # One-token-only flag
	restore S0  # Safekeeping (the line to insert)
	save S0
	bsr TOKENIZER
	bsr REVERSESTACK
	restore I0  # Depth
	ne I0, 1, ONELNCK
	set I8, 1   # Just the line number!
ONELNCK:
	restore S1  # Line number
	dec I0
	save I0
	bsr CLEAR   # Empty the stack
	restore I5  # Dummy

	set I1, S1
	lt I1, 1, ENOTVALIDLINE

	set I5, 0   # Start with a blank stack.

CLOAD:  set I0, 0
CNEXT:  gt I0, I28, CEND
        get_keyed I3, P24, I0   # Get the next line
        get_keyed S1, P22, I3   # Get the line code itself
	inc I0
	eq I3, I1, CNEXT	# Skip this, it's being replaced.
	save S1
	inc I5
	branch CNEXT

CEND:   eq I8, 1, CINIT
	save S0			# Insert the new line
	bsr STRIPSPACE
	inc I5

CINIT:  save I5
	# Initialize program area
        new P22, PerlHash     # The lines themselves  (Keyed on Line #)
        new P23, PerlHash     # Pointers from the lines to the array  (Keyed on Line #)
        new P24, PerlArray    # Array of line numbers
	set I28, -1

CENDLOAD:		# Entry point for LOAD
	bsr REVERSESTACK
	bsr NSORTSTACK

	# Take the stack and re-insert it as lines
        restore I5
STOREC: eq I5, 0, DONEADD
        restore S0              # Code line
        set I1, S0              # Line Number

        set_keyed P22, I1, S0   # The line itself
        inc I28
        set_keyed P23, I1, I28   # Index back to array
        set_keyed P24, I28, I1
        dec I5
        branch STOREC

DONEADD:
	save I28
	popi
	pops
	restore I28
	ret

ENOTVALIDLINE:
	print "BAD LINE NUMBER\n"
	end


# Vardecode
# All-purpose variable decoder.  It's kinda blind though, so when you call it
# had better be a varaible there or the results are... unpredictable.  
# Deals with "A$" as one *or* two tokens!
#   Inputs: Stopword for evaluation
#	    Normal stack.  With what you *think* is the start of the variable
#           on top.  A$ ...
#  Outputs: Type (NTYPE, STYPE, CTYPE, etc...) on top then the name.
#           Array variables will be encoded in such a way they can be looked up
#           as-is.
VARDECODE:
	pushi
	pushs
	set S3, ""
	restore S3  # Stopword
	restore I5  # Depth
	
	restore S1	# Variable name
	set I3, NTYPE	# Numeric (assume)
	dec I5

	set S5, ""	# Check for 1-token string vars.
	length I2, S1
	substr S5, S1, I2, 1
	eq S5, "$", DECSTRING

	eq I5, 0, VARDECODED  # Nothing left it has to be numeric

	restore S2	# $, ( or stopword
	dec I5

	ne S2, "$", FINDEC

DECSTRING:
	set I3, STYPE
	eq I5, 0, VARDECODED

	restore S2	# There's something else...
	dec I5
FINDEC:			# S2's either the stop, expression, something.
	save S2
	inc I5
	eq S2, "(", VARSUBSCRIPT
	branch VARDECODED  # Nothing more to see here.
	
VARSUBSCRIPT:
	save I5
	save S3		# Stop word
	bsr EVAL_EXPR
	restore S0	# Subscript
	concat S1, "|"
	concat S1, S0   # var|expr[,expr...]
	restore I5

VARDECODED:
	save I5		# Fix the stack
	save S1		# Save the name
	save I3		# Save the type
	popi
	pops
	ret
