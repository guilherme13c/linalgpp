#include <ctime>
#include <iostream>

#include "linalg.hpp"

int main(int argc, char *argv[]) {
    PRNG g = PRNG(time(NULL));

    Matrix a(3, 3);
    a.randomize(g);

    std::cout << a;

    Matrix b(5, 1);
    b.randomize(g);

    std::cout << b;

    b.transpose();

    std::cout << b;

    a = b.transpose();

    std::cout << a;

    return 0;
}
