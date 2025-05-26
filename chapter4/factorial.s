# 计算阶乘

    .section .data

    .section .text

    .globl _start
_start:
    pushq $4              # Push argument for factorial (will be 64-bit value on stack)
    call factorial
    addq $8, %rsp         # Clean up stack after call (1 argument * 8 bytes)
    
    movq %rax, %rdi       # Factorial result (in %rax) is the exit status for %rdi

    movq $60, %rax        # SYS_EXIT syscall number
    syscall

    .type factorial, @function
factorial:
    pushq %rbp            # Save old base pointer
    movq %rsp, %rbp       # Set new base pointer

    movq 16(%rbp), %rax   # Get argument n (16 bytes offset from %rbp: 8 for ret addr, 8 for saved %rbp)

    cmpq $1, %rax         # Compare n with 1
    je end_factorial

    decq %rax             # n-1
    pushq %rax            # Push n-1 for recursive call
    
    call factorial        # Recursive call: factorial(n-1)
    addq $8, %rsp         # Clean up stack after recursive call

    # Result of factorial(n-1) is in %rax
    # n (original argument) needs to be retrieved again
    movq 16(%rbp), %rbx   # Get original n into %rbx
    imulq %rbx, %rax      # rax = rax * rbx  ( (n-1)! * n )

end_factorial:
    movq %rbp, %rsp       # Restore stack pointer
    popq %rbp             # Restore old base pointer
    ret                   # Return, result in %rax
