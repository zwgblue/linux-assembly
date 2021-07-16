.section .data
.section .text
.globl _start

_start:
    movl $1, %eax
    movl $0, %ebx # 返回值
    int $0x80
