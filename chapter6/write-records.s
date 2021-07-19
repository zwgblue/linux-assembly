    .code32
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
    # 为文件描述符分配空间(ST_FILE_DESCRIPTOR)
    subl $4, %esp

    # 打开文件
    movl $SYS_OPEN, %eax
    movl $file_name, %ebx
    movl $0101, %ecx # 文件不存在则创建
    movl $0666, %edx
    int $LINUX_SYSCALL

    movl %eax, ST_FILE_DESCRIPTOR(%ebp)

    # 写入第一条记录 
    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record1
    call write_record
    addl $8, %esp

    # 写入第二条记录 
    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record2
    call write_record
    addl $8, %esp

    # 写入第三条记录 
    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record3
    call write_record
    addl $8, %esp

    movl $SYS_CLOSE, %eax
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
