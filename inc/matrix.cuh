#pragma once

#include <cassert>
#include <cstdlib>
#include <cstring>
#include <dlfcn.h>
#include <fstream>
#include <initializer_list>
#include <iomanip>
#include <iostream>

#include "rand.hpp"

#include <cuda_runtime.h>

class Matrix {
  private:
    float *data;
    size_t dim[2];

  public:
    Matrix(void);
    Matrix(size_t rows, size_t cols);
    Matrix(size_t rows, size_t cols, const std::initializer_list<float> &data);
    Matrix(const Matrix &other);

    ~Matrix(void);

    size_t get_dim(size_t axis) const;
    float &at(size_t row, size_t col);
    float read_at(size_t row, size_t col) const;
    void randomize(PRNG &prng, float min = 0, float max = 1);
    void fill(float value);

    Matrix transpose(void);

    void assign(const Matrix &other);
    Matrix add(Matrix &other);
    Matrix sub(Matrix &other);
    Matrix mul(Matrix &other);
    Matrix mul(float a);
    Matrix hadamard(Matrix &other);

    Matrix apply(float (*f)(float));

    float sum(void);
    float trace(void);

    Matrix expand(Matrix &other, size_t axis = 0);
    Matrix extract(size_t row0, size_t row1, size_t col0, size_t col1);

    float &operator()(size_t row, size_t col);

    Matrix &operator=(const Matrix &other);
    Matrix operator+(Matrix &other);
    Matrix operator-(Matrix &other);
    Matrix operator*(Matrix &other);
    Matrix operator*(float a);

    Matrix &operator+=(Matrix &other);
    Matrix &operator-=(Matrix &other);
    Matrix &operator*=(Matrix &other);
    Matrix &operator*=(float a);

    void save(const char *filename);
    void load(const char *filename);

    friend std::ostream &operator<<(std::ostream &os, const Matrix &m);
};
