.include "../common/linux_amd64.s" # Adjusted path

    .section .data

    # Constant definitions (syscall numbers are in linux_amd64.s)
    # O_RDONLY, O_CREAT_WRONLY_TRUNC (use O_CREAT | O_WRONLY | O_TRUNC)
    # STDIN, STDOUT, STDERR are in linux_amd64.s
    # END_OF_FILE is in linux_amd64.s

    .equ O_WRONLY_TRUNC_CREATE, O_WRONLY | O_TRUNC | O_CREAT # Combine flags

    .equ NUMBER_ARGUMENTS, 2 # This constant isn't directly used in a way that affects 64-bit translation of logic

    # Buffer
    .section .bss
    .equ BUFFER_SIZE, 500
    .lcomm BUFFER_DATA, BUFFER_SIZE

    .section .text

    # ... existing code ...

    open_input_failed_exit:
        movq $SYS_EXIT, %rax
        movq $2, %rdi      # Exit code 2 for input open fail
        syscall

    open_output_failed_exit:
        movq $SYS_EXIT, %rax
        movq $3, %rdi      # Exit code 3 for output open fail
        syscall

    # Stack layout relative to RBP for _start function
    # Original ST_SIZE_RESERVE was 8. Let's use 16 for two 8-byte slots for FDs for alignment.
    .equ ST_SIZE_RESERVE, 16
    .equ ST_FD_IN, -8      # Offset from RBP for input file descriptor (stored as 8 bytes)
    .equ ST_FD_OUT, -16    # Offset from RBP for output file descriptor (stored as 8 bytes)
    
    # Arguments passed by kernel on stack: argc, argv[0], argv[1], ...
    # These are relative to the initial %rsp *before* we set up %rbp.
    # After 'pushq %rbp' and 'movq %rsp, %rbp':
    # 16(%rbp) is argc (assuming main-like _start)
    # 24(%rbp) is argv[0]
    # 32(%rbp) is argv[1] (input filename)
    # 40(%rbp) is argv[2] (output filename)
    # For this program structure, it seems it gets them directly.

    .globl _start
_start:
    pushq %rbp
    movq %rsp, %rbp
    subq $ST_SIZE_RESERVE, %rsp # Reserve space for local variables (FDs)

    # Kernel passes arguments on the stack:
    # %rsp+0 (at time of _start): argc
    # %rsp+8: argv[0]
    # %rsp+16: argv[1] (input file)
    # %rsp+24: argv[2] (output file)
    # After our PUSH RBP, MOV RBP, RSP, SUB RSP, ST_SIZE_RESERVE
    # these are at:
    # ST_SIZE_RESERVE + 8(%rbp) = argc
    # ST_SIZE_RESERVE + 16(%rbp) = argv[0]
    # ST_SIZE_RESERVE + 24(%rbp) = argv[1]
    # ST_SIZE_RESERVE + 32(%rbp) = argv[2]
    # Let's use these adjusted offsets, assuming ST_SIZE_RESERVE is 16
    # .equ ST_ARGC_ON_STACK, 16+8         # argc relative to rbp after prologue (commenting out as not used)
    # .equ ST_ARGV_0_ON_STACK, 16+16      # argv[0] relative to rbp (commenting out as not used)
    # Corrected offsets for argv[1] and argv[2] as per prompt
    # After 'pushq %rbp' and 'movq %rsp, %rbp':
    # 8(%rbp) contains the saved %rbp
    # 16(%rbp) contains the return address
    # Then, arguments passed by the kernel:
    # argc is at 16(%rbp) + 8 (this is wrong, argc is first after ret addr)
    # Kernel actually puts on stack before _start call:
    # [rsp]: argc
    # [rsp+8]: argv[0]
    # [rsp+16]: argv[1]
    # [rsp+24]: argv[2]
    # After `pushq %rbp` and `movq %rsp, %rbp`:
    # 16(%rbp) is argc
    # 24(%rbp) is argv[0]
    # 32(%rbp) is argv[1]
    # 40(%rbp) is argv[2]
    # The prompt is asking for 24(%rbp) for argv[1] and 32(%rbp) for argv[2].
    # This means it's treating what is traditionally argv[0] as argv[1] and argv[1] as argv[2].
    # This is unconventional but I will follow the prompt's literal values.
    .equ ST_ARGV_1_OFFSET, 24      # Per prompt: effectively argv[0] (program name) as input file
    .equ ST_ARGV_2_OFFSET, 32      # Per prompt: effectively argv[1] (1st arg) as output file

open_files:
open_fd_in:
    movq $SYS_OPEN, %rax
    movq ST_ARGV_1_OFFSET(%rbp), %rdi  # Filename string pointer
    movq $O_RDONLY, %rsi                 # Flags
    movq $0, %rdx                        # Mode (not needed for O_RDONLY)
    syscall                              # rax = fd_in or error
    cmpq $0, %rax                        # Check if fd_in is negative
    jl open_input_failed_exit            # Jump if error
    # store_fd_in: (label is fine, or remove if not jumped to)
    movq %rax, ST_FD_IN(%rbp)

open_fd_out:
    movq $SYS_OPEN, %rax
    movq ST_ARGV_2_OFFSET(%rbp), %rdi  # Filename string pointer
    movq $O_WRONLY_TRUNC_CREATE, %rsi    # Flags: O_WRONLY | O_TRUNC | O_CREAT
    movq $MODE_RW_UGO, %rdx              # Mode for O_CREAT
    syscall                              # rax = fd_out or error
    cmpq $0, %rax                        # Check if fd_out is negative
    jl open_output_failed_exit           # Jump if error
    # store_fd_out: (label is fine)
    movq %rax, ST_FD_OUT(%rbp)

read_loop_begin:
    movq $SYS_READ, %rax
    movq ST_FD_IN(%rbp), %rdi          # fd
    movq $BUFFER_DATA, %rsi            # buffer address
    movq $BUFFER_SIZE, %rdx            # count
    syscall                            # rax = bytes_read or error
    
    cmpq $0, %rax                      # Check for EOF (0 bytes read) or error (<0)
    jle end_loop                       # If rax <= 0, then EOF or error

continue_read_loop:
    # %rax contains bytes_read
    # Store bytes_read from SYS_READ before calling convert_to_upper
    movq %rax, %r10                    # Save bytes_read in %r10 (caller-saved, but we manage it)

    pushq $BUFFER_DATA                 # Arg 2: buffer address
    pushq %r10                         # Arg 1: buffer length (bytes_read)
    call convert_to_upper
    addq $16, %rsp                     # Clean up 2 arguments

    movq $SYS_WRITE, %rax
    movq ST_FD_OUT(%rbp), %rdi         # fd
    movq $BUFFER_DATA, %rsi            # buffer address
    movq %r10, %rdx                    # count (original bytes_read)
    syscall

    jmp read_loop_begin

end_loop:
    movq $SYS_CLOSE, %rax
    movq ST_FD_OUT(%rbp), %rdi
    syscall

    movq $SYS_CLOSE, %rax
    movq ST_FD_IN(%rbp), %rdi
    syscall

    movq $SYS_EXIT, %rax
    movq $0, %rdi                      # Exit status 0
    syscall

# convert_to_upper: Converts lowercase chars in a buffer to uppercase.
# Args on stack:
# 16(%rbp): buffer length (count)
# 24(%rbp): buffer address
# Does not return a value in %rax, modifies buffer in place.
    .equ LOWERCASE_A, 'a'
    .equ LOWERCASE_Z, 'z'
    .equ UPPER_CONVERSION, 'A' - 'a'

    # Stack relative to %rbp inside convert_to_upper
    .equ ST_BUFFER_LEN_ARG, 16 # Argument: length of buffer
    .equ ST_BUFFER_ARG, 24    # Argument: address of buffer

convert_to_upper:
    pushq %rbp
    movq %rsp, %rbp
    
    movq ST_BUFFER_ARG(%rbp), %rax    # %rax = buffer address
    movq ST_BUFFER_LEN_ARG(%rbp), %rbx # %rbx = buffer length
    movq $0, %rdi                     # %rdi = index (current_char_offset)

    cmpq $0, %rbx                     # Check if length is 0
    je end_convert_loop

convert_loop:
    movb (%rax,%rdi,1), %cl           # Get char: cl = buffer[index]

    cmpb $LOWERCASE_A, %cl
    jl next_byte
    cmpb $LOWERCASE_Z, %cl
    jg next_byte

    addb $UPPER_CONVERSION, %cl       # Convert to uppercase
    movb %cl, (%rax,%rdi,1)           # Store char back: buffer[index] = cl

next_byte:
    incq %rdi                         # Increment index
    cmpq %rdi, %rbx                   # Compare index with length
    jne convert_loop                  # Loop if index != length

end_convert_loop:
    movq %rbp, %rsp                   # Restore stack pointer
    popq %rbp                         # Restore old base pointer
    ret
