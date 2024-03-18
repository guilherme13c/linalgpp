#include "matrix.hpp"

cudaDeviceProp deviceProp;

Matrix::Matrix(void) {
    this->data = new float[1]();
    this->dim[0] = 0;
    this->dim[1] = 0;
}

Matrix::Matrix(size_t rows, size_t cols) {
    this->data = new float[rows * cols]();
    this->dim[0] = rows;
    this->dim[1] = cols;

    memset(this->data, 0, this->dim[0] * this->dim[1] * sizeof(float));
}

Matrix::Matrix(size_t rows, size_t cols,
               const std::initializer_list<float> &initList) {
    assert(initList.size() == rows * cols);

    this->data = new float[rows * cols]();
    this->dim[0] = rows;
    this->dim[1] = cols;

    memcpy(this->data, initList.begin(), sizeof(float) * rows * cols);
}

Matrix::Matrix(const Matrix &other) : dim{other.dim[0], other.dim[1]} {
    size_t totalElements = dim[0] * dim[1];
    data = new float[totalElements];
    memcpy(data, other.data, totalElements * sizeof(float));
}

Matrix::~Matrix(void) {
    if (this->data != nullptr) {
        delete[] this->data;
        this->data = nullptr;
    }
}

size_t Matrix::get_dim(size_t axis) const {
    assert(axis == 1 || axis == 0);
    return this->dim[axis];
}

float &Matrix::at(size_t row, size_t col) {
    assert(row < this->dim[0]);
    assert(col < this->dim[1]);

    return this->data[row * this->dim[1] + col];
}

float &Matrix::operator()(size_t row, size_t col) {
    return this->data[row * this->dim[1] + col];
}

float Matrix::read_at(size_t row, size_t col) const {
    assert(row < this->dim[0]);
    assert(col < this->dim[1]);

    return this->data[row * this->dim[1] + col];
}

void Matrix::randomize(PRNG &prng, float min, float max) {
    assert(this->data != nullptr);
    assert(this->dim[0] != 0 && this->dim[1] != 0);
    assert(max >= min);

    for (int i = 0; i < this->dim[0] * this->dim[1]; i++) {
        this->data[i] =
            (float)prng.generate() / prng.get_max() * (max - min) + min;
    }
}

void Matrix::fill(float value) {
    for (int i = 0; i < this->dim[0] * this->dim[1]; i++) {
        this->data[i] = value;
    }
}

Matrix Matrix::transpose(void) {
    Matrix transposed(this->dim[1], this->dim[0]);

    for (int i = 0; i < this->dim[0]; i++) {
        for (int j = 0; j < this->dim[1]; j++) {
            transposed(j, i) = (*this)(i, j);
        }
    }

    return transposed;
}

float Matrix::sum(void) {
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

    os.precision(3);
    os.fill(' ');

    os << "┌ ";
    for (int i = 0; i < m.get_dim(1); i++) {
        os << std::setw(6) << " ";
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
        os << std::setw(6) << " ";
    }
    os << "┘" << std::endl;

    os.flags(old_settings);

    return os;
}

void Matrix::assign(const Matrix &other) {
    this->dim[0] = other.dim[0];
    this->dim[1] = other.dim[1];

    if (this->data != nullptr)
        delete[] this->data;

    this->data = new float[this->dim[0] * this->dim[1]]();

    memcpy(this->data, other.data, this->dim[0] * this->dim[1] * sizeof(float));
}

__global__ void addKernel(float *matrix1, float *matrix2, float *result,
                          int rows, int cols) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < rows && j < cols) {
        result[i * cols + j] = matrix1[i * cols + j] + matrix2[i * cols + j];
    }
}

Matrix Matrix::add(Matrix &other) {
    assert(dim[0] == other.get_dim(0) && dim[1] == other.get_dim(1));

    Matrix result(dim[0], dim[1]);

    if (deviceProp.maxThreadsPerBlock > 0) {
        float *d_matrix1, *d_matrix2, *d_result;

        cudaMalloc(&d_matrix1, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_matrix2, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_result, dim[0] * dim[1] * sizeof(float));

        cudaMemcpy(d_matrix1, data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);
        cudaMemcpy(d_matrix2, other.data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);

        if (deviceProp.maxThreadsPerBlock <= 0) {
            cudaGetDeviceProperties(&deviceProp, 0);
        }

        dim3 blockSize(deviceProp.maxThreadsPerBlock, 1);
        dim3 gridSize((dim[0] + blockSize.x - 1) / blockSize.x,
                      (dim[1] + blockSize.y - 1) / blockSize.y);

        addKernel<<<gridSize, blockSize>>>(d_matrix1, d_matrix2, d_result,
                                           dim[0], dim[1]);

        cudaMemcpy(result.data, d_result, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyDeviceToHost);

        cudaFree(d_matrix1);
        cudaFree(d_matrix2);
        cudaFree(d_result);
    } else {
        for (size_t i = 0; i < dim[0]; ++i) {
            for (size_t j = 0; j < dim[1]; ++j) {
                result(i, j) = other(i, j) + (*this)(i, j);
            }
        }
    }

    return result;
}

__global__ void subKernel(float *matrix1, float *matrix2, float *result,
                          int rows, int cols) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < rows && j < cols) {
        result[i * cols + j] = matrix2[i * cols + j] - matrix1[i * cols + j];
    }
}

Matrix Matrix::sub(Matrix &other) {
    assert(dim[0] == other.get_dim(0) && dim[1] == other.get_dim(1));

    Matrix result(dim[0], dim[1]);

    if (deviceProp.maxThreadsPerBlock > 0) {
        float *d_matrix1, *d_matrix2, *d_result;

        cudaMalloc(&d_matrix1, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_matrix2, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_result, dim[0] * dim[1] * sizeof(float));

        cudaMemcpy(d_matrix1, data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);
        cudaMemcpy(d_matrix2, other.data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);

        if (deviceProp.maxThreadsPerBlock <= 0) {
            cudaGetDeviceProperties(&deviceProp, 0);
        }

        dim3 blockSize(deviceProp.maxThreadsPerBlock, 1);
        dim3 gridSize((dim[0] + blockSize.x - 1) / blockSize.x,
                      (dim[1] + blockSize.y - 1) / blockSize.y);

        subKernel<<<gridSize, blockSize>>>(d_matrix1, d_matrix2, d_result,
                                           dim[0], dim[1]);

        cudaMemcpy(result.data, d_result, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyDeviceToHost);

        cudaFree(d_matrix1);
        cudaFree(d_matrix2);
        cudaFree(d_result);
    } else {
        for (size_t i = 0; i < dim[0]; ++i) {
            for (size_t j = 0; j < dim[1]; ++j) {
                result(i, j) = other(i, j) - (*this)(i, j);
            }
        }
    }

    return result;
}

__global__ void mulKernel(float *matrix1, float *matrix2, float *result,
                          int rows1, int cols1, int cols2) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < rows1 && j < cols2) {
        float sum = 0.0f;
        for (int k = 0; k < cols1; ++k) {
            sum += matrix1[i * cols1 + k] * matrix2[k * cols2 + j];
        }
        result[i * cols2 + j] = sum;
    }
}

Matrix Matrix::mul(Matrix &other) {
    assert(dim[1] == other.get_dim(0));

    Matrix result(dim[0], other.get_dim(1));

    if (deviceProp.maxThreadsPerBlock > 0) {
        float *d_matrix1, *d_matrix2, *d_result;

        cudaMalloc(&d_matrix1, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_matrix2,
                   other.get_dim(0) * other.get_dim(1) * sizeof(float));
        cudaMalloc(&d_result, dim[0] * other.get_dim(1) * sizeof(float));

        cudaMemcpy(d_matrix1, data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);
        cudaMemcpy(d_matrix2, other.data,
                   other.get_dim(0) * other.get_dim(1) * sizeof(float),
                   cudaMemcpyHostToDevice);

        if (deviceProp.maxThreadsPerBlock <= 0) {
            cudaGetDeviceProperties(&deviceProp, 0);
        }

        dim3 blockSize(deviceProp.maxThreadsPerBlock, 1);
        dim3 gridSize((dim[0] + blockSize.x - 1) / blockSize.x,
                      (other.get_dim(1) + blockSize.y - 1) / blockSize.y);

        mulKernel<<<gridSize, blockSize>>>(d_matrix1, d_matrix2, d_result,
                                           dim[0], dim[1], other.get_dim(1));

        cudaMemcpy(result.data, d_result,
                   dim[0] * other.get_dim(1) * sizeof(float),
                   cudaMemcpyDeviceToHost);

        cudaFree(d_matrix1);
        cudaFree(d_matrix2);
        cudaFree(d_result);
    } else {
        for (size_t i = 0; i < dim[0]; ++i) {
            for (size_t j = 0; j < other.get_dim(1); ++j) {
                result(i, j) = 0;
                for (size_t k = 0; k < dim[1]; ++k) {
                    result(i, j) += (*this)(i, k) * other(k, j);
                }
            }
        }
    }

    return result;
}

__global__ void mulScalarKernel(float *matrix, float scalar, float *result,
                                int rows, int cols) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < rows && j < cols) {
        result[i * cols + j] = matrix[i * cols + j] * scalar;
    }
}

Matrix Matrix::mul(float a) {
    if (deviceProp.maxThreadsPerBlock > 0) {
        Matrix result(dim[0], dim[1]);
        float *d_matrix, *d_result;

        cudaMalloc(&d_matrix, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_result, dim[0] * dim[1] * sizeof(float));

        cudaMemcpy(d_matrix, data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);

        if (deviceProp.maxThreadsPerBlock <= 0) {
            cudaGetDeviceProperties(&deviceProp, 0);
        }

        dim3 blockSize(deviceProp.maxThreadsPerBlock, 1);
        dim3 gridSize((dim[0] + blockSize.x - 1) / blockSize.x,
                      (dim[1] + blockSize.y - 1) / blockSize.y);

        mulScalarKernel<<<gridSize, blockSize>>>(d_matrix, a, d_result, dim[0],
                                                 dim[1]);

        cudaMemcpy(result.data, d_result, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyDeviceToHost);

        cudaFree(d_matrix);
        cudaFree(d_result);

        return result;
    } else {
        Matrix result(*this);

        for (size_t i = 0; i < dim[0]; ++i) {
            for (size_t j = 0; j < dim[1]; ++j) {
                result(i, j) *= a;
            }
        }
        return result;
    }
}

__global__ void hadamardKernel(float *matrix1, float *matrix2, float *result,
                               int rows, int cols) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < rows && j < cols) {
        result[i * cols + j] = matrix1[i * cols + j] * matrix2[i * cols + j];
    }
}

Matrix Matrix::hadamard(Matrix &other) {
    assert(dim[0] == other.dim[0] && dim[1] == other.dim[1]);

    Matrix result(dim[0], dim[1]);

    if (deviceProp.maxThreadsPerBlock > 0) {
        float *d_matrix1, *d_matrix2, *d_result;

        cudaMalloc(&d_matrix1, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_matrix2, other.dim[0] * other.dim[1] * sizeof(float));
        cudaMalloc(&d_result, dim[0] * dim[1] * sizeof(float));

        cudaMemcpy(d_matrix1, data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);
        cudaMemcpy(d_matrix2, other.data,
                   other.dim[0] * other.dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);

        if (deviceProp.maxThreadsPerBlock <= 0) {
            cudaGetDeviceProperties(&deviceProp, 0);
        }

        dim3 blockSize(deviceProp.maxThreadsPerBlock, 1);
        dim3 gridSize((dim[0] + blockSize.x - 1) / blockSize.x,
                      (dim[1] + blockSize.y - 1) / blockSize.y);

        hadamardKernel<<<gridSize, blockSize>>>(d_matrix1, d_matrix2, d_result,
                                                dim[0], dim[1]);

        cudaMemcpy(result.data, d_result, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyDeviceToHost);

        cudaFree(d_matrix1);
        cudaFree(d_matrix2);
        cudaFree(d_result);
    } else {
        for (size_t i = 0; i < this->dim[0]; i++) {
            for (size_t j = 0; j < this->dim[1]; j++) {
                result(i, j) = this->at(i, j) * other.at(i, j);
            }
        }
    }

    return result;
}

__global__ void applyKernel(float *matrix, float *result, int rows, int cols,
                            float (*f)(float)) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    if (i < rows && j < cols) {
        result[i * cols + j] = f(matrix[i * cols + j]);
    }
}

Matrix Matrix::apply(float (*f)(float)) {
    Matrix result(dim[0], dim[1]);

    if (deviceProp.maxThreadsPerBlock) {
        float *d_matrix, *d_result;

        cudaMalloc(&d_matrix, dim[0] * dim[1] * sizeof(float));
        cudaMalloc(&d_result, dim[0] * dim[1] * sizeof(float));

        cudaMemcpy(d_matrix, data, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyHostToDevice);

        if (deviceProp.maxThreadsPerBlock <= 0) {
            cudaGetDeviceProperties(&deviceProp, 0);
        }

        dim3 blockSize(deviceProp.maxThreadsPerBlock, 1);
        dim3 gridSize((dim[0] + blockSize.x - 1) / blockSize.x,
                      (dim[1] + blockSize.y - 1) / blockSize.y);

        applyKernel<<<gridSize, blockSize>>>(d_matrix, d_result, dim[0], dim[1],
                                             f);

        cudaMemcpy(result.data, d_result, dim[0] * dim[1] * sizeof(float),
                   cudaMemcpyDeviceToHost);

        cudaFree(d_matrix);
        cudaFree(d_result);
    } else {
        for (size_t i = 0; i < dim[0]; ++i) {
            for (size_t j = 0; j < dim[1]; ++j) {
                result(i, j) = f((*this)(i, j));
            }
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

Matrix &Matrix::operator=(const Matrix &other) {
    if (this != &other) {
        this->assign(other);
    }
    return (*this);
}

Matrix Matrix::operator+(Matrix &other) { return this->add(other); }

Matrix Matrix::operator-(Matrix &other) { return this->sub(other); }

Matrix Matrix::operator*(Matrix &other) { return this->mul(other); }

Matrix Matrix::operator*(float a) { return this->mul(a); }

Matrix &Matrix::operator+=(Matrix &other) {
    (*this) = this->add(other);
    return (*this);
}

Matrix &Matrix::operator-=(Matrix &other) {
    (*this) = this->sub(other);
    return (*this);
}

Matrix &Matrix::operator*=(Matrix &other) {
    (*this) = this->mul(other);
    return (*this);
}

Matrix &Matrix::operator*=(float a) {
    (*this) = this->mul(a);

    return (*this);
}

void Matrix::save(const char *filename) {
    std::ofstream fp(filename, std::ios::binary | std::ios::out);

    if (fp.is_open()) {
        fp.write(reinterpret_cast<const char *>(&(this->dim[0])),
                 sizeof(size_t));
        fp.write(reinterpret_cast<const char *>(&(this->dim[1])),
                 sizeof(size_t));

        fp.write(reinterpret_cast<const char *>(data),
                 dim[0] * dim[1] * sizeof(float));

        fp.close();
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
        abort();
    }
}

void Matrix::load(const char *filename) {
    std::ifstream fp(filename, std::ios::in | std::ios::binary);

    if (fp.is_open()) {
        fp.read(reinterpret_cast<char *>(&(this->dim[1])), sizeof(size_t));
        fp.read(reinterpret_cast<char *>(&(this->dim[0])), sizeof(size_t));

        if (this->data) {
            delete[] this->data;
            this->data = nullptr;
        }
        this->data = new float[this->dim[0] * this->dim[1]]();

        fp.read(reinterpret_cast<char *>(this->data),
                this->dim[0] * this->dim[1] * sizeof(float));

        fp.close();
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
        abort();
    }
}

float Matrix::trace(void) {
    assert(this->dim[0] == this->dim[1]);

    float ret = 0.0f;
    for (size_t i = 0; i < this->dim[0]; i++) {
        ret += (*this)(i, i);
    }

    return ret;
}
