#!/bin/bash
as read-records.s -o read-records.o
as read-record.s -o read-record.o
as write-newline.s -o write-newline.o
as count-chars.s -o count-chars.o
ld read-record.o read-records.o write-newline.o count-chars.o -o read-records
./read-records
echo "read-records_exit_status=$?"