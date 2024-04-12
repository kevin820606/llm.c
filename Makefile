CC ?= clang
CFLAGS = -O3 -Ofast -Wno-unused-result
LDFLAGS =
LDLIBS = -lm
INCLUDES =

# Check if OpenMP is available
# This is done by attempting to compile an empty file with OpenMP flags
# OpenMP makes the code a lot faster so I advise installing it
# e.g. on MacOS: brew install libomp
# e.g. on Ubuntu: sudo apt-get install libomp-dev
# later, run the program by prepending the number of threads, e.g.: OMP_NUM_THREADS=8 ./gpt2
ifeq ($(shell uname), Darwin)
  # macOS
  ifeq ($(shell [ -d /opt/homebrew/opt/libomp/lib ] && echo "exists"), exists)
    # macOS with Homebrew and directory exists
    CFLAGS += -Xclang -fopenmp -DOMP
    LDFLAGS += -L/opt/homebrew/opt/libomp/lib
    LDLIBS += -lomp
    INCLUDES += -I/opt/homebrew/opt/libomp/include
    $(info NICE Compiling with OpenMP support)
  else ifeq ($(shell [ -d /usr/local/opt/libomp/lib ] && echo "exists"), exists)
    CFLAGS += -Xclang -fopenmp -DOMP
    LDFLAGS += -L/usr/local/opt/libomp/lib
    LDLIBS += -lomp
    INCLUDES += -I/usr/local/opt/libomp/include
    $(info NICE Compiling with OpenMP support)
  else
    $(warning Compiling without OpenMP support on macOS)
  endif
else
  # Other Unix-like systems
  ifeq ($(shell $(CC) --version | grep -o 'clang' | head -n1), clang)
    # Using clang
    CFLAGS += -fopenmp -DOMP
    LDLIBS += -lomp
    $(info Compiling with OpenMP support using clang)
  else
    # Other compilers
    ifeq ($(shell echo | $(CC) -fopenmp -x c -E - > /dev/null 2>&1; echo $$?), 0)
      CFLAGS += -fopenmp -DOMP
      LDLIBS += -lgomp
      $(info Compiling with OpenMP support)
    else
      $(warning Compiling without OpenMP support)
    endif
  endif
endif
# PHONY means these targets will always be executed
.PHONY: all train_gpt2 test_gpt2 train_gpt2cu test_gpt2cu

# default target is all
all: train_gpt2 test_gpt2 train_gpt2cu test_gpt2cu

train_gpt2: train_gpt2.c
	$(CC) $(CFLAGS) $(INCLUDES) $(LDFLAGS) $< $(LDLIBS) -o $@

test_gpt2: test_gpt2.c
	$(CC) $(CFLAGS) $(INCLUDES) $(LDFLAGS) $< $(LDLIBS) -o $@

# possibly may want to disable warnings? e.g. append -Xcompiler -Wno-unused-result
train_gpt2cu: train_gpt2.cu
	nvcc -O3 --use_fast_math $< -lcublas -o $@

test_gpt2cu: test_gpt2.cu
	nvcc -O3 --use_fast_math $< -lcublas -o $@

clean:
	rm -f train_gpt2 test_gpt2 train_gpt2cu test_gpt2cu

