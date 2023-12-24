CC = g++
CFLAGS = -O3 -Wall -Wno-sign-compare -std=c++20 -Iinc

SOURCES := src/rand.cpp src/matrix.cpp src/test.cpp
OBJECTS := obj/rand.o obj/matrix.o obj/test.o

TEST_EXECUTABLE = bin/test

$(TEST_EXECUTABLE): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $(TEST_EXECUTABLE)

obj/%.o: src/%.cpp
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -rf $(OBJECTS) $(TEST_EXECUTABLE)
