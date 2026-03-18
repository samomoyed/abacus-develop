#!/bin/bash

SOURCE_DIR="source"
# 检查目录
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: $SOURCE_DIR not found."
    exit 1
fi

# 1. 建立文件列表和初步依赖表
declare -A dependencies
declare -A depths
all_files=$(find "$SOURCE_DIR" -type f \( -name "*.cpp" -o -name "*.h" \))

for file in $all_files; do
    # 提取 #include "..." 中的文件名（去掉路径，只保留文件名，方便匹配）
    # 如果项目路径复杂，这里可能需要根据实际 include 规范调整
    deps=$(grep '^#include "' "$file" | sed -E 's/.*"(.+)".*/\1/' | xargs -n1 basename 2>/dev/null)
    dependencies["$file"]="$deps"
    depths["$file"]=-1
done

# 2. 迭代计算深度
changed=true
while $changed; do
    changed=false
    for file in $all_files; do
        # 如果深度已经确定，跳过
        [ "${depths[$file]}" != -1 ] && continue

        max_d=-1
        ready=true
        has_internal_dep=false

        for dep in ${dependencies["$file"]}; do
            # 在所有文件中查找这个依赖文件
            dep_path=$(echo "$all_files" | grep -m1 "/$dep$")
            
            if [ -n "$dep_path" ]; then
                has_internal_dep=true
                if [ "${depths[$dep_path]}" == -1 ]; then
                    # 依赖的文件深度还没算出来
                    ready=false
                    break
                else
                    # 更新当前见到的最大深度
                    [ "${depths[$dep_path]}" -gt "$max_d" ] && max_d=${depths[$dep_path]}
                fi
            fi
        done

        if $ready; then
            if ! $has_internal_dep; then
                new_depth=0
            else
                new_depth=$((max_d + 1))
            fi
            
            if [ "${depths[$file]}" != "$new_depth" ]; then
                depths["$file"]=$new_depth
                changed=true
            fi
        fi
    done
done

# 3. 结果输出
echo "================ ABACUS Dependency Depth Analysis ================"

# 输出深度最大的文件
max_val=-1
max_file=""
leaf_files=""

for file in $all_files; do
    d=${depths[$file]}
    # 找最大深度
    if [ "$d" -gt "$max_val" ]; then
        max_val=$d
	max_file="$max_file $(basename $file)"
    fi
    # 深度为 0 的即为叶子文件（底层文件）
    if [ "$d" == 0 ]; then
        leaf_files="$leaf_files $(basename $file)"
    fi
done

echo "最大深度: $max_val"
echo "深度最大的文件: $max_file"
echo "------------------------------------------------------------------"
echo "叶子文件 (深度为 0):"
echo "$leaf_files" | tr ' ' '\n' | sort -u | column
echo "=================================================================="
