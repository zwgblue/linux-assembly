#!/bin/bash
as helloworld-lib.s -o helloworld-lib.o
# Link with gcc to correctly handle libc and dynamic linker for 64-bit
gcc helloworld-lib.o -o helloworld-lib
# ./helloworld-lib # Optional execution
# echo $?