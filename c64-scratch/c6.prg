
5 print chr$(147): rem clear screen

10 rem initialize sprite data
20 for i = 0 to 62: read a: poke 832+i,a: next i
30 rem sprite data for AWS logo (simplified)
40 data 0,0,0,12,66,112,18,66,136,51,66,128,33,90,112,63
50 data 90,8,33,102,136,33,66,112,0,0,0,0,0,60,0,0
60 data 4,96,0,36,56,0,228,15,131,128,0,254,0,0,0,0
70 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
80 rem set up sprite
90 poke 53248,100: rem x coordinate (low byte)
100 poke 53249,100: rem y coordinate
110 poke 2040,13: rem sprite 0 data from block 13 (832/64)
120 poke 53287,5: rem sprite 0 color (green)
130 poke 53269,1: rem enable sprite 0
140 poke 53271,1: rem y-expand sprite 0
150 poke 53277,1: rem x-expand sprite 0

160 rem initialize variables
170 x = 100: y = 100: jumping = 0: jh = 0

180 rem main loop
190 poke 53248,x: rem update x coordinate
200 poke 53249,y: rem update y coordinate

210 rem check for space bar
220 if peek(203) = 60 and jumping = 0 then jumping = 1: jh = 0

230 rem handle jumping
240 if jumping = 1 then gosub 1000

250 rem move sprite
260 x = x + 1: if x > 255 then x = 0: poke 53264, peek(53264) xor 1

270 rem delay
280 for d = 1 to 25: next d

290 goto 190

1000 rem jumping subroutine
1010 if jh < 20 then y = y - 2: jh = jh + 1: return
1020 if jh < 40 then y = y + 2: jh = jh + 1
1030 if jh = 40 then jumping = 0
1040 return



5 print chr$(147): rem clear screen

10 rem initialize sprite data
20 for i = 0 to 62: read a: poke 832+i,a: next i
30 rem sprite data for AWS logo (simplified)
40 data 0,0,0,12,66,112,18,66,136,51,66,128,33,90,112,63
50 data 90,8,33,102,136,33,66,112,0,0,0,0,0,60,0,0
60 data 4,96,0,36,56,0,228,15,131,128,0,254,0,0,0,0
70 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
80 rem set up sprite
90 poke 53248,100: rem x coordinate (low byte)
100 poke 53249,100: rem y coordinate
110 poke 2040,13: rem sprite 0 data from block 13 (832/64)
120 poke 53287,5: rem sprite 0 color (green)
130 poke 53269,1: rem enable sprite 0
140 poke 53271,1: rem y-expand sprite 0
150 poke 53277,1: rem x-expand sprite 0

160 rem initialize variables
170 x = 100: y = 100: dx = 2: dy = 2

180 rem main loop
190 rem update position
200 x = x + dx: y = y + dy

210 rem check boundaries and bounce
220 if x < 24 or x > 320 then dx = -dx
230 if y < 50 or y > 230 then dy = -dy

240 rem update sprite position
250 poke 53248, x and 255
260 poke 53264, (peek(53264) and 254) or ((x > 255) and 1)
270 poke 53249, y

280 rem delay
290 for d = 1 to 25: next d

300 goto 190


5 print chr$(147): rem clear screen

10 rem initialize sprite data
20 for i = 0 to 62: read a: poke 832+i,a: next i
30 rem sprite data for AWS logo (simplified)
40 data 0,0,0,12,66,112,18,66,136,51,66,128,33,90,112,63
50 data 90,8,33,102,136,33,66,112,0,0,0,0,0,60,0,0
60 data 4,96,0,36,56,0,228,15,131,128,0,254,0,0,0,0
70 data 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
80 rem set up sprites
90 for s = 0 to 3
100   poke 53248+s*2, 50+s*50: rem x coordinate
110   poke 53249+s*2, 50+s*40: rem y coordinate
120   poke 2040+s, 13: rem sprite data pointer
130   poke 53287+s, s+2: rem sprite color
140 next s
150 poke 53269, 15: rem enable first 4 sprites
160 poke 53271, 15: rem y-expand first 4 sprites
170 poke 53277, 15: rem x-expand first 4 sprites

180 rem initialize variables
190 dim x(3), y(3), dx(3), dy(3)
200 for s = 0 to 3
210   x(s) = 50+s*50: y(s) = 50+s*40
220   dx(s) = int(rnd(1)*4)-2: dy(s) = int(rnd(1)*4)-2
230   if dx(s) = 0 then dx(s) = 1
240   if dy(s) = 0 then dy(s) = 1
250 next s

260 rem main loop
270 for s = 0 to 3
280   rem update position
290   x(s) = x(s) + dx(s): y(s) = y(s) + dy(s)

300   rem check boundaries and bounce
310   if x(s) < 24 or x(s) > 320 then dx(s) = -dx(s)
320   if y(s) < 50 or y(s) > 230 then dy(s) = -dy(s)

330   rem update sprite position
340   poke 53248+s*2, x(s) and 255
350   poke 53264, (peek(53264) and (255-2^s)) or ((x(s) > 255) * 2^s)
360   poke 53249+s*2, y(s)
370 next s

380 rem delay
390 for d = 1 to 25: next d

400 goto 270
