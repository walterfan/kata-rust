# Unsafe Rust

`unsafe` 关键字允许执行编译器无法验证安全性的操作。

## 何时使用 unsafe

```{important}
**unsafe 能做的事情**：

1. 解引用裸指针
2. 调用 unsafe 函数或方法
3. 访问或修改可变静态变量
4. 实现 unsafe trait
5. 访问 union 字段

**unsafe 不能关闭借用检查器**！只是允许上述操作。
```

## 裸指针

```rust
let mut num = 5;

// 创建裸指针是安全的
let r1 = &num as *const i32;
let r2 = &mut num as *mut i32;

// 解引用需要 unsafe
unsafe {
    println!("r1: {}", *r1);
    *r2 = 10;
}
```

## unsafe 函数

```rust
unsafe fn dangerous() {
    // 可以在这里执行不安全操作
}

fn main() {
    unsafe {
        dangerous();
    }
}
```

## FFI（外部函数接口）

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    unsafe {
        println!("abs(-3) = {}", abs(-3));
    }
}
```

## 安全的 unsafe 封装

```rust
pub fn split_at_mut(values: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = values.len();
    let ptr = values.as_mut_ptr();
    
    assert!(mid <= len);
    
    unsafe {
        (
            std::slice::from_raw_parts_mut(ptr, mid),
            std::slice::from_raw_parts_mut(ptr.add(mid), len - mid),
        )
    }
}
```

## 最佳实践

1. **最小化 unsafe 范围**
2. **封装 unsafe 代码提供安全接口**
3. **充分测试和文档化 unsafe 代码**
4. **使用 MIRI 检查 undefined behavior**

```bash
# 使用 MIRI 检测 UB
rustup +nightly component add miri
cargo +nightly miri test
```
