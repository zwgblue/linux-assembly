# System call numbers for amd64
    .equ SYS_READ, 0
    .equ SYS_WRITE, 1
    .equ SYS_OPEN, 2
    .equ SYS_CLOSE, 3
    .equ SYS_EXIT, 60
    .equ SYS_BRK, 12

    # File open flags (from fcntl.h, typically the same values)
    .equ O_RDONLY, 0
    .equ O_WRONLY, 1             # Typically 1
    .equ O_RDWR, 2               # Typically 2
    .equ O_CREAT, 0100           # Typically 64 (octal 0100)
    .equ O_TRUNC, 01000          # Typically 512 (octal 01000)
    .equ O_APPEND, 02000         # Typically 1024 (octal 02000)
    
    # Mode for O_CREAT (permissions)
    .equ MODE_RW_UGO, 0666       # Read/write for user, group, others

    # Standard file descriptors
    .equ STDIN, 0
    .equ STDOUT, 1
    .equ STDERR, 2

    .equ END_OF_FILE, 0 # read() returns 0 on EOF
