1 REM Taken from David Ahl's 101 BASIC Games reproduced in article
2 REM (available on Google) 9207071854.AA21847@thep.lu.se
3 REM      Ported to Parrot BASIC by Clinton Pierce.
4 REM License status: Unknown
5 REM *** HUNT THE WUMPUS ***
11 DIM I$(20)
15 PRINT "INSTRUCTIONS (Y-N)";
20 INPUT I$
25 IF I$="N" THEN GOTO 35
30 GOSUB 375
35 GOTO 80
80 REM *** SET UP CAVE (DODECAHEDRAL NODE LIST) ***
90 FOR J=1 TO 20
95 FOR K=1 TO 3
100 READ S(J,K)
105 NEXT K
110 NEXT J
115 DATA 2,5,8,1,3,10,2,4,12,3,5,14,1,4,6
120 DATA 5,7,15,6,8,17,1,7,9,8,10,18,2,9,11
125 DATA 10,12,19,3,11,13,12,14,20,4,13,15,6,14,16
130 DATA 15,17,20,7,16,18,9,17,19,11,18,20,13,16,19
150 REM *** LOCATE L ARRAY ITEMS ***
155 REM *** 1-YOU, 2-WUMPUS, 3&4-PITS, 5&6-BATS ***
170 PRINT "SETTING UP MAZE.  PLEASE WAIT."
171 FOR J=1 TO 6
175 LET L(J)=RND(20)+1
180 LET M(J)=L(J)
185 NEXT J
190 REM *** CHECK FOR CROSSOVERS (IE L(1)=L(2), ETC) ***
195 FOR J=1 TO 6
200 FOR K=1 TO 6
205 IF J=K THEN GOTO 215
210 IF L(J)=L(K) THEN GOTO 171
215 NEXT K
220 NEXT J
225 REM *** SET NO. OF ARROWS ***
230 LET A=5
235 LET L=L(1)
240 REM *** RUN THE GAME ***
245 PRINT "HUNT THE WUMPUS"
250 REM *** HAZARD WARNING AND LOCATION ***
255 GOSUB 585
260 REM *** MOVE OR SHOOT ***
265 GOSUB 670
271 IF O=1 THEN GOTO 280
272 IF O=2 THEN GOTO 300
273 REM 270 ON O GOTO 280,300
275 REM *** SHOOT ***
280 GOSUB 715
285 IF F=0 THEN GOTO 255
290 GOTO 310
295 REM *** MOVE ***
300 GOSUB 975
305 IF F=0 THEN GOTO 255
310 IF F>0 THEN GOTO 335
315 REM *** LOSE ***
320 PRINT "HA HA HA - YOU LOSE!"
325 GOTO 340
330 REM *** MOVE ***
335 PRINT "HEE HEE HEE - THE WUMPUS`LL GET YOU NEXT TIME!!"
340 FOR J=1 TO 6
345 LET L(J)=M(J)
350 NEXT J
355 PRINT "SAME SETUP (Y-N)";
360 INPUT I$
365 IF I$ <> "Y" THEN GOTO 170
370 GOTO 230
375 REM *** INSTRUCTIONS ***
380 PRINT "WELCOME TO HUNT THE WUMPUS"
385 PRINT "  THE WUMPUS LIVES IN A CAVE OF 20 ROOMS. EACH ROOM"
390 PRINT "HAS 3 TUNNELS LEADING TO OTHER ROOMS. (LOOK AT A"
395 PRINT "DODECAHEDRON TO SEE HOW THIS WORKS-IF YOU DONT KNOW"
400 PRINT "WHAT A DODECAHEDRON IS, ASK SOMEONE)"
405 PRINT
410 PRINT "     HAZARDS:"
415 PRINT " BOTTOMLESS PITS - TWO ROOMS HAVE BOTTOMLESS PITS IN THEM"
420 PRINT "     IF YOU GO THERE, YOU FALL INTO THE PIT (& LOSE!)"
425 PRINT " SUPER BATS - TWO OTHER ROOMS HAVE SUPER BATS. IF YOU"
430 PRINT "     GO THERE, A BAT GRABS YOU AND TAKES YOU TO SOME OTHER"
435 PRINT "     ROOM AT RANDOM. (WHICH MAY BE TROUBLESOME)"
439 PRINT "TYPE AN I THEN RETURN ";
440 INPUT W9
445 PRINT "     WUMPUS:"
450 PRINT " THE WUMPUS IS NOT BOTHERED BY HAZARDS (HE HAS SUCKER"
455 PRINT " FEET AND IS TOO BIG FOR A BAT TOO LIFT).  USUALLY"
460 PRINT " HE IS ASLEEP.  TWO THINGS WAKE HIM UP:YOU SHOOTING AN"
465 PRINT " OR YOU ENTERING HIS ROOM."
470 PRINT "     IF THE WUMPUS WAKES HE MOVES (P=.75) ONE ROOM"
475 PRINT " OR STAYS STILL (P=.25).  AFTER THAT, IF HE IS WHERE YOU"
480 PRINT " ARE, HE EATS YOU UP AND YOU LOSE!"
485 PRINT
490 PRINT "     YOU:"
495 PRINT " EACH TURN YOU MAY MOVE OR SHOOT A CROOKED ARROW"
500 PRINT "   MOVING:  YOU CAN MOVE ONE ROOM (THRU ONE TUNNEL)"
505 PRINT "   ARROWS:  YOU HAVE 5 ARROWS.  YOU LOSE WHEN YOU RUN OUT"
510 PRINT "   EACH ARROW CAN GO FROM 1 TO 5 ROOMS. YOU AIM BY TELLIN"
515 PRINT "   THE COMPUTER THE ROOM#S YOU WANT THE ARROW TO GO TO."
520 PRINT "   IF THE ARROW CANT GO THAT WAY (IF NO TUNNEL) IT MOVES"
525 PRINT "   AT RANDOM TO THE NEXT ROOM."
530 PRINT "     IF THE ARROW HITS THE WUMPUS, YOU WIN."
535 PRINT "     IF THE ARROW YOU, YOU LOSE."
539 PRINT "TYPE AN E THEN RETURN ";
540 INPUT W9
545 PRINT "    WARNINGS:"
550 PRINT "     WHEN YOU ARE ONE ROOM AWAY FROM A WUMPUS OR HAZARD,"
555 PRINT "     THE COMPUTER SAYS:"
560 PRINT " WUMPUS:  I SMELL A WUMPUS"
565 PRINT " BAT   :  BATS NEARBY"
570 PRINT " PIT   :  I FEEL A DRAFT"
575 PRINT
580 RETURN
585 REM *** PRINT LOCATION & HAZARD WARNINGS ***
590 PRINT
595 FOR J=2 TO 6
600 FOR K=1 TO 3
605 IF S(L(1),K) <> L(J) THEN GOTO 640
609 REM 610 ON J-1 GOTO 615,625,625,635,635
610 IF J-1=1 THEN GOTO 615
611 IF J-1=2 THEN GOTO 625
612 IF J-1=3 THEN GOTO 625
613 IF J-1=4 THEN GOTO 635
614 IF J-1=5 THEN GOTO 635
615 PRINT "I SMELL A WUMPUS!";
620 GOTO 640
625 PRINT "I FEEL A DRAFT"
630 GOTO 640
635 PRINT "BATS NEARBY!"
640 NEXT K
645 NEXT J
650 PRINT "YOU ARE IN ROOM ";
652 PRINT L(1)
655 PRINT "TUNNELS LEAD TO ";
656 PRINT S(L,1);
657 PRINT " ";
658 PRINT S(L,2);
659 PRINT " ";
660 PRINT S(L,3)
661 PRINT
665 RETURN
670 REM *** CHOOSE OPTION ***
675 PRINT "SHOOT OR MOVE (S-M) ";
680 INPUT I$
685 IF I$ <> "S" THEN GOTO 700
690 LET O=1
695 RETURN
700 IF I$ <> "M" THEN GOTO 675
705 LET O=2
710 RETURN
715 REM *** ARROW ROUTINE ***
720 LET F=0
725 REM *** PATH OF ARROW ***
735 PRINT "NO. OF ROOMS (1-5)";
740 INPUT J9
745 IF J9<1 THEN GOTO 735
750 IF J9>5 THEN GOTO 735
755 FOR K=1 TO J9
760 PRINT "ROOM #";
765 INPUT P(K)
770 IF K<=2 THEN GOTO 790
775 IF P(K) <> P(K-2) THEN GOTO 790
780 PRINT "ARROWS ARENT THAT CROOKED - TRY ANOTHER ROOM"
785 GOTO 760
790 NEXT K
795 REM *** SHOOT ARROW ***
800 LET L=L(1)
805 FOR K=1 TO J9
810 FOR K1=1 TO 3
815 IF S(L,K1)=P(K) THEN GOTO 895
820 NEXT K1
825 REM *** NO TUNNEL FOR ARROW ***
830 LET L=S(L,RND(3)+1)
835 GOTO 900
840 NEXT K
845 PRINT "MISSED"
850 LET L=L(1)
855 REM *** MOVE WUMPUS ***
860 GOSUB 935
865 REM *** AMMO CHECK ***
870 LET A=A-1
875 IF A>0 THEN GOTO 885
880 LET F=-1
885 RETURN
890 REM *** SEE IF ARROW IS AT L(1) OR AT L(2)
895 LET L=P(K)
900 IF L <> L(2) THEN GOTO 920
905 PRINT "AHA! YOU GOT THE WUMPUS!"
910 LET F=1
915 RETURN
920 IF L <> L(1) THEN GOTO 840
925 PRINT "OUCH! ARROW GOT YOU!"
930 GOTO 880
935 REM *** MOVE WUMPUS ROUTINE ***
940 LET K=RND(4)+1
945 IF K=4 THEN GOTO 955
950 LET L(2)=S(L(2),K)
955 IF L(2) <> L THEN GOTO 970
960 PRINT "TSK TSK TSK - WUMPUS GOT YOU!"
965 LET F=-1
970 RETURN
975 REM *** MOVE ROUTINE ***
980 LET F=0
985 PRINT "WHERE TO ";
990 INPUT L
995 IF L<1 THEN GOTO 985
1000 IF L>20 THEN GOTO 985
1002 REM PRINT "Wanted ",L
1005 FOR K=1 TO 3
1010 REM *** CHECK IF LEGAL MOVE ***
1017 IF S(L(1),K)=L THEN GOTO 1045
1020 NEXT K
1025 IF L=L(1) THEN GOTO 1045
1030 PRINT "NOT POSSIBLE -";
1035 GOTO 985
1040 REM *** CHECK FOR HAZARDS ***
1045 LET L(1)=L
1050 REM *** WUMPUS ***
1055 IF L <> L(2) THEN GOTO 1090
1060 PRINT "... OOPS! BUMPED A WUMPUS!"
1065 REM *** MOVE WUMPUS ***
1070 GOSUB 940
1075 IF F=0 THEN GOTO 1090
1080 RETURN
1085 REM *** PIT ***
1090 IF L=L(3) THEN GOTO 1100
1095 IF L <> L(4) THEN GOTO 1120
1100 PRINT "YYYYIIIIEEEE . . . FELL IN PIT"
1105 LET F=-1
1110 RETURN
1115 REM *** BATS ***
1120 IF L=L(5) THEN GOTO 1130
1125 IF L <> L(6) THEN GOTO 1145
1130 PRINT "ZAP--SUPER BAT SNATCH! ELSEWHEREVILLE FOR YOU!"
1135 LET L=RND(20)+1
1140 GOTO 1045
1145 RETURN
1150 END
