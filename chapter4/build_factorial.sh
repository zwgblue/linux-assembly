as --32 factorial.s -o factorial.o

ld -m elf_i386 factorial.o -o factorial

./factorial
echo $?