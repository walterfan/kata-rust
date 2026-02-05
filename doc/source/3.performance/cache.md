# CPU 缓存优化

## 缓存友好的数据结构

### 结构体布局

```rust
// 不好的布局（有填充）
struct Bad {
    a: u8,   // 1 byte
    b: u64,  // 8 bytes, 需要 7 字节填充
    c: u8,   // 1 byte
}  // 总大小: 24 bytes

// 好的布局
struct Good {
    b: u64,  // 8 bytes
    a: u8,   // 1 byte
    c: u8,   // 1 byte
}  // 总大小: 16 bytes（6 字节填充在末尾）

// 使用 repr(C) 控制布局
#[repr(C)]
struct Explicit {
    b: u64,
    a: u8,
    c: u8,
}
```

### SoA vs AoS

```rust
// Array of Structures (AoS) - 传统方式
struct Point {
    x: f32,
    y: f32,
    z: f32,
}
let points: Vec<Point> = vec![];

// Structure of Arrays (SoA) - 更好的缓存利用
struct Points {
    x: Vec<f32>,
    y: Vec<f32>,
    z: Vec<f32>,
}

// 当只访问一个字段时，SoA 更快
fn sum_x_soa(points: &Points) -> f32 {
    points.x.iter().sum()  // 连续内存访问
}
```

## 预取数据

```rust
// 编译器通常会自动预取
// 但可以手动提示
for chunk in data.chunks(64) {
    // 处理 chunk
}
```

## 避免缓存抖动

```rust
// 不好：跳跃访问
for i in 0..n {
    for j in 0..m {
        access(matrix[j][i]);  // 列优先，缓存不友好
    }
}

// 好：顺序访问
for i in 0..n {
    for j in 0..m {
        access(matrix[i][j]);  // 行优先，缓存友好
    }
}
```

## False Sharing

```rust
use std::sync::atomic::AtomicUsize;

// 不好：可能 false sharing
struct Counters {
    a: AtomicUsize,
    b: AtomicUsize,
}

// 好：填充以避免 false sharing
#[repr(align(64))]
struct PaddedCounter {
    value: AtomicUsize,
}

struct Counters {
    a: PaddedCounter,
    b: PaddedCounter,
}
```

## 使用 crossbeam 的缓存行填充

```rust
use crossbeam_utils::CachePadded;

struct Counters {
    a: CachePadded<AtomicUsize>,
    b: CachePadded<AtomicUsize>,
}
```
