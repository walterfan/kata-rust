# Rust 语言概览

## 为什么选择 Rust？

Rust 是一门专注于 **安全**、**并发** 和 **性能** 的系统编程语言。

### Rust 的核心承诺

1. **内存安全**：没有空指针、悬垂指针、数据竞争
2. **零成本抽象**：高级抽象不会带来运行时开销
3. **并发安全**：类型系统保证线程安全

## C++/Java 程序员需要知道的

### 与 C++ 的主要区别

| 特性 | C++ | Rust |
|------|-----|------|
| 内存管理 | 手动/智能指针 | 所有权系统 |
| 空指针 | nullptr | Option<T> |
| 异常处理 | try/catch | Result<T, E> |
| 继承 | 类继承 | Trait 组合 |
| 头文件 | 需要 .h | 模块系统 |
| 编译检查 | 部分检查 | 严格的借用检查 |

### 与 Java 的主要区别

| 特性 | Java | Rust |
|------|------|------|
| 内存管理 | GC | 所有权系统 |
| 空值 | null | Option<T> |
| 异常 | Exception | Result<T, E> |
| 多态 | 接口/继承 | Trait |
| 泛型 | 类型擦除 | 单态化 |

## Hello, Rust!

```rust
fn main() {
    println!("Hello, Rust!");
    
    // 不可变绑定（默认）
    let x = 5;
    // x = 6;  // 错误！不可变
    
    // 可变绑定
    let mut y = 5;
    y = 6;  // OK
    
    // 类型推断
    let z: i32 = 10;
    
    println!("x = {}, y = {}, z = {}", x, y, z);
}
```

## 基本数据类型

### 标量类型

```rust
// 整数类型
let a: i8 = -128;
let b: u8 = 255;
let c: i32 = 100_000;  // 可以用下划线提高可读性
let d: i64 = 1_000_000_000;
let e: isize = 100;    // 平台相关大小

// 浮点数
let f: f32 = 3.14;
let g: f64 = 2.71828;

// 布尔
let t: bool = true;

// 字符（4字节 Unicode）
let ch: char = '中';
```

### 复合类型

```rust
// 元组 - 固定长度，可以包含不同类型
let tup: (i32, f64, char) = (500, 6.4, '中');
let (x, y, z) = tup;  // 解构
let first = tup.0;     // 索引访问

// 数组 - 固定长度，相同类型，栈上分配
let arr: [i32; 5] = [1, 2, 3, 4, 5];
let first = arr[0];

// 切片 - 数组的视图
let slice: &[i32] = &arr[1..3];
```

## 控制流

```rust
fn main() {
    let number = 6;
    
    // if 表达式（不是语句！）
    let result = if number > 5 {
        "大于5"
    } else {
        "小于等于5"
    };
    
    // loop - 无限循环
    let mut counter = 0;
    let result = loop {
        counter += 1;
        if counter == 10 {
            break counter * 2;  // 可以返回值
        }
    };
    
    // while 循环
    while counter > 0 {
        counter -= 1;
    }
    
    // for 循环 - 最常用
    for i in 0..5 {
        println!("{}", i);
    }
    
    // 迭代集合
    let arr = [10, 20, 30];
    for element in arr.iter() {
        println!("{}", element);
    }
}
```

## 函数

```rust
// 函数定义
fn add(x: i32, y: i32) -> i32 {
    x + y  // 没有分号，作为返回值
}

// 提前返回使用 return
fn early_return(x: i32) -> i32 {
    if x < 0 {
        return 0;
    }
    x * 2
}

// 不返回值的函数返回 unit 类型 ()
fn print_hello() {
    println!("Hello");
}
```

## 易错点

```{warning}
**整数溢出**：在 debug 模式下会 panic，release 模式下会 wrap。
使用 `wrapping_*`、`checked_*`、`overflowing_*` 方法明确行为。
```

```{warning}
**默认不可变**：与 C++/Java 不同，Rust 变量默认不可变。
忘记加 `mut` 是初学者最常见的编译错误。
```

```{tip}
**Shadowing**：可以重新声明同名变量，甚至可以改变类型：

let x = "hello";
let x = x.len();  // 合法！x 现在是 usize 类型
```
