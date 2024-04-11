#! /bin/bash

testdir="test"
if [[ ! -d "$testdir" ]]; then
    echo "No test directory" >&2
    exit 1
fi

srcdir="${testdir}/src"
mkdir -p "$srcdir"

bindir="${testdir}/bin"
mkdir -p "$bindir"

logdir="${testdir}/log"
mkdir -p "$logdir"

for f in "$srcdir"/*; do
    b=$(basename "$f")
    b="${b%.*}"
    echo g++ "$f" -std=c++20 -o "$bindir/$b" -Llib -llinalg -Iinc -L/usr/local/cuda-12.4/lib64 -lcudart -I/usr/local/cuda-12.4/include
    g++ "$f" -std=c++20 -o "$bindir/$b" -Llib -llinalg -Iinc -L/usr/local/cuda-12.4/lib64 -lcudart -I/usr/local/cuda-12.4/include
done

exit 0
