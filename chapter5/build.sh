as --32 toupper.s -o toupper.o

ld -m elf_i386 toupper.o -o toupper

./toupper toupper.s toupper.txt