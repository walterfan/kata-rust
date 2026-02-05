# 内存泄漏检测

## Rust 中的内存泄漏

```{note}
Rust 保证 **内存安全**（无悬垂指针、无数据竞争），
但 **不保证** 无内存泄漏。

可能的泄漏场景：
1. `std::mem::forget()`
2. `Rc` 循环引用
3. 忘记关闭 channel
```

## 检测工具

### Valgrind

```bash
# 需要 debug 符号
cargo build
valgrind --leak-check=full ./target/debug/myapp
```

### AddressSanitizer

```bash
RUSTFLAGS="-Z sanitizer=address" cargo +nightly run
```

### MIRI

```bash
rustup +nightly component add miri
cargo +nightly miri run
```

## 循环引用示例

```rust
use std::rc::Rc;
use std::cell::RefCell;

struct Node {
    next: RefCell<Option<Rc<Node>>>,
}

// 创建循环引用
let a = Rc::new(Node { next: RefCell::new(None) });
let b = Rc::new(Node { next: RefCell::new(Some(Rc::clone(&a))) });
*a.next.borrow_mut() = Some(Rc::clone(&b));
// a -> b -> a，永远不会释放

// 解决：使用 Weak
use std::rc::Weak;

struct Node2 {
    next: RefCell<Option<Weak<Node2>>>,
}
```

## 手动释放

```rust
// 显式 drop
let v = vec![1, 2, 3];
drop(v);
// v 在这里已经释放

// ManuallyDrop
use std::mem::ManuallyDrop;

let mut data = ManuallyDrop::new(String::from("hello"));
// 手动决定何时释放
unsafe {
    ManuallyDrop::drop(&mut data);
}
```
