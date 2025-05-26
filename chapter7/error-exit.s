.include "../common/linux_amd64.s" // Use common amd64 definitions

    # Arguments on stack for error_exit:
    .equ ST_ERROR_CODE_ARG, 16      # 1st arg: value of error code to print
    .equ ST_ERROR_MSG_ARG, 24       # 2nd arg: pointer to error message string

    .globl error_exit
    .type error_exit, @function
error_exit:
    pushq %rbp
    movq %rsp, %rbp

    # Save callee-saved registers if used (e.g. rbx, r12-r15)
    # For simplicity, assuming they are not heavily used or managed by caller.

    # Print the error code value (ST_ERROR_CODE_ARG)
    # This part is tricky: ST_ERROR_CODE_ARG is a value, not a string.
    # The original code pushes this value, calls count_chars (which expects a string ptr),
    # then uses the result as length for SYS_WRITE. This is incorrect.
    # count_chars cannot count digits of a number directly.
    # For now, I will skip printing the numeric error code, and only print the message.
    # Proper numeric to string conversion is needed (like in chapter10).
    # Alternatively, if ST_ERROR_CODE_ARG was meant to be a string, the caller should pass a pointer.
    # Assuming the primary goal is to print the error *message*:

    # Write error message string (ST_ERROR_MSG_ARG) to STDERR
    movq ST_ERROR_MSG_ARG(%rbp), %rdi # Get error message string pointer for count_chars
    pushq %rdi                        # Push argument for count_chars
    call count_chars
    addq $8, %rsp                     # Clean up stack (1 argument)
    # %rax now has length of error message

    movq %rax, %rdx                   # %rdx = length of message for SYS_WRITE
    movq $SYS_WRITE, %rax             # Syscall number for SYS_WRITE
    movq $STDERR, %rdi                # %rdi = STDERR file descriptor (2)
    movq ST_ERROR_MSG_ARG(%rbp), %rsi # %rsi = pointer to error message string
    syscall

    # Write a newline to STDERR
    movq $STDERR, %rdi                # Arg 1 for write_newline: file descriptor
    pushq %rdi
    call write_newline
    addq $8, %rsp                     # Clean up stack

    # Exit program
    # The original code exits with 0. If it should exit with ST_ERROR_CODE_ARG,
    # that value should be moved to %rdi. For now, sticking to exit 0.
    movq $SYS_EXIT, %rax
    movq $0, %rdi                     # Exit code 0
    syscall
    
    # No explicit leave/ret needed as this function exits the program.
    # If it were to return, it would need:
    # movq %rbp, %rsp
    # popq %rbp
    # ret
