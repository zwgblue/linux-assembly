    .section .data

# 此处指向我们管理的内存的起始处
heap_begin:
    .long 0

# 此处指向我们管理的内存之后的一个内存位置
current_break:
    .long 0

    # 内存区头空间大小
    .equ HEADER_SIZE, 8
    # 头中AVAILABLE标志的位置
    .equ HDR_AVAIL_OFFEST, 0
    # 内存去头中大小字段的位置
    .equ HDR_SIZE_OFFSET, 4

