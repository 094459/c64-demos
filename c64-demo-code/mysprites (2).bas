10 print chr$(147)
20 print "generated with spritemate"
30 print "4 of 4 sprites displayed."
40 poke 53285,6: rem multicolor 1
50 poke 53286,14: rem multicolor 2
60 poke 53269,255 : rem set all 8 sprites visible
70 for x=12800 to 12800+255: read y: poke x,y: next x: rem sprite generation
80 :: rem sprite_0
90 poke 53287,1: rem color = 1
100 poke 2040,200: rem pointer
110 poke 53248, 44: rem x pos
120 poke 53249, 120: rem y pos
130 :: rem sprite_1
140 poke 53288,1: rem color = 1
150 poke 2041,201: rem pointer
160 poke 53250, 92: rem x pos
170 poke 53251, 120: rem y pos
180 :: rem sprite_2
190 poke 53289,3: rem color = 3
200 poke 2042,202: rem pointer
210 poke 53252, 140: rem x pos
220 poke 53253, 120: rem y pos
230 :: rem sprite_2
240 poke 53290,3: rem color = 3
250 poke 2043,203: rem pointer
260 poke 53254, 188: rem x pos
270 poke 53255, 120: rem y pos
280 poke 53276, 15: rem multicolor
290 poke 53277, 0: rem width
300 poke 53271, 0: rem height
1000 :: rem sprite_0 / multicolor / color: 1
1010 data 0,0,0,0,0,0,12,51,12,55,17,55,25,34,25,34
1020 data 34,34,34,34,32,42,34,8,34,42,2,34,38,34,17,29
1030 data 25,51,51,55,0,0,0,32,0,40,24,0,8,6,130,136
1040 data 3,105,192,0,0,0,0,0,0,0,0,0,0,0,0,129
1050 :: rem sprite_1 / multicolor / color: 1
1060 data 0,0,0,3,192,240,13,64,92,54,179,167,26,145,169,105
1070 data 102,170,111,170,170,110,170,170,102,170,170,106,170,170,106,170
1080 data 170,26,170,169,58,170,171,6,170,164,13,170,156,3,106,112
1090 data 0,106,64,0,217,192,0,25,0,0,55,0,0,12,0,129
1100 :: rem sprite_2 / multicolor / color: 3
1110 data 1,237,0,3,171,0,6,170,64,14,170,192,26,170,144,58
1120 data 170,176,42,170,160,42,186,160,42,222,160,42,66,160,42,199
1130 data 160,42,156,224,42,171,48,58,170,208,26,170,128,14,170,192
1140 data 6,170,64,3,171,0,1,237,0,0,116,0,0,16,0,131
1150 :: rem sprite_2 / multicolor / color: 3
1160 data 1,237,0,3,187,0,6,86,64,14,118,192,25,237,144,57
1170 data 169,176,39,171,96,38,186,96,38,222,96,38,66,96,38,199
1180 data 160,38,148,224,39,169,32,57,171,64,25,237,128,14,102,192
1190 data 6,118,64,3,155,0,1,237,0,0,116,0,0,16,0,131
