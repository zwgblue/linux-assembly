.include "../common/linux_amd64.s"
    .include "record-def.s"

    .equ ST_FILEDES_ARG, 16
    .equ ST_READ_BUFFER_ARG, 24

    .section .text
    .globl read_record
    .type read_record, @function
read_record:
    pushq %rbp
    movq %rsp, %rbp

    pushq %rbx # Callee-saved if used, though not strictly used here for passed args

    movq ST_FILEDES_ARG(%rbp), %rdi      # File descriptor
    movq ST_READ_BUFFER_ARG(%rbp), %rsi  # Buffer to read into
    movq $RECORD_SIZE, %rdx             # Number of bytes to read
    movq $SYS_READ, %rax
    syscall                             # %rax returns bytes read or error code

    # No explicit error check here, caller handles it based on %rax value
    
    popq %rbx
    movq %rbp, %rsp
    popq %rbp
    ret
