#include <ctime>
#include <iostream>

#include "linalg.hpp"

int main(void) {
    PRNG g = PRNG(time(NULL));

    Matrix m = Matrix(4, 4);
    m.randomize(g);

    Matrix n = Matrix(4, 1, {1.0f, 2.0f, 3.0f, 4.0f});
    n.randomize(g);

    std::cout << m;

    Matrix k = m.expand(n, 1);

    std::cout << n;

    std::cout << k;

    return 0;
}
