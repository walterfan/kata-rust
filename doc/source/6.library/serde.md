# Serde 序列化

Serde 是 Rust 最流行的序列化框架。

## 安装

```toml
[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
serde_yaml = "0.9"
toml = "0.8"
```

## 基本用法

```rust
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
struct Person {
    name: String,
    age: u32,
    #[serde(default)]
    email: Option<String>,
}

fn main() {
    let person = Person {
        name: "John".to_string(),
        age: 30,
        email: Some("john@example.com".to_string()),
    };
    
    // 序列化为 JSON
    let json = serde_json::to_string(&person).unwrap();
    println!("{}", json);
    
    // 反序列化
    let person: Person = serde_json::from_str(&json).unwrap();
    println!("{:?}", person);
}
```

## 常用属性

```rust
#[derive(Serialize, Deserialize)]
struct Config {
    #[serde(rename = "serverHost")]
    host: String,
    
    #[serde(default = "default_port")]
    port: u16,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    timeout: Option<u64>,
    
    #[serde(skip)]
    internal: String,
    
    #[serde(flatten)]
    extra: HashMap<String, Value>,
}

fn default_port() -> u16 {
    8080
}
```

## 枚举序列化

```rust
#[derive(Serialize, Deserialize)]
#[serde(tag = "type")]  // 内部标签
enum Message {
    #[serde(rename = "text")]
    Text { content: String },
    
    #[serde(rename = "image")]
    Image { url: String, width: u32, height: u32 },
}

// {"type": "text", "content": "hello"}
```

## 自定义序列化

```rust
use serde::{Deserialize, Deserializer, Serialize, Serializer};

#[derive(Debug)]
struct MyDate(chrono::NaiveDate);

impl Serialize for MyDate {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&self.0.format("%Y-%m-%d").to_string())
    }
}

impl<'de> Deserialize<'de> for MyDate {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        chrono::NaiveDate::parse_from_str(&s, "%Y-%m-%d")
            .map(MyDate)
            .map_err(serde::de::Error::custom)
    }
}
```
