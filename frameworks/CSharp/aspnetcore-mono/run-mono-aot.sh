#!/bin/bash
for filename in ./*.dll; do
    [ -e "$file" ] || continue

    mono --aot=llvm "$filename"
done

mono --aot=llvm PlatformBenchmarks.exe