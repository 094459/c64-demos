10 rem display 10 sprites using sprite multiplexing
20 rem set background color to black
30 poke 53281,0
40 rem clear screen
50 print chr$(147)
60 rem sprite data starts at 12288
70 s = 12288
75 dim x(9), y(9), dx(9), dy(9)
80 rem create sprite data
90 for i = 0 to 7
100 for j = 0 to 62
110 poke s + i * 64 + j,85
120 next j
130 next i
140 rem set sprite pointers
150 for i = 0 to 7
160 poke 2040 + i, s / 64 + i
170 next i
180 rem enable sprites 0 to 7
190 poke 53269,255
200 rem set sprite colors
210 for i = 0 to 7
220 poke 53287 + i, i + 1
230 next i
240 rem set initial sprite positions
250 for i = 0 to 9
260 x(i) = 50 + (i * 20 - int((i * 20) / 250) * 250)
270 y(i) = 50 + (i * 10 - int((i * 10) / 200) * 200)
280 dx(i) = 1 + (i and 1)
290 dy(i) = 1 + (i and 1)
300 next i
310 rem main loop
320 for l = 1 to 1000
330 gosub 500
340 next l
350 goto 320
360 rem update sprite positions
500 rem move sprites
510 for i = 0 to 9
520 x(i) = x(i) + dx(i)
530 if x(i) > 250 then x(i) = 50
540 y(i) = y(i) + dy(i)
550 if y(i) > 250 then y(i) = 50
560 rem assign hardware sprite number
570 hs = i - int(i / 8) * 8
580 poke 53248 + hs * 2, x(i)
590 poke 53249 + hs * 2, y(i)
600 next i
610 return
