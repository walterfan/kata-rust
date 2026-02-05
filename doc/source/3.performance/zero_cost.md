# 零成本抽象

Rust 的核心设计原则之一是 **零成本抽象**（Zero-Cost Abstractions）。

## 什么是零成本抽象

```{note}
Bjarne Stroustrup（C++ 创始人）的定义：

> What you don't use, you don't pay for.
> What you do use, you couldn't hand code any better.

1. 你不用的功能，不会产生开销
2. 你用的功能，手写也不会更快
```

## 泛型是零成本的

```rust
fn max<T: Ord>(a: T, b: T) -> T {
    if a > b { a } else { b }
}

// 编译器会为每个具体类型生成专门的代码
let i = max(1, 2);        // 生成 max::<i32>
let f = max(1.0, 2.0);    // 生成 max::<f64>
```

这种技术叫做 **单态化**（Monomorphization），与手写每个类型的函数一样快。

## 迭代器是零成本的

```rust
let sum: u32 = (1..1000)
    .filter(|n| n % 2 == 0)
    .map(|n| n * n)
    .sum();

// 编译后等价于手写循环
let mut sum = 0u32;
for n in 1..1000 {
    if n % 2 == 0 {
        sum += n * n;
    }
}
```

迭代器链不会创建中间集合，编译器会内联和优化整个链。

## 智能指针是零成本的

### Box<T>

```rust
let boxed = Box::new(5);
// 等价于
let raw = unsafe { 
    let ptr = std::alloc::alloc(Layout::new::<i32>()) as *mut i32;
    *ptr = 5;
    ptr
};
```

`Box<T>` 没有额外的运行时开销，只是堆分配的抽象。

### 引用

```rust
let x = 5;
let r = &x;

// 引用在运行时就是一个指针
// 没有额外的开销
```

## 与其他语言对比

### Java 泛型（有开销）

```java
// Java 泛型是类型擦除，需要装箱
List<Integer> list = new ArrayList<>();
list.add(5);  // 自动装箱 int -> Integer
```

### Rust 泛型（零成本）

```rust
let vec: Vec<i32> = vec![1, 2, 3];
// i32 直接存储，没有装箱
```

## 何时不是零成本

### 动态分发

```rust
// 静态分发（零成本）
fn process_static(item: impl Display) {
    println!("{}", item);
}

// 动态分发（有 vtable 查找开销）
fn process_dynamic(item: &dyn Display) {
    println!("{}", item);
}
```

### 智能指针的引用计数

```rust
// Box: 无开销
let b = Box::new(5);

// Rc: 有引用计数开销
let rc = Rc::new(5);
let rc2 = Rc::clone(&rc);  // 计数 +1

// Arc: 有原子操作开销
let arc = Arc::new(5);
```

## 验证零成本

使用 `cargo-asm` 查看生成的汇编：

```bash
cargo install cargo-asm
cargo asm my_crate::my_function
```

或者使用 Compiler Explorer (godbolt.org) 在线查看。
