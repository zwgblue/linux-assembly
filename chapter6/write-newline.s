.include "../common/linux_amd64.s"
    .globl write_newline
    .type write_newline, @function

    .section .data
newline:
    .ascii "\n"

    .section .text
    .equ ST_FILEDES_ARG, 16

write_newline:
    pushq %rbp
    movq %rsp, %rbp

    movq $SYS_WRITE, %rax
    movq ST_FILEDES_ARG(%rbp), %rdi   # File descriptor
    movq $newline, %rsi               # Address of newline string
    movq $1, %rdx                     # Length of newline string (1 byte)
    syscall

    movq %rbp, %rsp
    popq %rbp
    ret
