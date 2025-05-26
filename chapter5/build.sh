#!/bin/bash
as toupper.s -o toupper.o
ld toupper.o -o toupper
# Test with itself and output to toupper.txt
# Make sure this test is valid and input file exists (e.g. toupper.s)
./toupper toupper.s toupper.txt
echo "toupper_exit_status=$?"