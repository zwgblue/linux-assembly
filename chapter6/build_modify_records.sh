as --32 add-year.s -o add-year.o
as --32 read-record.s -o read-record.o
as --32 write-record.s -o write-record.o

ld -m elf_i386 add-year.o read-record.o write-record.o -o add-year