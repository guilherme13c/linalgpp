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

for f in "$bindir"/*; do
    b=$(basename "$f")
    b="${b%.*}"
    blog="$logdir/$b.log"
    ./"$bindir/$b" > "$blog"
done

exit 0
