.include "../common/linux_amd64.s" # Assuming common is at root
    .include "record-def.s"

    .equ ST_FILEDES_ARG, 16        # Argument: file descriptor
    .equ ST_WRITE_BUFFER_ARG, 24   # Argument: buffer address

    .section .text
    .globl write_record
    .type write_record, @function
write_record:
    pushq %rbp
    movq %rsp, %rbp

    # Callee-saved registers typically pushed here if used, e.g. %rbx
    # pushq %rbx 

    movq $SYS_WRITE, %rax
    movq ST_FILEDES_ARG(%rbp), %rdi      # %rdi = fd
    movq ST_WRITE_BUFFER_ARG(%rbp), %rsi # %rsi = buffer address
    movq $RECORD_SIZE, %rdx             # %rdx = count (RECORD_SIZE)
    syscall                             # %rax returns bytes written or error

    # popq %rbx
    movq %rbp, %rsp
    popq %rbp
    ret
