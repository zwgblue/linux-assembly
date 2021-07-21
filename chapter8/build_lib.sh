as --32 helloworld-lib.s -o helloworld-lib.o

# failed
ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 \
               -dynamic-linker /lib/i386-linux-gnu/libc.so.6 \
               -o helloworld-lib helloworld-lib.o