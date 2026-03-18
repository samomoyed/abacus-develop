#!/bin/bash
cd source
cpp_count=$(find . -name "*.cpp" | wc -l)
cpp_line=$(find . -name "*.cpp" | xargs wc -l | tail -n  1 | awk "{print $1}")
h_count=$(find . -name "*.h" | wc -l)
h_line=$(find . -name "*.h" | xargs wc -l | tail -n  1 | awk "{print $1}")
echo ".cpp文件数量:$cpp_count"
echo ".cpp总行数:$cpp_line"
echo ".h文件数量:$h_count"
echo ".h总行数:$h_line"
cd ..
