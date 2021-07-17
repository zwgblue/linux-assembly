# 计算幂表达加减 2^3+5^2

    .code32 # 64位编译32位代码时需要，否则popl和pushl命令无法识别

    .section .data

    .section .text

    .globl _start

_start:
    push $3 # 第二个参数
    push $2 # 第一个参数
    call power # 调用函数，同时返回地址(被调用的函数返回后下条指令的地址)入栈 (call指令隐含操作 pushl %eip )
    addl $8, %esp
    pushl %eax # 第一次调用函数的返回值入栈

    push $2 # 第二个参数
    push $5 # 第一个参数
    call power
    addl $8, %esp
    popl %ebx

    addl %eax, %ebx

    movl $1, %eax
    int $0x80
    
# 幂计算函数
    .type power, @function
power:
    pushl %ebp # 在栈上保存调用方的基指针 Caller BP
    movl %esp, %ebp # 被调用方的基指针 Callee BP
    subl $4, %esp  # 在栈上分配用于存储计算结果(局部变量)的空间

    movl 8(%ebp), %ebx  # 第一个参数读取至寄存器ebx
    movl 12(%ebp), %ecx # 第二个参数读取至寄存器ecx

    movl %ebx, -4(%ebp) # 初始计算结果的中间值
    
power_loop_start:
    cmpl $1, %ecx
    je end_power
    movl -4(%ebp), %eax
    imull %ebx, %eax
    movl %eax, -4(%ebp)

    decl %ecx # 指数减1
    jmp power_loop_start

end_power:
    movl -4(%ebp), %eax  # 返回值存储到寄存器，因为该函数返回前要收回局部变量的栈空间
    movl %ebp, %esp # 恢复栈指针 (完成局部变量的回收)
    popl %ebp # 恢复成调用方的基指针
    ret # (ret指令隐含操作 popl %eip )
