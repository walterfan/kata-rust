# 错误处理

Rust 没有异常机制，而是使用 `Result` 和 `Option` 类型进行错误处理。
这是与 C++/Java 最大的不同之一。

## Option：处理可能为空的值

```rust
enum Option<T> {
    Some(T),
    None,
}
```

### 替代 null

```rust
// Java 思维（不要这样做）：
// String s = null;
// if (s != null) { ... }

// Rust 思维：
let s: Option<String> = None;
if let Some(value) = s {
    println!("{}", value);
}
```

### 常用方法

```rust
let some_number = Some(5);
let no_number: Option<i32> = None;

// unwrap：有值返回，None 则 panic
let x = some_number.unwrap();  // 5
// let y = no_number.unwrap();  // panic!

// unwrap_or：提供默认值
let x = no_number.unwrap_or(0);  // 0

// unwrap_or_else：延迟计算默认值
let x = no_number.unwrap_or_else(|| expensive_computation());

// map：转换内部值
let x = some_number.map(|n| n * 2);  // Some(10)

// and_then：链式操作
let x = some_number
    .and_then(|n| Some(n.to_string()))  // Some("5")
    .and_then(|s| s.parse::<i32>().ok());  // Some(5)

// is_some / is_none
if some_number.is_some() {
    println!("Has value");
}
```

## Result：处理可能失败的操作

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

### 基本用法

```rust
use std::fs::File;
use std::io::Read;

fn read_file(path: &str) -> Result<String, std::io::Error> {
    let mut file = File::open(path)?;  // ? 操作符
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn main() {
    match read_file("hello.txt") {
        Ok(contents) => println!("{}", contents),
        Err(e) => eprintln!("Error: {}", e),
    }
}
```

### ? 操作符

`?` 是错误传播的语法糖：

```rust
// 使用 ?
fn read_file(path: &str) -> Result<String, std::io::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

// 等同于
fn read_file(path: &str) -> Result<String, std::io::Error> {
    let mut file = match File::open(path) {
        Ok(f) => f,
        Err(e) => return Err(e),
    };
    // ...
}
```

### Result 常用方法

```rust
let ok: Result<i32, &str> = Ok(5);
let err: Result<i32, &str> = Err("error");

// unwrap / expect
let x = ok.unwrap();         // 5
let x = ok.expect("failed"); // 5，panic 时显示 "failed"

// unwrap_or / unwrap_or_else
let x = err.unwrap_or(0);    // 0
let x = err.unwrap_or_else(|e| {
    eprintln!("Error: {}", e);
    0
});

// map / map_err
let x = ok.map(|n| n * 2);           // Ok(10)
let x = err.map_err(|e| e.len());    // Err(5)

// and_then
let x = ok.and_then(|n| Ok(n.to_string()));  // Ok("5")

// ok / err：转换为 Option
let x = ok.ok();   // Some(5)
let x = err.err(); // Some("error")
```

## 与 C++ 异常的对比

### C++ 异常问题

```cpp
void process() {
    try {
        auto file = openFile("data.txt");
        // 如果这里抛异常，file 的析构函数会被调用吗？
        processFile(file);
    } catch (const std::exception& e) {
        // 需要捕获哪些异常？文档通常不完整
    }
}
```

### Rust Result 优势

```rust
fn process() -> Result<(), Error> {
    let file = open_file("data.txt")?;  // 错误类型明确
    process_file(&file)?;               // 必须处理或传播
    Ok(())
}
```

优势：
1. **显式错误类型**：函数签名明确告诉你可能的错误
2. **强制处理**：不处理 Result 会有编译警告
3. **零成本**：没有异常表，没有 unwinding 开销

## 与 Java 异常的对比

### Java Checked Exception 的问题

```java
// Java 强制处理 checked exception
public void process() throws IOException {
    // 但 unchecked exception（如 NullPointerException）不强制处理
}
```

### Rust 的一致性

```rust
// 所有可能失败的操作都返回 Result
fn process() -> Result<(), MyError> {
    // 统一的错误处理模式
}
```

## 自定义错误类型

### 简单错误

```rust
#[derive(Debug)]
struct MyError {
    message: String,
}

impl std::fmt::Display for MyError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl std::error::Error for MyError {}
```

### 使用 thiserror（推荐）

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum DataError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
    
    #[error("Invalid data: {0}")]
    Invalid(String),
}
```

### 使用 anyhow（应用程序）

```rust
use anyhow::{Context, Result};

fn main() -> Result<()> {
    let config = std::fs::read_to_string("config.toml")
        .context("Failed to read config file")?;
    
    let port: u16 = config.parse()
        .context("Failed to parse port number")?;
    
    Ok(())
}
```

## panic! 何时使用

```{warning}
`panic!` 会终止程序（或线程），只在以下情况使用：

1. **不可恢复的错误**：程序状态已损坏
2. **编程错误**：如数组越界（bug，不是预期错误）
3. **测试和原型**：快速失败，稍后处理
```

```rust
// 合理使用 panic
fn divide(a: i32, b: i32) -> i32 {
    if b == 0 {
        panic!("Division by zero");  // 编程错误
    }
    a / b
}

// 更好的做法：返回 Result
fn divide_safe(a: i32, b: i32) -> Result<i32, &'static str> {
    if b == 0 {
        Err("Division by zero")
    } else {
        Ok(a / b)
    }
}
```

## 常见模式

### 组合多个 Option/Result

```rust
// 使用 ? 在 Option 上下文中
fn get_user_age(user_id: u32) -> Option<u32> {
    let user = get_user(user_id)?;
    let profile = get_profile(&user)?;
    profile.age
}

// 使用 collect 收集 Result
let results: Result<Vec<i32>, _> = 
    vec!["1", "2", "3"]
        .iter()
        .map(|s| s.parse::<i32>())
        .collect();  // 任一失败则整体失败
```

### 忽略错误（慎用）

```rust
// 明确忽略错误
let _ = do_something();

// 或使用 ok() 转换为 Option 然后忽略
do_something().ok();
```

## 练习

1. 重写下面的 Java 风格代码为惯用 Rust：

```rust
fn get_value(map: &HashMap<String, String>, key: &str) -> String {
    if map.contains_key(key) {
        map.get(key).unwrap().clone()
    } else {
        String::new()
    }
}
```

<details>
<summary>答案</summary>

```rust
fn get_value(map: &HashMap<String, String>, key: &str) -> String {
    map.get(key).cloned().unwrap_or_default()
}

// 或者返回 Option 让调用者决定
fn get_value(map: &HashMap<String, String>, key: &str) -> Option<&String> {
    map.get(key)
}
```
</details>
