// Constants
.const SPRITE_DATA = $0340  // 832 in decimal
.const SPRITE_POINTER = $07F8  // 2040 in decimal
.const VIC_SPRITE_X = $D000   // 53248 in decimal
.const VIC_SPRITE_Y = $D001   // 53249 in decimal
.const VIC_SPRITE_MSB_X = $D010  // 53264 in decimal
.const VIC_SPRITE_COLOR = $D027  // 53287 in decimal
.const VIC_SPRITE_ENABLE = $D015  // 53269 in decimal
.const VIC_SPRITE_EXPAND_Y = $D017  // 53271 in decimal
.const VIC_SPRITE_EXPAND_X = $D01D  // 53277 in decimal
.const CHROUT = $FFD2
.const RASTER = $D012
.const RANDOM = $D41B

// Zero page variables
.const zp_x = $FB
.const zp_y = $FE
.const zp_dx = $101
.const zp_dy = $104

BasicUpstart2(start)

* = $0810 "Main Program"

start:
    jsr clear_screen
    jsr init_sprite_data
    jsr setup_sprites
    jsr init_variables
    jmp main_loop

clear_screen:
    lda #147  // Clear screen character
    jsr CHROUT
    rts

init_sprite_data:
    ldx #0
load_sprite_data:
    lda sprite_data,x
    sta SPRITE_DATA,x
    inx
    cpx #63
    bne load_sprite_data
    rts

setup_sprites:
    ldx #0
setup_sprite_loop:
    txa
    asl
    tay
    lda #160  // Center X (approximately)
    sta VIC_SPRITE_X,y  // X coordinate
    lda #100  // Center Y (approximately)
    sta VIC_SPRITE_Y,y  // Y coordinate
    lda #13
    sta SPRITE_POINTER,x  // Sprite data pointer
    txa
    clc
    adc #2
    sta VIC_SPRITE_COLOR,x  // Sprite color (different for each sprite)
    inx
    cpx #3
    bne setup_sprite_loop
    lda #7
    sta VIC_SPRITE_ENABLE  // Enable first 3 sprites
    sta VIC_SPRITE_EXPAND_Y  // Y-expand first 3 sprites
    sta VIC_SPRITE_EXPAND_X  // X-expand first 3 sprites
    rts

init_variables:
    ldx #0
init_var_loop:
    lda #160
    sta zp_x,x
    lda #100
    sta zp_y,x
    jsr random_direction
    sta zp_dx,x
    jsr random_direction
    sta zp_dy,x
    inx
    cpx #3
    bne init_var_loop
    rts

random_direction:
    lda RANDOM
    and #1
    beq positive
    lda #$FF  // -1
    rts
positive:
    lda #1
    rts

main_loop:
    ldx #0
sprite_loop:
    jsr update_position
    jsr check_boundaries
    jsr update_sprite_position
    inx
    cpx #3
    bne sprite_loop
    jsr delay
    jmp main_loop

update_position:
    lda zp_x,x
    clc
    adc zp_dx,x
    sta zp_x,x
    lda zp_y,x
    clc
    adc zp_dy,x
    sta zp_y,x
    rts

check_boundaries:
    // Check X boundaries
    lda zp_x,x
    cmp #50
    bcc bounce_x
    cmp #250
    bcs bounce_x
    jmp check_y
bounce_x:
    lda zp_dx,x
    eor #$FF
    clc
    adc #1
    sta zp_dx,x

check_y:
    // Check Y boundaries
    lda zp_y,x
    cmp #70
    bcc bounce_y
    cmp #220
    bcs bounce_y
    rts
bounce_y:
    lda zp_dy,x
    eor #$FF
    clc
    adc #1
    sta zp_dy,x
    rts

update_sprite_position:
    txa
    asl
    tay
    lda zp_x,x
    sta VIC_SPRITE_X,y
    lda zp_x,x
    cmp #255
    bcc msb_clear
    lda VIC_SPRITE_MSB_X
    ora bit_masks,x
    jmp msb_set
msb_clear:
    lda VIC_SPRITE_MSB_X
    and bit_masks_inv,x
msb_set:
    sta VIC_SPRITE_MSB_X
    lda zp_y,x
    sta VIC_SPRITE_Y,y
    rts

delay:
    ldx #3
delay_loop:
    ldy #255
inner_delay:
    nop
    nop
    nop
    nop
    dey
    bne inner_delay
    dex
    bne delay_loop
    rts

bit_masks:
    .byte 1, 2, 4

bit_masks_inv:
    .byte $FE, $FD, $FB

sprite_data:
    .byte 0,0,0,12,66,112,18,66,136,51,66,128,33,90,112,63
    .byte 90,8,33,102,136,33,66,112,0,0,0,0,0,60,0,0
    .byte 4,96,0,36,56,0,228,15,131,128,0,254,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
