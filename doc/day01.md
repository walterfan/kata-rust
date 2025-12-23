# 第1天：Rust 简介与环境搭建

## 🎯 今日目标

- 了解 Rust 语言的特点和优势
- 安装 Rust 开发环境
- 创建第一个 Rust 程序
- 熟悉 Cargo 包管理器

## 🦀 Rust 语言简介

Rust 是由 Mozilla 研究院开发的一种系统编程语言，它具有以下特点：

### ✨ 核心特性
- **内存安全**：编译时检查，防止空指针、悬垂引用等内存错误
- **零成本抽象**：高级抽象不会带来运行时性能损失
- **并发安全**：编译时保证线程安全，避免数据竞争
- **高性能**：性能接近 C/C++，没有垃圾回收器
- **现代语法**：支持模式匹配、闭包、迭代器等现代语言特性

### 🚀 适用场景
- 系统编程（操作系统、驱动程序）
- Web 服务后端
- 嵌入式开发
- 游戏引擎
- 命令行工具

## 🛠️ 环境搭建

### 1. 安装 Rust

#### Windows
访问 [https://rustup.rs/](https://rustup.rs/) 下载 `rustup-init.exe`

#### macOS/Linux
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 2. 配置环境变量
安装完成后，需要配置环境变量：

```bash
# 重新加载 shell 配置
source ~/.bashrc  # Linux
source ~/.zshrc   # macOS
```

### 3. 验证安装
```bash
rustc --version
cargo --version
```

你应该看到类似输出：
```
rustc 1.70.0 (90c541806 2023-05-31)
cargo 1.70.0 (ec8a8a0ca 2022-06-13)
```

## 🚀 第一个 Rust 程序

### 1. 使用 Cargo 创建项目
```bash
cargo new hello_rust
cd hello_rust
```

### 2. 项目结构
```
hello_rust/
├── Cargo.toml      # 项目配置文件
└── src/
    └── main.rs     # 主程序文件
```

### 3. 查看 main.rs
```rust
fn main() {
    println!("Hello, world!");
}
```

### 4. 运行程序
```bash
cargo run
```

输出：`Hello, world!`

## 📦 Cargo 包管理器

Cargo 是 Rust 的官方包管理器和构建工具，类似于 Node.js 的 npm 或 Python 的 pip。

### 常用命令

| 命令 | 说明 |
|------|------|
| `cargo new <project_name>` | 创建新项目 |
| `cargo build` | 编译项目 |
| `cargo run` | 编译并运行项目 |
| `cargo check` | 检查代码（不生成可执行文件） |
| `cargo test` | 运行测试 |
| `cargo doc` | 生成文档 |
| `cargo add <dependency>` | 添加依赖 |

### Cargo.toml 文件解析
```toml
[package]
name = "hello_rust"           # 项目名称
version = "0.1.0"             # 版本号
edition = "2021"              # Rust 版本

[dependencies]
# 这里可以添加项目依赖
```

## 💻 动手实践

### 练习 1：修改 Hello World
修改 `main.rs` 文件，让程序输出你的名字：

```rust
fn main() {
    let name = "你的名字";
    println!("你好，{}！欢迎学习 Rust！", name);
}
```

### 练习 2：创建计算器项目
```bash
cargo new calculator
cd calculator
```

在 `src/main.rs` 中添加：
```rust
fn main() {
    let a = 10;
    let b = 5;
    
    println!("{} + {} = {}", a, b, a + b);
    println!("{} - {} = {}", a, b, a - b);
    println!("{} * {} = {}", a, b, a * b);
    println!("{} / {} = {}", a, b, a / b);
}
```

## 🔍 代码解释

### 函数定义
```rust
fn main() {
    // 函数体
}
```
- `fn` 是函数声明关键字
- `main` 是函数名，程序入口点
- `()` 是参数列表（这里为空）
- `{}` 是函数体

### println! 宏
```rust
println!("Hello, world!");
```
- `println!` 是宏（注意感叹号）
- 宏在编译时展开，提供格式化输出功能
- 字符串用双引号包围

### 变量声明
```rust
let name = "Rust";
```
- `let` 声明不可变变量
- Rust 支持类型推断
- 变量默认不可变

## 📚 今日总结

今天我们学习了：
1. ✅ Rust 语言的特点和优势
2. ✅ 安装和配置 Rust 开发环境
3. ✅ 创建第一个 Rust 程序
4. ✅ 使用 Cargo 管理项目
5. ✅ 基本的 Rust 语法

## 🎯 明日预告

明天我们将学习 Rust 的变量和数据类型，包括：
- 变量的可变性
- 基本数据类型
- 类型注解
- 常量和静态变量

## 💡 小贴士

- 使用 `cargo check` 可以快速检查代码错误，比 `cargo build` 更快
- 在开发过程中，可以同时运行 `cargo check` 和 `cargo run`
- Rust 的错误信息非常详细，仔细阅读错误信息有助于快速定位问题

---

**恭喜你完成了第一天的学习！明天见！** 🎉
