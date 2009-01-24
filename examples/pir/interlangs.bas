1 REM Copyright (C) 2009, The Perl Foundation.
2 REM $Id$
3 REM
110 REM +--------------------------------------------------------------------+
120 REM + interlangs.bas                                                     +
130 REM + A test of parrot HLL languages interoperability                    +
140 REM + from pirric basic interpreter                                      +
150 REM + First build perl6 and ecmascript                                   +
160 REM + Then do:                                                           +
170 REM + ../../parrot -L /yourparrotdir/languages/perl6                     +
180 REM +              -L /yourparrotdir/languages/ecamscript                +
190 REM +               pirric.pir perl6-js.bas                              +
200 REM +--------------------------------------------------------------------+
210 REM
1000 REM Load languages
1010 GOSUB 2000
1020 REM Compile code
1030 GOSUB 3000
1200 REM Execute compiled code
1210 REM Forget the return value from ecmascript
1220 unused= jsblock()
1230 REM The perl6 block return the sub we need
1240 perl6sub= perl6block()
1300 REM Now start playing
1310 REM Get the javascript function created
1318 REM Get the function from the js HLL.
1319 REM *** This syntax is subject to change ***
1320 myfunc= js.myecmascriptfunc
1330 REM Call the perl6 sub passing the ecmascript function as second argument
1340 PRINT perl6sub("pirric", myfunc)
1600 REM First the ecmascript function PRINT his message,
1610 REM then the parrot sub returns a string,
1620 REM that is printed by pirric.
1630 REM The output must be:
1640 REM
1650 REM Hello from ecmascript
1660 REM Hello from a perl6 sub, pirric
1670 REM
1900 REM That's all folks!
1910 EXIT
3000 REM
3010 REM Compile code
3020 REM
3100 REM Perl6 code that return an anonymous sub
3110 ON ERROR GOTO 3900
3120 perl6block=perl6compiler.compile("sub ($a, $b){$b(); 'Hello from a perl6 sub, ' ~ $a; };")
3200 REM ecmascript code that defines a function
3210 ON ERROR GOTO 3920
3220 jsblock=ecmascriptcompiler.compile("function myecmascriptfunc() { print ('Hello from ecmascript'); }")
3800 ON ERROR GOTO 0
3810 RETURN
3900 PRINT "Error compiling perl6"
3910 EXIT 1
3920 PRINT "Error compiling ecmascript"
3930 EXIT 1
2000 REM
2010 REM Load languages
2020 REM
2100 ON ERROR GOTO 2900
2110 LOAD "perl6.pbc", b
2120 perl6compiler = COMPREG("Perl6")
2200 ON ERROR GOTO 2920
2210 LOAD "js.pbc", b
2220 ecmascriptcompiler= COMPREG("JS")
2800 ON ERROR GOTO 0
2810 RETURN
2900 PRINT "Can't load perl6"
2910 EXIT 1
2920 PRINT "Can't load ecmascript"
2930 EXIT 1
