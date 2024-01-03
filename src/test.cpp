#include <ctime>
#include <iostream>

#include "linalg.hpp"

int main(int argc, char *argv[]) {
    // PRNG g = PRNG(time(NULL));

    Matrix a(3, 3, {1.001, 2, 3, 4, 5, 6, 7, 8, 9.99});

    std::cout << a;

    Matrix b(3, 3, {1.001, 2, 3, 4, 5, 6, 7, 8, 9.99});

    Matrix c(3, 3);
    c.fill(0);
    c += b;

    std::cout << c;

    c *= 0.8f;

    std::cout << c;

    std::cout << b;

    std::cout << a.hadamard(b);

    return 0;
}
