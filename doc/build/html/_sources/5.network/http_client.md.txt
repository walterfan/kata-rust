# HTTP 客户端

## reqwest（推荐）

```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
```

### 基本请求

```rust
use reqwest;

#[tokio::main]
async fn main() -> Result<(), reqwest::Error> {
    // GET 请求
    let body = reqwest::get("https://httpbin.org/get")
        .await?
        .text()
        .await?;
    
    println!("{}", body);
    
    Ok(())
}
```

### POST JSON

```rust
use reqwest::Client;
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct CreateUser {
    name: String,
    email: String,
}

#[derive(Deserialize)]
struct User {
    id: u64,
    name: String,
}

#[tokio::main]
async fn main() -> Result<(), reqwest::Error> {
    let client = Client::new();
    
    let new_user = CreateUser {
        name: "John".to_string(),
        email: "john@example.com".to_string(),
    };
    
    let response = client
        .post("https://api.example.com/users")
        .json(&new_user)
        .send()
        .await?;
    
    let user: User = response.json().await?;
    println!("Created user: {:?}", user.id);
    
    Ok(())
}
```

### 带 Header

```rust
use reqwest::header::{AUTHORIZATION, CONTENT_TYPE};

let client = Client::new();

let response = client
    .get("https://api.example.com/data")
    .header(AUTHORIZATION, "Bearer token123")
    .header(CONTENT_TYPE, "application/json")
    .send()
    .await?;
```

### 处理错误和状态码

```rust
let response = client.get(url).send().await?;

match response.status() {
    reqwest::StatusCode::OK => {
        let data = response.json::<MyData>().await?;
    }
    reqwest::StatusCode::NOT_FOUND => {
        println!("Not found");
    }
    _ => {
        println!("Unexpected status: {}", response.status());
    }
}
```

### 超时设置

```rust
use std::time::Duration;

let client = Client::builder()
    .timeout(Duration::from_secs(10))
    .connect_timeout(Duration::from_secs(5))
    .build()?;
```

## 同步请求

```rust
// 使用 blocking 功能
// reqwest = { version = "0.11", features = ["blocking"] }

use reqwest::blocking;

fn main() -> Result<(), reqwest::Error> {
    let body = blocking::get("https://httpbin.org/get")?
        .text()?;
    
    println!("{}", body);
    Ok(())
}
```
