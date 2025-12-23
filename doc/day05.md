# 第5天：所有权系统（上）

## 🎯 今日目标

- 理解 Rust 所有权系统的核心概念
- 掌握移动语义
- 学会避免常见的所有权错误
- 了解栈和堆的区别

## 🧠 所有权系统概述

Rust 的所有权系统是其最独特的特性，它通过编译时检查来保证内存安全，无需垃圾回收器。

### 为什么需要所有权系统？

传统语言的内存管理问题：
- **C/C++**：手动管理内存，容易产生内存泄漏、悬垂指针
- **Java/Python**：垃圾回收器，运行时开销大，无法保证内存安全
- **Rust**：编译时检查，零运行时开销，保证内存安全

### 所有权规则

Rust 的所有权系统基于三个核心规则：

1. **每个值都有一个所有者**
2. **同一时间只能有一个所有者**
3. **当所有者离开作用域，值将被丢弃**

## 🏠 栈与堆

### 栈（Stack）

- **特点**：后进先出（LIFO）
- **大小**：固定大小，编译时确定
- **访问速度**：快速
- **存储内容**：函数参数、局部变量、指针

### 堆（Heap）

- **特点**：动态分配
- **大小**：运行时确定，可增长
- **访问速度**：相对较慢
- **存储内容**：动态大小的数据

```rust
fn main() {
    // 栈上的数据
    let x = 5;              // 整数存储在栈上
    
    // 堆上的数据
    let s1 = String::from("hello");  // String 存储在堆上
}
```

## 🔄 所有权与作用域

### 基本作用域规则

```rust
fn main() {
    {   // s 在这里开始有效
        let s = String::from("hello");
        // 在这个作用域内，s 是有效的
        println!("{}", s);
    }   // 作用域结束，s 不再有效，内存被释放
    
    // println!("{}", s);  // 编译错误！s 已经不存在
}
```

### 变量与数据的交互

#### 1. 移动（Move）

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;  // s1 的所有权移动到 s2
    
    // println!("{}", s1);  // 编译错误！s1 已经无效
    println!("{}", s2);     // 正常工作
    
    // 解释：String 包含三个部分：
    // - 指向堆内存的指针
    // - 长度
    // - 容量
    // 当 s1 移动到 s2 时，s1 变为无效
}
```

#### 2. 克隆（Clone）

如果需要深度复制数据：

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1.clone();  // 深度复制，s1 和 s2 都有效
    
    println!("s1: {}", s1);  // 正常工作
    println!("s2: {}", s2);  // 正常工作
}
```

#### 3. 栈上数据的复制

实现了 `Copy` trait 的类型会自动复制：

```rust
fn main() {
    let x = 5;
    let y = x;  // x 被复制给 y，x 仍然有效
    
    println!("x: {}, y: {}", x, y);  // 都正常工作
    
    // 实现了 Copy trait 的类型：
    // - 整数类型（i32, u32, i64, u64 等）
    // - 浮点类型（f32, f64）
    // - 布尔类型（bool）
    // - 字符类型（char）
    // - 包含 Copy 类型的元组
}
```

## 🚀 函数与所有权

### 函数参数的所有权

```rust
fn main() {
    let s = String::from("hello");
    takes_ownership(s);  // s 的所有权移动到函数内部
    
    // println!("{}", s);  // 编译错误！s 已经无效
    
    let x = 5;
    makes_copy(x);       // x 被复制，仍然有效
    println!("x: {}", x); // 正常工作
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
} // some_string 离开作用域，内存被释放

fn makes_copy(some_integer: i32) {
    println!("{}", some_integer);
} // some_integer 离开作用域，但它是 Copy 类型，没有特殊操作
```

### 函数返回值与所有权

```rust
fn main() {
    let s1 = gives_ownership();  // 函数返回值的所有权移动到 s1
    
    let s2 = String::from("hello");
    let s3 = takes_and_gives_back(s2);  // s2 移动到函数，函数返回值移动到 s3
    
    println!("s1: {}", s1);
    println!("s3: {}", s3);
    
    // println!("s2: {}", s2);  // 编译错误！s2 已经无效
}

fn gives_ownership() -> String {
    let some_string = String::from("hello");
    some_string  // 返回 some_string，所有权移动到调用者
}

fn takes_and_gives_back(a_string: String) -> String {
    a_string  // 返回 a_string，所有权移动到调用者
}
```

## 🎯 引用与借用

### 引用基础

引用允许你访问数据而不获取所有权：

```rust
fn main() {
    let s1 = String::from("hello");
    let len = calculate_length(&s1);  // 传递引用，不获取所有权
    
    println!("'{}' 的长度是 {}", s1, len);  // s1 仍然有效
}

fn calculate_length(s: &String) -> usize {
    s.len()  // 使用引用访问数据
} // s 离开作用域，但因为它没有所有权，所以不会释放内存
```

### 可变引用

```rust
fn main() {
    let mut s = String::from("hello");
    change(&mut s);  // 传递可变引用
    
    println!("修改后的字符串: {}", s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");  // 通过可变引用修改数据
}
```

### 借用规则

Rust 的借用规则防止数据竞争：

1. **在任意给定时间，只能有一个可变引用，或者任意数量的不可变引用**
2. **引用必须总是有效的**

```rust
fn main() {
    let mut s = String::from("hello");
    
    let r1 = &s;     // 不可变引用
    let r2 = &s;     // 另一个不可变引用
    // let r3 = &mut s;  // 编译错误！不能同时有可变和不可变引用
    
    println!("{} 和 {}", r1, r2);
    
    // r1 和 r2 在这里不再使用
    
    let r3 = &mut s;  // 现在可以创建可变引用
    r3.push_str(", world");
    println!("{}", r3);
}
```

## 💻 动手实践

### 练习 1：所有权转移实验

```rust
fn main() {
    // 创建一些数据
    let s1 = String::from("hello");
    let x = 5;
    
    println!("初始值: s1 = '{}', x = {}", s1, x);
    
    // 测试移动
    let s2 = s1;  // s1 移动到 s2
    println!("移动后: s2 = '{}'", s2);
    // println!("s1 = '{}'", s1);  // 取消注释会看到编译错误
    
    // 测试复制
    let y = x;  // x 被复制给 y
    println!("复制后: x = {}, y = {}", x, y);
    
    // 测试克隆
    let s3 = s2.clone();  // s2 被克隆给 s3
    println!("克隆后: s2 = '{}', s3 = '{}'", s2, s3);
}
```

### 练习 2：函数所有权测试

```rust
fn main() {
    let s = String::from("hello world");
    println!("原始字符串: '{}'", s);
    
    // 测试不可变引用
    let length = get_length(&s);
    println!("字符串长度: {}", length);
    println!("引用后字符串: '{}'", s);  // 仍然有效
    
    // 测试可变引用
    let mut s = s;  // 重新绑定为可变
    append_world(&mut s);
    println!("修改后字符串: '{}'", s);
}

fn get_length(s: &String) -> usize {
    s.len()
}

fn append_world(s: &mut String) {
    s.push_str(" world");
}
```

### 练习 3：所有权错误修复

```rust
fn main() {
    // 修复这些所有权问题
    
    // 问题 1：尝试使用已移动的值
    let s1 = String::from("hello");
    let s2 = s1;
    // 修复：使用 s2 而不是 s1
    println!("字符串: {}", s2);
    
    // 问题 2：同时使用可变和不可变引用
    let mut s = String::from("hello");
    let r1 = &s;
    let r2 = &s;
    println!("{} 和 {}", r1, r2);
    
    // 修复：在创建可变引用之前，确保不可变引用不再使用
    let r3 = &mut s;
    r3.push_str(", world");
    println!("{}", r3);
    
    // 问题 3：悬垂引用
    let reference = no_dangle();
    println!("引用: {}", reference);
}

fn no_dangle() -> String {
    let s = String::from("hello");
    s  // 返回所有权，而不是引用
}
```

### 练习 4：字符串处理函数

```rust
fn main() {
    let text = String::from("hello world");
    
    // 测试各种字符串操作
    let word_count = count_words(&text);
    let reversed = reverse_string(&text);
    let uppercased = to_uppercase(&text);
    
    println!("原文: '{}'", text);
    println!("单词数: {}", word_count);
    println!("反转: '{}'", reversed);
    println!("大写: '{}'", uppercased);
}

fn count_words(s: &String) -> usize {
    s.split_whitespace().count()
}

fn reverse_string(s: &String) -> String {
    s.chars().rev().collect()
}

fn to_uppercase(s: &String) -> String {
    s.to_uppercase()
}
```

## 🔍 代码解释

### 所有权移动
```rust
let s1 = String::from("hello");
let s2 = s1;  // s1 的所有权移动到 s2，s1 变为无效
```

### 引用语法
```rust
&s      // 不可变引用
&mut s  // 可变引用
```

### 借用规则
- 同一时间只能有一个可变引用，或者任意数量的不可变引用
- 引用必须总是有效的（不能有悬垂引用）

## 📚 今日总结

今天我们学习了：
1. ✅ Rust 所有权系统的核心概念
2. ✅ 栈与堆的区别
3. ✅ 所有权规则和移动语义
4. ✅ 引用与借用的基础
5. ✅ 借用规则和常见错误

## 🎯 明日预告

明天我们将继续学习所有权系统，包括：
- 引用与借用的深入理解
- 生命周期注解
- 悬垂引用问题
- 所有权系统的最佳实践

## 💡 小贴士

- 理解所有权是掌握 Rust 的关键
- 使用引用可以避免不必要的所有权转移
- 借用检查器在编译时防止数据竞争
- 优先使用不可变引用，只在需要修改时使用可变引用
- 练习识别和修复所有权错误

---

**恭喜你完成了第五天的学习！明天见！** 🎉
