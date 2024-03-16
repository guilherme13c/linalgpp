ifndef CUDA
    CUDA := false
else
    CUDA := true
endif

CPPSTANDARD = -std=c++20

CC = g++
CFLAGS = -Wall -Wno-sign-compare $(CPPSTANDARD) -Iinc

CUDA_PATH = /usr/local/cuda-12.4
CUDA_CC = nvcc
CUDA_CFLAGS = $(CPPSTANDARD) -Iinc -I$(CUDA_PATH)/include

LDFLAGS := -L$(CUDA_PATH)/lib64 -lcudart

SOURCES := src/rand.cpp src/matrix.cpp src/test.cpp
OBJECTS := obj/rand.o obj/matrix.o obj/test.o

LIB_SOURCES := src/rand.cpp src/matrix.cpp inc/linalg.hpp inc/rand.hpp inc/matrix.hpp
LIB_OBJECTS := obj/rand.o obj/matrix.o

LIBRARY = lib/liblinalg.a
TEST_EXECUTABLE = bin/test

INSTALL_INCLUDE_DIR = /usr/include/linalg
INSTALL_LIB_DIR = /usr/lib

$(shell mkdir -p lib bin obj)

$(TEST_EXECUTABLE): $(OBJECTS) $(LIBRARY)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TEST_EXECUTABLE) $(LDFLAGS)

obj/rand.o: src/rand.cpp
	$(CC) $(CFLAGS) -c $< -o $@

obj/matrix.o: src/matrix.cpp src/matrix.cu
ifeq ($(CUDA),true)
	@echo "CUDA is enabled"
	$(CUDA_CC) $(CUDA_CFLAGS) -c src/matrix.cu -o $@
else
	@echo "CUDA is disabled"
	$(CC) $(CFLAGS) -c src/matrix.cpp -o $@
endif

obj/test.o: src/test.cpp
	$(CC) $(CFLAGS) -c $< -o $@

$(LIBRARY): $(LIB_OBJECTS)
	ar rcs $(LIBRARY) $(LIB_OBJECTS)

.PHONY: build test clean install

build: $(LIBRARY)

test: $(TEST_EXECUTABLE)
	d=$$(date +%s%3N); bin/test && echo "Test took $$(($$(date +%s%3N)-d))ms"

clean:
	rm -rf $(OBJECTS) $(TEST_EXECUTABLE) $(LIBRARY) $(LIB_OBJECTS) valgrind.rpt lib bin obj *.mtx

install: $(LIB_SOURCES) $(LIBRARY)
	mkdir -p $(INSTALL_INCLUDE_DIR)
	cp inc/*.hpp $(INSTALL_INCLUDE_DIR)
	cp $(LIBRARY) $(INSTALL_LIB_DIR)

memcheck: $(TEST_EXECUTABLE)
	rm -rf valgrind.rpt
	valgrind --leak-check=yes --track-origins=yes --log-file=valgrind.rpt -s bin/test
