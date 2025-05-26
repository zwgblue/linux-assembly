.section .data
.section .text
.globl _start

_start:
    movq $60, %rax   # SYS_EXIT syscall number for amd64
    movq $0, %rdi    # Exit status 0
    syscall
