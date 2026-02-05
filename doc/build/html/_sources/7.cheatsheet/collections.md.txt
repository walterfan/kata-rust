# 集合速查

## Vec<T>

```rust
// 创建
let v: Vec<i32> = Vec::new();
let v = vec![1, 2, 3];
let v = Vec::with_capacity(10);

// 添加
v.push(4);
v.insert(0, 0);  // 在索引 0 插入
v.extend([5, 6, 7]);

// 移除
v.pop();         // 移除最后一个
v.remove(0);     // 移除索引 0
v.clear();       // 清空

// 访问
let first = &v[0];          // panic if out of bounds
let first = v.get(0);       // Option<&T>
let first = v.first();      // Option<&T>
let last = v.last();        // Option<&T>

// 迭代
for item in &v { }
for item in &mut v { }
for item in v { }  // 移动

// 其他
v.len();
v.is_empty();
v.contains(&3);
v.sort();
v.reverse();
v.dedup();  // 去重（需要先排序）
```

## HashMap<K, V>

```rust
use std::collections::HashMap;

// 创建
let mut map: HashMap<String, i32> = HashMap::new();
let map: HashMap<_, _> = vec![("a", 1), ("b", 2)].into_iter().collect();

// 插入
map.insert("key".to_string(), 10);
map.entry("key".to_string()).or_insert(0);
map.entry("key".to_string()).or_insert_with(|| expensive_fn());

// 获取
let value = map.get("key");  // Option<&V>
let value = map["key"];      // panic if not found

// 移除
map.remove("key");

// 迭代
for (key, value) in &map { }
for (key, value) in &mut map { }

// 其他
map.len();
map.is_empty();
map.contains_key("key");
map.keys();
map.values();
```

## HashSet<T>

```rust
use std::collections::HashSet;

// 创建
let mut set: HashSet<i32> = HashSet::new();
let set: HashSet<_> = vec![1, 2, 3].into_iter().collect();

// 操作
set.insert(4);
set.remove(&4);
set.contains(&3);

// 集合运算
let a: HashSet<_> = [1, 2, 3].into_iter().collect();
let b: HashSet<_> = [2, 3, 4].into_iter().collect();

let union: HashSet<_> = a.union(&b).collect();
let intersection: HashSet<_> = a.intersection(&b).collect();
let difference: HashSet<_> = a.difference(&b).collect();
```

## String

```rust
// 创建
let s = String::new();
let s = String::from("hello");
let s = "hello".to_string();
let s = format!("Hello, {}!", name);

// 追加
s.push('!');
s.push_str(" world");
s += " more";

// 拼接
let s = s1 + &s2;  // s1 被移动
let s = format!("{}{}", s1, s2);  // 不移动

// 切片
let slice = &s[0..5];  // 注意：UTF-8 字节边界

// 遍历
for c in s.chars() { }
for b in s.bytes() { }

// 其他
s.len();  // 字节数
s.chars().count();  // 字符数
s.is_empty();
s.contains("hello");
s.starts_with("he");
s.ends_with("lo");
s.replace("old", "new");
s.trim();
s.split(',');
s.lines();
```

## VecDeque<T>

双端队列：

```rust
use std::collections::VecDeque;

let mut deque = VecDeque::new();
deque.push_back(1);
deque.push_front(0);
deque.pop_back();
deque.pop_front();
```

## BinaryHeap<T>

最大堆：

```rust
use std::collections::BinaryHeap;

let mut heap = BinaryHeap::new();
heap.push(1);
heap.push(5);
heap.push(2);

assert_eq!(heap.pop(), Some(5));
assert_eq!(heap.peek(), Some(&2));
```

## BTreeMap<K, V> / BTreeSet<T>

有序集合（基于 B 树）：

```rust
use std::collections::{BTreeMap, BTreeSet};

let mut map = BTreeMap::new();
map.insert(3, "three");
map.insert(1, "one");
map.insert(2, "two");

// 按键顺序迭代
for (k, v) in &map {
    println!("{}: {}", k, v);  // 1, 2, 3
}

// 范围查询
for (k, v) in map.range(1..3) {
    // 1..3 范围内的元素
}
```
