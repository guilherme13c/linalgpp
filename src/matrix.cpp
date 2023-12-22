#include "matrix.hpp"
#include <iomanip>

Matrix::Matrix() {
    this->data = nullptr;
    this->dim[0] = 0;
    this->dim[1] = 0;
}

Matrix::Matrix(size_t rows, size_t cols) {
    this->data = new float[rows * cols];
    this->dim[0] = rows;
    this->dim[1] = cols;
}

Matrix::~Matrix() { delete this->data; }

size_t Matrix::get_dim(size_t axis) const { return this->dim[axis]; }

float &Matrix::at(size_t row, size_t col) {
    assert(row >= 0 || row < this->dim[0]);
    assert(col >= 0 || col < this->dim[1]);

    return this->data[row * this->dim[1] + col];
}

float &Matrix::operator()(size_t row, size_t col) {
    return this->data[row * this->dim[1] + col];
}

float Matrix::read_at(size_t row, size_t col) const {
    assert(row >= 0 || row < this->dim[0]);
    assert(col >= 0 || col < this->dim[1]);

    return this->data[row * this->dim[1] + col];
}

void Matrix::randomize(PRNG &prng, float min, float max) {
    assert(max >= min);

    for (int i = 0; i < this->dim[0] * this->dim[1]; i++) {
        this->data[i] =
            (float)prng.generate() / prng.get_max() * (max - min) + min;
    }
}

void Matrix::fill(float value) {
    for (int i = 0; i < this->dim[0]; i++) {
        for (int j = 0; j < this->dim[1]; j++) {
            (*this)(i, j) = value;
        }
    }
}

void Matrix::transpose() {
    float *transposed = new float[this->dim[0] * this->dim[1]];

    for (int i = 0; i < this->dim[0]; i++) {
        for (int j = 0; j < this->dim[1]; j++) {
            transposed[j * this->dim[0] + i] = (*this)(i, j);
        }
    }

    std::swap(this->dim[0], this->dim[1]);

    delete[] this->data;
    this->data = transposed;
}

float Matrix::sum() {
    float total = 0.0f;
    for (int i = 0; i < this->dim[0]; i++) {
        for (int j = 0; j < this->dim[1]; j++) {
            total += (*this)(i, j);
        }
    }

    return total;
}

std::ostream &operator<<(std::ostream &os, const Matrix &m) {
    assert(m.get_dim(0) != 0 && m.get_dim(1) != 0);

    std::ios::fmtflags old_settings = os.flags();

    os.precision(5);
    os.fill(' ');
    os.setf(std::ios::fixed, std::ios::floatfield);

    os << "┌ ";
    for (int i = 0; i < m.get_dim(1); i++) {
        os << std::setw(8) << " ";
    }
    os << "┐" << std::endl;

    for (int l = 0; l < m.get_dim(0); l++) {
        os << "│ ";
        for (int c = 0; c < m.get_dim(1); c++) {
            os << std::setw(5) << m.read_at(l, c) << " ";
        }
        os << "│" << std::endl;
    }

    os << "└ ";
    for (int i = 0; i < m.get_dim(1); i++) {
        os << std::setw(8) << " ";
    }
    os << "┘" << std::endl;

    os.flags(old_settings);

    return os;
}
