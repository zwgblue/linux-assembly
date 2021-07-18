    .include "record-def.s"
    .include "linux.s"

    .section .data
record1:
    .ascii "Fredrick\0"
    .rept 31
    .byte 0
    .endr

    .ascii "Bartlett\0"
    .rept 31
    .byte 0
    .endr

    .ascii "china street\0"
    .rept 227
    .byte 0
    .endr

    .long 45

record2:

    .ascii "Marilyn\0"
    .rept 32
    .byte 0
    .endr

    .ascii "Taylor\0"
    .rept 33
    .byte 0
    .endr

    .ascii "wuhan street\0"
    .rept 227
    .byte 0
    .endr

    .long 29

record3:
    .ascii "Derrick\0"
    .rept 32
    .byte 0
    .endr

    .ascii "McIntire\0"
    .rept 31
    .byte 0
    .endr

    .ascii "somewhere\0"
    .rept 230
    .byte 0
    .endr

    .long 36

file_name:
    .ascii "test.dat\0"

    .equ ST_FILE_DESCRIPTOR, -4
    .globl _start
_start:
    movl %esp, %ebp
    # 为文件描述符分配空间
    subl $4, %esp

    movl $SYS_OPEN, %eax
    movl $file_name, %ebx









