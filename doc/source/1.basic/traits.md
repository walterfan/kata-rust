# Trait 系统

Trait 是 Rust 的核心抽象机制，类似于其他语言的接口，但功能更强大。

## Trait vs 接口

| 特性 | Java Interface | C++ Concept/虚函数 | Rust Trait |
|------|----------------|-------------------|------------|
| 运行时多态 | ✅ | ✅ (虚函数) | ✅ (dyn Trait) |
| 编译时多态 | ❌ | ✅ (模板) | ✅ (泛型) |
| 为外部类型实现 | ❌ | ❌ | ✅ |
| 默认实现 | ✅ (Java 8+) | ❌ | ✅ |
| 关联类型 | ❌ | ✅ | ✅ |

## 定义 Trait

```rust
pub trait Summary {
    // 必须实现的方法
    fn summarize(&self) -> String;
    
    // 带默认实现的方法
    fn summarize_author(&self) -> String {
        String::from("(Unknown Author)")
    }
}
```

## 为类型实现 Trait

```rust
pub struct NewsArticle {
    pub headline: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {}", self.headline, self.author)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
    
    // 覆盖默认实现
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}
```

## Trait 作为参数

### 方式 1：impl Trait（语法糖）

```rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
```

### 方式 2：Trait Bound

```rust
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

### 方式 3：where 子句（多个约束时更清晰）

```rust
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{
    // ...
}
```

## Trait 对象（动态分发）

```rust
pub fn notify_all(items: &[&dyn Summary]) {
    for item in items {
        println!("{}", item.summarize());
    }
}

fn main() {
    let article = NewsArticle { /* ... */ };
    let tweet = Tweet { /* ... */ };
    
    // 不同类型可以放在同一个集合中
    let items: Vec<&dyn Summary> = vec![&article, &tweet];
    notify_all(&items);
}
```

```{note}
**静态分发 vs 动态分发**

- `impl Trait` / 泛型：编译时单态化，零运行时开销
- `dyn Trait`：通过虚表（vtable）动态分发，有少量运行时开销

C++ 程序员：类似于模板 vs 虚函数的区别
Java 程序员：类似于泛型 vs 接口引用的区别
```

## 常用标准库 Trait

### Clone 和 Copy

```rust
// Copy：按位复制，适用于简单类型
#[derive(Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

// Clone：显式深拷贝
#[derive(Clone)]
struct Buffer {
    data: Vec<u8>,
}

let buf1 = Buffer { data: vec![1, 2, 3] };
let buf2 = buf1.clone();  // 深拷贝
```

### Debug 和 Display

```rust
use std::fmt;

#[derive(Debug)]  // 自动派生，用于调试输出
struct Point {
    x: i32,
    y: i32,
}

// 手动实现 Display
impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

let p = Point { x: 1, y: 2 };
println!("{:?}", p);  // Debug: Point { x: 1, y: 2 }
println!("{}", p);    // Display: (1, 2)
```

### Default

```rust
#[derive(Default)]
struct Config {
    timeout: u32,
    retries: u32,
}

let config = Config::default();  // timeout: 0, retries: 0

// 部分覆盖
let config = Config {
    timeout: 30,
    ..Default::default()
};
```

### From 和 Into

```rust
use std::convert::From;

struct Wrapper(i32);

impl From<i32> for Wrapper {
    fn from(value: i32) -> Self {
        Wrapper(value)
    }
}

let w: Wrapper = 42.into();  // Into 自动实现
let w = Wrapper::from(42);
```

### Iterator

```rust
struct Counter {
    count: u32,
    max: u32,
}

impl Iterator for Counter {
    type Item = u32;
    
    fn next(&mut self) -> Option<Self::Item> {
        if self.count < self.max {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}

let counter = Counter { count: 0, max: 5 };
for i in counter {
    println!("{}", i);  // 1, 2, 3, 4, 5
}
```

## 关联类型 vs 泛型参数

### 关联类型（一个实现对应一个类型）

```rust
trait Iterator {
    type Item;  // 关联类型
    fn next(&mut self) -> Option<Self::Item>;
}
```

### 泛型参数（可以有多个实现）

```rust
trait From<T> {
    fn from(value: T) -> Self;
}

// 可以为同一类型实现多次
impl From<i32> for MyType { ... }
impl From<String> for MyType { ... }
```

## Trait 对象的限制：Object Safety

不是所有 trait 都能用作 trait 对象。必须满足 **对象安全** 规则：

```rust
// 不是对象安全的（有泛型方法）
trait NotObjectSafe {
    fn generic_method<T>(&self, t: T);
}

// 不是对象安全的（返回 Self）
trait AlsoNotSafe {
    fn clone_self(&self) -> Self;
}

// 对象安全
trait ObjectSafe {
    fn method(&self);
    fn method_with_arg(&self, x: i32);
}
```

## 常见错误

### 孤儿规则（Orphan Rule）

```rust
// 错误：不能为外部类型实现外部 trait
impl std::fmt::Display for Vec<i32> {
    // ...
}

// 解决：使用 newtype 模式
struct MyVec(Vec<i32>);

impl std::fmt::Display for MyVec {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{:?}", self.0)
    }
}
```

## 练习

1. 实现一个 `Printable` trait，让任何实现它的类型都能打印自己：

```rust
trait Printable {
    fn print(&self);
}

// 为 i32 和 String 实现这个 trait
```

<details>
<summary>答案</summary>

```rust
trait Printable {
    fn print(&self);
}

impl Printable for i32 {
    fn print(&self) {
        println!("{}", self);
    }
}

impl Printable for String {
    fn print(&self) {
        println!("{}", self);
    }
}

fn print_anything(item: &impl Printable) {
    item.print();
}
```
</details>
