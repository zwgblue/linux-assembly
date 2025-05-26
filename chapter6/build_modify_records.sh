#!/bin/bash
as add-year.s -o add-year.o
as read-record.s -o read-record.o
as write-record.s -o write-record.o
ld add-year.o read-record.o write-record.o -o modify-records
./modify-records
echo "modify-records_exit_status=$?"