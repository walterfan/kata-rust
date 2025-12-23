#!/bin/bash

# 21天 Rust 实战教程 - 运行脚本
# 用法: 
#   ./run_kata.sh          # 列出所有可用的 Rust 程序
#   ./run_kata.sh day01    # 运行 day01 目录下所有程序
#   ./run_kata.sh day01/hello_rust.rs  # 运行指定文件
#   ./run_kata.sh all      # 运行所有程序

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KATA_DIR="${SCRIPT_DIR}/kata"
BUILD_DIR="${SCRIPT_DIR}/.build"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 创建构建目录
mkdir -p "${BUILD_DIR}"

# 打印帮助信息
print_help() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}       ${YELLOW}🦀 21天 Rust 实战教程 - 运行脚本${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}用法:${NC}"
    echo "  $0                         列出所有可用的 Rust 程序"
    echo "  $0 list                    列出所有可用的 Rust 程序"
    echo "  $0 day01                   运行 day01 目录下所有程序"
    echo "  $0 day01/hello_rust.rs     运行指定文件"
    echo "  $0 all                     运行所有程序"
    echo "  $0 clean                   清理构建文件"
    echo "  $0 help                    显示此帮助信息"
    echo ""
}

# 列出所有 Rust 程序
list_programs() {
    echo -e "${CYAN}📚 可用的 Rust 程序:${NC}"
    echo ""
    
    for day_dir in "${KATA_DIR}"/day*; do
        if [ -d "$day_dir" ]; then
            day_name=$(basename "$day_dir")
            echo -e "${YELLOW}📁 ${day_name}/${NC}"
            
            for rs_file in "${day_dir}"/*.rs; do
                if [ -f "$rs_file" ]; then
                    file_name=$(basename "$rs_file")
                    echo -e "   ${GREEN}├── ${file_name}${NC}"
                fi
            done
            echo ""
        fi
    done
}

# 编译并运行单个 Rust 文件
run_rust_file() {
    local rs_file="$1"
    local file_name=$(basename "$rs_file" .rs)
    local output_file="${BUILD_DIR}/${file_name}"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📄 编译: ${rs_file}${NC}"
    
    if rustc "$rs_file" -o "$output_file" 2>&1; then
        echo -e "${GREEN}✅ 编译成功！${NC}"
        echo -e "${CYAN}🚀 运行输出:${NC}"
        echo ""
        "$output_file"
        echo ""
        echo -e "${GREEN}✅ 运行完成！${NC}"
        return 0
    else
        echo -e "${RED}❌ 编译失败！${NC}"
        return 1
    fi
}

# 运行指定目录下的所有 Rust 程序
run_day() {
    local day="$1"
    local day_dir="${KATA_DIR}/${day}"
    
    if [ ! -d "$day_dir" ]; then
        echo -e "${RED}❌ 错误: 目录 '${day}' 不存在${NC}"
        echo -e "${YELLOW}提示: 使用 '$0 list' 查看可用的目录${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}🏃 运行 ${day} 的所有程序...${NC}"
    echo ""
    
    local count=0
    local success=0
    local failed=0
    
    for rs_file in "${day_dir}"/*.rs; do
        if [ -f "$rs_file" ]; then
            ((count++))
            if run_rust_file "$rs_file"; then
                ((success++))
            else
                ((failed++))
            fi
            echo ""
        fi
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 统计: 共 ${count} 个程序, ${GREEN}成功 ${success}${NC}, ${RED}失败 ${failed}${NC}"
}

# 运行所有程序
run_all() {
    echo -e "${CYAN}🏃 运行所有 Rust 程序...${NC}"
    echo ""
    
    local total=0
    local success=0
    local failed=0
    
    for day_dir in "${KATA_DIR}"/day*; do
        if [ -d "$day_dir" ]; then
            day_name=$(basename "$day_dir")
            echo -e "${YELLOW}📁 ${day_name}/${NC}"
            echo ""
            
            for rs_file in "${day_dir}"/*.rs; do
                if [ -f "$rs_file" ]; then
                    ((total++))
                    if run_rust_file "$rs_file"; then
                        ((success++))
                    else
                        ((failed++))
                    fi
                    echo ""
                fi
            done
        fi
    done
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 总计: 共 ${total} 个程序, ${GREEN}成功 ${success}${NC}, ${RED}失败 ${failed}${NC}"
}

# 清理构建文件
clean() {
    echo -e "${YELLOW}🧹 清理构建文件...${NC}"
    rm -rf "${BUILD_DIR}"
    echo -e "${GREEN}✅ 清理完成！${NC}"
}

# 主逻辑
main() {
    if [ $# -eq 0 ]; then
        print_help
        list_programs
        exit 0
    fi
    
    case "$1" in
        help|-h|--help)
            print_help
            ;;
        list)
            list_programs
            ;;
        clean)
            clean
            ;;
        all)
            run_all
            ;;
        day*)
            if [[ "$1" == *".rs" ]]; then
                # 运行指定文件 (如 day01/hello_rust.rs)
                rs_file="${KATA_DIR}/$1"
                if [ -f "$rs_file" ]; then
                    run_rust_file "$rs_file"
                else
                    echo -e "${RED}❌ 错误: 文件 '$1' 不存在${NC}"
                    exit 1
                fi
            else
                # 运行指定目录 (如 day01)
                run_day "$1"
            fi
            ;;
        *)
            echo -e "${RED}❌ 未知命令: $1${NC}"
            echo ""
            print_help
            exit 1
            ;;
    esac
}

main "$@"

