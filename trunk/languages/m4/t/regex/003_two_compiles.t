#!perl

# $Id$

use strict;
use lib '../../lib';             # Finding Parrot/Config.pm
use lib '../../imcc';            # Finding imcc/TestCompiler.pm

use TestCompiler tests => 3;

my $parrot_home = '../..';
$ENV{PARROT} = "$parrot_home/parrot";

{
  my $pir = << 'END_PIR';
.include "library/pcre.imc"
.sub _main prototyped
  print	"\n"
  .local pmc lib
  .PCRE_INIT(lib)
  .local string error
  .local int errptr
  .local string pat

  .local pmc regex
  pat = 'as'
  .PCRE_COMPILE(pat, 0, regex, error, errptr)
  $I0 = defined regex
  unless $I0 goto match_err

  .local pmc regex_2
  #pat = 'df'
  #.PCRE_COMPILE(pat, 0, regex, error, errptr)
  #$I0 = defined regex_2
  #unless $I0 goto match_err

  .local int ok
  .local pmc result
  .local string s
  s = "asdf"
  .PCRE_MATCH(regex, s, 0, 0, ok, result)
  if ok < 0 goto nomatch
  print ok
  print " match(es):\n"
  .local int i
  i = 0
  .local string match
  .local string s
lp: .PCRE_DOLLAR(s, ok, result, i, match)
  print match
  print "\n"
  inc i
  if i < ok goto lp
  end
nomatch:
  print "no match\n"
  end
match_err:
  print "error in regex: "
  print "at: '"
  length $I0, pat
  $I0 = $I0 - errptr
  substr $S0, pat, errptr, $I0
  print $S0
  print "'\n"
  exit 1
.end
END_PIR

  output_is( $pir, << 'OUTPUT', "calling .PCRE_COMPILE one time" );

1 match(es):
as
OUTPUT
}
{
  my $pir = << 'END_PIR';
.sub _main prototyped

  # Loading shared lib
  .local pmc pcre_lib
  loadlib pcre_lib, "libpcre"

  # pcre *pcre_compile(const char *pattern, int options,
  #            const char **errptr, int *erroffset,
  #            const unsigned char *tableptr
  .local pmc pcre_compile
  dlfunc pcre_compile, pcre_lib, "pcre_compile", "ptiB3P"

  #int pcre_exec(const pcre *code, const pcre_extra *extra,
  #        const char *subject, int length, int startoffset,
  #        int options, int *ovector, int ovecsize);
  .local pmc pcre_exec
  dlfunc pcre_exec, pcre_lib, "pcre_exec", "ipPtiiipi"

  .local string error
  repeat error, " ", 500      # could be enough
  .local int    errptr
  .local string s
  s = "asdf"
  .local int s_len
  length s_len, s
  .local pmc NULL
  null NULL
  .local int ok
  .local pmc ovector
  ovector = new ManagedStruct
  ovector = 120       # 1/(2/3) * 4  * 2 * 10 for 10 result pairs
  .local int is_defined

  # compile regular expression 'as'
  .local pmc re_as
  .pcc_begin prototyped
    .arg 'as'
    .arg 0
    .arg error
    .arg errptr
    .arg NULL
    .nci_call pcre_compile
    .result re_as
  .pcc_end

  defined is_defined, re_as
  unless is_defined goto COMPILE_FAILED

  # compile regular expression 'df'
  .local pmc re_df
  .pcc_begin prototyped
    .arg 'df'
    .arg 0
    .arg error
    .arg errptr
    .arg NULL
  .nci_call pcre_compile
    .result re_df
  .pcc_end

  # Try a match
  .pcc_begin prototyped
    .arg re_as
    .arg NULL           # P extra
    .arg s              # t subject
    .arg s_len    
    .arg 0
    .arg 0
    .arg ovector        # p ovector
    .arg 10             # i ovecsize
  .nci_call pcre_exec
    .result ok
  .pcc_end
  if ok < 0 goto EXEC_FAILED
  print ok
  print " match(es):\n"

  # Try another match
  .pcc_begin prototyped
    .arg re_df
    .arg NULL           # P extra
    .arg s              # t subject
    .arg s_len    
    .arg 0
    .arg 0
    .arg ovector        # p ovector
    .arg 10             # i ovecsize
  .nci_call pcre_exec
    .result ok
  .pcc_end
  print ok
  if ok < 0 goto NO_MATCH
  print " match(es):\n"

  end

NO_MATCH:
  print " no match\n"
  end

COMPILE_FAILED:
  print "error in pcre_compile :"
  print error
  print "\n"
  end

.end
END_PIR

  output_is( $pir, << 'OUTPUT', "calling pcre_compile directly two times" );
1 match(es):
1 match(es):
OUTPUT
}
{
  my $pir = << 'END_PIR';
# Macros for accessing libpcre
.include "library/pcre.imc"

.sub _main prototyped

  # Loading shared lib
  .local pmc pcre_lib
  .PCRE_INIT(pcre_lib)

  # pcre *pcre_compile(const char *pattern, int options,
  #            const char **errptr, int *erroffset,
  #            const unsigned char *tableptr
  .local pmc pcre_compile
  pcre_compile = global "pcre::compile"

  #int pcre_exec(const pcre *code, const pcre_extra *extra,
  #        const char *subject, int length, int startoffset,
  #        int options, int *ovector, int ovecsize);
  .local pmc pcre_exec
  pcre_exec = global "pcre::exec"

  .local int is_defined

  # Variables for compiling
  .local string error
  repeat error, " ", 500      # could be enough
  .local int    errptr
  .local pmc NULL
  null NULL

  # compile regular expression 'as'
  .local pmc re_as
  .PCRE_COMPILE('as', 0, re_as, error, errptr)

  # compile regular expression 'df'
  .local pmc re_df
  .pcc_begin prototyped
    .arg 'df'
    .arg 0
    .arg error
    .arg errptr
    .arg NULL
  .nci_call pcre_compile
    .result re_df
  .pcc_end

  # Variables for matching
  .local string s
  s = "asdf"
  .local int s_len
  length s_len, s
  .local int ok
  .local pmc ovector
  ovector = new ManagedStruct
  ovector = 120       # 1/(2/3) * 4  * 2 * 10 for 10 result pairs

  # Try a match
  .pcc_begin prototyped
    .arg re_as
    .arg NULL           # P extra
    .arg s              # t subject
    .arg s_len    
    .arg 0
    .arg 0
    .arg ovector        # p ovector
    .arg 10             # i ovecsize
  .nci_call pcre_exec
    .result ok
  .pcc_end
  if ok < 0 goto EXEC_FAILED
  print ok
  print " match(es):\n"

  # Try another match
  .pcc_begin prototyped
    .arg re_df
    .arg NULL           # P extra
    .arg s              # t subject
    .arg s_len    
    .arg 0
    .arg 0
    .arg ovector        # p ovector
    .arg 10             # i ovecsize
  .nci_call pcre_exec
    .result ok
  .pcc_end
  print ok
  if ok < 0 goto NO_MATCH
  print " match(es):\n"

  end

NO_MATCH:
  print " no match\n"
  end

COMPILE_FAILED:
  print "error in pcre_compile :"
  print error
  print "\n"
  end

.end
END_PIR

  output_is( $pir, << 'OUTPUT', "calling pcre_compile directly two times" );
1 match(es):
1 match(es):
OUTPUT
}
if ( 0 )
{
  my $pir = << 'END_PIR';
.include "library/pcre.imc"
.sub _main prototyped
  print	"\n"
  .local pmc lib
  .PCRE_INIT(lib)
  .local string error
  .local int errptr
  .local string pat

  .local pmc regex
  pat = 'as'
  .PCRE_COMPILE(pat, 0, regex, error, errptr)
  $I0 = defined regex
  unless $I0 goto match_err

  .local pmc regex_2
  pat = 'df'
  .PCRE_COMPILE(pat, 0, regex_2, error, errptr)
  $I0 = defined regex_2
  unless $I0 goto match_err

  .local int ok
  .local pmc result
  .local string s
  s = "asdf"
  .PCRE_MATCH(regex, s, 0, 0, ok, result)
  if ok < 0 goto nomatch
  print ok
  print " match(es):\n"
  .local int i
  i = 0
  .local string match
  .local string s
lp: .PCRE_DOLLAR(s, ok, result, i, match)
  print match
  print "\n"
  inc i
  if i < ok goto lp
  end
nomatch:
  print "no match\n"
  end
match_err:
  print "error in regex: "
  print "at: '"
  length $I0, pat
  $I0 = $I0 - errptr
  substr $S0, pat, errptr, $I0
  print $S0
  print "'\n"
  exit 1
.end
END_PIR

  output_is( $pir, << 'OUTPUT', "calling .PCRE_COMPILE two times" );

1 match(es):
as
OUTPUT
}

# doesn't work
if ( 0 )
{
  my $pir = << 'END_PIR';
.include "library/pcre.imc"
.sub _main prototyped
  print	"\n"
  .local pmc lib
  .PCRE_INIT(lib)
  .local string error
  .local int errptr
  .local string pat

  .local pmc regex
  pat = 'as'
  .PCRE_COMPILE(pat, 0, regex, error, errptr)
  $I0 = defined regex
  unless $I0 goto match_err

  .local int ok
  .local pmc result
  .local string s
  .local int i
  s = "asdf"
  .PCRE_MATCH(regex, s, 0, 0, ok, result)
  if ok < 0 goto nomatch
  print ok
  print " match(es):\n"
  i = 0
  .local string match
lp: .PCRE_DOLLAR(s, ok, result, i, match)
  print match
  print "\n"
  inc i
  if i < ok goto lp

  .local pmc regex_2
  .local string pat_2
  pat_2 = 'df'
  .local string error_2
  .local int errptr_2
  #.PCRE_COMPILE(pat_2, 0, regex_2, error_2, errptr_2)
  #------ Start of PCRE_COMPILE ------------------
    $P1 = global "_pcre_compile"     # This sub is defined in libpcre.imc
    .pcc_begin prototyped
    .arg pat_2
    .arg 0
    .pcc_call $P1
    .result regex_2
    .result error_2
    .result errptr_2
    .pcc_end
  #------ End of PCRE_COMPILE ------------------
  $I0 = defined regex_2
  unless $I0 goto match_err

  .local int ok_2
  .local pmc result_2
  .local string s_2
  .local int i_2
  s_2 = "asdf"

  end
nomatch:
  print "no match\n"
  end
match_err:
  print "error in regex: "
  print "at: '"
  length $I0, pat
  $I0 = $I0 - errptr
  substr $S0, pat, errptr, $I0
  print $S0
  print "'\n"
  exit 1
.end
END_PIR

  output_is( $pir, << 'OUTPUT', "calling .PCRE_COMPILE two times" );

1 match(es):
as

1 match(es):
df
OUTPUT
}

