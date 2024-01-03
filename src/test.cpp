#include <ctime>
#include <iostream>

#include "linalg.hpp"

int main(int argc, char *argv[]) {
    PRNG g = PRNG(time(NULL));

    Matrix a(10, 10);
    a.randomize(g);

    std::cout << a;

    Matrix b(5, 1);
    b.randomize(g);
    b.transpose();

    std::cout << b;

    b = a;

    std::cout << b;

    return 0;
}
