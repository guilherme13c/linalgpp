#include "linalg.hpp"
#include <iostream>
#include <time.h>

int main(void) {
    PRNG g((int)time(NULL));

    Matrix A(3, 3);
    A.randomize(g, -1, 1);

    Matrix B(3, 1);
    B.randomize(g, -1, 1);

    Matrix C = A * B;

    std::cout << A;
    std::cout << B;
    std::cout << C;

    return 0;
}
