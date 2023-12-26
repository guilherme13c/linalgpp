CC = g++
CFLAGS = -O3 -Wall -Wno-sign-compare -std=c++20 -Iinc

SOURCES := src/rand.cpp src/matrix.cpp src/test.cpp
OBJECTS := obj/rand.o obj/matrix.o obj/test.o

LIB_SOURCES := src/rand.cpp src/matrix.cpp inc/linalg.hpp inc/rand.hpp inc/matrix.hpp
LIB_OBJECTS := obj/rand_lib.o obj/matrix_lib.o

LIBRARY = lib/liblinalg.a
TEST_EXECUTABLE = bin/test

INSTALL_INCLUDE_DIR = /usr/include/linalg
INSTALL_LIB_DIR = /usr/lib

$(TEST_EXECUTABLE): $(OBJECTS) $(LIBRARY)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TEST_EXECUTABLE)

obj/%.o: src/%.cpp
	$(CC) $(CFLAGS) -c $< -o $@

$(LIBRARY): $(LIB_OBJECTS)
	ar rcs $(LIBRARY) $(LIB_OBJECTS)

obj/%_lib.o: src/%.cpp inc/%.hpp
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: build test clean install

build: $(LIBRARY)

test: $(TEST_EXECUTABLE)
	bin/test

clean:
	rm -rf $(OBJECTS) $(TEST_EXECUTABLE) $(LIBRARY) $(LIB_OBJECTS)

install: $(LIB_SOURCES) $(LIBRARY)
	mkdir -p $(INSTALL_INCLUDE_DIR)
	cp inc/*.hpp $(INSTALL_INCLUDE_DIR)
	cp $(LIBRARY) $(INSTALL_LIB_DIR)
