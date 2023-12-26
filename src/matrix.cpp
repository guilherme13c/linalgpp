#include "matrix.hpp"

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

Matrix::Matrix(size_t rows, size_t cols,
               const std::initializer_list<float> &initList) {
    assert(initList.size() == rows * cols);

    this->data = new float[rows * cols];
    this->dim[0] = rows;
    this->dim[1] = cols;

    std::memcpy(this->data, initList.begin(), sizeof(float) * rows * cols);
}

Matrix::~Matrix() { delete[] this->data; }

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

Matrix Matrix::add(Matrix &other) {
    assert(dim[0] == other.get_dim(0) && dim[1] == other.get_dim(1));

    Matrix result(dim[0], dim[1]);

    for (size_t i = 0; i < dim[0]; ++i) {
        for (size_t j = 0; j < dim[1]; ++j) {
            result(i, j) += other(i, j);
        }
    }

    return result;
}

Matrix Matrix::sub(Matrix &other) {
    assert(dim[0] == other.get_dim(0) && dim[1] == other.get_dim(1));

    Matrix result(dim[0], dim[1]);

    for (size_t i = 0; i < dim[0]; ++i) {
        for (size_t j = 0; j < dim[1]; ++j) {
            result(i, j) -= other(i, j);
        }
    }

    return result;
}

Matrix Matrix::mul(Matrix &other) {
    assert(dim[1] == other.get_dim(0));

    Matrix result(dim[0], other.get_dim(1));

    for (size_t i = 0; i < dim[0]; ++i) {
        for (size_t j = 0; j < other.get_dim(1); ++j) {
            result(i, j) = 0;
            for (size_t k = 0; k < dim[1]; ++k) {
                result(i, j) += (*this)(i, k) * other(k, j);
            }
        }
    }

    return result;
}

Matrix Matrix::mul(float a) {
    Matrix result(dim[0], dim[1]);

    for (size_t i = 0; i < dim[0]; ++i) {
        for (size_t j = 0; j < dim[1]; ++j) {
            result(i, j) *= a;
        }
    }

    return result;
}

Matrix Matrix::apply(float (*f)(float)) {
    Matrix result(dim[0], dim[1]);

    for (size_t i = 0; i < dim[0]; ++i) {
        for (size_t j = 0; j < dim[1]; ++j) {
            result(i, j) = f((*this)(i, j));
        }
    }

    return result;
}

Matrix Matrix::expand(Matrix &other, size_t axis) {
    assert(axis == 0 || axis == 1);

    size_t nrows = 0, ncols = 0;

    if (axis == 0) {
        assert(other.dim[1] == dim[1]);

        nrows = dim[0] + other.dim[0];
        ncols = dim[1];
    } else // axis == 1
    {
        assert(other.dim[0] == dim[0]);

        nrows = dim[0];
        ncols = dim[1] + other.dim[1];
    }

    Matrix result(nrows, ncols);

    for (size_t i = 0; i < dim[0]; ++i) {
        for (size_t j = 0; j < dim[1]; ++j) {
            result(i, j) = (*this)(i, j);
        }
    }

    if (axis == 0) {
        for (size_t i = dim[0]; i < nrows; ++i) {
            for (size_t j = 0; j < ncols; ++j) {
                result(i, j) = other(i - dim[0], j);
            }
        }
    } else // axis == 1
    {
        for (size_t i = 0; i < nrows; ++i) {
            for (size_t j = dim[1]; j < ncols; ++j) {
                result(i, j) = other(i, j - dim[1]);
            }
        }
    }

    return result;
}

Matrix Matrix::extract(size_t row0, size_t row1, size_t col0, size_t col1) {
    assert(row1 > row0 && col1 > col0);

    Matrix result(row1 - row0, col1 - col0);

    for (size_t i = 0; i < row1 - row0; ++i) {
        for (size_t j = 0; j < col1 - col0; ++j) {
            result(i, j) = (*this)(row0 + i, col0 + j);
        }
    }

    return result;
}

Matrix Matrix::operator+(Matrix &other) { return this->add(other); }

Matrix Matrix::operator-(Matrix &other) { return this->sub(other); }

Matrix Matrix::operator*(Matrix &other) { return this->mul(other); }

Matrix Matrix::operator*(float a) { return this->mul(a); }
