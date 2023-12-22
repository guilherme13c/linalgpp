#include <ctime>
#include <iostream>

#include "linalg.hpp"

int main(void) {
    PRNG g = PRNG(time(NULL));

    Matrix m = Matrix(6, 9);
    m.randomize(g);

    std::cout << m;

    return 0;
}
