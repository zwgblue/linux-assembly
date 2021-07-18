    .include "record-def.s"
    .include "linux.s"

    .equ ST_WRITE_BUFFER, 8
    .equ ST_FILEDES, 12

    .section .text
    .globl write_record
    .type write_record, @function
write_record:
    pushl %ebp
    movb %esp, %ebp

    pushl %ebx
    movl $SYS_WRITE, %eax
    movl ST_FILEDES(%ebp), %ebx
    movl ST_WRITE_BUFFER(%ebp), %ecx
    movl $RECORD_SIZE, %edx
    int $LINUX_SYSCALL

    # 返回值
    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret