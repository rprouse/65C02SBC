      .setcpu "65C02"
      .include "utils.inc"
      .include "lcd.inc"
      .include "core.inc"
      .include "acia.inc"
      .include "syscalls.inc"

SPARK64 := 1

      .include "../microsoft_basic/msbasic.s"

      .import _run_shell
      .export os_version
      .export init_os

      .segment "VECTORS"

      .word   $0000
      .word   init_os
      .word   _interrupt_handler

      .code

init_os:
      ; clean up stack and zeropage
      ldx #$00
@clean_stack_loop:
      stz $0100,x
      stz $00,x
      inx
      bne @clean_stack_loop
      ; Set up stack
      ldx #$ff
      txs
      ; Run setup routine
      jsr _system_init
      ; Display hello message
      write_lcd #os_version
      ; Display Instructions
      ldx #$00
      ldy #$01
      jsr lcd_set_position
      lda #250
      jsr _delay_ms
      write_lcd #instruction
@wait_for_acia_input:
      jsr _acia_is_data_available
      cmp #(ACIA_NO_DATA_AVAILABLE)
      beq @wait_for_acia_input
      jsr _acia_read_byte
      bra @run_shell
@run_shell:
      jsr _lcd_clear
      write_lcd #eightbitlabs
      ldx #$00
      ldy #$01
      jsr lcd_set_position
      lda #250
      jsr _delay_ms
      write_lcd #shell_connected
      jsr _run_shell
      ; Disable interrupt processing during init
      sei
      jmp init_os

      .segment "RODATA"

os_version:
      .asciiz "Spark64 v0.6.1"
instruction:
      .asciiz "Awaiting TTY"
eightbitlabs:
      .asciiz "8bitlabs.ca"
shell_connected:
      .asciiz "TTY connected"
