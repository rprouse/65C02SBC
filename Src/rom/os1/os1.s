      .setcpu "65C02"
      .include "utils.inc"
      .include "lcd.inc"
      .include "core.inc"
      .include "acia.inc"
      .include "syscalls.inc"

      .import _run_shell
      .export os1_version

      .segment "VECTORS"

      .word   $0000
      .word   init
      .word   _interrupt_handler

      .code

init:
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
      write_lcd #os1_version
      ; Display Instructions
      ldx #$00
      ldy #$01
      jsr lcd_set_position
      lda #01
      jsr _delay_sec
      write_lcd #instruction
@wait_for_acia_input:
      jsr _acia_is_data_available
      cmp #(ACIA_NO_DATA_AVAILABLE)
      beq @wait_for_acia_input
      jsr _acia_read_byte
      bra @run_shell
@run_shell:
      jsr _lcd_clear
      write_lcd #shell_connected
      jsr _run_shell
      ; Disable interrupt processing during init
      sei
      jmp init

      .segment "RODATA"

os1_version:
      .asciiz "OS/1 version 0.4"
instruction:
      .asciiz "19200 N8S1 CTS/RTS"
shell_connected:
      .asciiz "Shell connected"
