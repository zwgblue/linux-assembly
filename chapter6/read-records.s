    .code32
    .include "linux.s"
    .include "record-def.s"

    .section .data
file_name:
    .ascii "test.dat\0"

    .section .bss
    .lcomm record_buffer, RECORD_SIZE

    .section .text
    # 主程序
    .globl _start
_start:
    .equ ST_INPUT_DESCRIPTOR, -4
    .equ ST_OUTPUT_DESCRIPTOR, -8

    movl %esp, %ebp
    subl $8, %esp

    movl $SYS_OPEN, %eax
    movl $file_name, %ebx
    movl $0, %ecx # 表示只读方式打开
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_INPUT_DESCRIPTOR(%ebp)
    movl $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)

record_read_loop:
    pushl ST_INPUT_DESCRIPTOR(%ebp)
    pushl $record_buffer

    call read_record
    addl $8, %esp

    # 如果返回的字节数与我们请求的字节数不同，说明已到达文件结束处或出现错误
    cmpl $RECORD_SIZE, %eax
    jne finished_reading

    pushl $RECORD_FIRSTNAME + record_buffer
    call count_chars
    add $4, %esp
    movl %eax, %edx # 获取写入字节数
    movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
    movl $SYS_WRITE, %eax
    movl $RECORD_FIRSTNAME + record_buffer, %ecx
    int $LINUX_SYSCALL

    pushl ST_OUTPUT_DESCRIPTOR(%ebp)
    call write_newline
    addl $4, %esp

    jmp record_read_loop

finished_reading:
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    
