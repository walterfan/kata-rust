# 日志和追踪

## tracing（推荐）

```toml
[dependencies]
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
```

### 基本用法

```rust
use tracing::{info, warn, error, debug, trace, instrument};
use tracing_subscriber;

#[instrument]
fn process_data(id: u32) {
    info!("Processing data");
    debug!(id, "Data ID");
    
    if id == 0 {
        warn!("ID is zero");
    }
}

fn main() {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();
    
    info!("Application started");
    process_data(42);
}
```

### Span

```rust
use tracing::{span, Level};

let span = span!(Level::INFO, "my_span", id = 42);
let _enter = span.enter();

info!("Inside span");
```

### 异步追踪

```rust
#[instrument]
async fn async_operation(id: u32) -> String {
    info!("Starting async operation");
    tokio::time::sleep(Duration::from_secs(1)).await;
    format!("Result for {}", id)
}
```

## env_logger

简单的日志实现：

```toml
[dependencies]
log = "0.4"
env_logger = "0.10"
```

```rust
use log::{info, warn, error};

fn main() {
    env_logger::init();
    
    info!("Starting application");
    warn!("This is a warning");
    error!("This is an error");
}
```

```bash
RUST_LOG=debug cargo run
```

## 结构化日志

```rust
use tracing::info;

struct User {
    id: u32,
    name: String,
}

let user = User { id: 1, name: "Alice".to_string() };

info!(
    user.id,
    user.name,
    action = "login",
    "User logged in"
);

// Output: 2024-01-01T00:00:00 INFO User logged in user.id=1 user.name="Alice" action="login"
```
