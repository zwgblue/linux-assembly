# 问答

## .bss段和.data段的区别？

    `text`和`data`段都在可执行文件中,由系统从可执行文件中加载；而`bss`段不在可执行文件中，由系统初始化。

## .equ的作用是什么？

    定义静态符号。
    虽然数据段主要用于定义变量数据，但是也可以在这里声明静态数据符号。
    `.equ`命令用于把常量值设置为可以在文本段中使用的符号。如：

```s
.equ factor, 3
.equ LINUX_SYS_CALL, 0x80
```

    经过设置之后，数据符号值是不能在程序中改动的。
    `.equ`命令可以出现在数据段中任何位置，但是出于好的代码习惯，最好是在定义其他数据之前或之后集中定义所有数据符号。

    为了引用静态数据元素，必须在标签名称前面使用美元符号`$`。如：

```s
movl $LINUX_SYS_CALL, %eax
```

    把赋值给`LINUX_SYS_CALL`符号的值传送给`EAX`寄存器
