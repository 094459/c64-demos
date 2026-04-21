.const SCREEN = $0400
.const COLOR_RAM = $d800
.const SPRITE_POINTERS = $07f8
.const VIC_SPRITE_ENABLE = $d015
.const VIC_SPRITE_MULTICOLOR = $d01c
.const VIC_SPRITE_X = $d000
.const VIC_SPRITE_Y = $d001
.const VIC_SPRITE_MSB = $d010

.const NUM_SPRITES = 10
.const VISIBLE_SPRITES = 10
.const SPRITE_DATA_START = $2000

BasicUpstart2(start)

* = $0810 "Main Program"

start:
    sei             // Disable interrupts
    lda #$35        // Bank out BASIC and Kernal ROM
    sta $01
    
    jsr init
    
    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff
    
    lda #$7f
    sta $dc0d       // Disable CIA interrupts
    sta $dd0d
    lda $dc0d       // Acknowledge CIA interrupts
    lda $dd0d
    
    lda #$01
    sta $d01a       // Enable raster interrupts
    
    lda #50         // Set raster line for first interrupt
    sta $d012
    lda $d011
    and #$7f        // Clear high bit of raster line
    sta $d011
    
    cli             // Enable interrupts
    jmp *           // Infinite loop

init:
    lda #$00        // Black background and border
    sta $d020
    sta $d021

    // Set multicolor registers
    lda #$06        // Blue
    sta $d025       // Multicolor 1
    lda #$0e        // Light blue
    sta $d026       // Multicolor 2

    // Enable all 8 hardware sprites
    lda #$ff
    sta VIC_SPRITE_ENABLE

    // Copy sprite data
    ldx #0
copy_sprite_data:
    lda sprite_data,x
    sta SPRITE_DATA_START,x
    inx
    bne copy_sprite_data

    // Set up sprites
    ldx #0
init_sprites:
    lda sprite_colors,x
    sta $d027,x     // Set sprite colors

    txa
    clc
    adc #(SPRITE_DATA_START / 64)
    sta SPRITE_POINTERS,x

    lda initial_x,x
    sta sprite_x,x
    lda initial_y,x
    sta sprite_y,x
    lda initial_dir_x,x
    sta sprite_dir_x,x
    lda initial_dir_y,x
    sta sprite_dir_y,x

    inx
    cpx #NUM_SPRITES
    bne init_sprites

    lda #$ff
    sta VIC_SPRITE_MULTICOLOR  // Set multicolor for all sprites

    lda #0
    sta $d01d       // Width (normal)
    sta $d017       // Height (normal)

    rts

irq:
    pha
    txa
    pha
    tya
    pha

    lda $d019
    sta $d019       // Acknowledge raster interrupt

    jsr update_sprites
    jsr display_sprites

    lda #50         // Set next raster interrupt to fixed line
    sta $d012

    pla
    tay
    pla
    tax
    pla
    rti

update_sprites:
    ldx #0
update_loop:
    // Update X position
    lda sprite_x,x
    clc
    adc sprite_dir_x,x
    sta sprite_x,x

    // Check X boundaries
    cmp #24
    bcc reverse_x
    cmp #255
    bcs reverse_x
    jmp update_y

reverse_x:
    lda sprite_dir_x,x
    eor #$ff
    clc
    adc #1
    sta sprite_dir_x,x

update_y:
    // Update Y position
    lda sprite_y,x
    clc
    adc sprite_dir_y,x
    sta sprite_y,x

    // Check Y boundaries
    cmp #50
    bcc reverse_y
    cmp #229
    bcs reverse_y
    jmp next_sprite

reverse_y:
    lda sprite_dir_y,x
    eor #$ff
    clc
    adc #1
    sta sprite_dir_y,x

next_sprite:
    inx
    cpx #NUM_SPRITES
    bne update_loop
    rts

display_sprites:
    ldx #0
    ldy #0
display_loop:
    cpy #VISIBLE_SPRITES
    bcs done_display

    lda sprite_x,x
    sta VIC_SPRITE_X,y
    lda sprite_y,x
    sta VIC_SPRITE_Y,y
    lda sprite_colors,x
    sta $d027,y

    inx
    iny
    jmp display_loop

done_display:
    rts

sprite_x:
    .fill NUM_SPRITES, 0
sprite_y:
    .fill NUM_SPRITES, 0
sprite_dir_x:
    .fill NUM_SPRITES, 0
sprite_dir_y:
    .fill NUM_SPRITES, 0

initial_x:
    .fill NUM_SPRITES, 24 + i * 15
initial_y:
    .fill NUM_SPRITES, 50 + i * 10
initial_dir_x:
    .byte 2, -2, 2, -2, 2, -2, 2, -2, 2, -2, 2, -2, 2, -2, 2, -2
initial_dir_y:
    .byte 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1

sprite_colors:
    .byte $01, $02, $03, $04, $05, $06, $07, $08
    .byte $09, $0a, $0b, $0c, $0d, $0e, $0f, $07

* = SPRITE_DATA_START "Sprite Data"
sprite_data:
    // 8 different sprite shapes
    .byte $00,$7e,$00,$01,$ff,$80,$03,$ff,$c0,$07,$ff,$e0,$0f,$ff,$f0,$1f
    .byte $ff,$f8,$3f,$ff,$fc,$7f,$ff,$fe,$7f,$ff,$fe,$7f,$ff,$fe,$7f,$ff
    .byte $fe,$7f,$ff,$fe,$3f,$ff,$fc,$1f,$ff,$f8,$0f,$ff,$f0,$07,$ff,$e0
    .byte $03,$ff,$c0,$01,$ff,$80,$00,$7e,$00,$00,$3c,$00,$00,$18,$00,$81

    .byte $00,$00,$00,$00,$00,$00,$0f,$f0,$00,$3f,$fc,$00,$7f,$fe,$00,$ff
    .byte $ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff
    .byte $00,$ff,$ff,$00,$7f,$fe,$00,$3f,$fc,$00,$0f,$f0,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$82

    .byte $00,$00,$00,$07,$e0,$00,$1f,$f8,$00,$3f,$fc,$00,$7f,$fe,$00,$ff
    .byte $ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$7f,$fe,$00,$3f,$fc
    .byte $00,$1f,$f8,$00,$07,$e0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$83

    .byte $00,$00,$00,$03,$c0,$00,$0f,$f0,$00,$1f,$f8,$00,$3f,$fc,$00,$7f
    .byte $fe,$00,$7f,$fe,$00,$7f,$fe,$00,$7f,$fe,$00,$3f,$fc,$00,$1f,$f8
    .byte $00,$0f,$f0,$00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$84

    .byte $00,$00,$00,$01,$80,$00,$07,$e0,$00,$0f,$f0,$00,$1f,$f8,$00,$3f
    .byte $fc,$00,$3f,$fc,$00,$3f,$fc,$00,$3f,$fc,$00,$1f,$f8,$00,$0f,$f0
    .byte $00,$07,$e0,$00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$85

    .byte $00,$00,$00,$00,$00,$00,$03,$c0,$00,$07,$e0,$00,$0f,$f0,$00,$1f
    .byte $f8,$00,$1f,$f8,$00,$1f,$f8,$00,$1f,$f8,$00,$0f,$f0,$00,$07,$e0
    .byte $00,$03,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$86

    .byte $00,$00,$00,$00,$00,$00,$01,$80,$00,$03,$c0,$00,$07,$e0,$00,$0f
    .byte $f0,$00,$0f,$f0,$00,$0f,$f0,$00,$0f,$f0,$00,$07,$e0,$00,$03,$c0
    .byte $00,$01,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$87

    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$80,$00,$03,$c0,$00,$07
    .byte $e0,$00,$07,$e0,$00,$07,$e0,$00,$07,$e0,$00,$03,$c0,$00,$01,$80
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$88