as --32 read-records.s -o read-records.o
as --32 read-record.s -o read-record.o
as --32 write-newline.s -o write-newline.o
as --32 count-chars.s -o count-chars.o

ld -m elf_i386 read-record.o read-records.o write-newline.o count-chars.o -o read-records