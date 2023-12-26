#include <ctime>
#include <iostream>

#include <linalg/linalg.hpp>

float relu(float a) { return a > 0 ? a : 0; }

int main(int argc, char *argv[]) {
    PRNG g = PRNG(time(NULL));

    Matrix I(2, 1, {1, 0});

    Matrix W(1, 2);
    W.randomize(g);

    Matrix B(1, 1);
    B.randomize(g);

    std::cout << I;
    std::cout << W;
    std::cout << B;

    Matrix Z = (W * I) + B;

    std::cout << Z;

    Z.apply(relu);

    std::cout << Z;

    return 0;
}
