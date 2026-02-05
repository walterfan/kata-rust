# 优化技巧

## 编译器优化

### Cargo.toml 配置

```toml
[profile.release]
opt-level = 3        # 最高优化级别
lto = true           # 链接时优化
codegen-units = 1    # 单代码生成单元（更好的优化）
panic = "abort"      # 减小二进制大小

[profile.release-with-debug]
inherits = "release"
debug = true         # 保留调试信息用于分析
```

### 平台特定优化

```toml
[build]
rustflags = ["-C", "target-cpu=native"]
```

## 常见优化模式

### 1. 避免不必要的分配

```rust
// 慢：每次迭代都分配
for item in items {
    let s = format!("Item: {}", item);
    process(&s);
}

// 快：复用缓冲区
let mut buf = String::new();
for item in items {
    buf.clear();
    use std::fmt::Write;
    write!(&mut buf, "Item: {}", item).unwrap();
    process(&buf);
}
```

### 2. 使用迭代器而非索引

```rust
// 慢：边界检查
for i in 0..vec.len() {
    process(vec[i]);
}

// 快：迭代器没有边界检查
for item in &vec {
    process(*item);
}
```

### 3. 使用 `&str` 而非 `String`

```rust
// 慢：不必要的分配
fn process(s: String) { ... }

// 快：借用即可
fn process(s: &str) { ... }
```

### 4. 使用 `Cow` 延迟分配

```rust
use std::borrow::Cow;

fn process(s: Cow<str>) {
    if need_modify {
        let owned = s.into_owned();
        // ...
    } else {
        // 不需要分配
        println!("{}", s);
    }
}

process(Cow::Borrowed("hello"));      // 不分配
process(Cow::Owned(String::from("hello")));  // 已分配
```

### 5. 预分配集合容量

```rust
let mut v = Vec::with_capacity(1000);
let mut m = HashMap::with_capacity(100);
let mut s = String::with_capacity(256);
```

### 6. 使用 `Entry` API

```rust
use std::collections::HashMap;

// 慢：两次查找
if !map.contains_key(&key) {
    map.insert(key, expensive_compute());
}

// 快：一次查找
map.entry(key).or_insert_with(|| expensive_compute());
```

## SIMD 优化

```rust
#[cfg(target_arch = "x86_64")]
use std::arch::x86_64::*;

#[target_feature(enable = "avx2")]
unsafe fn sum_avx(data: &[f32]) -> f32 {
    // SIMD 实现
    // ...
}
```

更简单的方式是使用 `packed_simd` 或 `wide` crate。

## 内联提示

```rust
#[inline]
fn small_function() { ... }

#[inline(always)]  // 强制内联
fn critical_function() { ... }

#[inline(never)]   // 禁止内联
fn debug_function() { ... }
```

## 分支预测提示

```rust
#![feature(likely_unlikely)]

if likely(condition) {
    // 很可能执行
} else {
    // 不太可能执行
}
```

## 常见陷阱

### 过早优化

```{warning}
Donald Knuth: "Premature optimization is the root of all evil"

1. 先让代码正确工作
2. 用 profiler 找到热点
3. 只优化热点代码
```

### 优化错误的地方

```rust
// 假设这里是瓶颈，花了很多时间优化
fn complex_calculation() { ... }

// 实际上 I/O 才是瓶颈
fn read_data() { ... }

// 使用 profiler 确定真正的瓶颈！
```
