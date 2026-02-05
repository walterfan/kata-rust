# Java 程序员迁移指南

本节帮助有 Java 背景的程序员快速理解 Rust。

## 概念映射

| Java 概念 | Rust 等价物 | 说明 |
|----------|------------|------|
| `Object` | 无基类 | Rust 没有通用基类 |
| `interface` | `trait` | 更强大的接口 |
| `class` | `struct` + `impl` | 数据和行为分离 |
| 继承 | Trait + 组合 | 没有类继承 |
| `null` | `Option<T>` | 编译期空安全 |
| `throws Exception` | `Result<T, E>` | 显式错误处理 |
| GC | 所有权系统 | 编译期内存管理 |
| `final` | 默认 | Rust 变量默认不可变 |
| `instanceof` | 模式匹配 | 更强大的类型检查 |
| `List<T>` | `Vec<T>` | 动态数组 |
| `Map<K, V>` | `HashMap<K, V>` | 哈希映射 |
| `Set<T>` | `HashSet<T>` | 哈希集合 |
| `synchronized` | `Mutex<T>` | 互斥锁 |
| `Optional<T>` | `Option<T>` | 内置语言特性 |

## 主要思维转变

### 1. 没有 null，使用 Option

```java
// Java: null 可能导致 NullPointerException
String name = getName();
if (name != null) {
    System.out.println(name.length());
}
```

```rust
// Rust: Option 强制处理空值
let name: Option<String> = get_name();
if let Some(n) = name {
    println!("{}", n.len());
}

// 或者使用 match
match name {
    Some(n) => println!("{}", n.len()),
    None => println!("No name"),
}
```

### 2. 没有 GC，使用所有权

```java
// Java: GC 自动管理
public void process() {
    List<String> list = new ArrayList<>();
    list.add("hello");
    // 不需要手动释放，GC 会处理
}
```

```rust
// Rust: 所有权自动管理
fn process() {
    let mut list = Vec::new();
    list.push(String::from("hello"));
}  // list 在这里自动释放，无 GC 开销
```

### 3. 值语义 vs 引用语义

```java
// Java: 对象总是引用传递
public void modify(List<String> list) {
    list.add("new item");  // 修改原对象
}
```

```rust
// Rust: 默认移动，需要显式借用
fn modify(list: &mut Vec<String>) {
    list.push(String::from("new item"));
}

let mut list = vec![];
modify(&mut list);  // 显式可变借用
```

### 4. 没有类继承，使用 Trait

```java
// Java 继承
public abstract class Animal {
    public abstract void speak();
}

public class Dog extends Animal {
    @Override
    public void speak() {
        System.out.println("Woof!");
    }
}
```

```rust
// Rust: Trait（接口）+ 组合
trait Speak {
    fn speak(&self);
}

struct Dog;

impl Speak for Dog {
    fn speak(&self) {
        println!("Woof!");
    }
}
```

### 5. 数据和行为分离

```java
// Java: 字段和方法在一起
public class Person {
    private String name;
    private int age;
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}
```

```rust
// Rust: struct 定义数据，impl 定义行为
struct Person {
    name: String,
    age: i32,
}

impl Person {
    // 关联函数（类似静态方法）
    fn new(name: String, age: i32) -> Self {
        Person { name, age }
    }
    
    // 方法
    fn get_name(&self) -> &str {
        &self.name
    }
    
    fn set_name(&mut self, name: String) {
        self.name = name;
    }
}
```

## 常见陷阱

### 陷阱 1：期望 clone 自动发生

```java
// Java: 对象赋值是引用复制
String s1 = new String("hello");
String s2 = s1;  // s1 和 s2 指向同一对象
```

```rust
// Rust: 赋值是移动
let s1 = String::from("hello");
let s2 = s1;  // s1 无效了！

// 需要显式 clone
let s1 = String::from("hello");
let s2 = s1.clone();  // 显式复制
```

### 陷阱 2：忘记处理 Result

```java
// Java: 可以忽略返回值
file.read(buffer);  // 可能的异常被忽略或向上抛
```

```rust
// Rust: Result 不处理会有警告
file.read(&mut buffer);  // 警告：unused Result

// 正确做法
file.read(&mut buffer)?;  // 传播错误
// 或
let _ = file.read(&mut buffer);  // 显式忽略
```

### 陷阱 3：期望方法链式调用自动返回 self

```java
// Java Builder 模式
builder.setName("test")
       .setAge(20)
       .build();
```

```rust
// Rust: 需要显式返回 self
impl Builder {
    fn set_name(mut self, name: &str) -> Self {
        self.name = name.to_string();
        self  // 必须显式返回
    }
}
```

### 陷阱 4：泛型是单态化的，不是类型擦除

```java
// Java: 类型擦除，运行时没有类型信息
List<String> list = new ArrayList<>();
// 运行时只知道是 List，不知道是 String
```

```rust
// Rust: 单态化，为每个类型生成专门代码
let list: Vec<String> = Vec::new();
// 编译时生成 Vec<String> 的专门代码

// 优点：更快（无装箱）
// 缺点：可能代码膨胀
```

## 错误处理对比

### Java Checked Exception

```java
public String readFile(String path) throws IOException {
    return Files.readString(Path.of(path));
}

public void process() {
    try {
        String content = readFile("data.txt");
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

### Rust Result

```rust
use std::fs;
use std::io;

fn read_file(path: &str) -> io::Result<String> {
    fs::read_to_string(path)
}

fn process() -> io::Result<()> {
    let content = read_file("data.txt")?;
    println!("{}", content);
    Ok(())
}

// main 可以返回 Result
fn main() -> io::Result<()> {
    process()
}
```

## 集合使用

### Vec vs ArrayList

```rust
// 创建
let mut v: Vec<i32> = Vec::new();
let v = vec![1, 2, 3];

// 添加
v.push(4);

// 访问
let third = &v[2];        // panic if out of bounds
let third = v.get(2);     // returns Option<&i32>

// 迭代
for item in &v {
    println!("{}", item);
}

// 迭代并修改
for item in &mut v {
    *item += 10;
}
```

### HashMap vs Map

```rust
use std::collections::HashMap;

// 创建
let mut map: HashMap<String, i32> = HashMap::new();

// 插入
map.insert(String::from("key"), 42);

// 获取
let value = map.get("key");  // Option<&i32>

// 如果不存在则插入
map.entry(String::from("key2")).or_insert(0);

// 迭代
for (key, value) in &map {
    println!("{}: {}", key, value);
}
```

## 并发对比

### Java synchronized

```java
public class Counter {
    private int count = 0;
    
    public synchronized void increment() {
        count++;
    }
}
```

### Rust Mutex

```rust
use std::sync::{Arc, Mutex};

struct Counter {
    count: Mutex<i32>,
}

impl Counter {
    fn increment(&self) {
        let mut count = self.count.lock().unwrap();
        *count += 1;
    }
}

// 多线程使用
let counter = Arc::new(Counter { count: Mutex::new(0) });
```

## 快速上手建议

1. **理解所有权**：这是最重要的概念，没有之一
2. **接受编译错误**：编译器是你的朋友，它在防止 bug
3. **使用 Option 和 Result**：不要试图绕过它们
4. **学习模式匹配**：比 Java 的 `instanceof` 强大得多
5. **用 `cargo`**：它比 Maven/Gradle 简单得多
6. **跑 `cargo clippy`**：学习惯用 Rust 写法
