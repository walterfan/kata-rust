# 常见编译错误

本节汇总 Rust 初学者最常遇到的编译错误及其解决方法。

## E0382: 移动后使用

```rust
let s1 = String::from("hello");
let s2 = s1;
println!("{}", s1);  // error[E0382]: borrow of moved value: `s1`
```

**原因**：Rust 中赋值默认是移动语义，`s1` 的所有权已转移给 `s2`。

**解决方案**：

```rust
// 方案 1: 使用 clone
let s1 = String::from("hello");
let s2 = s1.clone();
println!("{}", s1);

// 方案 2: 使用引用
let s1 = String::from("hello");
let s2 = &s1;
println!("{}", s1);
```

## E0499: 多次可变借用

```rust
let mut s = String::from("hello");
let r1 = &mut s;
let r2 = &mut s;  // error[E0499]: cannot borrow `s` as mutable more than once
println!("{}, {}", r1, r2);
```

**原因**：同一时刻只能有一个可变引用。

**解决方案**：

```rust
// 方案 1: 使用作用域
let mut s = String::from("hello");
{
    let r1 = &mut s;
    // 使用 r1
}  // r1 在这里释放
let r2 = &mut s;  // OK

// 方案 2: 利用 NLL（非词法生命周期）
let mut s = String::from("hello");
let r1 = &mut s;
println!("{}", r1);  // r1 最后一次使用
let r2 = &mut s;     // OK，r1 已经 "死亡"
println!("{}", r2);
```

## E0502: 可变借用和不可变借用冲突

```rust
let mut v = vec![1, 2, 3];
let first = &v[0];
v.push(4);  // error[E0502]: cannot borrow `v` as mutable
println!("{}", first);
```

**原因**：`v.push()` 需要可变借用，但 `first` 还持有不可变引用。

**解决方案**：

```rust
// 方案 1: 复制值而非借用
let mut v = vec![1, 2, 3];
let first = v[0];  // 复制 i32
v.push(4);
println!("{}", first);

// 方案 2: 重新组织代码
let mut v = vec![1, 2, 3];
v.push(4);
let first = &v[0];
println!("{}", first);
```

## E0106: 缺少生命周期标注

```rust
struct Foo {
    x: &i32,  // error[E0106]: missing lifetime specifier
}
```

**原因**：结构体包含引用时必须标注生命周期。

**解决方案**：

```rust
struct Foo<'a> {
    x: &'a i32,
}
```

## E0597: 借用的值存活时间不够

```rust
let r;
{
    let x = 5;
    r = &x;  // error[E0597]: `x` does not live long enough
}
println!("{}", r);
```

**原因**：`x` 在内部作用域结束时被释放，`r` 成为悬垂引用。

**解决方案**：

```rust
// 确保被引用的值活得够长
let x = 5;
let r = &x;
println!("{}", r);
```

## E0308: 类型不匹配

```rust
fn add(x: i32, y: i32) -> i32 {
    x + y;  // error[E0308]: mismatched types
            // expected `i32`, found `()`
}
```

**原因**：最后一行有分号，变成了语句，返回 `()`。

**解决方案**：

```rust
fn add(x: i32, y: i32) -> i32 {
    x + y  // 没有分号，作为返回值
}
```

## E0277: Trait 未实现

```rust
fn print_debug<T>(x: T) {
    println!("{:?}", x);  // error[E0277]: `T` doesn't implement `Debug`
}
```

**原因**：泛型 `T` 没有约束，不保证实现了 `Debug`。

**解决方案**：

```rust
use std::fmt::Debug;

fn print_debug<T: Debug>(x: T) {
    println!("{:?}", x);
}
```

## E0596: 不能可变借用不可变变量

```rust
let x = 5;
let r = &mut x;  // error[E0596]: cannot borrow `x` as mutable
```

**原因**：`x` 不是 `mut`，不能创建可变引用。

**解决方案**：

```rust
let mut x = 5;
let r = &mut x;
```

## E0507: 不能移出借用的内容

```rust
struct MyBox {
    value: String,
}

fn take_string(b: &MyBox) -> String {
    b.value  // error[E0507]: cannot move out of `b.value`
}
```

**原因**：`b` 是借用，不能移动其内部的值。

**解决方案**：

```rust
// 方案 1: 返回引用
fn get_string(b: &MyBox) -> &String {
    &b.value
}

// 方案 2: Clone
fn take_string(b: &MyBox) -> String {
    b.value.clone()
}

// 方案 3: 获取所有权
fn take_string(b: MyBox) -> String {
    b.value
}
```

## E0515: 不能返回局部变量的引用

```rust
fn create_string() -> &str {
    let s = String::from("hello");
    &s  // error[E0515]: cannot return reference to local variable
}
```

**原因**：`s` 在函数结束时被释放，返回的引用将悬垂。

**解决方案**：

```rust
// 方案 1: 返回拥有的值
fn create_string() -> String {
    String::from("hello")
}

// 方案 2: 返回 'static（字面量）
fn create_string() -> &'static str {
    "hello"
}
```

## E0373: 闭包捕获移动的值

```rust
let s = String::from("hello");
let closure = || {
    println!("{}", s);
};
std::thread::spawn(closure);  // error[E0373]: closure may outlive the current function
```

**原因**：闭包可能在当前函数返回后运行，而 `s` 会被释放。

**解决方案**：

```rust
let s = String::from("hello");
let closure = move || {
    println!("{}", s);
};
std::thread::spawn(closure);
```

## E0425: 找不到值

```rust
fn main() {
    println!("{}", x);  // error[E0425]: cannot find value `x` in this scope
}
```

**原因**：变量 `x` 未定义或作用域错误。

**解决方案**：

```rust
fn main() {
    let x = 42;
    println!("{}", x);
}
```

## 调试技巧

### 1. 打印类型

```rust
fn print_type_of<T>(_: &T) {
    println!("{}", std::any::type_name::<T>());
}

let x = 5;
print_type_of(&x);  // i32
```

### 2. 使用 dbg! 宏

```rust
let x = 5;
let y = dbg!(x * 2);  // 打印: [src/main.rs:3] x * 2 = 10
```

### 3. 编译器建议

Rust 编译器通常会给出修复建议：

```
error[E0382]: borrow of moved value: `s1`
  --> src/main.rs:4:20
   |
2  |     let s1 = String::from("hello");
   |         -- move occurs because `s1` has type `String`
3  |     let s2 = s1;
   |              -- value moved here
4  |     println!("{}", s1);
   |                    ^^ value borrowed here after move
   |
   = note: this error originates in the macro `$crate::format_args_nl`
help: consider cloning the value if the performance cost is acceptable
   |
3  |     let s2 = s1.clone();
   |                ++++++++
```

### 4. 使用 cargo check

```bash
# 只检查不编译，更快
cargo check
```

### 5. 使用 cargo clippy

```bash
# 获取更多代码质量建议
cargo clippy
```
