10 print chr$(147)
20 print "generated with spritemate"
30 print "1 of 1 sprites displayed."
40 poke 53285,8: rem multicolor 1
50 poke 53286,6: rem multicolor 2
60 poke 53269,255 : rem set all 8 sprites visible
70 for x=12800 to 12800+63: read y: poke x,y: next x: rem sprite generation
80 :: rem sprite_0
90 poke 53287,4: rem color = 4
100 poke 2040,200: rem pointer
110 poke 53248, 44: rem x pos
120 poke 53249, 120: rem y pos
130 poke 53276, 0: rem multicolor
140 poke 53277, 0: rem width
150 poke 53271, 0: rem height
1000 :: rem sprite_0 / singlecolor / color: 4
1010 data 0,0,0,12,66,112,18,66,136,51,66,128,33,90,112,63
1020 data 90,8,33,102,136,33,66,112,0,0,0,0,0,60,0,0
1030 data 4,96,0,36,56,0,228,15,131,128,0,254,0,0,0,0
1040 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
