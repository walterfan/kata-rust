# 内部可变性

内部可变性允许在持有不可变引用时修改数据。

## RefCell<T>

运行时借用检查（单线程）。

```rust
use std::cell::RefCell;

let data = RefCell::new(5);

// 不可变借用
let r = data.borrow();
println!("{}", r);
drop(r);  // 必须先释放

// 可变借用
let mut w = data.borrow_mut();
*w += 1;
```

```{warning}
RefCell 在运行时检查借用规则。如果违反，会 **panic**：

let data = RefCell::new(5);
let r1 = data.borrow();
let r2 = data.borrow_mut();  // panic!
```

## Cell<T>

适用于 Copy 类型的简单情况。

```rust
use std::cell::Cell;

let c = Cell::new(5);
c.set(10);
println!("{}", c.get());  // 10
```

## Mutex<T> / RwLock<T>

线程安全的内部可变性。

```rust
use std::sync::Mutex;

let m = Mutex::new(5);
{
    let mut num = m.lock().unwrap();
    *num = 6;
}

use std::sync::RwLock;

let lock = RwLock::new(5);
{
    let r = lock.read().unwrap();
    println!("{}", r);
}
{
    let mut w = lock.write().unwrap();
    *w = 6;
}
```

## 常用组合

```rust
// 单线程多所有者可变
Rc<RefCell<T>>

// 多线程多所有者可变
Arc<Mutex<T>>
Arc<RwLock<T>>
```

## 与传统可变性对比

| 类型 | 线程安全 | 检查时机 | 使用场景 |
|------|---------|---------|---------|
| `&mut T` | - | 编译期 | 独占可变访问 |
| `Cell<T>` | ❌ | 无 | Copy 类型的简单值 |
| `RefCell<T>` | ❌ | 运行时 | 单线程内部可变 |
| `Mutex<T>` | ✅ | 运行时 | 多线程可变 |
| `RwLock<T>` | ✅ | 运行时 | 读多写少场景 |
