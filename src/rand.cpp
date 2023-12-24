#include "rand.hpp"

PRNG::PRNG(uint64_t seed, uint64_t a, uint64_t c,
     uint64_t m, uint64_t max) {
    this->curr = seed;
    this->max = max;
    this->a = a;
    this->c = c;
    this->m = m;
}

int PRNG::get_max() { return (int)max; }

int PRNG::generate() {
    curr = (a * curr + c) % m;
    return curr & max;
}
