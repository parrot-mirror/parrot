	# For each operator
	# S0/I0/N0  First operand
	# S2	    First operand type
	# S1/I1/N1  Second operand
	# S3	    Second operand type
	# S4        Operator
	#
	# Trash the 5's for results.
	#
	
	# Set I2, I3 to true/false
LOGICAL:bsr SETUP_MATH_BINARY	# P6, P7
	bsr TRUTH
	set I2, I1
	set P6, P7
	bsr TRUTH
	set I3, I1
	ret

OR:	bsr LOGICAL
	eq I2, 1, RETURNBOOL_TRUE
	eq I3, 1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE

AND:	bsr LOGICAL
	ne I2, I3, RETURNBOOL_FALSE
	eq I2, 0,  RETURNBOOL_FALSE
	branch RETURNBOOL_TRUE
	
XOR:	bsr LOGICAL
	eq I2, I3, RETURNBOOL_FALSE
	branch RETURNBOOL_TRUE
	
EQV:	bsr LOGICAL
	eq I2, I3, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE

IMP:    bsr LOGICAL
	eq I2, 0, RETURNBOOL_TRUE
	eq I3, 0, RETURNBOOL_FALSE
	branch RETURNBOOL_TRUE

NOT:	bsr TRUTH
	not I5, I1
	set S0, "INT"
	branch MATHOPEND

EXPR_GT:     bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", GTINT
	eq S0, "FLO", GTFLO
	eq S0, "STRING", GTSTRING
	branch ERR
GTINT:	bsr SETUPINT
	gt I1, I0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
GTFLO:	bsr SETUPFLO
	gt N1, N0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
GTSTRING:bsr SETUPSTRING
	gt S1, S0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE

	
EXPR_LT:     bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", LTINT
	eq S0, "FLO", LTFLO
	eq S0, "STRING", LTSTRING
	branch ERR
LTINT:	bsr SETUPINT
	lt I1, I0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
LTFLO:	bsr SETUPFLO
	lt N1, N0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
LTSTRING:bsr SETUPSTRING
	lt S1, S0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE


EXPR_LE:bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", LEINT
	eq S0, "FLO", LEFLO
	eq S0, "STRING", LESTRING
	branch ERR
LEINT:	bsr SETUPINT
	le I1, I0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
LEFLO:	bsr SETUPFLO
	le N1, N0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
LESTRING:bsr SETUPSTRING
	le S1, S0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE

EXPR_GE:bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", GEINT
	eq S0, "FLO", GEFLO
	eq S0, "STRING", GESTRING
	branch ERR
GEINT:	bsr SETUPINT
	ge I1, I0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
GEFLO:	bsr SETUPFLO
	ge N1, N0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
GESTRING:bsr SETUPSTRING
	ge S1, S0, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE


EXPR_EQ:bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", EQINT
	eq S0, "FLO", EQFLO
	eq S0, "STRING", EQSTRING
	branch ERR
EQINT:	bsr SETUPINT
	eq I0, I1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
EQFLO:	bsr SETUPFLO
	eq N0, N1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
EQSTRING:bsr SETUPSTRING
	eq S0, S1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE


EXPR_NE:bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", NEINT
	eq S0, "FLO", NEFLO
	eq S0, "STRING", NESTRING
	branch ERR
NEINT:	bsr SETUPINT
	ne I0, I1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
NEFLO:	bsr SETUPFLO
	ne N0, N1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE
NESTRING:bsr SETUPSTRING
	ne S0, S1, RETURNBOOL_TRUE
	branch RETURNBOOL_FALSE


EXPR_ADD:
	bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", ADDINT
	eq S0, "FLO", ADDFLO
	eq S0, "STRING", ADDSTRING
	branch ERR
ADDINT: bsr SETUPINT
	add I5, I0, I1
	branch MATHOPEND
ADDFLO: bsr SETUPFLO
	add N5, N0, N1
	branch MATHOPEND
ADDSTRING:
	bsr SETUPSTRING
	concat S5, S1, S0
	set S0, "STRING"
	branch MATHOPEND
	
EXPR_MUL: 
	bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", MULINT
	eq S0, "FLO", MULFLO
	branch ERR
MULINT: bsr SETUPINT
	mul I5, I0, I1
	branch MATHOPEND
MULFLO: bsr SETUPFLO
	mul N5, N0, N1
	branch MATHOPEND

EXPR_SUB:bsr SETUP_MATH_BINARY
	bsr CAST_UP
	eq S0, "INT", SUBINT
	eq S0, "FLO", SUBFLO
	branch ERR
SUBINT: bsr SETUPINT
	sub I5, I1, I0
	branch MATHOPEND
SUBFLO: bsr SETUPFLO
	sub N5, N1, N0
	branch MATHOPEND

	# Divide's weird.  Make 'em both floats
EXPR_DIV:
	bsr SETUP_MATH_BINARY
        bsr CAST_TO_FLOAT
	bsr SETUPFLO
	div N5, N1, N0
	set S0, "FLO"	# Result is float too!
	branch MATHOPEND

MOD: 	bsr SETUP_MATH_BINARY
	bsr CAST_TO_FLOAT
	bsr SETUPFLO
	mod N3, N1, N0
	set I5, N3		 # ouch.  BASIC wants this.
	set S0, "INT"
	branch MATHOPEND

POW:	bsr SETUP_MATH_BINARY
	bsr CAST_TO_FLOAT
	bsr SETUPFLO
	pow N5, N1, N0
	set S0, "FLO"
	branch MATHOPEND

SETUPINT:set I0, P6[.VALUE]
	set I1, P7[.VALUE]
	ret
SETUPFLO:set N0, P6[.VALUE]
	set N1, P7[.VALUE]
	ret
SETUPSTRING:
	set S0, P6[.VALUE]
	set S1, P7[.VALUE]
	ret

	# Take results from math op, push to stack
	#    Type in S0
	#    Results in N5/I5
MATHOPEND:
	new P6, .PerlArray
	set P6[.TYPE], S0
	eq S0, "INT", MATHOPENDINT
	eq S0, "STRING", MATHOPENDSTRING
	set P6[.VALUE], N5
	branch MATHOPEND2
MATHOPENDINT:
	set P6[.VALUE], I5
	branch MATHOPEND2
MATHOPENDSTRING:
	set P6[.VALUE], S5
MATHOPEND2:
	ret

	# BOOL returns are INTs
	#
RETURNBOOL_TRUE:
	set I0, 1
	branch RETURNBOOL
RETURNBOOL_FALSE:
	set I0, 0
RETURNBOOL:
	set I5, I0
	set S0, "INT"
	branch MATHOPEND

	# For binary & unary operators 
	# make sure we're using STRING/INT/FLO and not 
	# references or arrays or anything nasty
SETUP_MATH_BINARY:
	set S0, P7[.TYPE]
	ne S0, "BARE", SETUP_MATH_UNARY
	set S0, P7[.VALUE]
	bsr VARLOOKUP
	bsr VARSTUFF
	set P7, P0
SETUP_MATH_UNARY:
	set S0, P6[.TYPE]
	ne S0, "BARE", SETUP_MATH_DONE
	set S0, P6[.VALUE]
	bsr VARLOOKUP
	bsr VARSTUFF
	set P6, P0
SETUP_MATH_DONE:
	ret	