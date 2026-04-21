// Attribution - based from code here - https://raw.githubusercontent.com/zendar/spritemultiplexer/refs/heads/master/multi.asm
// Constants
.const PADDING = 4
.const MAX_SPRITES = 16  // 16 makes a great circle
.const TEMP1 = $FB
.const TEMP2 = $FC
.const SpriteIndex = $FD
.const VicSpriteIndex = $FE

// Use BasicUpstart2 to create proper BASIC startup
.pc = $0801 "Basic Upstart"
:BasicUpstart2(start)

// Main program
.pc = $1000 "Main Program"
start:
                sei
                lda #$7f
                sta $dc0d
                sta $dd0d
                lda #$35
                sta $01

                lda #$05            // Blue color
                sta $d020           // Set border color
                sta $d021           // Set background color

                ldx #$00
clear_screen:   lda #$20            // Space character
                sta $0400,x         // Clear screen memory (row 1)
                sta $0500,x         // Clear screen memory (row 2)
                sta $0600,x         // Clear screen memory (row 3)
                sta $0700,x         // Clear screen memory (row 4)
                inx
                bne clear_screen    // Repeat until all rows are cleared

                lda #$01
                sta $d01a
                lda #$00        // interrupt occurs when raster beam on line 0
                sta $d012
                lda $d011
                and #$7f
                sta $d011
                lda #<irq
                sta $fffe
                lda #>irq
                sta $ffff
                asl $d019
                cli

                // sprite setup
                lda #$ff
                sta $d015       // sprites set on
                sta $d01c       // Set all sprites to multicolor mode

                lda #$06        // sprite multicolor 1
                sta $d025
                lda #$0e        // sprite multicolor 2
                sta $d026

                lda #$00
                sta $d020
                sta $d021

                ldx #0
                stx $FA
                stx $FB
                stx $FC
                stx $FD
                stx $FE
loop:           jmp loop

// Interrupt routine
irq:            pha             // AXY registers values are placed on stack
                txa
                pha
                tya
                pha
lp:             ldx SpriteIndex // X first used to read Spriteorder table
                lda SpriteOrder,x
                tax             // X will hold value of routine's sprite number

                lda VicSpriteIndex
                and #$07
                tay             // Y will hold value of VIC sprite number

                lda SpriteColor,x
                sta $d027,y
                lda SpritePointer,x
                sta $0400 + $03f8,y

                stx TEMP1
                lda SpriteXMSB,x
                beq nomsb
msb:            lda $d010
                ora POT,y
                sta $d010
                bne msbdone
nomsb:          lda $d010
                and IPOT,y
                sta $d010
msbdone:        ldx TEMP1
                tya
                asl
                tay
                lda SpriteX,x
                sta $d000,y
                lda SpriteY,x
                sta $d001,y

                inc VicSpriteIndex
                inc SpriteIndex
                ldx SpriteIndex

                cpx #MAX_SPRITES
                beq finish

                lda SpriteOrder,x
                tax
                lda SpriteY,x
                sec
                sbc #PADDING*2
                cmp $d012
                bcc lp

                clc
                adc #PADDING/2
                sta $d012
                jmp exitRaster

finish:         ldy #$00
                sty $d012
                sty VicSpriteIndex
                sty SpriteIndex
circleIndex:    ldx #0

lp2:            lda CircleX,x
                sta SpriteX,y
                lda CircleY,x
                sta SpriteY,y
                txa
                clc
                adc #256/MAX_SPRITES
                tax
                iny
                cpy #MAX_SPRITES
                bne lp2

                inc circleIndex+1
                jsr sort

exitRaster:     lda $d011
                and #$7f
                sta $d011
                asl $d019
                pla
                tay
                pla
                tax
                pla
                rti

// Sorting routine
sort:           ldx #$00
                txa
sortloop:       ldy SpriteOrder,x
                cmp SpriteY,y
                beq noswap2
                bcc noswap1
                stx TEMP1
                sty TEMP2
                lda SpriteY,y
                ldy SpriteOrder-1,x
                pha                 // Save A temporarily
                tya
                sta SpriteOrder,x  // Use STA instead of STY
                pla                // Restore A
                dex
                beq swapdone
swaploop:       ldy SpriteOrder-1,x
                pha                 // Save A temporarily
                tya
                sta SpriteOrder,x  // Use STA instead of STY
                pla                // Restore A
                cmp SpriteY,y
                bcs swapdone
                dex
                bne swaploop
swapdone:       lda TEMP2
                sta SpriteOrder,x  // Use STA instead of STY
                ldx TEMP1
                ldy SpriteOrder,x
noswap1:        lda SpriteY,y
noswap2:        inx
                cpx #MAX_SPRITES
                bne sortloop
                rts

// Data tables
* = * "Data Tables"
SpriteX:        .fill MAX_SPRITES, 0
SpriteXMSB:     .fill MAX_SPRITES, 0
SpriteY:        .fill MAX_SPRITES, 0
SpriteColor:    .fill MAX_SPRITES/2, $01  // Color for sprites 0 and 1
                .fill MAX_SPRITES/2, $03  // Color for sprites 2 and 3
SpriteOrder:    .fill MAX_SPRITES, i    // 0-21

// Circle data - 256 values for X and Y coordinates
CircleX:        .fill 256, 128 + 64*cos(toRadians(i*360/256))
CircleY:        .fill 256, 128 + 64*sin(toRadians(i*360/256))

POT:            .byte %00000001,%00000010,%00000100,%00001000
                .byte %00010000,%00100000,%01000000,%10000000

IPOT:           .byte %11111110,%11111101,%11111011,%11110111
                .byte %11101111,%11011111,%10111111,%01111111

// Sprite data

* = $2000 "Sprite Data"

// sprite 0 / multicolor / color: $01
sprite_0:
.byte $00,$00,$00,$00,$00,$00,$0c,$33
.byte $0c,$37,$11,$37,$19,$22,$19,$22
.byte $22,$22,$22,$22,$20,$2a,$22,$08
.byte $22,$2a,$02,$22,$26,$22,$11,$1d
.byte $19,$33,$33,$37,$00,$00,$00,$20
.byte $00,$28,$18,$00,$08,$06,$82,$88
.byte $03,$69,$c0,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$81

// sprite 1 / multicolor / color: $01
sprite_1:
.byte $00,$00,$00,$03,$c0,$f0,$0d,$40
.byte $5c,$36,$b3,$a7,$1a,$91,$a9,$69
.byte $66,$aa,$6f,$aa,$aa,$6e,$aa,$aa
.byte $66,$aa,$aa,$6a,$aa,$aa,$6a,$aa
.byte $aa,$1a,$aa,$a9,$3a,$aa,$ab,$06
.byte $aa,$a4,$0d,$aa,$9c,$03,$6a,$70
.byte $00,$6a,$40,$00,$d9,$c0,$00,$19
.byte $00,$00,$37,$00,$00,$0c,$00,$81

// sprite 2 / multicolor / color: $03
sprite_2:
.byte $01,$ed,$00,$03,$ab,$00,$06,$aa
.byte $40,$0e,$aa,$c0,$1a,$aa,$90,$3a
.byte $aa,$b0,$2a,$aa,$a0,$2a,$ba,$a0
.byte $2a,$de,$a0,$2a,$42,$a0,$2a,$c7
.byte $a0,$2a,$9c,$e0,$2a,$ab,$30,$3a
.byte $aa,$d0,$1a,$aa,$80,$0e,$aa,$c0
.byte $06,$aa,$40,$03,$ab,$00,$01,$ed
.byte $00,$00,$74,$00,$00,$10,$00,$83

// sprite 3 / multicolor / color: $03
sprite_3:
.byte $01,$ed,$00,$03,$bb,$00,$06,$56
.byte $40,$0e,$76,$c0,$19,$ed,$90,$39
.byte $a9,$b0,$27,$ab,$60,$26,$ba,$60
.byte $26,$de,$60,$26,$42,$60,$26,$c7
.byte $a0,$26,$94,$e0,$27,$a9,$20,$39
.byte $ab,$40,$19,$ed,$80,$0e,$66,$c0
.byte $06,$76,$40,$03,$9b,$00,$01,$ed
.byte $00,$00,$74,$00,$00,$10,$00,$83

// Update SpritePointer to point to the correct sprite data
SpritePointer:  .fill MAX_SPRITES/4, $80  // Points to sprite_0
                .fill MAX_SPRITES/4, $81  // Points to sprite_1
                .fill MAX_SPRITES/4, $82  // Points to sprite_2
                .fill MAX_SPRITES/4, $83  // Points to sprite_3
