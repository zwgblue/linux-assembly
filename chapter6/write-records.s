.include "../common/linux_amd64.s"
    .include "record-def.s"

    .section .data
record1:
    .ascii "Fredrick\0"
    .rept 31 ; .byte 0 ; .endr 
    .ascii "Bartlett\0"
    .rept 31 ; .byte 0 ; .endr 
    .ascii "china street\0"
    .rept 227 ; .byte 0 ; .endr 
    .long 45

record2:
    .ascii "Marilyn\0"
    .rept 32 ; .byte 0 ; .endr
    .ascii "Taylor\0"
    .rept 33 ; .byte 0 ; .endr
    .ascii "wuhan street\0"
    .rept 227 ; .byte 0 ; .endr
    .long 29

record3:
    .ascii "Derrick\0"
    .rept 32 ; .byte 0 ; .endr
    .ascii "McIntire\0"
    .rept 31 ; .byte 0 ; .endr
    .ascii "somewhere\0"
    .rept 230 ; .byte 0 ; .endr
    .long 36

file_name:
    .ascii "test.dat\0"

    # Local variable on stack
    .equ ST_FILE_DESCRIPTOR, -8

    .section .text
    .globl _start
_start:
    pushq %rbp
    movq %rsp, %rbp
    subq $8, %rsp  # Reserve space for one file descriptor (or $16 for alignment)

    # Open file (create, write-only, truncate)
    movq $SYS_OPEN, %rax
    movq $file_name, %rdi
    movq $(O_CREAT | O_WRONLY | O_TRUNC), %rsi # e.g. octal 01101
    movq $MODE_RW_UGO, %rdx                   # Permissions 0666
    syscall
    movq %rax, ST_FILE_DESCRIPTOR(%rbp)

    # Write record1
    # write_record expects: fd at 16(%rbp), buffer_address at 24(%rbp)
    pushq $record1                           # Arg 2: buffer address
    movq ST_FILE_DESCRIPTOR(%rbp), %rax     # Get fd
    pushq %rax                               # Arg 1: file descriptor
    call write_record
    addq $16, %rsp

    # Write record2
    pushq $record2
    movq ST_FILE_DESCRIPTOR(%rbp), %rax
    pushq %rax
    call write_record
    addq $16, %rsp

    # Write record3
    pushq $record3
    movq ST_FILE_DESCRIPTOR(%rbp), %rax
    pushq %rax
    call write_record
    addq $16, %rsp

    # Close file
    movq $SYS_CLOSE, %rax
    movq ST_FILE_DESCRIPTOR(%rbp), %rdi
    syscall

    # Exit
    movq $SYS_EXIT, %rax
    movq $0, %rdi
    syscall
