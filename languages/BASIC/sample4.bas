10 GOSUB 100
20 GOSUB 300
99 END
100 REM
101 REM Test strings and stuff
102 REM
105 PRINT "String test.  My name and then a Tic-Tac-Toe board"
110 LET A$="Clinton Pierce"
120 PRINT "Parrot BASIC by: ";
130 PRINT A$
140 FOR I=0 TO 2
150 FOR J=0 TO 2
155 READ R$
157 LET T$(I,J)=R$
160 NEXT J
170 NEXT I
190 DATA "X","O"," "
200 DATA "X","X","O"
210 DATA "O","O","X"
220 FOR I=0 TO 2
230 FOR J=0 TO 2
240 PRINT T$(I,J);
250 PRINT " ";
260 NEXT J
265 PRINT
270 NEXT I
280 RETURN
300 REM
301 REM String Concatenation
302 REM
305 DUMP
310 LET A$="HELLO "
315 DUMP
320 LET B$="WORLD"
340 LET C$=A$+B$
350 PRINT "Standard greeting: ";
360 PRINT C$
370 RETURN
                                      