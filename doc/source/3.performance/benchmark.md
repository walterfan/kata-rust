# 基准测试

## criterion（推荐）

```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmark"
harness = false
```

```rust
// benches/my_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci(n: u64) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        n => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| {
        b.iter(|| fibonacci(black_box(20)))
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

```bash
cargo bench
```

## 比较基准

```rust
use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion};

fn bench_compare(c: &mut Criterion) {
    let mut group = c.benchmark_group("String Creation");
    
    for size in [100, 1000, 10000].iter() {
        group.bench_with_input(
            BenchmarkId::new("String::with_capacity", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut s = String::with_capacity(size);
                    for _ in 0..size {
                        s.push('a');
                    }
                    s
                })
            },
        );
        
        group.bench_with_input(
            BenchmarkId::new("String::new", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut s = String::new();
                    for _ in 0..size {
                        s.push('a');
                    }
                    s
                })
            },
        );
    }
    
    group.finish();
}

criterion_group!(benches, bench_compare);
criterion_main!(benches);
```

## 内置 benchmark（nightly）

```rust
#![feature(test)]

extern crate test;

use test::Bencher;

#[bench]
fn bench_add(b: &mut Bencher) {
    b.iter(|| {
        1 + 1
    });
}
```

```bash
cargo +nightly bench
```

## black_box 的重要性

```rust
use criterion::black_box;

// 错误：编译器可能优化掉整个计算
b.iter(|| fibonacci(20));

// 正确：black_box 阻止编译器优化
b.iter(|| fibonacci(black_box(20)));
```

## 基准测试最佳实践

1. **在 release 模式下测试**
2. **使用 `black_box` 防止过度优化**
3. **多次运行取平均值**
4. **比较前后版本的性能**
5. **注意缓存预热效果**
