#!/bin/bash
shopt -s globstar
cd source
h_sum=0
cpp_sum=0
cpp_count=$(find . -name "*.cpp" | wc -l)
cpp_line=$(find . -name "*.cpp" | xargs wc -l | tail -n  1 | awk "{print $1}")
h_count=$(find . -name "*.h" | wc -l)
h_line=$(find . -name "*.h" | xargs wc -l | tail -n  1 | awk "{print $1}")
for file in ./**/*.cpp; do
	line=$(grep -E "^[[:space:]]*(\/\/|\/\*|\*)|.*\*\/[[:space:]]*$" "$file" |wc -l)
	cpp_sum=$((cpp_sum + line))
done
for file in ./**/*.h; do
	line=$(grep -E "^[[:space:]]*(\/\/|\/\*|\*)|.*\*\/[[:space:]]*$" "$file" |wc -l)
        h_sum=$((h_sum + line))
done
echo ".cpp文件数量:$cpp_count"
echo ".cpp总行数:$cpp_line"
echo ".cpp注释行数:$cpp_sum"
echo ".cpp注释率:$(awk "BEGIN {printf \"%.2f\", $cpp_sum * 100 / $cpp_line}")%"
echo ".h文件数量:$h_count"
echo ".h总行数:$h_line"
echo ".h注释行数:$h_sum"
echo ".h注释率:$(awk "BEGIN {printf \"%.2f\", $h_sum * 100 / $h_line}")%"
cd ..
