.setcpu "65C02"
.segment "OS"
.org $8000

PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

E  = %10000000
RW = %01000000
RS = %00100000

one:   ;1234567890123456
  .asciiz "    65C02 Single"
two:
  .asciiz "   Board Computer"
four:
  .asciiz "    Rob Prouse"

reset:           ; Initialize the LCD Display
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  JSR lcd_configure

  lda #%00001110 ; Display on; cursor on; blink off
  JSR lcd_configure

  lda #%00000110 ; Increment and shift cursor; don't shift display
  JSR lcd_configure

  lda #%00000001 ; Clear the display, set address to 0
  JSR lcd_configure

  ldx #0
@one_loop:
  lda one,x
  beq @one_done
  jsr print_char
  inx
  bra @one_loop
@one_done:

  ; Set the DDRAM Address to start of second line
  lda #%11000000
  JSR lcd_configure

  ldx #0
@two_loop:
  lda two,x
  beq @two_done
  jsr print_char
  inx
  bra @two_loop
@two_done:

  ; Set the DDRAM Address to start of forth line
  lda #%11010100
  JSR lcd_configure

  ldx #0
@four_loop:
  lda four,x
  beq @four_done
  jsr print_char
  inx
  bra @four_loop
@four_done:

loop:
  jmp loop

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts


; Send a configuration command to the LCD
lcd_lcd_configure:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  RTS

; Output the letter in the A register to the LCD
print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Toggle the Enable bit
  sta PORTA
  lda #RS         ; Clear RW/E bits
  sta PORTA
  RTS

nmi:
  jmp nmi

irq_brk:
  jmp irq_brk

.segment "VECTORS"
.org $FFFA
.word nmi
.word reset
.word irq_brk