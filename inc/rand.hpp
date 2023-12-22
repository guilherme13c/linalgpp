#pragma once

class PRNG {
  private:
	unsigned long a = 1103515245;
	unsigned long c = 12345;
	unsigned long m = 2147483648; // 2^31
	unsigned long curr = 0;
	unsigned long max = 0x7FFFFFFF; // first 31 bits

  public:
	PRNG(unsigned long seed, unsigned long a = 1103515245UL,
		 unsigned long c = 12345UL, unsigned long m = 2147483648UL,
		 unsigned long max = 0x7FFFFFFF) {
		this->curr = seed;
		this->max = max;
		this->a = a;
		this->c = c;
		this->m = m;
	}

	int get_max() { return (int)max; }

	int generate() {
		curr = (a * curr + c) % m;
		return curr & max;
	}
};
