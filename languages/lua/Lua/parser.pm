####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Lua::parser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------




sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'' => -4,
			'NAME' => -4,
			'REPEAT' => -4,
			'FOR' => -4,
			"(" => -4,
			'IF' => -4,
			'error' => 1,
			'FUNCTION' => -4,
			'DO' => -4,
			'LOCAL' => -4,
			'WHILE' => -4
		},
		GOTOS => {
			'chunk' => 2,
			'program' => 3
		}
	},
	{#State 1
		DEFAULT => -2
	},
	{#State 2
		ACTIONS => {
			'NAME' => 4,
			'REPEAT' => 5,
			'FOR' => 6,
			"(" => 8,
			'IF' => 10,
			'FUNCTION' => 12,
			'DO' => 14,
			'LOCAL' => 15,
			'WHILE' => 16
		},
		DEFAULT => -1,
		GOTOS => {
			'functioncall' => 9,
			'var' => 11,
			'varlist1' => 13,
			'stat' => 7
		}
	},
	{#State 3
		ACTIONS => {
			'' => 17
		}
	},
	{#State 4
		DEFAULT => -34
	},
	{#State 5
		DEFAULT => -4,
		GOTOS => {
			'block' => 19,
			'chunk' => 18
		}
	},
	{#State 6
		ACTIONS => {
			'NAME' => 20
		},
		GOTOS => {
			'namelist' => 21
		}
	},
	{#State 7
		ACTIONS => {
			";" => 22
		},
		DEFAULT => -6,
		GOTOS => {
			'_semicolon_opt' => 23
		}
	},
	{#State 8
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 37,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 9
		ACTIONS => {
			":" => 40,
			'LITERAL' => 42,
			"[" => 45,
			"{" => 38,
			"(" => 46,
			"." => 47
		},
		DEFAULT => -13,
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 41,
			'key' => 43
		}
	},
	{#State 10
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 48,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 11
		ACTIONS => {
			":" => 49,
			"{" => 38,
			'LITERAL' => 42,
			"(" => 46,
			"[" => 45,
			"." => 47
		},
		DEFAULT => -33,
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 50,
			'key' => 51
		}
	},
	{#State 12
		ACTIONS => {
			'NAME' => 52
		},
		GOTOS => {
			'funcname' => 53,
			'_funcname' => 54
		}
	},
	{#State 13
		ACTIONS => {
			"," => 55,
			"=" => 56
		}
	},
	{#State 14
		DEFAULT => -4,
		GOTOS => {
			'block' => 57,
			'chunk' => 18
		}
	},
	{#State 15
		ACTIONS => {
			'NAME' => 59,
			'FUNCTION' => 58
		},
		GOTOS => {
			'namelist' => 60
		}
	},
	{#State 16
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 61,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 17
		DEFAULT => 0
	},
	{#State 18
		ACTIONS => {
			'NAME' => 4,
			'BREAK' => 62,
			'REPEAT' => 5,
			'FOR' => 6,
			"(" => 8,
			'IF' => 10,
			'RETURN' => 64,
			'FUNCTION' => 12,
			'DO' => 14,
			'LOCAL' => 15,
			'WHILE' => 16
		},
		DEFAULT => -7,
		GOTOS => {
			'functioncall' => 9,
			'var' => 11,
			'_end_block' => 63,
			'varlist1' => 13,
			'stat' => 7
		}
	},
	{#State 19
		ACTIONS => {
			'UNTIL' => 65
		}
	},
	{#State 20
		ACTIONS => {
			"=" => 66
		},
		DEFAULT => -41
	},
	{#State 21
		ACTIONS => {
			"," => 67,
			'IN' => 68
		}
	},
	{#State 22
		DEFAULT => -5
	},
	{#State 23
		DEFAULT => -3
	},
	{#State 24
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 69,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 25
		DEFAULT => -65
	},
	{#State 26
		DEFAULT => -68
	},
	{#State 27
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 70,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 28
		DEFAULT => -44
	},
	{#State 29
		DEFAULT => -67
	},
	{#State 30
		DEFAULT => -63
	},
	{#State 31
		ACTIONS => {
			":" => 40,
			"[" => 45,
			"(" => 46,
			"." => 47,
			'LITERAL' => 42,
			"{" => 38
		},
		DEFAULT => -46,
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 41,
			'key' => 43
		}
	},
	{#State 32
		DEFAULT => -69
	},
	{#State 33
		DEFAULT => -64
	},
	{#State 34
		ACTIONS => {
			"(" => 72
		},
		GOTOS => {
			'funcbody' => 71
		}
	},
	{#State 35
		ACTIONS => {
			":" => 49,
			"[" => 45,
			"(" => 46,
			"." => 47,
			'LITERAL' => 42,
			"{" => 38
		},
		DEFAULT => -45,
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 50,
			'key' => 51
		}
	},
	{#State 36
		DEFAULT => -66
	},
	{#State 37
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			"<=" => 86,
			'OR' => 85,
			")" => 82,
			">" => 87
		}
	},
	{#State 38
		ACTIONS => {
			"}" => 88,
			"-" => 24,
			'NAME' => 92,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			"[" => 89,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 91,
			'function' => 26,
			'primary' => 28,
			'fieldlist' => 93,
			'functioncall' => 31,
			'tableconstructor' => 32,
			'var' => 35,
			'_field_plus' => 94,
			'field' => 90
		}
	},
	{#State 39
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 95,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 40
		ACTIONS => {
			'NAME' => 96
		}
	},
	{#State 41
		DEFAULT => -75
	},
	{#State 42
		DEFAULT => -80
	},
	{#State 43
		DEFAULT => -36
	},
	{#State 44
		DEFAULT => -79
	},
	{#State 45
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 97,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 46
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36,
			")" => 99
		},
		GOTOS => {
			'exp' => 100,
			'functioncall' => 31,
			'explist1' => 98,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 47
		ACTIONS => {
			'NAME' => 101
		}
	},
	{#State 48
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			'THEN' => 102,
			"<=" => 86,
			'OR' => 85,
			">" => 87
		}
	},
	{#State 49
		ACTIONS => {
			'NAME' => 103
		}
	},
	{#State 50
		DEFAULT => -73
	},
	{#State 51
		DEFAULT => -37
	},
	{#State 52
		DEFAULT => -31
	},
	{#State 53
		ACTIONS => {
			"(" => 72
		},
		GOTOS => {
			'funcbody' => 104
		}
	},
	{#State 54
		ACTIONS => {
			":" => 105,
			"." => 106
		},
		DEFAULT => -28
	},
	{#State 55
		ACTIONS => {
			"(" => 8,
			'NAME' => 4
		},
		GOTOS => {
			'functioncall' => 107,
			'var' => 108
		}
	},
	{#State 56
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 100,
			'functioncall' => 31,
			'explist1' => 109,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 57
		ACTIONS => {
			'END' => 110
		}
	},
	{#State 58
		ACTIONS => {
			'NAME' => 111
		}
	},
	{#State 59
		DEFAULT => -41
	},
	{#State 60
		ACTIONS => {
			"," => 67,
			"=" => 112
		},
		DEFAULT => -25
	},
	{#State 61
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			'DO' => 113,
			"<=" => 86,
			'OR' => 85,
			">" => 87
		}
	},
	{#State 62
		DEFAULT => -11
	},
	{#State 63
		ACTIONS => {
			";" => 22
		},
		DEFAULT => -6,
		GOTOS => {
			'_semicolon_opt' => 114
		}
	},
	{#State 64
		ACTIONS => {
			"-" => 24,
			'TRUE' => 25,
			'NOT' => 27,
			'LITERAL' => 29,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36,
			'NAME' => 4,
			"{" => 38,
			"(" => 39
		},
		DEFAULT => -10,
		GOTOS => {
			'exp' => 100,
			'functioncall' => 31,
			'explist1' => 115,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 65
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 116,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 66
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 117,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 67
		ACTIONS => {
			'NAME' => 118
		}
	},
	{#State 68
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 100,
			'functioncall' => 31,
			'explist1' => 119,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 69
		ACTIONS => {
			"^" => 80
		},
		DEFAULT => -61
	},
	{#State 70
		ACTIONS => {
			"^" => 80
		},
		DEFAULT => -62
	},
	{#State 71
		DEFAULT => -81
	},
	{#State 72
		ACTIONS => {
			'NAME' => 59,
			"..." => 121,
			")" => 120
		},
		GOTOS => {
			'namelist' => 122,
			'parlist1' => 123
		}
	},
	{#State 73
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 124,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 74
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 125,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 75
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 126,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 76
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 127,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 77
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 128,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 78
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 129,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 79
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 130,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 80
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 131,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 81
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 132,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 82
		ACTIONS => {
			":" => 133,
			"(" => 46,
			"{" => 38,
			"[" => 45,
			'LITERAL' => 42,
			"." => 47
		},
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 134,
			'key' => 135
		}
	},
	{#State 83
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 136,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 84
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 137,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 85
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 138,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 86
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 139,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 87
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 140,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 88
		DEFAULT => -88
	},
	{#State 89
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 141,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 90
		DEFAULT => -92
	},
	{#State 91
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"==" => 78,
			">=" => 79,
			"^" => 80,
			"*" => 81,
			"/" => 83,
			'AND' => 84,
			'OR' => 85,
			"<=" => 86,
			">" => 87
		},
		DEFAULT => -95
	},
	{#State 92
		ACTIONS => {
			"=" => 142
		},
		DEFAULT => -34
	},
	{#State 93
		ACTIONS => {
			"}" => 143
		}
	},
	{#State 94
		ACTIONS => {
			";" => 145,
			"," => 146
		},
		DEFAULT => -90,
		GOTOS => {
			'fieldsep' => 144
		}
	},
	{#State 95
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			"<=" => 86,
			'OR' => 85,
			")" => 147,
			">" => 87
		}
	},
	{#State 96
		ACTIONS => {
			"(" => 46,
			"{" => 38,
			'LITERAL' => 42
		},
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 148
		}
	},
	{#State 97
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			"<=" => 86,
			'OR' => 85,
			"]" => 149,
			">" => 87
		}
	},
	{#State 98
		ACTIONS => {
			"," => 150,
			")" => 151
		}
	},
	{#State 99
		DEFAULT => -78
	},
	{#State 100
		ACTIONS => {
			"-" => 74,
			"<" => 76,
			"==" => 78,
			">=" => 79,
			"*" => 81,
			'AND' => 84,
			'OR' => 85,
			"<=" => 86,
			">" => 87,
			".." => 73,
			"~=" => 75,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -43
	},
	{#State 101
		DEFAULT => -39
	},
	{#State 102
		DEFAULT => -4,
		GOTOS => {
			'block' => 152,
			'chunk' => 18
		}
	},
	{#State 103
		ACTIONS => {
			"(" => 46,
			"{" => 38,
			'LITERAL' => 42
		},
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 153
		}
	},
	{#State 104
		DEFAULT => -22
	},
	{#State 105
		ACTIONS => {
			'NAME' => 154
		}
	},
	{#State 106
		ACTIONS => {
			'NAME' => 155
		}
	},
	{#State 107
		ACTIONS => {
			":" => 40,
			"(" => 46,
			"{" => 38,
			"[" => 45,
			'LITERAL' => 42,
			"." => 47
		},
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 41,
			'key' => 43
		}
	},
	{#State 108
		ACTIONS => {
			":" => 49,
			"{" => 38,
			'LITERAL' => 42,
			"(" => 46,
			"[" => 45,
			"." => 47
		},
		DEFAULT => -32,
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 50,
			'key' => 51
		}
	},
	{#State 109
		ACTIONS => {
			"," => 150
		},
		DEFAULT => -12
	},
	{#State 110
		DEFAULT => -14
	},
	{#State 111
		ACTIONS => {
			"(" => 72
		},
		GOTOS => {
			'funcbody' => 156
		}
	},
	{#State 112
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 100,
			'functioncall' => 31,
			'explist1' => 157,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 113
		DEFAULT => -4,
		GOTOS => {
			'block' => 158,
			'chunk' => 18
		}
	},
	{#State 114
		DEFAULT => -8
	},
	{#State 115
		ACTIONS => {
			"," => 150
		},
		DEFAULT => -9
	},
	{#State 116
		ACTIONS => {
			"-" => 74,
			"<" => 76,
			"==" => 78,
			">=" => 79,
			"*" => 81,
			'AND' => 84,
			'OR' => 85,
			"<=" => 86,
			">" => 87,
			".." => 73,
			"~=" => 75,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -16
	},
	{#State 117
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"," => 159,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			"<=" => 86,
			'OR' => 85,
			">" => 87
		}
	},
	{#State 118
		DEFAULT => -40
	},
	{#State 119
		ACTIONS => {
			"," => 150,
			'DO' => 160
		}
	},
	{#State 120
		DEFAULT => -4,
		GOTOS => {
			'block' => 161,
			'chunk' => 18
		}
	},
	{#State 121
		DEFAULT => -86
	},
	{#State 122
		ACTIONS => {
			"," => 162
		},
		DEFAULT => -85
	},
	{#State 123
		ACTIONS => {
			")" => 163
		}
	},
	{#State 124
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -52
	},
	{#State 125
		ACTIONS => {
			"*" => 81,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -48
	},
	{#State 126
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			".." => 73,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -58
	},
	{#State 127
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			".." => 73,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -53
	},
	{#State 128
		ACTIONS => {
			"*" => 81,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -47
	},
	{#State 129
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			".." => 73,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -57
	},
	{#State 130
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			".." => 73,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -56
	},
	{#State 131
		ACTIONS => {
			"^" => 80
		},
		DEFAULT => -51
	},
	{#State 132
		ACTIONS => {
			"^" => 80
		},
		DEFAULT => -49
	},
	{#State 133
		ACTIONS => {
			'NAME' => 164
		}
	},
	{#State 134
		DEFAULT => -71
	},
	{#State 135
		DEFAULT => -35
	},
	{#State 136
		ACTIONS => {
			"^" => 80
		},
		DEFAULT => -50
	},
	{#State 137
		ACTIONS => {
			"-" => 74,
			"<" => 76,
			"==" => 78,
			">=" => 79,
			"*" => 81,
			"<=" => 86,
			">" => 87,
			".." => 73,
			"~=" => 75,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -59
	},
	{#State 138
		ACTIONS => {
			"-" => 74,
			"<" => 76,
			"==" => 78,
			">=" => 79,
			"*" => 81,
			"<=" => 86,
			">" => 87,
			".." => 73,
			"~=" => 75,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -60
	},
	{#State 139
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			".." => 73,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -54
	},
	{#State 140
		ACTIONS => {
			"-" => 74,
			"*" => 81,
			".." => 73,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -55
	},
	{#State 141
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			"<=" => 86,
			'OR' => 85,
			"]" => 165,
			">" => 87
		}
	},
	{#State 142
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 166,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 143
		DEFAULT => -87
	},
	{#State 144
		ACTIONS => {
			"-" => 24,
			'NAME' => 92,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			"[" => 89,
			'NUMBER' => 36
		},
		DEFAULT => -89,
		GOTOS => {
			'exp' => 91,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28,
			'field' => 167
		}
	},
	{#State 145
		DEFAULT => -97
	},
	{#State 146
		DEFAULT => -96
	},
	{#State 147
		ACTIONS => {
			":" => 133,
			"[" => 45,
			"(" => 46,
			"." => 47,
			'LITERAL' => 42,
			"{" => 38
		},
		DEFAULT => -70,
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 134,
			'key' => 135
		}
	},
	{#State 148
		DEFAULT => -76
	},
	{#State 149
		DEFAULT => -38
	},
	{#State 150
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 168,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 151
		DEFAULT => -77
	},
	{#State 152
		DEFAULT => -27,
		GOTOS => {
			'_elseif_star' => 169
		}
	},
	{#State 153
		DEFAULT => -74
	},
	{#State 154
		DEFAULT => -29
	},
	{#State 155
		DEFAULT => -30
	},
	{#State 156
		DEFAULT => -23
	},
	{#State 157
		ACTIONS => {
			"," => 150
		},
		DEFAULT => -24
	},
	{#State 158
		ACTIONS => {
			'END' => 170
		}
	},
	{#State 159
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 171,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 160
		DEFAULT => -4,
		GOTOS => {
			'block' => 172,
			'chunk' => 18
		}
	},
	{#State 161
		ACTIONS => {
			'END' => 173
		}
	},
	{#State 162
		ACTIONS => {
			'NAME' => 118,
			"..." => 174
		}
	},
	{#State 163
		DEFAULT => -4,
		GOTOS => {
			'block' => 175,
			'chunk' => 18
		}
	},
	{#State 164
		ACTIONS => {
			"(" => 46,
			"{" => 38,
			'LITERAL' => 42
		},
		GOTOS => {
			'tableconstructor' => 44,
			'args' => 176
		}
	},
	{#State 165
		ACTIONS => {
			"=" => 177
		}
	},
	{#State 166
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"==" => 78,
			">=" => 79,
			"^" => 80,
			"*" => 81,
			"/" => 83,
			'AND' => 84,
			'OR' => 85,
			"<=" => 86,
			">" => 87
		},
		DEFAULT => -94
	},
	{#State 167
		DEFAULT => -91
	},
	{#State 168
		ACTIONS => {
			"-" => 74,
			"<" => 76,
			"==" => 78,
			">=" => 79,
			"*" => 81,
			'AND' => 84,
			'OR' => 85,
			"<=" => 86,
			">" => 87,
			".." => 73,
			"~=" => 75,
			"+" => 77,
			"^" => 80,
			"/" => 83
		},
		DEFAULT => -42
	},
	{#State 169
		ACTIONS => {
			'ELSE' => 178,
			'ELSEIF' => 180,
			'END' => 179
		}
	},
	{#State 170
		DEFAULT => -15
	},
	{#State 171
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"," => 181,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			'DO' => 182,
			"<=" => 86,
			'OR' => 85,
			">" => 87
		}
	},
	{#State 172
		ACTIONS => {
			'END' => 183
		}
	},
	{#State 173
		DEFAULT => -83
	},
	{#State 174
		DEFAULT => -84
	},
	{#State 175
		ACTIONS => {
			'END' => 184
		}
	},
	{#State 176
		DEFAULT => -72
	},
	{#State 177
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 185,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 178
		DEFAULT => -4,
		GOTOS => {
			'block' => 186,
			'chunk' => 18
		}
	},
	{#State 179
		DEFAULT => -18
	},
	{#State 180
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 187,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 181
		ACTIONS => {
			"-" => 24,
			'NAME' => 4,
			'TRUE' => 25,
			"{" => 38,
			'NOT' => 27,
			'LITERAL' => 29,
			"(" => 39,
			'NIL' => 30,
			'FALSE' => 33,
			'FUNCTION' => 34,
			'NUMBER' => 36
		},
		GOTOS => {
			'exp' => 188,
			'functioncall' => 31,
			'function' => 26,
			'tableconstructor' => 32,
			'var' => 35,
			'primary' => 28
		}
	},
	{#State 182
		DEFAULT => -4,
		GOTOS => {
			'block' => 189,
			'chunk' => 18
		}
	},
	{#State 183
		DEFAULT => -21
	},
	{#State 184
		DEFAULT => -82
	},
	{#State 185
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"==" => 78,
			">=" => 79,
			"^" => 80,
			"*" => 81,
			"/" => 83,
			'AND' => 84,
			'OR' => 85,
			"<=" => 86,
			">" => 87
		},
		DEFAULT => -93
	},
	{#State 186
		ACTIONS => {
			'END' => 190
		}
	},
	{#State 187
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			'THEN' => 191,
			"<=" => 86,
			'OR' => 85,
			">" => 87
		}
	},
	{#State 188
		ACTIONS => {
			"-" => 74,
			".." => 73,
			"<" => 76,
			"~=" => 75,
			"+" => 77,
			"/" => 83,
			"==" => 78,
			">=" => 79,
			'AND' => 84,
			"^" => 80,
			"*" => 81,
			'DO' => 192,
			"<=" => 86,
			'OR' => 85,
			">" => 87
		}
	},
	{#State 189
		ACTIONS => {
			'END' => 193
		}
	},
	{#State 190
		DEFAULT => -17
	},
	{#State 191
		DEFAULT => -4,
		GOTOS => {
			'block' => 194,
			'chunk' => 18
		}
	},
	{#State 192
		DEFAULT => -4,
		GOTOS => {
			'block' => 195,
			'chunk' => 18
		}
	},
	{#State 193
		DEFAULT => -20
	},
	{#State 194
		DEFAULT => -26
	},
	{#State 195
		ACTIONS => {
			'END' => 196
		}
	},
	{#State 196
		DEFAULT => -19
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'program', 1,
sub
#line 46 "Lua\lua50.yp"
{
			BuildMain($_[0], $_[1]);
		}
	],
	[#Rule 2
		 'program', 1,
sub
#line 50 "Lua\lua50.yp"
{
			print "Error (program)\n";
		}
	],
	[#Rule 3
		 'chunk', 3,
sub
#line 57 "Lua\lua50.yp"
{
			[@{$_[1]}, @{$_[2]}];
		}
	],
	[#Rule 4
		 'chunk', 0,
sub
#line 61 "Lua\lua50.yp"
{
			[];
		}
	],
	[#Rule 5
		 '_semicolon_opt', 1, undef
	],
	[#Rule 6
		 '_semicolon_opt', 0, undef
	],
	[#Rule 7
		 'block', 1, undef
	],
	[#Rule 8
		 'block', 3,
sub
#line 77 "Lua\lua50.yp"
{
			[@{$_[1]}, @{$_[2]}];
		}
	],
	[#Rule 9
		 '_end_block', 2,
sub
#line 84 "Lua\lua50.yp"
{
			BuildReturn($_[0], $_[2]);
		}
	],
	[#Rule 10
		 '_end_block', 1,
sub
#line 88 "Lua\lua50.yp"
{
			BuildReturn($_[0], []);
		}
	],
	[#Rule 11
		 '_end_block', 1,
sub
#line 92 "Lua\lua50.yp"
{
			BuildBreak($_[0]);
		}
	],
	[#Rule 12
		 'stat', 3,
sub
#line 99 "Lua\lua50.yp"
{
			[
				BuildAssigns($_[0], $_[1], $_[3])
			];
		}
	],
	[#Rule 13
		 'stat', 1,
sub
#line 105 "Lua\lua50.yp"
{
			get_void($_[0], $_[1]);
		}
	],
	[#Rule 14
		 'stat', 3,
sub
#line 109 "Lua\lua50.yp"
{
			$_[2];
		}
	],
	[#Rule 15
		 'stat', 5,
sub
#line 113 "Lua\lua50.yp"
{
			BuildWhile($_[0], $_[2], $_[4]);
		}
	],
	[#Rule 16
		 'stat', 4,
sub
#line 117 "Lua\lua50.yp"
{
			BuildRepeat($_[0], $_[2], $_[4]);
		}
	],
	[#Rule 17
		 'stat', 8,
sub
#line 121 "Lua\lua50.yp"
{
			BuildIf($_[0], $_[2], $_[4], $_[5], $_[7]);
		}
	],
	[#Rule 18
		 'stat', 6,
sub
#line 125 "Lua\lua50.yp"
{
			BuildIf($_[0], $_[2], $_[4], $_[5], undef);
		}
	],
	[#Rule 19
		 'stat', 11,
sub
#line 129 "Lua\lua50.yp"
{
			BuildForNum($_[0], $_[2], $_[4], $_[6], $_[8], $_[10]);
		}
	],
	[#Rule 20
		 'stat', 9,
sub
#line 133 "Lua\lua50.yp"
{
			BuildForNum($_[0], $_[2], $_[4], $_[6], undef, $_[8]);
		}
	],
	[#Rule 21
		 'stat', 7,
sub
#line 137 "Lua\lua50.yp"
{
			BuildForList($_[0], $_[2], $_[4], $_[6]);
		}
	],
	[#Rule 22
		 'stat', 3,
sub
#line 141 "Lua\lua50.yp"
{
			[
				BuildAssigns($_[0], [$_[2]], [$_[3]])
			];
		}
	],
	[#Rule 23
		 'stat', 4,
sub
#line 147 "Lua\lua50.yp"
{
			my $var = BuildLocalVariable($_[0], $_[3]); 
			[
				BuildLocalVariables($_[0], [$var]),
				BuildAssigns($_[0], [$var], [$_[4]])
			];
		}
	],
	[#Rule 24
		 'stat', 4,
sub
#line 155 "Lua\lua50.yp"
{
			[
				BuildLocalVariables($_[0], $_[2]),
				BuildAssigns($_[0], $_[2], $_[4])
			];
		}
	],
	[#Rule 25
		 'stat', 2,
sub
#line 162 "Lua\lua50.yp"
{
			[
				BuildLocalVariables($_[0], $_[2]),
				BuildAssigns($_[0], $_[2], [])
			];
		}
	],
	[#Rule 26
		 '_elseif_star', 5,
sub
#line 172 "Lua\lua50.yp"
{
			[@{$_[1]}, [$_[3], $_[5]]];
		}
	],
	[#Rule 27
		 '_elseif_star', 0,
sub
#line 176 "Lua\lua50.yp"
{
			[];
		}
	],
	[#Rule 28
		 'funcname', 1, undef
	],
	[#Rule 29
		 'funcname', 3, undef
	],
	[#Rule 30
		 '_funcname', 3,
sub
#line 189 "Lua\lua50.yp"
{
			[@{$_[1]}, $_[3]];
		}
	],
	[#Rule 31
		 '_funcname', 1,
sub
#line 193 "Lua\lua50.yp"
{
			[$_[1]];
		}
	],
	[#Rule 32
		 'varlist1', 3,
sub
#line 200 "Lua\lua50.yp"
{
			[@{$_[1]}, $_[3]];
		}
	],
	[#Rule 33
		 'varlist1', 1,
sub
#line 204 "Lua\lua50.yp"
{
			[$_[1]];
		}
	],
	[#Rule 34
		 'var', 1,
sub
#line 211 "Lua\lua50.yp"
{
			[$_[1]];
		}
	],
	[#Rule 35
		 'var', 4, undef
	],
	[#Rule 36
		 'var', 2, undef
	],
	[#Rule 37
		 'var', 2,
sub
#line 217 "Lua\lua50.yp"
{
			[@{$_[1]}, $_[2]];
		}
	],
	[#Rule 38
		 'key', 3,
sub
#line 224 "Lua\lua50.yp"
{
			$_[2];
		}
	],
	[#Rule 39
		 'key', 2,
sub
#line 228 "Lua\lua50.yp"
{
			BuildLiteral($_[0], $_[2], 'string');
		}
	],
	[#Rule 40
		 'namelist', 3,
sub
#line 235 "Lua\lua50.yp"
{
			[
				@{$_[1]},
				BuildLocalVariable($_[0], $_[3])
			];
		}
	],
	[#Rule 41
		 'namelist', 1,
sub
#line 242 "Lua\lua50.yp"
{
			[
				BuildLocalVariable($_[0], $_[1])
			]
		}
	],
	[#Rule 42
		 'explist1', 3,
sub
#line 252 "Lua\lua50.yp"
{
			[@{$_[1]}, $_[3]];
		}
	],
	[#Rule 43
		 'explist1', 1,
sub
#line 256 "Lua\lua50.yp"
{
			[$_[1]];
		}
	],
	[#Rule 44
		 'exp', 1, undef
	],
	[#Rule 45
		 'exp', 1,
sub
#line 265 "Lua\lua50.yp"
{
			BuildCallVar($_[0], $_[1]);
		}
	],
	[#Rule 46
		 'exp', 1, undef
	],
	[#Rule 47
		 'exp', 3,
sub
#line 271 "Lua\lua50.yp"
{
			BuildBinop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 48
		 'exp', 3,
sub
#line 275 "Lua\lua50.yp"
{
			BuildBinop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 49
		 'exp', 3,
sub
#line 279 "Lua\lua50.yp"
{
			BuildBinop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 50
		 'exp', 3,
sub
#line 283 "Lua\lua50.yp"
{
			BuildBinop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 51
		 'exp', 3,
sub
#line 287 "Lua\lua50.yp"
{
			BuildBinop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 52
		 'exp', 3,
sub
#line 291 "Lua\lua50.yp"
{
			BuildBinop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 53
		 'exp', 3,
sub
#line 295 "Lua\lua50.yp"
{
			BuildRelop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 54
		 'exp', 3,
sub
#line 299 "Lua\lua50.yp"
{
			BuildRelop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 55
		 'exp', 3,
sub
#line 303 "Lua\lua50.yp"
{
			BuildRelop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 56
		 'exp', 3,
sub
#line 307 "Lua\lua50.yp"
{
			BuildRelop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 57
		 'exp', 3,
sub
#line 311 "Lua\lua50.yp"
{
			BuildRelop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 58
		 'exp', 3,
sub
#line 315 "Lua\lua50.yp"
{
			BuildRelop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 59
		 'exp', 3,
sub
#line 319 "Lua\lua50.yp"
{
			BuildLogop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 60
		 'exp', 3,
sub
#line 323 "Lua\lua50.yp"
{
			BuildLogop($_[0], $_[1], $_[2], $_[3]);
		}
	],
	[#Rule 61
		 'exp', 2,
sub
#line 327 "Lua\lua50.yp"
{
			BuildUnop($_[0], $_[1], $_[2]);
		}
	],
	[#Rule 62
		 'exp', 2,
sub
#line 331 "Lua\lua50.yp"
{
			BuildUnop($_[0], $_[1], $_[2]);
		}
	],
	[#Rule 63
		 'primary', 1,
sub
#line 338 "Lua\lua50.yp"
{
			BuildLiteral($_[0], $_[1], 'nil');
		}
	],
	[#Rule 64
		 'primary', 1,
sub
#line 342 "Lua\lua50.yp"
{
			BuildLiteral($_[0], $_[1], 'boolean');
		}
	],
	[#Rule 65
		 'primary', 1,
sub
#line 346 "Lua\lua50.yp"
{
			BuildLiteral($_[0], $_[1], 'boolean');
		}
	],
	[#Rule 66
		 'primary', 1,
sub
#line 350 "Lua\lua50.yp"
{
			BuildLiteral($_[0], $_[1], 'number');
		}
	],
	[#Rule 67
		 'primary', 1,
sub
#line 354 "Lua\lua50.yp"
{
			BuildLiteral($_[0], $_[1], 'string');
		}
	],
	[#Rule 68
		 'primary', 1, undef
	],
	[#Rule 69
		 'primary', 1, undef
	],
	[#Rule 70
		 'primary', 3,
sub
#line 362 "Lua\lua50.yp"
{
			$_[2];
		}
	],
	[#Rule 71
		 'functioncall', 4,
sub
#line 369 "Lua\lua50.yp"
{
			BuildCallFunction($_[0], $_[2], $_[4]);
		}
	],
	[#Rule 72
		 'functioncall', 6, undef
	],
	[#Rule 73
		 'functioncall', 2,
sub
#line 374 "Lua\lua50.yp"
{
			my $fct = BuildCallVar($_[0], $_[1]);
			BuildCallFunction($_[0], $fct, $_[2]);
		}
	],
	[#Rule 74
		 'functioncall', 4, undef
	],
	[#Rule 75
		 'functioncall', 2,
sub
#line 380 "Lua\lua50.yp"
{
			BuildCallFunction($_[0], $_[1], $_[2]);
		}
	],
	[#Rule 76
		 'functioncall', 4, undef
	],
	[#Rule 77
		 'args', 3,
sub
#line 388 "Lua\lua50.yp"
{
			$_[2];
		}
	],
	[#Rule 78
		 'args', 2,
sub
#line 392 "Lua\lua50.yp"
{
			[];
		}
	],
	[#Rule 79
		 'args', 1,
sub
#line 396 "Lua\lua50.yp"
{
			[
				$_[1]
			]
		}
	],
	[#Rule 80
		 'args', 1,
sub
#line 402 "Lua\lua50.yp"
{
			[
				BuildLiteral($_[0], $_[1], 'string')
			]
		}
	],
	[#Rule 81
		 'function', 2,
sub
#line 411 "Lua\lua50.yp"
{
			$_[2];
		}
	],
	[#Rule 82
		 'funcbody', 5,
sub
#line 418 "Lua\lua50.yp"
{
			BuildFunctionBody($_[0], $_[2], $_[4]);
		}
	],
	[#Rule 83
		 'funcbody', 4,
sub
#line 422 "Lua\lua50.yp"
{
			BuildFunctionBody($_[0], [], $_[3]);
		}
	],
	[#Rule 84
		 'parlist1', 3,
sub
#line 429 "Lua\lua50.yp"
{
			[
				@{$_[1]},
				BuildLocalVariable($_[0], $_[3])
			];
		}
	],
	[#Rule 85
		 'parlist1', 1, undef
	],
	[#Rule 86
		 'parlist1', 1,
sub
#line 438 "Lua\lua50.yp"
{
			[
				BuildLocalVariable($_[0], $_[1])
			];
		}
	],
	[#Rule 87
		 'tableconstructor', 3,
sub
#line 447 "Lua\lua50.yp"
{
			BuildTable($_[0], $_[2]);
		}
	],
	[#Rule 88
		 'tableconstructor', 2,
sub
#line 451 "Lua\lua50.yp"
{
			BuildTable($_[0], []);
		}
	],
	[#Rule 89
		 'fieldlist', 2, undef
	],
	[#Rule 90
		 'fieldlist', 1, undef
	],
	[#Rule 91
		 '_field_plus', 3,
sub
#line 465 "Lua\lua50.yp"
{
			[@{$_[1]}, $_[3]];
		}
	],
	[#Rule 92
		 '_field_plus', 1,
sub
#line 469 "Lua\lua50.yp"
{
			[$_[1]];
		}
	],
	[#Rule 93
		 'field', 5,
sub
#line 476 "Lua\lua50.yp"
{
			[$_[2], $_[5]]
		}
	],
	[#Rule 94
		 'field', 3,
sub
#line 480 "Lua\lua50.yp"
{
			[BuildLiteral($_[0], $_[1], 'string'), $_[3]]
		}
	],
	[#Rule 95
		 'field', 1,
sub
#line 484 "Lua\lua50.yp"
{
			[$_[1]]
		}
	],
	[#Rule 96
		 'fieldsep', 1, undef
	],
	[#Rule 97
		 'fieldsep', 1, undef
	]
],
                                  @_);
    bless($self,$class);
}

#line 496 "Lua\lua50.yp"


package Lua::parser;

use strict;

use Lua::lexer;
use Lua::build;
use Lua::symbtab;
use Lua::pir;


sub Run {
	my $parser = shift;
	my ($srcname) = @_;

	open $parser->YYData->{fh}, $srcname
			or die "can't open $srcname ($!).\n";

	$parser->YYData->{shebang} = 1;
	$parser->YYData->{srcname} = $srcname;
	my @st = stat($parser->YYData->{srcname});
	$parser->YYData->{srcname_size} = $st[7];
	$parser->YYData->{srcname_mtime} = $st[9];
	$parser->_InitLexico();
	$parser->YYData->{functs} = [];
	$parser->YYData->{symbtab} = new SymbTabVar($parser);
	$parser->YYData->{symbtab_cst} = new SymbTabConst($parser);
	$parser->YYData->{idx_tmp} = 0;
	$parser->YYData->{idx_lbl} = 0;
	$parser->YYData->{idx_fct} = 0;
	$parser->YYParse(
			yylex	=> \&_Lexer,
			yyerror	=> sub { return; },
#			yydebug	=> 0x17,
#    Bit Value    Outputs
#    0x01         Token reading (useful for Lexer debugging)
#    0x02         States information
#    0x04         Driver actions (shifts, reduces, accept...)
#    0x08         Parse Stack dump
#    0x10         Error Recovery tracing
	);

	close $parser->YYData->{fh};
	delete $parser->{RULES};
	delete $parser->{STATES};
	delete $parser->{STACK};
}

sub Generate {
	my $parser = shift;

	my $filename = $parser->YYData->{srcname};
	$filename =~ s/\.lua$/\.pir/i;
	open FH, "> $filename"
			or die "can't open $filename ($!).\n";

	my $generator = new pirVisitor(\*FH);
	print FH $generator->{prologue};
	foreach my $fct (@{$parser->YYData->{functs}}) {
		foreach (@{$fct}) {
#			if (ref $_) {
			if (ref($_) =~ /(Dir|Op)$/) {
				$_->visit($generator);
			} else {
				print $_,"\n";
				die;
			}
		}
	}
}


1;
