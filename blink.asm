.setcpu "65C02"
.segment "OS"
.org $8000

reset:
  lda #$ff
  sta $6002

  lda #$50
  sta $6000

loop:
  ror
  sta $6000

  jmp loop

nmi:
  jmp nmi

irq_brk:
  jmp irq_brk

.segment "VECTORS"
.org $FFFA
.word nmi
.word reset
.word irq_brk