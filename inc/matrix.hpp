#pragma once

#include <cassert>
#include <cstdlib>
#include <iomanip>
#include <iostream>

#include "rand.hpp"

class Matrix
{
private:
  float *data;
  size_t dim[2];

public:
  Matrix();
  Matrix(size_t rows, size_t cols);

  ~Matrix();

  size_t get_dim(size_t axis) const;
  float &at(size_t row, size_t col);
  float read_at(size_t row, size_t col) const;
  void randomize(PRNG &prng, float min = 0, float max = 1);
  void fill(float value);

  void transpose();

  Matrix add(Matrix &other);
  Matrix sub(Matrix &other);
  Matrix mul(Matrix &other);
  Matrix mul(float a);

  Matrix apply(float (*f)(float));

  float sum();

  Matrix expand(Matrix &other, size_t axis = 0);
  Matrix slice(size_t row0, size_t row1, size_t col0, size_t col1);

  float &operator()(size_t row, size_t col);

  friend std::ostream &operator<<(std::ostream &os, const Matrix &m);
};
