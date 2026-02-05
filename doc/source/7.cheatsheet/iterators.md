# 迭代器速查

## 创建迭代器

```rust
// 从集合
vec.iter()       // &T
vec.iter_mut()   // &mut T
vec.into_iter()  // T (移动)

// 范围
0..10           // 0 到 9
0..=10          // 0 到 10
(0..).take(10)  // 无限迭代器取前 10 个

// 其他
std::iter::once(value)     // 单个元素
std::iter::repeat(value)   // 重复
std::iter::empty()         // 空迭代器
std::iter::from_fn(|| Some(42))  // 从闭包
```

## 适配器（Adapter）

```rust
// 转换
.map(|x| x * 2)
.filter(|x| x > 0)
.filter_map(|x| x.parse().ok())

// 扁平化
.flatten()        // [[1,2], [3,4]] -> [1,2,3,4]
.flat_map(|x| x.chars())

// 取值
.take(n)          // 取前 n 个
.skip(n)          // 跳过前 n 个
.take_while(|x| *x < 5)
.skip_while(|x| *x < 5)

// 窥视
.peekable()       // 可以 peek 下一个
.inspect(|x| println!("{:?}", x))  // 调试用

// 组合
.chain(other)     // 连接
.zip(other)       // 配对
.enumerate()      // (index, value)

// 其他
.rev()            // 反向
.cycle()          // 无限循环
.step_by(2)       // 步进
.fuse()           // 遇到 None 后永远返回 None
```

## 消费者（Consumer）

```rust
// 收集
.collect::<Vec<_>>()
.collect::<HashMap<_, _>>()
.collect::<String>()

// 聚合
.count()
.sum::<i32>()
.product::<i32>()
.min()
.max()
.min_by_key(|x| x.len())
.max_by_key(|x| x.len())

// 查找
.find(|x| *x > 5)
.position(|x| x == 5)
.any(|x| x > 5)
.all(|x| x > 0)

// 折叠
.fold(0, |acc, x| acc + x)
.reduce(|acc, x| acc + x)

// 其他
.for_each(|x| println!("{}", x))
.last()
.nth(5)
.partition::<Vec<_>, _>(|x| x > 0)
```

## 常用模式

```rust
// 过滤并转换
let results: Vec<_> = items
    .iter()
    .filter(|x| x.is_valid())
    .map(|x| x.transform())
    .collect();

// 查找第一个匹配
let first = items.iter().find(|x| x.matches());

// 分组
let (positive, negative): (Vec<_>, Vec<_>) = 
    numbers.iter().partition(|&&x| x > 0);

// 展开嵌套
let flat: Vec<_> = nested
    .iter()
    .flat_map(|inner| inner.iter())
    .collect();

// 带索引迭代
for (i, item) in items.iter().enumerate() {
    println!("{}: {:?}", i, item);
}

// 配对迭代
for (a, b) in list1.iter().zip(list2.iter()) {
    println!("{}, {}", a, b);
}

// 窗口迭代
for window in items.windows(2) {
    println!("{:?}", window);
}

// 块迭代
for chunk in items.chunks(3) {
    println!("{:?}", chunk);
}
```
