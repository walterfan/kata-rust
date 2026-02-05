# Tokio 异步运行时

Tokio 是 Rust 最流行的异步运行时，提供了完整的异步生态系统。

## 安装

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

特性说明：
- `full`：启用所有特性
- `rt`：运行时核心
- `rt-multi-thread`：多线程调度器
- `io-util`：I/O 工具
- `net`：网络
- `time`：定时器
- `fs`：文件系统
- `sync`：同步原语
- `macros`：宏（`#[tokio::main]` 等）

## 运行时配置

### 使用宏

```rust
// 多线程运行时（默认）
#[tokio::main]
async fn main() {
    println!("Hello from Tokio!");
}

// 单线程运行时
#[tokio::main(flavor = "current_thread")]
async fn main() {
    println!("Single threaded!");
}

// 自定义线程数
#[tokio::main(worker_threads = 4)]
async fn main() {
    println!("4 worker threads!");
}
```

### 手动构建运行时

```rust
use tokio::runtime::Runtime;

fn main() {
    let rt = Runtime::new().unwrap();
    
    rt.block_on(async {
        println!("Running in Tokio runtime");
    });
}
```

## 任务（Tasks）

### spawn

```rust
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
    // spawn 返回 JoinHandle
    let handle = tokio::spawn(async {
        sleep(Duration::from_secs(1)).await;
        "Task completed"
    });

    // 等待任务完成
    let result = handle.await.unwrap();
    println!("{}", result);
}
```

### spawn_blocking

用于执行阻塞操作，不会阻塞异步运行时：

```rust
#[tokio::main]
async fn main() {
    let result = tokio::task::spawn_blocking(|| {
        // 这里可以执行阻塞操作
        std::thread::sleep(std::time::Duration::from_secs(1));
        "Blocking task done"
    }).await.unwrap();

    println!("{}", result);
}
```

### 本地任务

```rust
use tokio::task::LocalSet;

#[tokio::main]
async fn main() {
    let local = LocalSet::new();
    
    // spawn_local 只能在 LocalSet 中使用
    local.run_until(async {
        tokio::task::spawn_local(async {
            // 可以使用非 Send 类型
            let rc = std::rc::Rc::new(42);
            println!("{}", rc);
        }).await.unwrap();
    }).await;
}
```

## 异步 I/O

### 文件操作

```rust
use tokio::fs;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[tokio::main]
async fn main() -> std::io::Result<()> {
    // 写文件
    fs::write("hello.txt", "Hello, Tokio!").await?;

    // 读文件
    let contents = fs::read_to_string("hello.txt").await?;
    println!("{}", contents);

    // 使用 File
    let mut file = fs::File::create("data.txt").await?;
    file.write_all(b"Some data").await?;

    Ok(())
}
```

### TCP 服务器

```rust
use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080").await?;
    
    loop {
        let (mut socket, addr) = listener.accept().await?;
        println!("New connection from {}", addr);
        
        tokio::spawn(async move {
            let mut buf = [0; 1024];
            
            loop {
                let n = match socket.read(&mut buf).await {
                    Ok(0) => return,  // Connection closed
                    Ok(n) => n,
                    Err(_) => return,
                };

                // Echo back
                if socket.write_all(&buf[..n]).await.is_err() {
                    return;
                }
            }
        });
    }
}
```

### TCP 客户端

```rust
use tokio::net::TcpStream;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let mut stream = TcpStream::connect("127.0.0.1:8080").await?;
    
    stream.write_all(b"Hello, server!").await?;
    
    let mut buf = [0; 1024];
    let n = stream.read(&mut buf).await?;
    
    println!("Received: {}", String::from_utf8_lossy(&buf[..n]));
    
    Ok(())
}
```

## 同步原语

### Mutex

```rust
use tokio::sync::Mutex;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    let data = Arc::new(Mutex::new(0));
    
    let mut handles = vec![];
    
    for _ in 0..10 {
        let data = Arc::clone(&data);
        handles.push(tokio::spawn(async move {
            let mut lock = data.lock().await;
            *lock += 1;
        }));
    }
    
    for handle in handles {
        handle.await.unwrap();
    }
    
    println!("Result: {}", *data.lock().await);
}
```

### Channel

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    // 有界通道
    let (tx, mut rx) = mpsc::channel(100);
    
    tokio::spawn(async move {
        for i in 0..10 {
            tx.send(i).await.unwrap();
        }
    });
    
    while let Some(value) = rx.recv().await {
        println!("Received: {}", value);
    }
}
```

### broadcast

```rust
use tokio::sync::broadcast;

#[tokio::main]
async fn main() {
    let (tx, mut rx1) = broadcast::channel(16);
    let mut rx2 = tx.subscribe();
    
    tokio::spawn(async move {
        while let Ok(value) = rx1.recv().await {
            println!("rx1: {}", value);
        }
    });
    
    tokio::spawn(async move {
        while let Ok(value) = rx2.recv().await {
            println!("rx2: {}", value);
        }
    });
    
    tx.send(1).unwrap();
    tx.send(2).unwrap();
    
    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
}
```

### oneshot

```rust
use tokio::sync::oneshot;

#[tokio::main]
async fn main() {
    let (tx, rx) = oneshot::channel();
    
    tokio::spawn(async move {
        tx.send("Hello from task").unwrap();
    });
    
    let result = rx.await.unwrap();
    println!("{}", result);
}
```

## 定时器

```rust
use tokio::time::{sleep, interval, timeout, Duration};

#[tokio::main]
async fn main() {
    // 延迟
    sleep(Duration::from_secs(1)).await;
    
    // 定时器
    let mut interval = interval(Duration::from_millis(100));
    for _ in 0..5 {
        interval.tick().await;
        println!("tick");
    }
    
    // 超时
    let result = timeout(Duration::from_secs(1), async {
        sleep(Duration::from_secs(2)).await;
        "done"
    }).await;
    
    match result {
        Ok(value) => println!("Completed: {}", value),
        Err(_) => println!("Timeout!"),
    }
}
```

## 最佳实践

1. **避免在 async 中阻塞**：使用 `spawn_blocking` 处理阻塞操作
2. **适当设置 channel 大小**：太小可能导致背压，太大浪费内存
3. **使用 `tokio::select!`**：处理多个并发操作
4. **谨慎使用 `Mutex`**：考虑是否可以用 channel 替代
5. **错误处理**：使用 `?` 和 `Result` 传播错误
