10 rem display 10 sprites using sprite multiplexing
20 rem set background color to black
30 poke 53281,0
40 rem sprite data starts at 12288 (49152)
50 sprite_base = 12288
60 rem create sprite data
70 for i = 0 to 7
80 for j = 0 to 62
90 poke sprite_base + i * 64 + j,85 : rem fill sprite with pattern
100 next j
110 next i
120 rem set sprite pointers
130 for i = 0 to 7
140 poke 2040 + i, (sprite_base / 64) + i
150 next i
160 rem enable sprites 0 to 7
170 poke 53269,255
180 rem set sprite colors
190 for i = 0 to 7
200 poke 53287 + i, i + 1 : rem colors 1 to 8
210 next i
220 rem set initial sprite positions
230 for i = 0 to 7
240 poke 53248 + i * 2, 50 + i * 20 : rem x position
250 poke 53249 + i * 2, 50 + i * 10 : rem y position
260 next i
270 rem main loop
280 for loop = 1 to 1000
290 gosub 500 : rem update sprite positions
300 next loop
310 goto 280
320 rem update sprite positions
500 for i = 0 to 7
510 y = peek(53249 + i * 2)
520 y = y + 1 : if y > 250 then y = 50
530 poke 53249 + i * 2, y
540 next i
550 rem reuse sprites 0 and 1 for sprites 8 and 9
560 rem sprite 0
570 poke 53248, 50 : poke 53249, y + 100
580 rem sprite 1
590 poke 53250, 100 : poke 53251, y + 120
600 return
