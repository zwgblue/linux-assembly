#!/bin/bash
as factorial.s -o factorial.o
ld factorial.o -o factorial
./factorial
echo $?