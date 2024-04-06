#include <ctime>
#include <filesystem>
#include <iostream>

#include <linalg/linalg.hpp>

int main(int argc, char *argv[]) {
    PRNG g(time(NULL));

    Matrix a(4, 4);

    a.randomize(g);

    std::cout << a;

    Matrix b = a;

    std::cout << b;

    Matrix c = a * b;

    std::cout << c;

    return 0;
}
