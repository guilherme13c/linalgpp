#pragma once

#include <stdint.h>

class PRNG {
  private:
    uint64_t a = 1103515245;
    uint64_t c = 12345;
    uint64_t m = 2147483648; // 2^31
    uint64_t curr = 0;
    uint64_t max = 0x7FFFFFFF; // first 31 bits

  public:
    PRNG(uint64_t seed, uint64_t a = 1103515245, uint64_t c = 12345,
         uint64_t m = 2147483648, uint64_t max = 0x7FFFFFFF);

    int get_max();

    int generate();
};
