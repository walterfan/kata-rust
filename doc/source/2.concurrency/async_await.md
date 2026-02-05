# async/await 异步编程

Rust 的异步编程模型基于 **Future** 和 **async/await** 语法。

## 什么是 async/await

```rust
// async 函数返回 Future
async fn fetch_data() -> String {
    // await 暂停执行，等待 Future 完成
    "data".to_string()
}

async fn process() {
    let data = fetch_data().await;  // 等待异步操作完成
    println!("{}", data);
}
```

## Future 概念

```{note}
**Future** 是一个可能还没完成的计算。关键特点：

1. **懒惰执行**：创建 Future 不会执行它
2. **需要轮询（poll）**：运行时负责驱动 Future 完成
3. **零成本抽象**：编译为状态机，无堆分配

与 JavaScript Promise 的区别：
- Promise 创建后立即开始执行
- Future 需要被 poll 才会推进
```

## 基本用法

```rust
use std::future::Future;

// async fn 是语法糖
async fn hello() -> String {
    "Hello".to_string()
}

// 等价于
fn hello_explicit() -> impl Future<Output = String> {
    async {
        "Hello".to_string()
    }
}
```

## 运行时（Runtime）

Rust 标准库没有内置异步运行时，需要使用第三方 crate：

### 使用 tokio

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

```rust
#[tokio::main]
async fn main() {
    let result = hello().await;
    println!("{}", result);
}

async fn hello() -> &'static str {
    "Hello, async world!"
}
```

### 使用 async-std

```toml
[dependencies]
async-std = { version = "1", features = ["attributes"] }
```

```rust
#[async_std::main]
async fn main() {
    let result = hello().await;
    println!("{}", result);
}
```

## 并发执行多个 Future

### join! 宏

```rust
use tokio::time::{sleep, Duration};

async fn task1() -> u32 {
    sleep(Duration::from_secs(1)).await;
    1
}

async fn task2() -> u32 {
    sleep(Duration::from_secs(1)).await;
    2
}

#[tokio::main]
async fn main() {
    // 并发执行，总时间约 1 秒
    let (r1, r2) = tokio::join!(task1(), task2());
    println!("{}, {}", r1, r2);
}
```

### select! 宏

```rust
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
    tokio::select! {
        _ = sleep(Duration::from_secs(1)) => {
            println!("1 second elapsed");
        }
        _ = sleep(Duration::from_secs(2)) => {
            println!("2 seconds elapsed");
        }
    }
    // 只会打印 "1 second elapsed"
}
```

## async 闭包和块

```rust
// async 块
let future = async {
    let x = 1;
    let y = 2;
    x + y
};

// 等待结果
let result = future.await;

// async move 块（捕获所有权）
let s = String::from("hello");
let future = async move {
    println!("{}", s);
};
```

## Pin 和 Unpin

```{warning}
这是 Rust 异步编程中最复杂的概念之一。

**问题**：async 块可能包含自引用（引用自己的局部变量）。
如果内存移动，这些引用就会失效。

**解决**：`Pin<P>` 保证指针指向的数据不会被移动。

大多数情况下你不需要直接处理 Pin，
因为 `tokio::spawn`、`Box::pin` 等会为你处理。
```

```rust
use std::pin::Pin;
use std::future::Future;

// 手动 pin 一个 Future
fn spawn_pinned<F: Future + Send + 'static>(f: F) 
where
    F::Output: Send,
{
    let pinned = Box::pin(f);
    tokio::spawn(pinned);
}
```

## 错误处理

```rust
use std::io;

async fn read_file() -> io::Result<String> {
    // ? 在 async 函数中正常工作
    let content = tokio::fs::read_to_string("file.txt").await?;
    Ok(content)
}

#[tokio::main]
async fn main() -> io::Result<()> {
    let content = read_file().await?;
    println!("{}", content);
    Ok(())
}
```

## 常见陷阱

### 陷阱 1：阻塞 async 运行时

```rust
// 错误：在 async 中使用阻塞操作
async fn bad() {
    std::thread::sleep(Duration::from_secs(1));  // 阻塞整个线程！
}

// 正确：使用 async 版本
async fn good() {
    tokio::time::sleep(Duration::from_secs(1)).await;
}
```

### 陷阱 2：跨 await 持有非 Send 类型

```rust
use std::rc::Rc;

async fn bad() {
    let rc = Rc::new(1);
    some_async_fn().await;  // 错误：Rc 不是 Send
    println!("{}", rc);
}

// 解决：限制非 Send 类型的作用域
async fn good() {
    {
        let rc = Rc::new(1);
        println!("{}", rc);
    }  // rc 在这里 drop
    some_async_fn().await;  // OK
}
```

### 陷阱 3：忘记 await

```rust
async fn fetch() -> String { "data".to_string() }

async fn bad() {
    let future = fetch();  // 只是创建了 Future，没有执行！
    // 没有 await，fetch 永远不会执行
}

async fn good() {
    let data = fetch().await;  // 正确执行
}
```

## 与其他语言对比

### JavaScript async/await

```javascript
// JavaScript: Promise 立即开始执行
async function fetchData() {
    const response = await fetch(url);
    return response.json();
}
```

### Rust async/await

```rust
// Rust: Future 是惰性的
async fn fetch_data() -> String {
    let response = reqwest::get(url).await.unwrap();
    response.text().await.unwrap()
}
// 必须 .await 或 spawn 才会执行
```

### Go goroutine

```go
// Go: 隐式并发，无需 await
go fetchData()  // 自动并发
```

### Rust spawn

```rust
// Rust: 显式并发
tokio::spawn(fetch_data());  // 显式启动
```
