# $Id$

use FindBin;
use lib "$FindBin::Bin/../lib";

use URM::Test tests => 3;

## Ok, writing my own mmu

output_is(<< 'CODE', << 'OUT', 'from testmmu.urm');

out(r100);

5: r5 <- 5
6: r6 <- 6
7: r7 <- 7
8: r8 <- 8
9: r9 <- 9
10: r10 <- 10
11: r11 <- 11
12: r12 <- 12
13: r13 <- 13
14: r14 <- 14
15: r15 <- 15
16: r16 <- 16
17: r17 <- 17
18: r18 <- 18
19: r19 <- 19
20: r20 <- 20
21: r21 <- 21
22: r22 <- 22
23: r23 <- 23
24: r24 <- 24
25: r25 <- 25
26: r26 <- 26
27: r27 <- 27
28: r28 <- 28
29: r29 <- 29
30: r30 <- 30
31: r31 <- 31
32: r32 <- 32
33: r33 <- 33
34: r34 <- 34
35: r35 <- 35
36: r36 <- 36
37: r37 <- 37
38: r38 <- 38
39: r39 <- 39
40: r40 <- 40
41: r41 <- 41
42: r42 <- 42
43: r43 <- 43
44: r44 <- 44
45: r45 <- 45
46: r46 <- 46
47: r47 <- 47
48: r48 <- 48
49: r49 <- 49
50: r50 <- 50
51: r51 <- 51
52: r52 <- 52
53: r53 <- 53
54: r54 <- 54
55: r55 <- 55
56: r56 <- 56
57: r57 <- 57
58: r58 <- 58
59: r59 <- 59
60: r60 <- 60
61: r61 <- 61
62: r62 <- 62
63: r63 <- 63
64: r64 <- 64
65: r65 <- 65
66: r66 <- 66
67: r67 <- 67
68: r68 <- 68
69: r69 <- 69
70: r70 <- 70
71: r71 <- 71
72: r72 <- 72
73: r73 <- 73
74: r74 <- 74
75: r75 <- 75
76: r76 <- 76
77: r77 <- 77
78: r78 <- 78
79: r79 <- 79
80: r80 <- 80
81: r81 <- 81
82: r82 <- 82
83: r83 <- 83
84: r84 <- 84
85: r85 <- 85
86: r86 <- 86
87: r87 <- 87
88: r88 <- 88
89: r89 <- 89
90: r90 <- 90
91: r91 <- 91
92: r92 <- 92
93: r93 <- 93
94: r94 <- 94
95: r95 <- 95
96: r96 <- 96
97: r97 <- 97
98: r98 <- 98
99: r99 <- 99
100: r100 <- 100
101: r101 <- 101
102: r102 <- 102
103: r103 <- 103
104: r104 <- 104
105: r105 <- 105
106: r106 <- 106
107: r107 <- 107
108: r108 <- 108
109: r109 <- 109
110: r110 <- 110
111: r111 <- 111
112: r112 <- 112
113: r113 <- 113
114: r114 <- 114
115: r115 <- 115
116: r116 <- 116
117: r117 <- 117
118: r118 <- 118
119: r119 <- 119
120: r120 <- 120
121: r121 <- 121
122: r122 <- 122
123: r123 <- 123
124: r124 <- 124
125: r125 <- 125
126: r126 <- 126
127: r127 <- 127
128: r128 <- 128
129: r129 <- 129
130: r130 <- 130
131: r131 <- 131
132: r132 <- 132
133: r133 <- 133
134: r134 <- 134
135: r135 <- 135
136: r136 <- 136
137: r137 <- 137
138: r138 <- 138
139: r139 <- 139
140: r140 <- 140
141: r141 <- 141
142: r142 <- 142
143: r143 <- 143
144: r144 <- 144
145: r145 <- 145
146: r146 <- 146
147: r147 <- 147
148: r148 <- 148
149: r149 <- 149
150: r150 <- 150
151: r151 <- 151
152: r152 <- 152
153: r153 <- 153
154: r154 <- 154
155: r155 <- 155
156: r156 <- 156
157: r157 <- 157
158: r158 <- 158
159: r159 <- 159
160: r160 <- 160
161: r161 <- 161
162: r162 <- 162
163: r163 <- 163
164: r164 <- 164
165: r165 <- 165
166: r166 <- 166
167: r167 <- 167
168: r168 <- 168
169: r169 <- 169
170: r170 <- 170
171: r171 <- 171
172: r172 <- 172
173: r173 <- 173
174: r174 <- 174
175: r175 <- 175
176: r176 <- 176
177: r177 <- 177
178: r178 <- 178
179: r179 <- 179
180: r180 <- 180
181: r181 <- 181
182: r182 <- 182
183: r183 <- 183
184: r184 <- 184
185: r185 <- 185
186: r186 <- 186
187: r187 <- 187
188: r188 <- 188
189: r189 <- 189
190: r190 <- 190
191: r191 <- 191
192: r192 <- 192
193: r193 <- 193
194: r194 <- 194
195: r195 <- 195
196: r196 <- 196
197: r197 <- 197
198: r198 <- 198
199: r199 <- 199
200: r200 <- 200
CODE
100
OUT



output_is(<< 'CODE', << 'OUT', 'from testmmu.urm');
## Ok, testing my own mmu
## The thing leo got me with

out(r32);

1: r40 <- r100 + r200 
2: r32 <- 5 # should be I0
3: r64 <- 3 # this too
4: r128 <- 29 # and this too
5: r32 <- r64 - 1
CODE
2
OUT


output_is(<< 'CODE', << 'OUT', 'from testmmu.urm');

out(r5);

5: r5 <- 5
6: r6 <- 6
7: r7 <- 7
8: r8 <- 8
9: r9 <- 9
10: r10 <- 10
11: r11 <- 11
12: r12 <- 12
13: r13 <- 13
14: r14 <- 14
15: r15 <- 15
16: r16 <- 16
17: r17 <- 17
18: r18 <- 18
19: r19 <- 19
20: r20 <- 20
21: r21 <- 21
22: r22 <- 22
23: r23 <- 23
24: r24 <- 24
25: r25 <- 25
26: r26 <- 26
27: r27 <- 27
28: r28 <- 28
29: r29 <- 29
30: r30 <- 30
31: r31 <- 31
32: r32 <- 32
33: r33 <- 33
34: r34 <- 34
35: r35 <- 35
36: r36 <- 36
37: r37 <- 37
38: r38 <- 38
39: r39 <- 39
40: r40 <- 40
41: r41 <- 41
42: r42 <- 42
43: r43 <- 43

44: r5 <- r10 + r32
55: r6 <- r20 + r30
56: r5 <- r5 + r6
CODE
92
OUT
