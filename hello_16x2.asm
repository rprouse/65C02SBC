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

header:   ;1234567890123456
  .asciiz "  65C02 Single"
footer:
  .asciiz " Board Computer"

reset:           ; Initialize the LCD Display
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  JSR configure

  lda #%00001110 ; Display on; cursor on; blink off
  JSR configure

  lda #%00000110 ; Increment and shift cursor; don't shift display
  JSR configure

  lda #%00000001 ; Clear the display, set address to 0
  JSR configure

  ldx #0
@header_loop:
  lda header,x
  beq @header_done
  jsr output
  inx
  bra @header_loop
@header_done:

  ; Set the DDRAM Address to start of second line
  lda #%11000000
  JSR configure

  ldx #0
@footer_loop:
  lda footer,x
  beq @footer_done
  jsr output
  inx
  bra @footer_loop
@footer_done:

loop:
  jmp loop

; Send a configuration command to the LCD
configure:
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  RTS

; Output the letter in the A register to the LCD
output:
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