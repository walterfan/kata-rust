# 消息传递

Rust 提供了 **channel**（通道）来实现线程间的消息传递。
这种方式遵循 **"不要通过共享内存来通信，而是通过通信来共享内存"** 的理念。

## 标准库 Channel

### 基本用法

```rust
use std::sync::mpsc;  // multiple producer, single consumer
use std::thread;

fn main() {
    // 创建通道
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
        // val 已经移动，这里不能使用
        // println!("{}", val);  // 错误
    });

    // 接收消息（阻塞）
    let received = rx.recv().unwrap();
    println!("Got: {}", received);
}
```

### 发送多个值

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_millis(200));
        }
    });

    // rx 可以作为迭代器使用
    for received in rx {
        println!("Got: {}", received);
    }
}
```

### 多个生产者

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    // 克隆发送端
    let tx1 = tx.clone();
    thread::spawn(move || {
        tx1.send(String::from("hi from 1")).unwrap();
    });

    thread::spawn(move || {
        tx.send(String::from("hi from 2")).unwrap();
    });

    for received in rx {
        println!("Got: {}", received);
    }
}
```

## 同步通道（Bounded Channel）

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    // 创建有界通道，缓冲区大小为 1
    let (tx, rx) = mpsc::sync_channel(1);

    thread::spawn(move || {
        tx.send(1).unwrap();  // 立即返回
        println!("Sent 1");
        tx.send(2).unwrap();  // 可能阻塞，直到接收方消费
        println!("Sent 2");
    });

    thread::sleep(std::time::Duration::from_secs(1));
    println!("Received: {}", rx.recv().unwrap());
    println!("Received: {}", rx.recv().unwrap());
}
```

## 非阻塞接收

```rust
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();
    
    tx.send(1).unwrap();

    // try_recv 不阻塞
    match rx.try_recv() {
        Ok(msg) => println!("Received: {}", msg),
        Err(mpsc::TryRecvError::Empty) => println!("No message"),
        Err(mpsc::TryRecvError::Disconnected) => println!("Channel closed"),
    }
}
```

## 超时接收

```rust
use std::sync::mpsc;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel::<i32>();

    // recv_timeout：等待指定时间
    match rx.recv_timeout(Duration::from_secs(1)) {
        Ok(msg) => println!("Received: {}", msg),
        Err(mpsc::RecvTimeoutError::Timeout) => println!("Timeout"),
        Err(mpsc::RecvTimeoutError::Disconnected) => println!("Disconnected"),
    }
}
```

## crossbeam-channel（推荐）

标准库的 `mpsc` 只支持多生产者单消费者。对于更复杂的场景，使用 `crossbeam-channel`：

```toml
[dependencies]
crossbeam-channel = "0.5"
```

```rust
use crossbeam_channel::{bounded, unbounded, select};
use std::thread;

fn main() {
    // 无界通道
    let (s, r) = unbounded();
    
    // 有界通道
    let (s2, r2) = bounded(10);

    thread::spawn(move || {
        s.send("hello").unwrap();
    });

    // select! 宏可以同时等待多个通道
    select! {
        recv(r) -> msg => println!("Received: {:?}", msg),
        recv(r2) -> msg => println!("Received from r2: {:?}", msg),
    }
}
```

### crossbeam 多消费者

```rust
use crossbeam_channel::unbounded;
use std::thread;

fn main() {
    let (s, r) = unbounded();

    // 可以 clone 接收端
    let r2 = r.clone();

    thread::spawn(move || {
        for msg in r {
            println!("Consumer 1: {}", msg);
        }
    });

    thread::spawn(move || {
        for msg in r2 {
            println!("Consumer 2: {}", msg);
        }
    });

    for i in 0..10 {
        s.send(i).unwrap();
    }
}
```

## 实际应用模式

### 工作队列

```rust
use std::sync::mpsc;
use std::thread;

fn main() {
    let (tx, rx) = mpsc::channel();

    // 启动工作线程
    let worker = thread::spawn(move || {
        for task in rx {
            println!("Processing task: {}", task);
        }
        println!("Worker shutting down");
    });

    // 发送任务
    for i in 0..5 {
        tx.send(format!("Task {}", i)).unwrap();
    }

    // 关闭通道（drop tx）
    drop(tx);

    worker.join().unwrap();
}
```

### 请求-响应模式

```rust
use std::sync::mpsc;
use std::thread;

struct Request {
    data: String,
    response_channel: mpsc::Sender<String>,
}

fn main() {
    let (tx, rx) = mpsc::channel();

    // 服务线程
    thread::spawn(move || {
        for request in rx {
            let response = format!("Processed: {}", request.data);
            request.response_channel.send(response).unwrap();
        }
    });

    // 发送请求
    let (resp_tx, resp_rx) = mpsc::channel();
    tx.send(Request {
        data: "Hello".to_string(),
        response_channel: resp_tx,
    }).unwrap();

    // 等待响应
    let response = resp_rx.recv().unwrap();
    println!("{}", response);
}
```

## 与 Go Channel 对比

```{note}
Rust 的 channel 与 Go 的 channel 类似，但有一些区别：

1. **所有权转移**：Rust 发送时会移动数据，Go 会复制
2. **类型安全**：Rust 在编译期检查类型，Go 使用 interface{}
3. **select**：Go 内置 select，Rust 使用 crossbeam 的 select!

Go 的方式：
```go
ch := make(chan int)
go func() { ch <- 42 }()
val := <-ch
```

Rust 的方式：
```rust
let (tx, rx) = channel();
spawn(move || tx.send(42).unwrap());
let val = rx.recv().unwrap();
```
```
