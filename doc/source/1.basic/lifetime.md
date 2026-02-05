# 生命周期

生命周期（Lifetime）是 Rust 最让人困惑的概念之一，但它本质上很简单：
**确保引用不会比它指向的数据活得更长**。

## 为什么需要生命周期？

### 悬垂引用问题

```rust
fn main() {
    let r;                // ---------+-- 'a
    {                     //          |
        let x = 5;        // -+-- 'b  |
        r = &x;           //  |       |
    }                     // -+       |
    // println!("{}", r); // 错误！x 已经被释放
}                         // ---------+
```

Rust 编译器通过生命周期分析，在编译期发现这个问题。

## 生命周期标注语法

生命周期标注不改变引用的实际生命周期，只是告诉编译器引用之间的关系。

```rust
&i32        // 引用
&'a i32     // 带生命周期标注的引用
&'a mut i32 // 带生命周期标注的可变引用
```

## 函数中的生命周期

### 问题场景

```rust
// 这个函数无法编译
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

编译器不知道返回的引用是 `x` 还是 `y`，所以无法确定返回值的生命周期。

### 解决方案：生命周期标注

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

这告诉编译器：**返回的引用与两个参数中生命周期较短的那个一样长**。

### 使用示例

```rust
fn main() {
    let string1 = String::from("long string is long");
    let result;
    {
        let string2 = String::from("xyz");
        result = longest(string1.as_str(), string2.as_str());
        println!("The longest string is {}", result);  // OK
    }
    // println!("{}", result);  // 错误！string2 已经释放
}
```

## 生命周期省略规则

Rust 编译器可以推断某些情况下的生命周期，这些规则叫做 **生命周期省略规则**。

### 规则 1：每个引用参数都有自己的生命周期

```rust
fn foo(x: &i32, y: &i32) -> ...
// 等同于
fn foo<'a, 'b>(x: &'a i32, y: &'b i32) -> ...
```

### 规则 2：只有一个输入生命周期时，它被赋给所有输出

```rust
fn foo(x: &i32) -> &i32
// 等同于
fn foo<'a>(x: &'a i32) -> &'a i32
```

### 规则 3：方法中，self 的生命周期被赋给所有输出

```rust
impl MyStruct {
    fn get_ref(&self, x: &str) -> &str
    // 等同于
    fn get_ref<'a, 'b>(&'a self, x: &'b str) -> &'a str
}
```

## 结构体中的生命周期

当结构体持有引用时，必须标注生命周期：

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().unwrap();
    
    let excerpt = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("{}", excerpt.part);
}
```

这意味着：**ImportantExcerpt 实例不能比它引用的数据活得更长**。

### 结构体方法中的生命周期

```rust
impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
    
    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("Attention please: {}", announcement);
        self.part  // 返回 &'a str
    }
}
```

## 静态生命周期

`'static` 是一个特殊的生命周期，表示引用在整个程序运行期间都有效。

```rust
let s: &'static str = "I have a static lifetime.";
```

字符串字面量都是 `'static` 的，因为它们被编译进二进制文件。

```{warning}
不要滥用 `'static`！当编译器建议使用 `'static` 时，
通常意味着你有悬垂引用问题，应该修复根本原因而不是强制使用 `'static`。
```

## C++ 程序员的对比

### C++ 悬垂引用（编译通过，运行时 UB）

```cpp
int& dangerous() {
    int x = 42;
    return x;  // 悬垂引用！编译器可能警告但不会阻止
}
```

### Rust（编译错误）

```rust
fn dangerous() -> &i32 {
    let x = 42;
    &x  // 错误：cannot return reference to local variable
}
```

## 常见生命周期错误

### E0106: 缺少生命周期标注

```rust
struct Foo {
    x: &i32,  // 错误：missing lifetime specifier
}
```

**解决**：添加生命周期标注

```rust
struct Foo<'a> {
    x: &'a i32,
}
```

### E0597: 借用的值存活时间不够

```rust
let r;
{
    let x = 5;
    r = &x;  // 错误：borrowed value does not live long enough
}
println!("{}", r);
```

**解决**：确保被引用的值活得足够长

```rust
let x = 5;
let r = &x;
println!("{}", r);
```

## 生命周期子类型

较长的生命周期可以当作较短的生命周期使用：

```rust
fn foo<'a, 'b: 'a>(x: &'a i32, y: &'b i32) -> &'a i32 {
    if *x > *y { x } else { y }
}
// 'b: 'a 表示 'b 至少和 'a 一样长
```

## 练习

1. 下面的代码有什么问题？如何修复？

```rust
fn get_str() -> &str {
    let s = String::from("hello");
    &s
}
```

<details>
<summary>答案</summary>

返回了对局部变量的引用，`s` 在函数结束时被释放。

修复方法 1：返回 String（转移所有权）
```rust
fn get_str() -> String {
    String::from("hello")
}
```

修复方法 2：返回 &'static str
```rust
fn get_str() -> &'static str {
    "hello"  // 字符串字面量是 'static
}
```
</details>

2. 为下面的函数添加生命周期标注：

```rust
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    &s[..]
}
```

<details>
<summary>答案</summary>

实际上这个函数不需要显式标注！根据生命周期省略规则 2，
只有一个输入引用参数，它的生命周期会自动赋给输出。

编译器自动推断为：
```rust
fn first_word<'a>(s: &'a str) -> &'a str
```
</details>
