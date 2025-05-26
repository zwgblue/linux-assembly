.type count_chars, @function
    .globl count_chars

    # Argument on stack: string start address at 16(%rbp)
    .equ ST_STRING_START_ADDRESS_ARG, 16
count_chars:
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rcx                         # Counter starts at 0
    movq ST_STRING_START_ADDRESS_ARG(%rbp), %rdx # Get string address

count_loop_begin:
    movb (%rdx), %al                      # Get current character
    cmpb $0, %al                          # Check for null terminator
    je count_loop_end

    incq %rcx                             # Increment count
    incq %rdx                             # Move to next character
    jmp count_loop_begin

count_loop_end:
    movq %rcx, %rax                       # Return count in %rax
    
    movq %rbp, %rsp
    popq %rbp
    ret
