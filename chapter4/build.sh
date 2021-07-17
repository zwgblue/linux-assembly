as --32 power.s -o power.o

# file power.o
# power.o: ELF 32-bit LSB relocatable, Intel 80386, version 1 (SYSV), not stripped

ld -m elf_i386 power.o -o power

# file power.o
# power: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, not stripped

./power
echo $?