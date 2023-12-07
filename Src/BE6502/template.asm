;
; template.asm
;
; > ca65 template.asm --listing template.lst
; > ld65 template.o -o template.bin -C 65C02.cfg
;
; > cl65 -t none -o template.bin -l template.lst -C 65C02.cfg
;

.setcpu "65C02"
.segment "OS"
.org $8000

reset:
  ldx #$ff
  txs

loop:
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