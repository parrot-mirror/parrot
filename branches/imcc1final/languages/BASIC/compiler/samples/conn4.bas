'===========================================================================
' Subject: FOUR IN A ROW                     Date: Unknown Date (00:00:00)
' Author:  Creative Computing                Code: QB, QBasic            
' Keys:    FOUR,IN,ROW,CONNECT             Packet: GAMES.ABC
'===========================================================================
10 PRINT TAB(22); "FOUR IN A ROW"
20 PRINT TAB(20); "CREATIVE COMPUTING"
30 PRINT TAB(18); "MORRISTOWN, NEW JERSEY"
40 PRINT : PRINT : PRINT
100 DIM B$(8, 8), L(8), S(4), F(4)
110 DIM V(16), N(4)
130 DATA 1,100,500,1E20,1,800,4000,1E20
140 DATA 1,75,900,1E18,1,450,3000,1E18
150 FOR Z1 = 1 TO 16: READ V(Z1): NEXT Z1
160 PRINT "THE GAME OF FOUR IN A ROW"
170 INPUT "DO YOU WANT INSTRUCTIONS"; A$
180 IF A$ = "NO" THEN 270
190 IF A$ = "YES" THEN 210
200 PRINT "YES OR NO": GOTO 170
210 PRINT "THE GAME CONSISTS OF STACKING X'S"
220 PRINT "AND O'S (THE COMPUTER HAS O) UNTIL"
230 PRINT "ONE OF THE PLAYER'S GETS FOUR IN A"
240 PRINT "ROW VERTICALLY, HORIZONTALLY, OR "
250 PRINT "DIAGONALLY."
260 PRINT : PRINT
270 X$ = "X": O$ = "O"
280 FOR I = 1 TO 8: FOR J = 1 TO 8: B$(I, J) = "-": NEXT J: NEXT I
290 FOR Z1 = 1 TO 8: L(Z1) = 0: NEXT Z1
300 INPUT "DO YOU WANT TO GO FIRST"; A$
310 IF A$ = "NO" THEN 610
320 GOSUB 340
330 GOTO 450
340 FOR I = 8 TO 1 STEP -1
350 FOR J = 1 TO 8
360 PRINT "  "; B$(I, J);
370 NEXT J
380 PRINT
390 NEXT I
400 PRINT " ";
410 FOR I = 1 TO 8: PRINT I; : NEXT I
420 PRINT : PRINT
430 RETURN
440 PRINT "ILLEGAL MOVE, TRY AGAIN."
450 INPUT "A NUMBER BETWEEN 1 AND 8"; M
460 M = INT(M)
470 IF M < 1 OR M > 8 THEN 440
480 L = L(M)
490 IF L > 7 THEN 440
500 L(M) = L + 1: L = L + 1
510 B$(L, M) = X$
520 PRINT
530 GOSUB 340
540 P$ = X$
550 GOSUB 1240
560 FOR Z = 1 TO 4
570 IF S(Z) < 4 THEN 600
580 PRINT "Y O U   W I N !!!"
590 GOTO ENDGAME
600 NEXT Z
610 M9 = 0: V1 = 0
620 N1 = 1
630 FOR M4 = 1 TO 8
640 L = L(M4) + 1
650 IF L > 8 THEN 1080
660 V = 1
670 P$ = O$: W = 0
680 M = M4
690 GOSUB 1240
700 FOR Z1 = 1 TO 4: N(Z1) = 0: NEXT Z1
710 FOR Z = 1 TO 4
720 S = S(Z)
730 IF S - W > 3 THEN 1130
740 T = S + F(Z)
750 IF T < 4 THEN 780
760 V = V + 4
770 N(S) = N(S) + 1
780 NEXT Z
790 FOR I = 1 TO 4
800 N = N(I) - 1
810 IF N = -1 THEN 840
820 I1 = 8 * W + 4 * SGN(N) + I
830 V = V + V(I1) + N * V(8 * W + I)
840 NEXT I
850 IF W = 1 THEN 880
860 W = 1: P$ = X$
870 GOTO 690
880 L = L + 1
920 IF L > 8 THEN 1020
930 GOSUB 1240
940 FOR Z = 1 TO 4
950 IF S(Z) > 3 THEN V = 2
960 NEXT Z
1020 IF V < V1 THEN 1080
1030 IF V > V1 THEN N1 = 1: GOTO 1060
1040 N1 = N1 + 1
1050 IF RND(1) > 1 / N1 THEN 1080
1060 V1 = V
1070 M9 = M4
1080 NEXT M4
1090 IF M9 <> 0 THEN 1120
1100 PRINT "T I E   G A M E ..."
1110 GOTO ENDGAME
1120 M = M9
1130 PRINT "COMPUTER PICKS COLUMN "; M: PRINT
1140 L = L(M) + 1: L(M) = L(M) + 1
1150 B$(L, M) = O$
1160 P$ = O$: GOSUB 340
1170 GOSUB 1240
1180 FOR Z = 1 TO 4
1190 IF S(Z) < 4 THEN 1220
1200 PRINT "C O M P U T E R   W I N S !!!"
1210 GOTO ENDGAME
1220 NEXT Z
1230 GOTO 450
1240 Q$ = X$
1250 IF P$ = X$ THEN Q$ = O$
1260 D2 = 1: D1 = 0
1270 Z = 0
1280 GOSUB 1360
1290 D1 = 1: D2 = 1
1300 GOSUB 1360
1310 D2 = 0: D1 = 1
1320 GOSUB 1360
1330 D2 = -1: D1 = 1
1340 GOSUB 1360
1350 RETURN
1360 D = 1: S = 1
1370 T = 0
1380 Z = Z + 1
1390 C = 0
1400 FOR K = 1 TO 3
1410 M5 = M + K * D1: L1 = L + K * D2
1420 IF M5 < 1 OR L1 < 1 OR M5 > 8 OR L1 > 8 THEN 1510
1430 B$ = B$(L1, M5)
1440 IF C = 0 THEN 1480
1450 IF B$ = Q$ THEN K = 3: GOTO 1510
1460 T = T + 1
1470 GOTO 1510
1480 IF B$ = P$ THEN S = S + 1: GOTO 1510
1490 C = 1
1500 GOTO 1450
1510 NEXT K
1520 IF D = 0 THEN 1550
1530 D = 0: D1 = -D1: D2 = -D2
1540 GOTO 1390
1550 S(Z) = S
1560 F(Z) = T
1570 RETURN

ENDGAME:

