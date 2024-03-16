#include <ctime>
#include <filesystem>
#include <iostream>

#include "linalg.hpp"

int main(int argc, char *argv[]) {
    PRNG g = PRNG(time(NULL));

    Matrix a(4, 4);
    std::cout << a;

    a.randomize(g);

    std::cout << a;

    a.save("a.mtx");

    std::cout << (a.get_dim(0) * a.get_dim(1) * sizeof(float) + 2 * sizeof(size_t)) << std::endl;

    Matrix b;
    b.load("a.mtx");

    std::cout << b;

    return 0;
}
