# 语法速查

## 变量绑定

```rust
let x = 5;           // 不可变
let mut y = 5;       // 可变
let z: i32 = 5;      // 类型标注
const MAX: u32 = 100_000;  // 常量
static HELLO: &str = "Hello";  // 静态变量
```

## 基本类型

```rust
// 整数
i8, i16, i32, i64, i128, isize  // 有符号
u8, u16, u32, u64, u128, usize  // 无符号

// 浮点
f32, f64

// 布尔
bool  // true, false

// 字符
char  // 4 字节 Unicode

// 字符串
&str      // 字符串切片
String    // 拥有的字符串
```

## 复合类型

```rust
// 元组
let tup: (i32, f64, char) = (500, 6.4, 'a');
let (x, y, z) = tup;
let first = tup.0;

// 数组
let arr: [i32; 5] = [1, 2, 3, 4, 5];
let arr = [0; 5];  // [0, 0, 0, 0, 0]

// 切片
let slice = &arr[1..3];
```

## 函数

```rust
fn add(x: i32, y: i32) -> i32 {
    x + y
}

fn no_return() {
    println!("No return");
}

fn early_return() -> i32 {
    return 42;
}
```

## 控制流

```rust
// if
if x > 0 {
    // ...
} else if x < 0 {
    // ...
} else {
    // ...
}

// if 表达式
let result = if x > 0 { "positive" } else { "non-positive" };

// loop
loop {
    break;
}

let result = loop {
    break 42;
};

// while
while x > 0 {
    x -= 1;
}

// for
for i in 0..10 {
    // ...
}

for item in collection.iter() {
    // ...
}

// match
match x {
    1 => println!("one"),
    2 | 3 => println!("two or three"),
    4..=10 => println!("four to ten"),
    _ => println!("other"),
}
```

## 模式匹配

```rust
// if let
if let Some(value) = optional {
    // ...
}

// while let
while let Some(value) = iterator.next() {
    // ...
}

// 解构
let (x, y) = (1, 2);
let Point { x, y } = point;

// @ 绑定
match x {
    n @ 1..=10 => println!("{} is 1-10", n),
    _ => {}
}

// 守卫
match x {
    n if n > 0 => println!("positive"),
    _ => {}
}
```

## 结构体

```rust
struct Point {
    x: i32,
    y: i32,
}

let p = Point { x: 1, y: 2 };
let Point { x, y } = p;

// 元组结构体
struct Color(i32, i32, i32);

// 单元结构体
struct Empty;

// 方法
impl Point {
    fn new(x: i32, y: i32) -> Self {
        Point { x, y }
    }
    
    fn distance(&self, other: &Point) -> f64 {
        // ...
    }
}
```

## 枚举

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

let msg = Message::Move { x: 1, y: 2 };

match msg {
    Message::Quit => println!("Quit"),
    Message::Move { x, y } => println!("Move to ({}, {})", x, y),
    Message::Write(text) => println!("Write: {}", text),
    Message::ChangeColor(r, g, b) => println!("Color: {}, {}, {}", r, g, b),
}
```

## 泛型

```rust
fn largest<T: Ord>(list: &[T]) -> &T {
    // ...
}

struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}
```

## Trait

```rust
trait Summary {
    fn summarize(&self) -> String;
    
    fn default_impl(&self) -> String {
        String::from("(Read more...)")
    }
}

impl Summary for Article {
    fn summarize(&self) -> String {
        // ...
    }
}

// Trait 约束
fn notify(item: &impl Summary) { }
fn notify<T: Summary>(item: &T) { }
fn notify<T: Summary + Display>(item: &T) { }

fn notify<T, U>(t: &T, u: &U)
where
    T: Summary + Clone,
    U: Display + Debug,
{ }
```

## 生命周期

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    // ...
}

struct Excerpt<'a> {
    part: &'a str,
}

impl<'a> Excerpt<'a> {
    fn level(&self) -> i32 { 3 }
}
```

## 闭包

```rust
let add = |x, y| x + y;
let add: fn(i32, i32) -> i32 = |x, y| x + y;

// 捕获
let x = 5;
let closure = || x;       // 借用
let closure = move || x;  // 移动
```

## 宏

```rust
// 声明宏
macro_rules! say_hello {
    () => {
        println!("Hello!");
    };
    ($name:expr) => {
        println!("Hello, {}!", $name);
    };
}

say_hello!();
say_hello!("World");
```
