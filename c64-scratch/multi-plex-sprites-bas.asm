.const SPRITE_PTR = $07F8
.const SPRITE_EN = $D015
.const SPRITE_COLORS = $D027
.const SPRITE_X = $D000
.const SPRITE_Y = $D001
.const SCREEN_CONTROL = $D011
.const INTERRUPT = $FFFE
// Color constants
.const BLACK  = 0
.const WHITE  = 1
.const RED    = 2
.const CYAN   = 3
.const PURPLE = 4
.const GREEN  = 5
.const BLUE   = 6
.const YELLOW = 7
.const ORANGE = 8
.const BROWN  = 9
* = $0810 "Program Start"

.macro @SetupSprite(spriteNum, color) {
    lda #spriteNum
    sta SPRITE_PTR,x
    lda #color
    sta SPRITE_COLORS,x
}

.macro @InitSprites() {
    lda #%11111111   // Enable all 8 sprites
    sta SPRITE_EN
}

// Sprite definition (8x8 square)
.align $40
sprite:
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %11111111
    .byte %00000000

Main:
    jsr SetupSprites
    jsr SetupInterrupt
    jmp *

SetupSprites:
    // Set sprite pointers and colors
    ldx #0
    @SetupSprite(sprite/64, RED)
    ldx #1
    @SetupSprite(sprite/64, BLUE)
    ldx #2
    @SetupSprite(sprite/64, GREEN)
    ldx #3
    @SetupSprite(sprite/64, YELLOW)
    ldx #4
    @SetupSprite(sprite/64, PURPLE)
    ldx #5
    @SetupSprite(sprite/64, CYAN)
    ldx #6
    @SetupSprite(sprite/64, ORANGE)
    ldx #7
    @SetupSprite(sprite/64, BROWN)

    @InitSprites()

    // Initial sprite positions
    ldx #0
    ldy #50
!:  tya
    sta SPRITE_X,x
    lda #50
    sta SPRITE_Y,x
    iny
    inx
    cpx #16
    bne !-

    rts

SetupInterrupt:
    sei             // Disable interrupts
    lda #$7F
    sta $DC0D       // Turn off CIA interrupts
    sta $DD0D

    lda $DC0D       // Acknowledge any pending interrupts
    lda $DD0D

    lda #<IRQ
    sta $FFFE
    lda #>IRQ
    sta $FFFF

    lda #$01        // Enable raster interrupts
    sta $D01A

    lda #$E0        // Interrupt trigger line
    sta $D012

    cli             // Enable interrupts
    rts

// Sprite movement variables
direction: .fill 8, 0   // Movement direction for each sprite
speed:     .fill 8, 2   // Movement speed for each sprite

IRQ:
    // Sprite movement logic
    ldx #0
!:  lda direction,x
    bne MoveSpriteUp

MoveSpriteDown:
    inc SPRITE_Y,x
    lda SPRITE_Y,x
    cmp #230
    bne NextSprite
    lda #1
    sta direction,x
    jmp NextSprite

MoveSpriteUp:
    dec SPRITE_Y,x
    lda SPRITE_Y,x
    cmp #50
    bne NextSprite
    lda #0
    sta direction,x

NextSprite:
    inx
    cpx #8
    bne !-

    asl $D019       // Acknowledge interrupt
    jmp $EA31       // Return to BASIC interrupt handler

