# 线程基础

## 创建线程

```rust
use std::thread;
use std::time::Duration;

fn main() {
    // 创建新线程
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    // 主线程工作
    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }

    // 等待子线程完成
    handle.join().unwrap();
}
```

## move 闭包

当需要在线程中使用外部数据时，需要使用 `move` 关键字转移所有权：

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    // 必须使用 move，否则编译错误
    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });

    // v 已经移动到新线程，这里不能使用
    // println!("{:?}", v);  // 错误！

    handle.join().unwrap();
}
```

## 为什么需要 move？

```{note}
线程可能比创建它的作用域活得更长。如果闭包只是借用外部数据，
当原作用域结束时，数据会被释放，线程中的引用就悬垂了。

Rust 编译器强制你使用 `move`，将数据的所有权转移到线程中，
保证数据在线程生命周期内有效。
```

## 线程返回值

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        // 线程可以返回值
        let result = 40 + 2;
        result
    });

    // join() 返回 Result<T, E>，T 是线程返回值
    let result = handle.join().unwrap();
    println!("Thread returned: {}", result);  // 42
}
```

## Thread Builder

使用 `thread::Builder` 可以自定义线程属性：

```rust
use std::thread;

fn main() {
    let builder = thread::Builder::new()
        .name("worker-thread".to_string())
        .stack_size(1024 * 1024);  // 1MB 栈

    let handle = builder.spawn(|| {
        println!("Thread name: {:?}", thread::current().name());
    }).unwrap();

    handle.join().unwrap();
}
```

## 线程局部存储（Thread Local Storage）

```rust
use std::cell::RefCell;

thread_local! {
    static COUNTER: RefCell<u32> = RefCell::new(0);
}

fn main() {
    COUNTER.with(|c| {
        *c.borrow_mut() += 1;
        println!("Main thread counter: {}", c.borrow());
    });

    std::thread::spawn(|| {
        COUNTER.with(|c| {
            *c.borrow_mut() += 1;
            // 每个线程有自己的 COUNTER
            println!("Spawned thread counter: {}", c.borrow());
        });
    }).join().unwrap();

    COUNTER.with(|c| {
        // 主线程的 counter 仍然是 1
        println!("Main thread counter: {}", c.borrow());
    });
}
```

## scoped threads（作用域线程）

从 Rust 1.63 开始，可以使用作用域线程安全地借用栈上数据：

```rust
use std::thread;

fn main() {
    let mut data = vec![1, 2, 3];

    thread::scope(|s| {
        // 可以借用外部数据，不需要 move
        s.spawn(|| {
            println!("Length: {}", data.len());
        });

        s.spawn(|| {
            for item in &data {
                println!("{}", item);
            }
        });
    });  // 所有 scoped 线程在这里自动 join

    // data 仍然可用
    data.push(4);
    println!("{:?}", data);
}
```

## 与 C++ 线程对比

### C++ std::thread

```cpp
#include <thread>
#include <vector>

int main() {
    std::vector<int> v = {1, 2, 3};
    
    // 危险：可能数据竞争
    std::thread t([&v]() {
        std::cout << v[0] << std::endl;
    });
    
    v.push_back(4);  // 数据竞争！
    t.join();
}
```

### Rust thread

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];
    
    let handle = thread::spawn(move || {
        println!("{}", v[0]);
    });
    
    // v.push(4);  // 编译错误：v 已经移动
    handle.join().unwrap();
}
```

## 常见错误

### 错误 1：不使用 move

```rust
let s = String::from("hello");
thread::spawn(|| {
    println!("{}", s);  // 错误：closure may outlive the current function
});
```

### 错误 2：在 move 后使用变量

```rust
let s = String::from("hello");
thread::spawn(move || {
    println!("{}", s);
});
println!("{}", s);  // 错误：s 已移动
```

### 错误 3：忘记 join

```rust
fn main() {
    thread::spawn(|| {
        // 这个线程可能不会完成
        println!("From thread");
    });
    // main 函数结束，程序退出
}
```
