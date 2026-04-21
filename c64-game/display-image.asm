// Basic upstart
BasicUpstart2(start)

// Constants
.const SCREEN = $0400
.const BITMAP = $2000
.const COLRAM = $d800

// VIC-II registers
.const VIC_BANK = $dd00
.const VIC_CONTROL1 = $d011
.const VIC_CONTROL2 = $d016
.const VIC_MEMORY = $d018
.const BACKGROUND_COLOR = $d021

// Load picture
.var picture = LoadPicture("images/q-image.png")

// Main program
start:
    // Set VIC-II bitmap mode
    sei                     // Disable interrupts

    // Set VIC bank (bank 1: $4000-$7fff)
    lda VIC_BANK
    and #%11111100         // Clear bits 0-1
    ora #%00000010         // Set bank 1
    sta VIC_BANK

    // Enable bitmap mode
    lda #%00111011         // Bitmap mode + 25 rows
    sta VIC_CONTROL1
    
    lda #%00011000         // Multi-color mode
    sta VIC_CONTROL2

    // Set bitmap memory location
    lda VIC_MEMORY
    and #%11110001         // Clear bitmap offset bits
    ora #%00001000         // Set bitmap offset ($2000)
    sta VIC_MEMORY

    // Set background color
    lda #0                 // Black
    sta BACKGROUND_COLOR

    // Main loop
loop:
    jmp loop

// Bitmap data
* = BITMAP "Bitmap Data"
.for (var y=0; y<25; y++) {
    .for (var x=0; x<40; x++) {
        .byte picture.getSinglecolorByte(x, y)
    }
}

// Screen data
* = SCREEN "Screen Data"
.fill 1000, 0

// Color data
* = COLRAM "Color Data"
.fill 1000, picture.getPixel(i).getColorIndex()