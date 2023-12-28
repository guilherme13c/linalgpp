#include <ctime>
#include <iostream>

#include <linalg/linalg.hpp>

int main(int argc, char *argv[]) {
    PRNG g = PRNG(time(NULL));

    Matrix a(2, 1, {1, 0});

    Matrix b = a;

    std::cout << a;
    std::cout << b;

    return 0;
}
