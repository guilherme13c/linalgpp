#include <ctime>
#include <filesystem>
#include <iostream>

#include "linalg.hpp"

int main(int argc, char *argv[]) {
    Matrix a(1000, 1000);

    a.fill(3.1415);

    // std::cout << a;

    Matrix b = a;

    // std::cout << b;

    Matrix c = a * b;

    Matrix d = c * a;

    Matrix e = d * a;

    Matrix f = e * a;

    Matrix g = e.hadamard(e);

    Matrix h = d.apply([](float x) { return x * x * x - x; });

    Matrix i = a - b;

    Matrix j = a + c;

    // std::cout << c;

    return 0;
}
