.include "../common/linux_amd64.s"
    .include "record-def.s"

    .section .data
file_name:
    .ascii "test.dat\0"

    .section .bss
    .lcomm record_buffer, RECORD_SIZE

    .section .text
    .globl _start
_start:
    # Stack frame: save %rbp, set %rbp to %rsp
    pushq %rbp
    movq %rsp, %rbp

    # Reserve space for local variables (file descriptors)
    # ST_INPUT_DESCRIPTOR at -8(%rbp), ST_OUTPUT_DESCRIPTOR at -16(%rbp)
    .equ ST_INPUT_DESCRIPTOR, -8
    .equ ST_OUTPUT_DESCRIPTOR, -16
    subq $16, %rsp # Reserve 16 bytes for two quadwords

    # Open file
    movq $SYS_OPEN, %rax
    movq $file_name, %rdi
    movq $O_RDONLY, %rsi      # Flags: read-only
    movq $0, %rdx             # Mode (not strictly needed for O_RDONLY)
    syscall                   # %rax = input file descriptor or error

    movq %rax, ST_INPUT_DESCRIPTOR(%rbp)
    movq $STDOUT, %rax        # Standard Output file descriptor
    movq %rax, ST_OUTPUT_DESCRIPTOR(%rbp)

record_read_loop:
    # Call read_record(input_fd, record_buffer)
    # read_record expects: fd at 16(%rbp), buffer_address at 24(%rbp)
    pushq $record_buffer                 # This will be at 24(%rbp) in callee
    movq ST_INPUT_DESCRIPTOR(%rbp), %rax # Get fd into a register first
    pushq %rax                           # This will be at 16(%rbp) in callee
    call read_record
    addq $16, %rsp                       # Clean up 2 arguments (2 * 8 bytes)

    # %rax contains bytes read from read_record
    cmpq $RECORD_SIZE, %rax
    jne finished_reading                 # If not equal, assume EOF or error

    # Call count_chars(record_buffer + RECORD_FIRSTNAME)
    movq $(record_buffer + RECORD_FIRSTNAME), %rdi # Arg 1: string address
    pushq %rdi
    call count_chars
    addq $8, %rsp                        # Clean up 1 argument
    
    # %rax contains char count from count_chars
    # Write the string (firstname) to stdout
    movq %rax, %rdx                      # Arg 3 for SYS_WRITE: count of chars
    movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi # Arg 1 for SYS_WRITE: output fd
    movq $(record_buffer + RECORD_FIRSTNAME), %rsi # Arg 2 for SYS_WRITE: buffer
    movq $SYS_WRITE, %rax                # Syscall number for SYS_WRITE
    syscall

    # Call write_newline(output_fd)
    movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi # Arg 1: file descriptor
    pushq %rdi
    call write_newline
    addq $8, %rsp                        # Clean up 1 argument

    jmp record_read_loop

finished_reading:
    movq $SYS_EXIT, %rax
    movq $0, %rdi                        # Exit code 0
    syscall
    
    # No explicit leave/ret needed as _start exits directly
    # If _start were a function, it would need:
    # movq %rbp, %rsp
    # popq %rbp
    # ret
