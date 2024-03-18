#include <ctime>
#include <filesystem>
#include <iostream>

#include "linalg.hpp"

int main(int argc, char *argv[]) {
    Matrix a(10, 10);

    a.fill(2);

    std::cout << a;

    Matrix b = a;

    std::cout << b;

    Matrix c = a * b;

    std::cout << c;

    Matrix g = b.hadamard(a);

    std::cout << g;

    Matrix h = g.apply([](float x) { return x * x * x - x; });

    std::cout << h;

    return 0;
}
