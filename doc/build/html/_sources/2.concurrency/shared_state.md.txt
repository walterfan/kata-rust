# 共享状态并发

虽然消息传递是推荐的并发方式，但有时共享状态更合适。
Rust 通过 `Mutex` 和 `Arc` 安全地实现共享状态并发。

## Mutex（互斥锁）

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(5);

    {
        // lock() 返回 MutexGuard，实现了 Deref 和 Drop
        let mut num = m.lock().unwrap();
        *num = 6;
    }  // MutexGuard 被 drop，自动释放锁

    println!("m = {:?}", m);
}
```

## Arc（原子引用计数）

`Rc<T>` 不是线程安全的，跨线程共享需要使用 `Arc<T>`：

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    // Arc 允许多个线程共享所有权
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", *counter.lock().unwrap());  // 10
}
```

## 为什么需要 Arc + Mutex？

```{note}
- `Mutex<T>` 提供内部可变性，允许通过共享引用修改数据
- `Arc<T>` 允许多个所有者（跨线程）
- 组合使用实现 **多线程共享可变状态**

类比：
- C++: `std::shared_ptr<std::mutex>` + 手动加锁
- Java: `synchronized` 或 `ReentrantLock`
- Go: `sync.Mutex`
```

## RwLock（读写锁）

当读多写少时，使用 `RwLock` 可以提高性能：

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn main() {
    let data = Arc::new(RwLock::new(vec![1, 2, 3]));
    let mut handles = vec![];

    // 多个读线程
    for i in 0..3 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            let r = data.read().unwrap();
            println!("Reader {}: {:?}", i, *r);
        }));
    }

    // 一个写线程
    {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            let mut w = data.write().unwrap();
            w.push(4);
            println!("Writer done");
        }));
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

## 原子类型

对于简单的计数器，原子类型比 Mutex 更高效：

```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::thread;

fn main() {
    let counter = Arc::new(AtomicUsize::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            counter.fetch_add(1, Ordering::SeqCst);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Result: {}", counter.load(Ordering::SeqCst));
}
```

### 常用原子操作

```rust
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};

let flag = AtomicBool::new(false);
let counter = AtomicUsize::new(0);

// 原子设置
flag.store(true, Ordering::SeqCst);

// 原子读取
let val = flag.load(Ordering::SeqCst);

// 比较并交换
let old = counter.compare_exchange(0, 1, Ordering::SeqCst, Ordering::SeqCst);

// 原子加法并返回旧值
let old = counter.fetch_add(1, Ordering::SeqCst);
```

## 死锁

Rust 不能防止死锁，需要程序员注意：

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let a = Arc::new(Mutex::new(0));
    let b = Arc::new(Mutex::new(0));

    let a1 = Arc::clone(&a);
    let b1 = Arc::clone(&b);
    let t1 = thread::spawn(move || {
        let _a = a1.lock().unwrap();
        thread::sleep(std::time::Duration::from_millis(100));
        let _b = b1.lock().unwrap();  // 可能死锁！
    });

    let a2 = Arc::clone(&a);
    let b2 = Arc::clone(&b);
    let t2 = thread::spawn(move || {
        let _b = b2.lock().unwrap();
        thread::sleep(std::time::Duration::from_millis(100));
        let _a = a2.lock().unwrap();  // 可能死锁！
    });

    t1.join().unwrap();
    t2.join().unwrap();
}
```

### 避免死锁

1. **始终按相同顺序获取锁**
2. **使用超时锁**：`try_lock()`
3. **使用更高级的同步原语**：如 `parking_lot` crate

## Send 和 Sync Trait

```{important}
Rust 使用 `Send` 和 `Sync` trait 确保线程安全：

- **Send**：类型可以安全地跨线程转移所有权
- **Sync**：类型可以安全地被多线程共享引用（即 `&T` 是 `Send`）

大多数类型自动实现这两个 trait。不实现的例子：
- `Rc<T>`：不是 Send，因为引用计数不是原子的
- `RefCell<T>`：不是 Sync，因为借用检查不是线程安全的
- 裸指针：都不是

如果尝试跨线程使用这些类型，编译器会报错。
```

## parking_lot（推荐）

`parking_lot` crate 提供了更快的锁实现：

```toml
[dependencies]
parking_lot = "0.12"
```

```rust
use parking_lot::{Mutex, RwLock};
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(Mutex::new(0));
    
    let data_clone = Arc::clone(&data);
    thread::spawn(move || {
        // parking_lot 的 lock() 不返回 Result
        let mut num = data_clone.lock();
        *num += 1;
    }).join().unwrap();

    println!("Result: {}", *data.lock());
}
```

### parking_lot 优势

1. **不需要 unwrap**：lock() 不会因为 poison 而 panic
2. **性能更好**：特别是在低竞争情况下
3. **更小的内存占用**：Mutex 只占用 1 字节
4. **公平锁选项**：`FairMutex`

## 与其他语言对比

### C++ std::mutex

```cpp
std::mutex m;
int counter = 0;

void increment() {
    std::lock_guard<std::mutex> lock(m);
    counter++;  // 可能忘记加锁！
}
```

### Rust Mutex

```rust
let counter = Mutex::new(0);

fn increment(counter: &Mutex<i32>) {
    let mut num = counter.lock().unwrap();
    *num += 1;  // 不持有锁就无法访问数据
}
```

Rust 的优势：**数据和锁绑定**，不可能忘记加锁。
