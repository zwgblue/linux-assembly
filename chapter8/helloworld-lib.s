.include "../common/linux_amd64.s" // For consistency, though not strictly used for syscalls here
    .section .data

helloworld:
    .ascii "hello world\n\0"

    .section .text
    .globl _start
_start:
    pushq %rbp            # Establish stack frame
    movq %rsp, %rbp

    # Align stack for printf: %rsp must be 16-byte aligned before call.
    # After pushq %rbp, %rsp is (%rbp_val - 8).
    # If original %rsp was 16-byte aligned, current %rsp is XXXXXXX8.
    # We need current %rsp to be XXXXXXX0 before call.
    # So, if %rbp is XXXXXXX8, current %rsp is XXXXXXX8.
    # 'call' pushes 8 bytes (return address). So, entry %rsp for printf will be (%rsp_before_call - 8).
    # We need (%rsp_before_call - 8) to be XXXXXXX8.
    # Thus, %rsp_before_call must be XXXXXXX0.
    # After 'pushq %rbp; movq %rsp, %rbp', %rsp is currently not necessarily 16-byte aligned for the call.
    # Let's ensure it:
    subq $8, %rsp         # Allocate a dummy 8-byte local, or just align for the call

    # Call printf from libc
    movq $helloworld, %rdi # 1st argument: pointer to string
    movq $0, %rax         # For variadic functions like printf, set %al to 0 (no FP args in XMMs)
    call printf           # Call C library printf

    addq $8, %rsp         # Deallocate dummy space / restore alignment

    # Call exit from libc
    movq $0, %rdi         # 1st argument: exit status
    call exit             # Call C library exit (does not return)

    # No need for leave/ret as exit() does not return.
    # If _start were to return, it would need:
    # movq %rbp, %rsp # or leave
    # popq %rbp
    # ret
