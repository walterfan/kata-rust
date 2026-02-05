# 错误处理库

## thiserror（库开发者）

定义自定义错误类型：

```toml
[dependencies]
thiserror = "1"
```

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DataError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
    
    #[error("Invalid data: {message}")]
    Invalid { message: String },
    
    #[error("Not found: {0}")]
    NotFound(String),
}

fn read_config() -> Result<Config, DataError> {
    let content = std::fs::read_to_string("config.txt")?;  // 自动转换 io::Error
    let port: u16 = content.parse()?;  // 自动转换 ParseIntError
    Ok(Config { port })
}
```

## anyhow（应用程序）

简化错误处理：

```toml
[dependencies]
anyhow = "1"
```

```rust
use anyhow::{Context, Result, bail, ensure};

fn main() -> Result<()> {
    let config = read_config()
        .context("Failed to read configuration")?;
    
    ensure!(config.port > 0, "Port must be positive");
    
    if config.port > 65535 {
        bail!("Port {} is out of range", config.port);
    }
    
    Ok(())
}

fn read_config() -> Result<Config> {
    let content = std::fs::read_to_string("config.txt")
        .context("Could not read config.txt")?;
    
    let port: u16 = content.trim().parse()
        .context("Invalid port number")?;
    
    Ok(Config { port })
}
```

## 错误链

```rust
use anyhow::Result;

fn main() -> Result<()> {
    if let Err(e) = run() {
        // 打印错误链
        eprintln!("Error: {}", e);
        for cause in e.chain().skip(1) {
            eprintln!("Caused by: {}", cause);
        }
    }
    Ok(())
}
```

## 何时使用哪个

| 场景 | 推荐 |
|------|------|
| 库开发 | thiserror |
| 应用程序 | anyhow |
| 需要错误类型 | thiserror |
| 快速原型 | anyhow |
