ifndef CUDA
    CUDA := false
else
    CUDA := true
endif

CPP_STANDARD = -std=c++20

CC = g++
CFLAGS = -Wall -Wno-sign-compare $(CPP_STANDARD) -Iinc

CUDA_PATH = /usr/local/cuda-12.4
CUDA_CC = nvcc
CUDA_CFLAGS = $(CPP_STANDARD) -Iinc -I$(CUDA_PATH)/include

LDFLAGS := -L$(CUDA_PATH)/lib64 -lcudart

SOURCES := src/rand.cpp src/matrix.cpp src/test.cpp
OBJECTS := obj/rand.o obj/matrix.o obj/test.o

LIB_OBJECTS := obj/rand.o obj/matrix.o

LIBRARY = lib/liblinalg.a

$(shell mkdir -p lib bin obj test)

obj/rand.o: src/rand.cpp
	$(CC) $(CFLAGS) -c $< -o $@

obj/matrix.o: src/matrix.cpp src/matrix.cu
ifeq ($(CUDA),true)
	$(CUDA_CC) $(CUDA_CFLAGS) -c src/matrix.cu -o $@
else
	$(CC) $(CFLAGS) -c src/matrix.cpp -o $@
endif

.PHONY: build test clean

build: $(LIB_OBJECTS)
	ar rcs $(LIBRARY) $(LIB_OBJECTS)

test: test/src/* test/scripts/* $(LIBRARY)
	chmod +x test/scripts/*.sh
ifeq ($(CUDA),true)
	./test/scripts/test_cuda.sh
else
	./test/scripts/test.sh
endif
	./test/scripts/run.sh

clean:
	rm -rf $(OBJECTS)  $(LIBRARY) $(LIB_OBJECTS) valgrind.rpt lib bin obj *.mtx
	./test/scripts/clean.sh

memcheck: $(LIBRARY)
	rm -rf valgrind.rpt
	valgrind --leak-check=yes --track-origins=yes --log-file=valgrind.rpt -s bin/test
