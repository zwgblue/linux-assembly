# 获取最大值

.section .data

data_items:
    .long 3,67,12,45,21,24,63,21,11,6,4,0 # Array of 4-byte integers

.section .text

.globl _start

_start:
    movq $0, %rdi                   # Initialize index to 0 (use %rdi as index)
    movl data_items(,%rdi,4), %eax  # Load first data item into %eax (as it's a .long)
    movl %eax, %ebx                 # Current maximum in %ebx (still 32-bit as data is .long)

start_loop:
    cmpl $0, %eax                   # Check if current element is 0 (end of data)
    je loop_exit                    # Jump if equal to 0

    incq %rdi                       # Increment index (%rdi is 64-bit)
    movl data_items(,%rdi,4), %eax  # Load next data item into %eax
    cmpl %ebx, %eax                 # Compare current item with current maximum
    jle start_loop                  # Jump if less than or equal (keep current max)

    movl %eax, %ebx                 # Update current maximum
    jmp start_loop

loop_exit:
    movq $60, %rax                  # SYS_EXIT syscall number for amd64
    movslq %ebx, %rdi               # Move the 32-bit max value from %ebx to %rdi, sign-extended to 64-bit for exit status
    syscall
