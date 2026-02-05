# C++ 程序员迁移指南

本节帮助有 C++ 背景的程序员快速理解 Rust。

## 概念映射

| C++ 概念 | Rust 等价物 | 说明 |
|---------|------------|------|
| `unique_ptr<T>` | `Box<T>` | 堆上分配，独占所有权 |
| `shared_ptr<T>` | `Arc<T>` / `Rc<T>` | 引用计数（Arc 线程安全）|
| `weak_ptr<T>` | `Weak<T>` | 弱引用 |
| RAII | 所有权系统 | 自动资源管理 |
| 移动语义 | 默认移动 | Rust 赋值默认移动 |
| `const T&` | `&T` | 不可变引用 |
| `T&` | `&mut T` | 可变引用 |
| 模板 | 泛型 | 编译时单态化 |
| 虚函数 | `dyn Trait` | 动态分发 |
| 概念 (Concepts) | Trait bounds | 约束泛型 |
| `std::optional` | `Option<T>` | 可空类型 |
| `std::variant` | `enum` | 代数数据类型 |
| `namespace` | `mod` | 模块系统 |
| `.h` + `.cpp` | `.rs` | 无需分离声明和定义 |

## 主要思维转变

### 1. 默认不可变

```cpp
// C++: 默认可修改
int x = 5;
x = 6;  // OK

const int y = 5;
// y = 6;  // 错误
```

```rust
// Rust: 默认不可变
let x = 5;
// x = 6;  // 错误！

let mut y = 5;
y = 6;  // OK
```

### 2. 赋值是移动而非复制

```cpp
// C++: 赋值复制
std::string s1 = "hello";
std::string s2 = s1;  // 复制，s1 仍有效

// 显式移动
std::string s3 = std::move(s1);  // s1 现在为空但仍 "有效"
```

```rust
// Rust: 赋值移动
let s1 = String::from("hello");
let s2 = s1;  // 移动，s1 无效

// 显式复制
let s3 = s2.clone();  // s2 和 s3 都有效
```

### 3. 引用有生命周期

```cpp
// C++: 引用可能悬垂
int& dangerous() {
    int x = 42;
    return x;  // 悬垂引用！编译器可能只是警告
}
```

```rust
// Rust: 编译器阻止悬垂引用
fn dangerous() -> &i32 {
    let x = 42;
    &x  // 编译错误：cannot return reference to local variable
}
```

### 4. 没有继承，使用组合 + Trait

```cpp
// C++ 继承
class Animal {
public:
    virtual void speak() = 0;
};

class Dog : public Animal {
public:
    void speak() override { std::cout << "Woof!\n"; }
};
```

```rust
// Rust: Trait + 组合
trait Speak {
    fn speak(&self);
}

struct Dog;

impl Speak for Dog {
    fn speak(&self) {
        println!("Woof!");
    }
}

// 组合而非继承
struct Pet {
    name: String,
    animal: Box<dyn Speak>,
}
```

### 5. 错误处理用 Result 而非异常

```cpp
// C++ 异常
void process() {
    try {
        auto data = read_file("data.txt");
    } catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
    }
}
```

```rust
// Rust Result
fn process() -> Result<(), Box<dyn std::error::Error>> {
    let data = read_file("data.txt")?;
    Ok(())
}
```

## 常见陷阱

### 陷阱 1：循环中移动

```rust
// 错误：第二次迭代时 s 已经无效
let s = String::from("hello");
for _ in 0..3 {
    takes_ownership(s);  // 编译错误
}

// 正确：clone 或使用引用
for _ in 0..3 {
    takes_ownership(s.clone());  // 或
    borrows(&s);
}
```

### 陷阱 2：结构体部分借用

```rust
struct Data {
    field1: String,
    field2: String,
}

let mut data = Data { ... };

// 错误理解：以为这是对整个 data 的两次可变借用
let r1 = &mut data.field1;
let r2 = &mut data.field2;  // OK！不同字段

// 但方法调用可能有问题
fn modify(&mut self) {
    self.helper();  // 错误：self 已经被借用
}
```

### 陷阱 3：String vs &str

```rust
// String: 拥有数据，可增长
let s: String = String::from("hello");

// &str: 借用的切片，通常更高效
let s: &str = "hello";  // 字面量
let s: &str = &string;  // 借用 String

// 函数参数通常用 &str
fn process(s: &str) { ... }
process(&string);  // String -> &str 自动转换
```

### 陷阱 4：Vec 迭代

```rust
let v = vec![1, 2, 3];

// 移动迭代（v 之后无效）
for item in v {
    println!("{}", item);
}
// println!("{:?}", v);  // 错误

// 借用迭代
for item in &v {
    println!("{}", item);
}
println!("{:?}", v);  // OK

// 可变借用迭代
for item in &mut v {
    *item += 1;
}
```

## 智能指针对比

### Box vs unique_ptr

```cpp
// C++
auto p = std::make_unique<int>(42);
auto p2 = std::move(p);  // p 现在是 nullptr，但仍可访问（UB）
```

```rust
// Rust
let p = Box::new(42);
let p2 = p;  // p 移动后无效，编译器阻止访问
// println!("{}", *p);  // 编译错误
```

### Arc vs shared_ptr

```cpp
// C++
auto p = std::make_shared<int>(42);
auto p2 = p;  // 引用计数 +1
```

```rust
// Rust
use std::sync::Arc;
let p = Arc::new(42);
let p2 = Arc::clone(&p);  // 显式 clone 增加引用计数
```

## 并发对比

### 线程安全

```cpp
// C++: 需要程序员保证正确性
std::vector<int> v;
std::thread t1([&v]() { v.push_back(1); });
std::thread t2([&v]() { v.push_back(2); });
// 数据竞争！没有编译错误
```

```rust
// Rust: 类型系统强制线程安全
let v = vec![];
let t1 = std::thread::spawn(|| {
    v.push(1);  // 编译错误：无法跨线程移动
});
```

### 正确的并发

```rust
use std::sync::{Arc, Mutex};

let v = Arc::new(Mutex::new(vec![]));
let v1 = Arc::clone(&v);
let v2 = Arc::clone(&v);

let t1 = std::thread::spawn(move || {
    v1.lock().unwrap().push(1);
});
let t2 = std::thread::spawn(move || {
    v2.lock().unwrap().push(2);
});
```

## 快速上手建议

1. **先忘掉继承**：用 Trait 和组合思考问题
2. **拥抱不可变**：只在需要时加 `mut`
3. **相信编译器**：编译错误是在帮你
4. **从小项目开始**：让借用检查器教你
5. **使用 clippy**：`cargo clippy` 会给出惯用写法建议
