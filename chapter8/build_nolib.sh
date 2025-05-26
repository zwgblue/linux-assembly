#!/bin/bash
as helloworld-nolib.s -o helloworld-nolib.o
ld helloworld-nolib.o -o helloworld-nolib
# ./helloworld-nolib # Optional execution
# echo $?