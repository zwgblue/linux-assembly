#!/bin/bash
as write-records.s -o write-records.o
as write-record.s -o write-record.o
ld write-records.o write-record.o -o write-records
./write-records
echo "write-records_exit_status=$?"
