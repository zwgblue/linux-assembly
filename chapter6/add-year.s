.include "../common/linux_amd64.s"
    .include "record-def.s"

    .section .data
input_file_name:
    .ascii "test.dat\0"
output_file_name:
    .ascii "testout.dat\0"

    .section .bss
    .lcomm record_buffer, RECORD_SIZE

    # Local variables on stack relative to %rbp
    .equ ST_INPUT_DESCRIPTOR, -8
    .equ ST_OUTPUT_DESCRIPTOR, -16

    .section .text
    .globl _start
_start:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp  # Reserve space for two file descriptors

    # Open input file (read-only)
    movq $SYS_OPEN, %rax
    movq $input_file_name, %rdi
    movq $O_RDONLY, %rsi
    movq $0, %rdx           # Mode not needed for O_RDONLY
    syscall
    movq %rax, ST_INPUT_DESCRIPTOR(%rbp)

    # Open output file (create, write-only, truncate)
    movq $SYS_OPEN, %rax
    movq $output_file_name, %rdi
    movq $(O_CREAT | O_WRONLY | O_TRUNC), %rsi # Flags: e.g. 0100 | 01 | 01000 = octal 01101
    movq $MODE_RW_UGO, %rdx                   # Permissions 0666
    syscall
    movq %rax, ST_OUTPUT_DESCRIPTOR(%rbp)

loop_begin:
    # Call read_record(input_fd, record_buffer)
    # read_record expects: fd at 16(%rbp), buffer_address at 24(%rbp)
    pushq $record_buffer                     # Arg 2: buffer address
    movq ST_INPUT_DESCRIPTOR(%rbp), %rax     # Get fd into %rax
    pushq %rax                               # Arg 1: file descriptor
    call read_record
    addq $16, %rsp                           # Clean up 2 args

    # %rax has bytes read. If not RECORD_SIZE, assume EOF or error.
    cmpq $RECORD_SIZE, %rax
    jne loop_end

    # Increment age in buffer (RECORD_AGE is offset to a 32-bit field)
    incl record_buffer + RECORD_AGE

    # Call write_record(output_fd, record_buffer)
    # write_record expects: fd at 16(%rbp), buffer_address at 24(%rbp)
    pushq $record_buffer                     # Arg 2: buffer address
    movq ST_OUTPUT_DESCRIPTOR(%rbp), %rax    # Get fd into %rax
    pushq %rax                               # Arg 1: file descriptor
    call write_record
    addq $16, %rsp                           # Clean up 2 args
    # write_record's return value in %rax (bytes written) is not checked here

    jmp loop_begin

loop_end:
    # Close files (optional, exit will do it, but good practice)
    movq $SYS_CLOSE, %rax
    movq ST_INPUT_DESCRIPTOR(%rbp), %rdi
    syscall
    
    movq $SYS_CLOSE, %rax
    movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
    syscall

    # Exit
    movq $SYS_EXIT, %rax
    movq $0, %rdi
    syscall
