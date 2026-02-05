# 性能分析

## perf（Linux）

```bash
# 记录性能数据
perf record -g ./target/release/myapp

# 查看报告
perf report

# 生成 flamegraph
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

## Flamegraph

```toml
[dependencies]
# 开发时使用
[profile.release]
debug = true  # 保留调试信息用于分析
```

```bash
# 安装 flamegraph 工具
cargo install flamegraph

# 生成火焰图
cargo flamegraph --bin myapp
```

## 内置性能统计

```rust
use std::time::Instant;

fn main() {
    let start = Instant::now();
    
    // 要测量的代码
    expensive_operation();
    
    let duration = start.elapsed();
    println!("Time: {:?}", duration);
}
```

## tracing 库

```toml
[dependencies]
tracing = "0.1"
tracing-subscriber = "0.3"
```

```rust
use tracing::{info, instrument, span, Level};
use tracing_subscriber;

#[instrument]
fn expensive_operation(n: u32) -> u32 {
    info!("Starting operation");
    // ...
    n * 2
}

fn main() {
    tracing_subscriber::fmt::init();
    
    let result = expensive_operation(42);
}
```

## 内存分析

### Valgrind（Linux）

```bash
valgrind --tool=massif ./target/release/myapp
ms_print massif.out.*
```

### heaptrack（Linux）

```bash
heaptrack ./target/release/myapp
heaptrack_gui heaptrack.*.gz
```

## 常见性能问题

### 1. 不必要的克隆

```rust
// 慢
fn process(s: String) { ... }
let s = String::from("hello");
process(s.clone());
process(s);

// 快
fn process(s: &str) { ... }
let s = String::from("hello");
process(&s);
process(&s);
```

### 2. 小字符串优化

```rust
// 考虑使用 SmartString 或 CompactString
use compact_str::CompactString;
```

### 3. 预分配容量

```rust
// 慢：多次重新分配
let mut v = Vec::new();
for i in 0..1000 {
    v.push(i);
}

// 快：预分配
let mut v = Vec::with_capacity(1000);
for i in 0..1000 {
    v.push(i);
}
```
