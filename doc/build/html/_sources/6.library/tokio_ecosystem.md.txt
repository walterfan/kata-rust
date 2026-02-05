# Tokio 生态

## 核心组件

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

- **Runtime**：异步执行器
- **I/O**：异步文件和网络
- **Time**：定时器
- **Sync**：异步同步原语

## 相关库

### tokio-util

```toml
tokio-util = { version = "0.7", features = ["codec"] }
```

```rust
use tokio_util::codec::{Framed, LinesCodec};

let lines = Framed::new(socket, LinesCodec::new());
```

### tokio-stream

```rust
use tokio_stream::StreamExt;

let mut stream = tokio_stream::iter(vec![1, 2, 3]);
while let Some(value) = stream.next().await {
    println!("{}", value);
}
```

### tower

HTTP 中间件框架：

```rust
use tower::{ServiceBuilder, ServiceExt};
use tower_http::timeout::TimeoutLayer;

let service = ServiceBuilder::new()
    .layer(TimeoutLayer::new(Duration::from_secs(10)))
    .service(my_service);
```

## 常用模式

### 优雅关闭

```rust
use tokio::signal;

#[tokio::main]
async fn main() {
    let server = tokio::spawn(async {
        // 运行服务器
    });
    
    signal::ctrl_c().await.unwrap();
    println!("Shutting down...");
    
    // 优雅关闭
    server.abort();
}
```

### 并发限制

```rust
use tokio::sync::Semaphore;
use std::sync::Arc;

let semaphore = Arc::new(Semaphore::new(10));

for url in urls {
    let permit = semaphore.clone().acquire_owned().await.unwrap();
    tokio::spawn(async move {
        fetch(url).await;
        drop(permit);  // 释放许可
    });
}
```
