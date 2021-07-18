    # 系统调用号
    .equ SYS_EXIT, 1
    .equ SYS_WRITE, 4
    .equ SYS_READ, 3
    .equ SYS_OPEN, 5
    .equ SYS_CLOSE, 6
    .equ SYS_BRK, 45

    # 文件打开选项 (/usr/include/asm/fcntl.h)
    .equ O_RDONLY, 0
    .equ O_CREATE_WRONLY_TRUNC, 03101

    # 标准文件描述符
    .equ STDIN, 0
    .equ STDOUT, 1
    .equ STDERR, 2

    # 系统调用中断
    .equ LINUX_SYSCALL, 0x80

    .equ END_OF_FILE, 0 # 这是读操作的返回值，表明到达文件结束处