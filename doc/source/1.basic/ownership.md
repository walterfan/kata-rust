# 所有权系统

所有权是 Rust 最独特的特性，也是 C++/Java 程序员最需要理解的概念。

## 所有权三原则

```{important}
Rust 的所有权规则：

1. **每个值都有一个所有者（owner）**
2. **同一时刻只能有一个所有者**
3. **当所有者离开作用域，值被丢弃（drop）**
```

## 移动语义（Move）

### C++ 程序员注意

在 C++ 中，赋值默认是复制。在 Rust 中，对于堆上的数据，赋值默认是 **移动**。

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;  // s1 的所有权移动到 s2
    
    // println!("{}", s1);  // 错误！s1 已经无效
    println!("{}", s2);     // OK
}
```

### Java 程序员注意

Java 中对象赋值是复制引用（两个引用指向同一对象）。Rust 的移动意味着原变量 **完全失效**。

```rust
// Java 思维（错误）：
// String s1 = new String("hello");
// String s2 = s1;  // s1 和 s2 都有效

// Rust 思维：
let s1 = String::from("hello");
let s2 = s1;  // 只有 s2 有效，s1 已死
```

## Copy 与 Clone

### Copy trait

对于简单的栈上数据，赋值是复制而不是移动：

```rust
let x = 5;
let y = x;  // x 仍然有效，因为 i32 实现了 Copy

println!("x = {}, y = {}", x, y);  // OK
```

**实现 Copy 的类型**：
- 所有整数类型
- 布尔类型
- 浮点类型
- 字符类型
- 只包含 Copy 类型的元组和数组

### Clone trait

对于不能 Copy 的类型，使用 `clone()` 显式复制：

```rust
let s1 = String::from("hello");
let s2 = s1.clone();  // 显式深拷贝

println!("s1 = {}, s2 = {}", s1, s2);  // 都有效
```

## 函数与所有权

### 传值 = 移动

```rust
fn take_ownership(s: String) {
    println!("{}", s);
}  // s 在这里被 drop

fn main() {
    let s = String::from("hello");
    take_ownership(s);
    // println!("{}", s);  // 错误！s 已经移动
}
```

### 返回值 = 转移所有权

```rust
fn give_ownership() -> String {
    String::from("hello")  // 所有权转移给调用者
}

fn take_and_give_back(s: String) -> String {
    s  // 所有权返回
}

fn main() {
    let s1 = give_ownership();
    let s2 = take_and_give_back(s1);
    // s1 无效，s2 有效
}
```

## 常见错误场景

### 错误 1：移动后使用

```rust
let v = vec![1, 2, 3];
let v2 = v;
println!("{:?}", v);  // 错误：value borrowed here after move
```

**解决**：使用 `clone()` 或引用

### 错误 2：循环中移动

```rust
let s = String::from("hello");
for _ in 0..3 {
    take_ownership(s);  // 错误：第一次迭代后 s 就无效了
}
```

**解决**：传递引用或每次 clone

```rust
let s = String::from("hello");
for _ in 0..3 {
    take_ownership(s.clone());  // OK
}
// 或者
for _ in 0..3 {
    use_reference(&s);  // 更高效
}
```

### 错误 3：结构体部分移动

```rust
struct Person {
    name: String,
    age: u32,
}

let person = Person {
    name: String::from("Alice"),
    age: 30,
};

let name = person.name;  // 部分移动
// println!("{}", person.name);  // 错误
println!("{}", person.age);      // OK，age 是 Copy 类型
```

## 与 C++ RAII 的比较

```{note}
C++ 程序员会发现 Rust 的所有权类似于 RAII + 移动语义的强制版本。

**C++ unique_ptr**：
```cpp
auto p1 = std::make_unique<int>(42);
auto p2 = std::move(p1);  // p1 变成 nullptr，但编译器不会阻止你使用它
```

**Rust**：
```rust
let p1 = Box::new(42);
let p2 = p1;  // 移动
// let _ = *p1;  // 编译错误！Rust 阻止了悬垂指针
```

Rust 在 **编译期** 强制执行这些规则，而 C++ 依赖程序员的自律。
```

## 练习

1. 下面的代码能编译吗？为什么？

```rust
fn main() {
    let s = String::from("hello");
    let s2 = s;
    let s3 = s;
}
```

2. 如何修改使其编译通过？

<details>
<summary>答案</summary>

不能编译。因为 `s` 在赋值给 `s2` 时已经移动，不能再赋值给 `s3`。

修改方法：
```rust
let s = String::from("hello");
let s2 = s.clone();
let s3 = s;  // 或者 s2.clone()
```
</details>
