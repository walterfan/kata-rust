# 内存布局

## 查看类型大小

```rust
use std::mem::{size_of, align_of};

println!("i32: {} bytes, align {}", size_of::<i32>(), align_of::<i32>());
println!("bool: {} bytes", size_of::<bool>());
println!("char: {} bytes", size_of::<char>());  // 4 bytes (Unicode)
println!("String: {} bytes", size_of::<String>());  // 24 bytes (ptr + len + cap)
println!("&str: {} bytes", size_of::<&str>());  // 16 bytes (ptr + len)
println!("Vec<i32>: {} bytes", size_of::<Vec<i32>>());  // 24 bytes
```

## 结构体布局

```rust
struct A {
    a: u8,   // 1 byte
    b: u32,  // 4 bytes
    c: u8,   // 1 byte
}  // 实际大小: 12 bytes（有填充）

#[repr(C)]
struct B {
    a: u8,
    b: u32,
    c: u8,
}  // C 布局，可预测

#[repr(packed)]
struct C {
    a: u8,
    b: u32,
    c: u8,
}  // 紧凑布局，无填充，6 bytes
```

## 枚举大小

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
}

// 大小 = max(变体大小) + 判别式
println!("Message: {} bytes", size_of::<Message>());

// Option 优化
println!("Option<&i32>: {} bytes", size_of::<Option<&i32>>());  // 8 bytes
println!("Option<Box<i32>>: {} bytes", size_of::<Option<Box<i32>>>());  // 8 bytes
// 空指针优化：None 用 null 表示，无额外开销
```

## repr 属性

```rust
#[repr(C)]       // C 兼容布局
#[repr(packed)]  // 紧凑无填充
#[repr(align(N))]  // 指定对齐
#[repr(transparent)]  // 与包含的类型相同布局

#[repr(u8)]  // 枚举判别式类型
enum Color {
    Red = 0,
    Green = 1,
    Blue = 2,
}
```
