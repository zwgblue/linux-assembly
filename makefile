AS = as
LD = ld
GCC = gcc

# Define executables that might be created by various chapters/scripts
# This list helps in cleaning them up.
TARGET_EXECS_TO_CLEAN = \
    chapter2/exit \
    chapter3/maximum \
    chapter4/factorial \
    chapter5/toupper \
    chapter6/modify-records \
    chapter6/read-records \
    chapter6/write-records \
    chapter8/helloworld-lib \
    chapter8/helloworld-nolib
# chapter10/integer2string is a module, not an executable
# chapter7/error-exit is also a module
# The other .s files in chapter6 are modules/parts of the above executables.

# Default target: Build a few simple examples.
# For more complex chapters (like chapter6 with multiple .s files per executable)
# or those using specific build scripts, users can run those scripts directly.
all: chapter2/exit chapter3/maximum chapter4/factorial chapter5/toupper chapter8/helloworld-nolib chapter8/helloworld-lib
	@echo "Built selected chapter targets."
	@echo "For other chapters or full builds, please use their respective .sh scripts or expand this Makefile."

# Chapter 2
chapter2/exit: chapter2/exit.s
	$(AS) $< -o chapter2/exit.o
	$(LD) chapter2/exit.o -o $@

# Chapter 3 (no build script previously, direct .s to executable)
chapter3/maximum: chapter3/maximum.s
	$(AS) $< -o chapter3/maximum.o
	$(LD) chapter3/maximum.o -o $@

# Chapter 4
chapter4/factorial: chapter4/factorial.s
	$(AS) $< -o chapter4/factorial.o
	$(LD) chapter4/factorial.o -o $@

# Chapter 5 (depends on common/linux_amd64.s indirectly via include)
chapter5/toupper: chapter5/toupper.o
	$(LD) $< -o $@
chapter5/toupper.o: chapter5/toupper.s common/linux_amd64.s
	$(AS) chapter5/toupper.s -o chapter5/toupper.o

# Chapter 8 (helloworld-nolib, depends on common/linux_amd64.s indirectly)
chapter8/helloworld-nolib: chapter8/helloworld-nolib.o
	$(LD) $< -o $@
chapter8/helloworld-nolib.o: chapter8/helloworld-nolib.s common/linux_amd64.s
	$(AS) chapter8/helloworld-nolib.s -o chapter8/helloworld-nolib.o

# Chapter 8 (helloworld-lib, uses gcc for linking)
chapter8/helloworld-lib: chapter8/helloworld-lib.o
	$(GCC) $< -o $@
chapter8/helloworld-lib.o: chapter8/helloworld-lib.s common/linux_amd64.s
	$(AS) chapter8/helloworld-lib.s -o chapter8/helloworld-lib.o

# Phony targets
.PHONY: all clean

# Clean target: remove object files and known executables
clean:
	find . -name "*.o" -delete
	$(RM) $(TARGET_EXECS_TO_CLEAN)
	@echo "Cleaned object files and known executables."