.const SCREEN = $0400
.const COLOR_RAM = $d800
.const SPRITE_POINTERS = $07f8
.const VIC_SPRITE_ENABLE = $d015
.const VIC_SPRITE_MULTICOLOR = $d01c
.const VIC_SPRITE_X = $d000
.const VIC_SPRITE_Y = $d001
.const VIC_SPRITE_MSB = $d010

BasicUpstart2(start)

* = $0810 "Main Program"

start:
    jsr init
    jmp main_loop

init:
    lda #$93        // Clear screen (CHR$(147))
    jsr $ffd2

    ldx #0
print_message:
    lda message,x
    beq done_print
    jsr $ffd2
    inx
    jmp print_message
done_print:

    // Set multicolor registers
    lda #6
    sta $d025       // Multicolor 1
    lda #14
    sta $d026       // Multicolor 2

    // Enable all sprites
    lda #$0f
    sta VIC_SPRITE_ENABLE

    // Copy sprite data
    ldx #0
copy_sprite_data:
    lda sprite_data,x
    sta $3200,x     // $3200 = 12800
    inx
    cpx #0
    bne copy_sprite_data

    // Set up sprites
    lda #1
    sta $d027       // Sprite 0 color
    sta $d028       // Sprite 1 color
    lda #3
    sta $d029       // Sprite 2 color
    sta $d02a       // Sprite 3 color

    lda #200
    sta SPRITE_POINTERS    // Sprite 0 pointer
    lda #201
    sta SPRITE_POINTERS+1  // Sprite 1 pointer
    lda #202
    sta SPRITE_POINTERS+2  // Sprite 2 pointer
    lda #203
    sta SPRITE_POINTERS+3  // Sprite 3 pointer

    // Initialize sprite positions and directions
    ldx #0
init_sprites:
    lda initial_x,x
    sta VIC_SPRITE_X,x
    lda initial_y,x
    sta VIC_SPRITE_Y,x
    lda initial_dir_x,x
    sta sprite_dir_x,x
    lda initial_dir_y,x
    sta sprite_dir_y,x
    inx
    cpx #8
    bne init_sprites

    lda #$0f
    sta VIC_SPRITE_MULTICOLOR  // Set multicolor for all sprites

    lda #0
    sta $d01d       // Width (normal)
    sta $d017       // Height (normal)

    rts

main_loop:
    jsr wait_frame
    jsr update_sprites
    jmp main_loop

wait_frame:
    lda #$ff
wait:
    cmp $d012
    bne wait
    rts

update_sprites:
    ldx #0
update_loop:
    // Update X position
    lda VIC_SPRITE_X,x
    clc
    adc sprite_dir_x,x
    sta VIC_SPRITE_X,x

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
    lda VIC_SPRITE_Y,x
    clc
    adc sprite_dir_y,x
    sta VIC_SPRITE_Y,x

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
    inx
    cpx #8
    bne update_loop
    rts

message:
    .text "generated with spritemate"
    .byte 13
    .text "4 of 4 sprites displayed."
    .byte 0

sprite_dir_x:
    .byte 0, 0, 0, 0
sprite_dir_y:
    .byte 0, 0, 0, 0

initial_x:
    .byte 44, 92, 140, 188
initial_y:
    .byte 120, 120, 120, 120
initial_dir_x:
    .byte 2, -2, 2, -2
initial_dir_y:
    .byte 1, -1, 1, -1

* = $3200 "Sprite Data"
sprite_data:
    // Sprite 0
    .byte 0,0,0,0,0,0,12,51,12,55,17,55,25,34,25,34
    .byte 34,34,34,34,32,42,34,8,34,42,2,34,38,34,17,29
    .byte 25,51,51,55,0,0,0,32,0,40,24,0,8,6,130,136
    .byte 3,105,192,0,0,0,0,0,0,0,0,0,0,0,0,129
    // Sprite 1
    .byte 0,0,0,3,192,240,13,64,92,54,179,167,26,145,169,105
    .byte 102,170,111,170,170,110,170,170,102,170,170,106,170,170,106,170
    .byte 170,26,170,169,58,170,171,6,170,164,13,170,156,3,106,112
    .byte 0,106,64,0,217,192,0,25,0,0,55,0,0,12,0,129
    // Sprite 2
    .byte 1,237,0,3,171,0,6,170,64,14,170,192,26,170,144,58
    .byte 170,176,42,170,160,42,186,160,42,222,160,42,66,160,42,199
    .byte 160,42,156,224,42,171,48,58,170,208,26,170,128,14,170,192
    .byte 6,170,64,3,171,0,1,237,0,0,116,0,0,16,0,131
    // Sprite 3
    .byte 1,237,0,3,187,0,6,86,64,14,118,192,25,237,144,57
    .byte 169,176,39,171,96,38,186,96,38,222,96,38,66,96,38,199
    .byte 160,38,148,224,39,169,32,57,171,64,25,237,128,14,102,192
    .byte 6,118,64,3,155,0,1,237,0,0,116,0,0,16,0,131