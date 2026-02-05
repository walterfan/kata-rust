# 借用与引用

借用（Borrowing）是 Rust 所有权系统的核心补充，让你在不转移所有权的情况下使用数据。

## 引用基础

```rust
fn main() {
    let s1 = String::from("hello");
    
    let len = calculate_length(&s1);  // 借用 s1
    
    println!("The length of '{}' is {}.", s1, len);  // s1 仍然有效
}

fn calculate_length(s: &String) -> usize {
    s.len()
}  // s 离开作用域，但它不拥有数据，所以什么都不会发生
```

## 借用规则

```{important}
Rust 的借用规则：

1. **同一时刻**，你可以拥有 **一个可变引用** 或 **任意数量的不可变引用**
2. **引用必须始终有效**（不能悬垂）
```

### 不可变引用（共享借用）

```rust
let s = String::from("hello");

let r1 = &s;  // OK
let r2 = &s;  // OK，可以有多个不可变引用
let r3 = &s;  // OK

println!("{}, {}, {}", r1, r2, r3);
```

### 可变引用（独占借用）

```rust
let mut s = String::from("hello");

let r1 = &mut s;  // OK
// let r2 = &mut s;  // 错误！不能同时有两个可变引用

r1.push_str(", world");
println!("{}", r1);
```

### 不能同时存在可变和不可变引用

```rust
let mut s = String::from("hello");

let r1 = &s;     // OK
let r2 = &s;     // OK
// let r3 = &mut s;  // 错误！已经有不可变引用了

println!("{} and {}", r1, r2);
// r1 和 r2 在这之后不再使用

let r3 = &mut s;  // OK，因为 r1 和 r2 已经 "死亡"
println!("{}", r3);
```

## Non-Lexical Lifetimes (NLL)

Rust 编译器足够智能，能识别引用的实际使用范围：

```rust
let mut s = String::from("hello");

let r1 = &s;
let r2 = &s;
println!("{} and {}", r1, r2);
// r1 和 r2 的最后一次使用在这里

let r3 = &mut s;  // OK！NLL 允许这样
println!("{}", r3);
```

## C++ 程序员的困惑

### 为什么不能有多个可变引用？

```{note}
C++ 允许多个指针/引用指向同一可变数据，但这会导致：

1. **数据竞争**：多线程同时修改
2. **迭代器失效**：修改集合导致迭代器悬垂
3. **别名问题**：编译器难以优化

Rust 通过借用规则在 **编译期** 消除这些问题。
```

### 迭代器失效示例

C++ 中常见的 bug：

```cpp
std::vector<int> v = {1, 2, 3};
for (auto& item : v) {
    if (item == 2) {
        v.push_back(4);  // 危险！可能导致迭代器失效
    }
}
```

Rust 在编译期阻止这种情况：

```rust
let mut v = vec![1, 2, 3];
for item in &v {  // 不可变借用 v
    if *item == 2 {
        // v.push(4);  // 错误！不能在借用期间修改
    }
}

// 正确的做法
let mut v = vec![1, 2, 3];
let mut indices_to_extend = Vec::new();
for (i, item) in v.iter().enumerate() {
    if *item == 2 {
        indices_to_extend.push(i);
    }
}
// 借用结束后再修改
v.push(4);
```

## Java 程序员的困惑

### 没有垃圾回收如何管理生命周期？

```{note}
Java 中你不需要考虑引用的生命周期，GC 会处理一切。
Rust 通过借用检查器在编译期验证所有引用的有效性。

好处：
- 无 GC 停顿
- 确定性的资源释放
- 零运行时开销
```

## 解引用

```rust
let x = 5;
let y = &x;

assert_eq!(5, x);
assert_eq!(5, *y);  // 解引用获取值

// 方法调用时自动解引用
let s = String::from("hello");
let r = &s;
println!("{}", r.len());  // 自动解引用，等同于 (*r).len()
```

## 可变引用的限制场景

### 场景 1：结构体字段借用

```rust
struct Point {
    x: i32,
    y: i32,
}

let mut point = Point { x: 0, y: 0 };

let x_ref = &mut point.x;
let y_ref = &mut point.y;  // OK！借用不同字段

*x_ref = 1;
*y_ref = 2;
```

### 场景 2：切片借用

```rust
let mut arr = [1, 2, 3, 4, 5];

let (left, right) = arr.split_at_mut(2);
// left 是 &mut [1, 2]
// right 是 &mut [3, 4, 5]
// 可以同时修改，因为它们不重叠
```

## 常见编译错误

### E0502: 可变借用后不能不可变借用

```rust
let mut v = vec![1, 2, 3];
let first = &v[0];     // 不可变借用
v.push(4);             // 错误！需要可变借用
println!("{}", first); // first 在这里仍被使用
```

**解决**：重新组织代码，确保借用不重叠

```rust
let mut v = vec![1, 2, 3];
let first = v[0];  // 复制值而不是借用
v.push(4);         // OK
println!("{}", first);
```

### E0499: 不能多次可变借用

```rust
let mut s = String::from("hello");
let r1 = &mut s;
let r2 = &mut s;  // 错误
println!("{}, {}", r1, r2);
```

**解决**：使用作用域限制借用

```rust
let mut s = String::from("hello");
{
    let r1 = &mut s;
    r1.push_str(" world");
}  // r1 在这里释放
let r2 = &mut s;  // OK
```

## 练习

1. 下面的代码有什么问题？

```rust
fn main() {
    let mut s = String::from("hello");
    let r1 = &s;
    let r2 = &s;
    let r3 = &mut s;
    println!("{}, {}, {}", r1, r2, r3);
}
```

<details>
<summary>答案</summary>

不能在不可变引用存在时创建可变引用。
`r1` 和 `r2` 是不可变引用，在 `println!` 中仍然被使用，
所以不能创建 `r3`。

修复方法：将可变借用移到不可变借用使用完之后。
</details>
