# 获取最大值

.section .data

data_items:
    .long 3,67,12,45,21,24,63,21,11,6,4,0

.section .text

.globl _start

_start:
    movl $0, %edi
    movl data_items(,%edi,4), %eax
    movl %eax, %ebx

start_loop:
    cmpl $0, %eax # 用0作为数据尾部标识
    je loop_exit 

    incl %edi
    movl data_items(,%edi,4), %eax
    cmpl %ebx, %eax
    jle start_loop # 不大于则跳转(jump if less or equal),相当于<=

    movl %eax, %ebx # 更新最大值
    jmp start_loop

loop_exit:
    movl $1, %eax # 1是exit()系统调用
    int $0x80
