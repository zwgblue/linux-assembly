    .code32
    .include "linux.s"
    .include "record-def.s"

    .section .data
file_name:
    .ascii "test.dat\0"
    