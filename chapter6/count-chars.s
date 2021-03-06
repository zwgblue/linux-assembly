    .type count_chars, @function
    .globl count_chars

    .equ ST_STRING_START_ADDRESS, 8
count_chars:
    pushl %ebp
    movl %esp, %ebp

    # 计算器从0开始
    movl $0, %ecx
    movl ST_STRING_START_ADDRESS(%ebp), %edx

count_loop_begin:
    # 获取当前字符
    movb (%edx), %al
    cmpb $0, %al
    je count_loop_end

    incl %ecx
    incl %edx
    jmp count_loop_begin

count_loop_end:
    movl %ecx, %eax
    popl %ebp
    ret
