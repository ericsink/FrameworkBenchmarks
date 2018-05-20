#!/bin/bash
for filename in ./*.dll; do
    [ -e "$filename" ] || continue

    mono --aot=llvm "$filename"
done

mono --aot=llvm PlatformBenchmarks.exe