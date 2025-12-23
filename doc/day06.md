# 第6天：所有权系统（下）

## 🎯 今日目标

- 深入理解引用与借用
- 掌握生命周期注解
- 学会解决悬垂引用问题
- 了解所有权系统的最佳实践

## 🔗 引用与借用的深入理解

### 引用类型详解

引用有两种类型：不可变引用（`&T`）和可变引用（`&mut T`）：

```rust
fn main() {
    let mut s = String::from("hello");
    
    // 不可变引用
    let r1: &String = &s;
    let r2: &String = &s;
    
    // 可以同时有多个不可变引用
    println!("r1: {}, r2: {}", r1, r2);
    
    // 可变引用
    let r3: &mut String = &mut s;
    r3.push_str(", world");
    
    // 注意：r1 和 r2 在这里已经不能使用了
    // 因为可变引用 r3 存在时，不可变引用 r1 和 r2 无效
    println!("修改后: {}", r3);
}
```

### 引用的作用域

引用的作用域从声明开始，到最后一次使用结束：

```rust
fn main() {
    let mut s = String::from("hello");
    
    let r1 = &s;  // r1 开始有效
    let r2 = &s;  // r2 开始有效
    
    println!("{} 和 {}", r1, r2);  // r1 和 r2 在这里最后一次使用
    
    let r3 = &mut s;  // r1 和 r2 的作用域结束，可以创建可变引用
    r3.push_str(", world");
    println!("{}", r3);
}
```

### 切片引用

切片是对集合中一段连续元素的引用：

```rust
fn main() {
    let s = String::from("hello world");
    
    // 字符串切片
    let hello = &s[0..5];  // "hello"
    let world = &s[6..11]; // "world"
    
    println!("{} {}", hello, world);
    
    // 数组切片
    let numbers = [1, 2, 3, 4, 5];
    let slice = &numbers[1..4];  // [2, 3, 4]
    
    println!("切片: {:?}", slice);
}
```

## ⏰ 生命周期注解

### 生命周期基础

生命周期是引用保持有效的作用域范围。Rust 编译器需要知道引用的生命周期：

```rust
fn main() {
    let string1 = String::from("long string is long");
    let string2 = String::from("xyz");
    
    let result = longest(string1.as_str(), string2.as_str());
    println!("最长的字符串是: {}", result);
}

// 这个函数有生命周期注解
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

### 生命周期注解语法

生命周期注解使用 `'a` 这样的标识符：

```rust
// 函数参数的生命周期
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

// 结构体中的生命周期
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("找不到句号");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("摘录: {}", i.part);
}
```

### 生命周期省略规则

Rust 编译器可以自动推断某些生命周期：

```rust
// 规则 1：每个引用参数都有自己的生命周期
fn first_word<'a>(s: &'a str) -> &'a str { ... }

// 规则 2：如果只有一个输入生命周期参数，那么它被赋给所有输出生命周期参数
fn first_word<'a>(s: &'a str) -> &'a str { ... }

// 规则 3：如果有多个输入生命周期参数，但其中一个是 &self 或 &mut self，
// 那么 self 的生命周期被赋给所有输出生命周期参数

// 这些规则让很多函数不需要显式的生命周期注解
fn first_word(s: &str) -> &str {  // 编译器自动推断生命周期
    s.split_whitespace().next().unwrap_or("")
}
```

## 🚫 悬垂引用问题

### 什么是悬垂引用？

悬垂引用是指引用指向的内存已经被释放：

```rust
// 这个函数会产生悬垂引用（编译错误）
fn dangle() -> &String {
    let s = String::from("hello");
    &s  // 返回 s 的引用，但 s 在这里离开作用域
} // s 在这里被释放，引用指向无效内存
```

### 解决悬垂引用

正确的做法是返回所有权而不是引用：

```rust
fn main() {
    let s = no_dangle();
    println!("{}", s);
}

// 修复：返回所有权
fn no_dangle() -> String {
    let s = String::from("hello");
    s  // 返回 s 的所有权，而不是引用
}
```

### 生命周期注解解决悬垂引用

```rust
fn main() {
    let string1 = String::from("long string is long");
    let result;
    
    {
        let string2 = String::from("xyz");
        result = longest(string1.as_str(), string2.as_str());
        println!("最长的字符串是: {}", result);
    }
    // string2 在这里离开作用域
    
    // 这里不能使用 result，因为它可能指向已释放的 string2
    // println!("{}", result);  // 编译错误！
}

fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

## 🏗️ 结构体中的生命周期

### 包含引用的结构体

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("找不到句号");
    
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("摘录: {}", i.part);
}
```

### 生命周期注解的约束

```rust
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("最大的成员是 x = {}", self.x);
        } else {
            println!("最大的成员是 y = {}", self.y);
        }
    }
}
```

## 💻 动手实践

### 练习 1：生命周期注解练习

```rust
fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";
    
    let result = longest_with_an_announcement(
        string1.as_str(),
        string2,
        "今天是个好日子！"
    );
    println!("最长的字符串是: {}", result);
}

// 添加生命周期注解和泛型
fn longest_with_an_announcement<'a, T>(
    x: &'a str,
    y: &'a str,
    ann: T,
) -> &'a str
where
    T: std::fmt::Display,
{
    println!("公告! {}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

### 练习 2：结构体生命周期

```rust
// 创建一个包含引用的结构体
struct Book<'a> {
    title: &'a str,
    author: &'a str,
    year: u32,
}

impl<'a> Book<'a> {
    fn new(title: &'a str, author: &'a str, year: u32) -> Self {
        Book { title, author, year }
    }
    
    fn display(&self) {
        println!("《{}》 by {} ({})", self.title, self.author, self.year);
    }
    
    fn get_title(&self) -> &'a str {
        self.title
    }
}

fn main() {
    let title = String::from("Rust 程序设计");
    let author = String::from("Steve Klabnik");
    
    let book = Book::new(&title, &author, 2020);
    book.display();
    
    let book_title = book.get_title();
    println!("书名: {}", book_title);
}
```

### 练习 3：字符串处理与生命周期

```rust
fn main() {
    let text = String::from("hello world rust programming");
    
    // 测试各种字符串操作
    let first_word = get_first_word(&text);
    let last_word = get_last_word(&text);
    let longest_word = find_longest_word(&text);
    
    println!("原文: '{}'", text);
    println!("第一个单词: '{}'", first_word);
    println!("最后一个单词: '{}'", last_word);
    println!("最长的单词: '{}'", longest_word);
}

fn get_first_word(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}

fn get_last_word(s: &str) -> &str {
    s.split_whitespace().last().unwrap_or("")
}

fn find_longest_word(s: &str) -> &str {
    s.split_whitespace()
        .max_by_key(|word| word.len())
        .unwrap_or("")
}
```

### 练习 4：修复生命周期错误

```rust
fn main() {
    // 修复这些生命周期问题
    
    // 问题 1：悬垂引用
    let s = create_string();
    println!("字符串: {}", s);
    
    // 问题 2：生命周期不匹配
    let string1 = String::from("long string is long");
    let result;
    
    {
        let string2 = String::from("xyz");
        result = longest_string(&string1, &string2);
        println!("最长的字符串是: {}", result);
    }
    
    // 修复：确保 result 的生命周期不超出 string2 的作用域
    // 或者重新获取 result
}

fn create_string() -> String {
    let s = String::from("hello");
    s  // 返回所有权，而不是引用
}

fn longest_string<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

### 练习 5：高级生命周期应用

```rust
use std::fmt::Display;

// 创建一个可以包含引用的容器
struct Container<'a, T> {
    items: Vec<&'a T>,
}

impl<'a, T> Container<'a, T> {
    fn new() -> Self {
        Container { items: Vec::new() }
    }
    
    fn add(&mut self, item: &'a T) {
        self.items.push(item);
    }
    
    fn get(&self, index: usize) -> Option<&'a T> {
        self.items.get(index).copied()
    }
    
    fn len(&self) -> usize {
        self.items.len()
    }
}

impl<'a, T: Display> Container<'a, T> {
    fn display_all(&self) {
        for (i, item) in self.items.iter().enumerate() {
            println!("{}: {}", i, item);
        }
    }
}

fn main() {
    let mut container = Container::new();
    
    let item1 = String::from("第一项");
    let item2 = String::from("第二项");
    let item3 = String::from("第三项");
    
    container.add(&item1);
    container.add(&item2);
    container.add(&item3);
    
    println!("容器大小: {}", container.len());
    container.display_all();
    
    if let Some(item) = container.get(1) {
        println!("第二项: {}", item);
    }
}
```

## 🔍 代码解释

### 生命周期注解语法
```rust
fn function<'a>(x: &'a str) -> &'a str
struct Struct<'a> { field: &'a str }
impl<'a> Struct<'a> { ... }
```

### 生命周期省略规则
1. 每个引用参数都有自己的生命周期
2. 如果只有一个输入生命周期参数，它被赋给所有输出生命周期参数
3. 如果有多个输入生命周期参数，但其中一个是 `&self` 或 `&mut self`，那么 `self` 的生命周期被赋给所有输出生命周期参数

### 悬垂引用的解决方案
- 返回所有权而不是引用
- 使用生命周期注解确保引用有效
- 注意引用的作用域

## 📚 今日总结

今天我们学习了：
1. ✅ 引用与借用的深入理解
2. ✅ 生命周期注解的语法和用法
3. ✅ 悬垂引用问题的识别和解决
4. ✅ 结构体中的生命周期
5. ✅ 生命周期省略规则

## 🎯 明日预告

明天我们将学习 Rust 的结构体与枚举，包括：
- 结构体定义与实例化
- 方法实现
- 枚举定义
- Option 与 Result 类型

## 💡 小贴士

- 生命周期注解是 Rust 中较难理解的概念，需要多练习
- 编译器会帮助你识别生命周期问题
- 优先使用生命周期省略规则，只在必要时显式注解
- 理解引用的作用域有助于避免生命周期错误
- 练习编写包含引用的结构体和方法

---

**恭喜你完成了第六天的学习！明天见！** 🎉
