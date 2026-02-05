# Rust 实战开发指南

基于 Sphinx 构建的 Rust 开发文档，专注于：

- **易错和易忽略的知识点**
- **Rust 相比其他语言的特殊之处**
- **从 C++/Java 程序员视角快速入门**
- **并发、性能调优、内存管理、网络编程**

## 快速开始

### 安装依赖

```bash
# 进入文档目录
cd doc

# 安装 Python 依赖
pip install -r requirements.txt
```

### 构建文档

```bash
# 构建 HTML
make html

# 或者快速构建
make quick

# 清理构建文件
make clean-all
```

### 查看文档

```bash
# 构建并启动本地服务器
make dev

# 或者单独启动服务器
make serve
```

然后在浏览器中打开 http://localhost:8000

### 实时预览（推荐开发时使用）

```bash
# 需要先安装 sphinx-autobuild
pip install sphinx-autobuild

# 启动实时预览
make livehtml
```

## 文档结构

```
doc/
├── Makefile            # 构建脚本
├── requirements.txt    # Python 依赖
└── source/
    ├── conf.py         # Sphinx 配置
    ├── index.rst       # 主页
    ├── 1.basic/        # 基础与所有权
    ├── 2.concurrency/  # 并发编程
    ├── 3.performance/  # 性能调优
    ├── 4.memory/       # 内存管理
    ├── 5.network/      # 网络编程
    ├── 6.library/      # 常用库
    └── 7.cheatsheet/   # 速查表
```

## 内容概览

| 章节 | 主题 | 目标读者 |
|------|------|---------|
| 1. 基础与所有权 | 所有权、借用、生命周期、Trait | 所有人 |
| 2. 并发编程 | 线程、Channel、async/await、Tokio | 需要并发的开发者 |
| 3. 性能调优 | 零成本抽象、Profiling、基准测试 | 性能敏感场景 |
| 4. 内存管理 | 智能指针、内部可变性、unsafe | 系统编程者 |
| 5. 网络编程 | TCP/UDP、HTTP、WebSocket | 网络应用开发者 |
| 6. 常用库 | serde、tokio、clap、tracing | 所有人 |
| 7. 速查表 | 语法、集合、迭代器 | 快速参考 |

## 贡献

欢迎提交 PR 改进文档！

1. Fork 仓库
2. 创建特性分支
3. 提交更改
4. 发起 Pull Request

## 许可证

本文档采用 [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) 许可证。
