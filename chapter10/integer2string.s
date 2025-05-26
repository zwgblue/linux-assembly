#PURPOSE: Convert an integer number to a decimal string 
#         for display
#
#INPUT:   A buffer large enough to hold the largest 
#         possible number (passed as a pointer)
#         An integer to convert (passed as a value)
#
#OUTPUT:  The buffer will be overwritten with the 
#         decimal string
#
#Variables:
# %rcx will hold the count of characters processed
# %rax will hold the current value / quotient
# %rdi will hold the base (10) for division
# %rdx will hold the remainder / character value / buffer pointer

    # Stack argument offsets from %rbp
    .equ ST_VALUE_ARG, 16     # Integer value to convert
    .equ ST_BUFFER_ARG, 24    # Pointer to output buffer

    .globl integer2string
    .type integer2string, @function
integer2string:
    # Standard function prologue
    pushq %rbp
    movq  %rsp, %rbp

    # Current character count
    movq  $0, %rcx

    # Move the value to convert into %rax
    movq  ST_VALUE_ARG(%rbp), %rax

    # Divisor 10 must be in a register or memory location for divq
    movq  $10, %rdi

conversion_loop:
    # divq uses %rdx:%rax. Zero %rdx before each division.
    movq  $0, %rdx

    # Divide %rdx:%rax by %rdi (10).
    # Quotient stored in %rax, remainder in %rdx.
    divq  %rdi

    # Remainder in %rdx (0-9) needs to be converted to ASCII '0'-'9'.
    addq  $'0', %rdx

    # Push the character (in %dl, but push whole %rdx) onto the stack.
    # This reverses the order of digits.
    pushq %rdx

    # Increment the digit count
    incq  %rcx

    # Check if quotient %rax is zero. If so, conversion is done.
    cmpq  $0, %rax
    je    end_conversion_loop

    # %rax (quotient) becomes the new number to convert for the next iteration.
    jmp conversion_loop

end_conversion_loop:
    # Digits are on the stack in reverse order. Pop them one by one
    # into the buffer.

    # Get the pointer to the output buffer into %rdx
    movq  ST_BUFFER_ARG(%rbp), %rdx
    
copy_reversing_loop:
    # Pop character from stack into %rax. We only need the byte in %al.
    popq  %rax
    movb  %al, (%rdx) # Move the character byte into the buffer

    # Decrement digit count (%rcx)
    decq  %rcx
    # Increment buffer pointer (%rdx)
    incq  %rdx

    # Check if all digits have been copied
    cmpq  $0, %rcx
    # If so, jump to the end of the function
    je    end_copy_reversing_loop
    # Otherwise, repeat the loop
    jmp   copy_reversing_loop

end_copy_reversing_loop:
    # Done copying. Write a null terminator.
    movb  $0, (%rdx)
    
    # Standard function epilogue
    movq  %rbp, %rsp
    popq  %rbp
    ret
