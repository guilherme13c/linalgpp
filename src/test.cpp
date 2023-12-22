#include <ctime>
#include <iostream>

#include "linalg.hpp"

int main(void) {
    PRNG g = PRNG(time(NULL));

    Matrix m = Matrix(4, 3);
    m.randomize(g);

    std::cout << m;

    m.transpose();

    std::cout << m;

    return 0;
}
