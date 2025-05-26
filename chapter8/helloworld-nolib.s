.include "../common/linux_amd64.s"
    .section .data

helloworld:
    .ascii "hello world\n"
helloworld_end:
    .equ helloworld_len, helloworld_end - helloworld

    .section .text
    .globl _start
_start:
    # SYS_WRITE
    movq $SYS_WRITE, %rax
    movq $STDOUT, %rdi          # fd: STDOUT (1)
    movq $helloworld, %rsi      # buf: address of helloworld string
    movq $helloworld_len, %rdx  # count: length of string
    syscall

    # SYS_EXIT
    movq $SYS_EXIT, %rax
    movq $0, %rdi               # status: 0
    syscall
