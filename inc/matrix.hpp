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

Matrix Matrix::add(Matrix &other)
{
  assert(dim[0] == other.get_dim(0) && dim[1] == other.get_dim(1));

  Matrix result(dim[0], dim[1]);

  for (size_t i = 0; i < dim[0]; ++i)
  {
    for (size_t j = 0; j < dim[1]; ++j)
    {
      result.at(i, j) = at(i, j) + other.at(i, j);
    }
  }

  return result;
}

Matrix Matrix::sub(Matrix &other)
{
  assert(dim[0] == other.get_dim(0) && dim[1] == other.get_dim(1));

  Matrix result(dim[0], dim[1]);

  for (size_t i = 0; i < dim[0]; ++i)
  {
    for (size_t j = 0; j < dim[1]; ++j)
    {
      result.at(i, j) = at(i, j) - other.at(i, j);
    }
  }

  return result;
}

Matrix Matrix::mul(Matrix &other)
{
  assert(dim[1] == other.get_dim(0));

  Matrix result(dim[0], other.get_dim(1));

  for (size_t i = 0; i < dim[0]; ++i)
  {
    for (size_t j = 0; j < other.get_dim(1); ++j)
    {
      result.at(i, j) = 0;
      for (size_t k = 0; k < dim[1]; ++k)
      {
        result.at(i, j) += at(i, k) * other.at(k, j);
      }
    }
  }

  return result;
}
