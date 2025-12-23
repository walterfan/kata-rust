# 第7天：结构体与枚举

## 🎯 今日目标

- 掌握结构体定义与实例化
- 学会实现结构体方法
- 理解枚举的定义和用法
- 掌握 Option 与 Result 类型

## 🏗️ 结构体基础

### 结构体定义

结构体是 Rust 中创建自定义类型的主要方式：

```rust
// 定义结构体
struct User {
    username: String,
    email: String,
    active: bool,
    sign_in_count: u64,
}

fn main() {
    // 创建结构体实例
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };
    
    println!("用户: {} ({})", user1.username, user1.email);
    println!("状态: {}, 登录次数: {}", user1.active, user1.sign_in_count);
}
```

### 结构体字段访问

```rust
fn main() {
    let mut user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };
    
    // 访问字段
    println!("用户名: {}", user1.username);
    
    // 修改字段（需要可变实例）
    user1.sign_in_count += 1;
    println!("新的登录次数: {}", user1.sign_in_count);
}
```

### 字段初始化简写

当字段名与变量名相同时，可以使用简写语法：

```rust
fn main() {
    let email = String::from("someone@example.com");
    let username = String::from("someusername123");
    
    let user = User {
        email,      // 等同于 email: email
        username,   // 等同于 username: username
        active: true,
        sign_in_count: 1,
    };
    
    println!("用户: {}", user.username);
}
```

### 结构体更新语法

使用 `..` 语法从其他实例创建新实例：

```rust
fn main() {
    let user1 = User {
        email: String::from("user1@example.com"),
        username: String::from("user1"),
        active: true,
        sign_in_count: 1,
    };
    
    // 使用 user1 的部分字段创建 user2
    let user2 = User {
        email: String::from("user2@example.com"),
        username: String::from("user2"),
        ..user1  // 使用 user1 的其余字段
    };
    
    println!("user2: {} ({})", user2.username, user2.email);
    println!("user2 状态: {}, 登录次数: {}", user2.active, user2.sign_in_count);
}
```

## 🔧 结构体方法

### 方法定义

使用 `impl` 块为结构体定义方法：

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    // 关联函数（类似静态方法）
    fn new(width: u32, height: u32) -> Rectangle {
        Rectangle { width, height }
    }
    
    // 实例方法
    fn area(&self) -> u32 {
        self.width * self.height
    }
    
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
    
    // 可变引用方法
    fn resize(&mut self, width: u32, height: u32) {
        self.width = width;
        self.height = height;
    }
}

fn main() {
    let rect1 = Rectangle::new(30, 50);
    let rect2 = Rectangle::new(10, 40);
    
    println!("矩形面积: {}", rect1.area());
    println!("rect1 能包含 rect2: {}", rect1.can_hold(&rect2));
    
    let mut rect3 = Rectangle::new(20, 20);
    rect3.resize(25, 25);
    println!("调整后面积: {}", rect3.area());
}
```

### 多个 impl 块

一个结构体可以有多个 `impl` 块：

```rust
struct Point {
    x: f64,
    y: f64,
}

impl Point {
    fn new(x: f64, y: f64) -> Self {
        Point { x, y }
    }
    
    fn distance_from_origin(&self) -> f64 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}

impl Point {
    fn distance_to(&self, other: &Point) -> f64 {
        ((self.x - other.x).powi(2) + (self.y - other.y).powi(2)).sqrt()
    }
    
    fn midpoint(&self, other: &Point) -> Point {
        Point {
            x: (self.x + other.x) / 2.0,
            y: (self.y + other.y) / 2.0,
        }
    }
}

fn main() {
    let p1 = Point::new(0.0, 0.0);
    let p2 = Point::new(3.0, 4.0);
    
    println!("p1 到原点距离: {}", p1.distance_from_origin());
    println!("p1 到 p2 距离: {}", p1.distance_to(&p2));
    
    let mid = p1.midpoint(&p2);
    println!("中点: ({}, {})", mid.x, mid.y);
}
```

## 🎭 枚举基础

### 枚举定义

枚举允许你定义一个类型，该类型可以是几个不同变体中的一个：

```rust
enum IpAddrKind {
    V4,
    V6,
}

fn main() {
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;
    
    route(four);
    route(six);
}

fn route(ip_kind: IpAddrKind) {
    match ip_kind {
        IpAddrKind::V4 => println!("路由 IPv4"),
        IpAddrKind::V6 => println!("路由 IPv6"),
    }
}
```

### 枚举与数据

枚举变体可以包含数据：

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

enum Message {
    Quit,                       // 无数据
    Move { x: i32, y: i32 },   // 匿名结构体
    Write(String),              // 包含一个 String
    ChangeColor(i32, i32, i32), // 包含三个 i32
}

fn main() {
    let home = IpAddr::V4(127, 0, 0, 1);
    let loopback = IpAddr::V6(String::from("::1"));
    
    let msg1 = Message::Quit;
    let msg2 = Message::Move { x: 10, y: 20 };
    let msg3 = Message::Write(String::from("hello"));
    let msg4 = Message::ChangeColor(255, 0, 0);
    
    process_message(msg1);
    process_message(msg2);
    process_message(msg3);
    process_message(msg4);
}

fn process_message(msg: Message) {
    match msg {
        Message::Quit => println!("退出"),
        Message::Move { x, y } => println!("移动到 ({}, {})", x, y),
        Message::Write(text) => println!("写入: {}", text),
        Message::ChangeColor(r, g, b) => println!("改变颜色: RGB({}, {}, {})", r, g, b),
    }
}
```

### 枚举方法

枚举也可以有方法：

```rust
enum Shape {
    Circle { radius: f64 },
    Rectangle { width: f64, height: f64 },
    Triangle { base: f64, height: f64 },
}

impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
            Shape::Rectangle { width, height } => width * height,
            Shape::Triangle { base, height } => 0.5 * base * height,
        }
    }
    
    fn perimeter(&self) -> f64 {
        match self {
            Shape::Circle { radius } => 2.0 * std::f64::consts::PI * radius,
            Shape::Rectangle { width, height } => 2.0 * (width + height),
            Shape::Triangle { base, height } => {
                let hypotenuse = (base * base + height * height).sqrt();
                base + height + hypotenuse
            }
        }
    }
}

fn main() {
    let shapes = vec![
        Shape::Circle { radius: 5.0 },
        Shape::Rectangle { width: 10.0, height: 5.0 },
        Shape::Triangle { base: 6.0, height: 8.0 },
    ];
    
    for shape in shapes {
        println!("面积: {:.2}, 周长: {:.2}", shape.area(), shape.perimeter());
    }
}
```

## 🎯 Option 枚举

`Option` 是 Rust 标准库中最重要的枚举之一，表示一个值可能存在或不存在：

```rust
fn main() {
    let some_number = Some(5);
    let some_string = Some("a string");
    let absent_number: Option<i32> = None;
    
    // 使用 match 处理 Option
    match some_number {
        Some(n) => println!("数字: {}", n),
        None => println!("没有数字"),
    }
    
    // 使用 if let 简化处理
    if let Some(n) = some_number {
        println!("数字: {}", n);
    }
    
    // Option 的常用方法
    let x: Option<i32> = Some(5);
    let y: Option<i32> = None;
    
    println!("x + 1 = {:?}", x.map(|n| n + 1));
    println!("y + 1 = {:?}", y.map(|n| n + 1));
    
    // unwrap 和 expect
    let z = x.unwrap();  // 5
    // let w = y.unwrap();  // 这会导致 panic!
    
    let w = y.expect("y 应该是 Some");  // 自定义错误信息
}
```

## ✅ Result 枚举

`Result` 用于表示操作可能成功或失败：

```rust
use std::fs::File;
use std::io::{self, Read};

fn main() {
    // 成功的情况
    let result = divide(10, 2);
    match result {
        Ok(value) => println!("结果: {}", value),
        Err(e) => println!("错误: {}", e),
    }
    
    // 错误的情况
    let result = divide(10, 0);
    match result {
        Ok(value) => println!("结果: {}", value),
        Err(e) => println!("错误: {}", e),
    }
    
    // 使用 ? 操作符
    let content = read_file_content("example.txt");
    match content {
        Ok(text) => println!("文件内容: {}", text),
        Err(e) => println!("读取错误: {}", e),
    }
}

fn divide(a: i32, b: i32) -> Result<i32, String> {
    if b == 0 {
        Err(String::from("除数不能为零"))
    } else {
        Ok(a / b)
    }
}

fn read_file_content(filename: &str) -> Result<String, io::Error> {
    let mut file = File::open(filename)?;  // ? 操作符自动传播错误
    let mut content = String::new();
    file.read_to_string(&mut content)?;
    Ok(content)
}
```

## 💻 动手实践

### 练习 1：学生管理系统

```rust
#[derive(Debug)]
struct Student {
    id: u32,
    name: String,
    age: u8,
    grades: Vec<f64>,
}

impl Student {
    fn new(id: u32, name: String, age: u8) -> Self {
        Student {
            id,
            name,
            age,
            grades: Vec::new(),
        }
    }
    
    fn add_grade(&mut self, grade: f64) {
        if grade >= 0.0 && grade <= 100.0 {
            self.grades.push(grade);
        }
    }
    
    fn average_grade(&self) -> Option<f64> {
        if self.grades.is_empty() {
            None
        } else {
            let sum: f64 = self.grades.iter().sum();
            Some(sum / self.grades.len() as f64)
        }
    }
    
    fn display_info(&self) {
        println!("学生 ID: {}", self.id);
        println!("姓名: {}", self.name);
        println!("年龄: {}", self.age);
        
        match self.average_grade() {
            Some(avg) => println!("平均分: {:.2}", avg),
            None => println!("暂无成绩"),
        }
    }
}

fn main() {
    let mut student = Student::new(1, String::from("张三"), 20);
    
    student.add_grade(85.5);
    student.add_grade(92.0);
    student.add_grade(78.5);
    
    student.display_info();
}
```

### 练习 2：几何图形计算器

```rust
enum Shape {
    Circle { radius: f64 },
    Rectangle { width: f64, height: f64 },
    Triangle { a: f64, b: f64, c: f64 },
}

impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
            Shape::Rectangle { width, height } => width * height,
            Shape::Triangle { a, b, c } => {
                // 海伦公式
                let s = (a + b + c) / 2.0;
                (s * (s - a) * (s - b) * (s - c)).sqrt()
            }
        }
    }
    
    fn is_valid(&self) -> bool {
        match self {
            Shape::Circle { radius } => *radius > 0.0,
            Shape::Rectangle { width, height } => *width > 0.0 && *height > 0.0,
            Shape::Triangle { a, b, c } => {
                *a > 0.0 && *b > 0.0 && *c > 0.0 &&
                a + b > *c && a + c > *b && b + c > *a
            }
        }
    }
}

fn main() {
    let shapes = vec![
        Shape::Circle { radius: 5.0 },
        Shape::Rectangle { width: 10.0, height: 5.0 },
        Shape::Triangle { a: 3.0, b: 4.0, c: 5.0 },
        Shape::Triangle { a: 1.0, b: 1.0, c: 3.0 }, // 无效三角形
    ];
    
    for (i, shape) in shapes.iter().enumerate() {
        println!("图形 {}: ", i + 1);
        
        if shape.is_valid() {
            println!("  面积: {:.2}", shape.area());
        } else {
            println!("  无效图形");
        }
    }
}
```

### 练习 3：简单数据库操作

```rust
#[derive(Debug, Clone)]
struct User {
    id: u32,
    username: String,
    email: String,
    active: bool,
}

enum DatabaseError {
    UserNotFound,
    DuplicateUsername,
    InvalidEmail,
}

enum DatabaseOperation {
    Create(User),
    Read(u32),
    Update(u32, User),
    Delete(u32),
}

struct Database {
    users: Vec<User>,
    next_id: u32,
}

impl Database {
    fn new() -> Self {
        Database {
            users: Vec::new(),
            next_id: 1,
        }
    }
    
    fn execute(&mut self, operation: DatabaseOperation) -> Result<User, DatabaseError> {
        match operation {
            DatabaseOperation::Create(user) => self.create_user(user),
            DatabaseOperation::Read(id) => self.read_user(id),
            DatabaseOperation::Update(id, user) => self.update_user(id, user),
            DatabaseOperation::Delete(id) => self.delete_user(id),
        }
    }
    
    fn create_user(&mut self, mut user: User) -> Result<User, DatabaseError> {
        // 检查用户名是否重复
        if self.users.iter().any(|u| u.username == user.username) {
            return Err(DatabaseError::DuplicateUsername);
        }
        
        // 检查邮箱格式
        if !user.email.contains('@') {
            return Err(DatabaseError::InvalidEmail);
        }
        
        user.id = self.next_id;
        self.next_id += 1;
        self.users.push(user.clone());
        Ok(user)
    }
    
    fn read_user(&self, id: u32) -> Result<User, DatabaseError> {
        self.users.iter()
            .find(|u| u.id == id)
            .cloned()
            .ok_or(DatabaseError::UserNotFound)
    }
    
    fn update_user(&mut self, id: u32, mut updated_user: User) -> Result<User, DatabaseError> {
        if let Some(user) = self.users.iter_mut().find(|u| u.id == id) {
            updated_user.id = id;
            *user = updated_user.clone();
            Ok(updated_user)
        } else {
            Err(DatabaseError::UserNotFound)
        }
    }
    
    fn delete_user(&mut self, id: u32) -> Result<User, DatabaseError> {
        if let Some(index) = self.users.iter().position(|u| u.id == id) {
            Ok(self.users.remove(index))
        } else {
            Err(DatabaseError::UserNotFound)
        }
    }
}

fn main() {
    let mut db = Database::new();
    
    // 创建用户
    let user1 = User {
        id: 0, // 会被自动分配
        username: String::from("alice"),
        email: String::from("alice@example.com"),
        active: true,
    };
    
    match db.execute(DatabaseOperation::Create(user1)) {
        Ok(user) => println!("创建用户成功: {:?}", user),
        Err(e) => println!("创建用户失败: {:?}", e),
    }
    
    // 读取用户
    match db.execute(DatabaseOperation::Read(1)) {
        Ok(user) => println!("读取用户成功: {:?}", user),
        Err(e) => println!("读取用户失败: {:?}", e),
    }
}
```

## 🔍 代码解释

### 结构体语法
```rust
struct StructName {
    field1: Type1,
    field2: Type2,
}
```

### 方法语法
```rust
impl StructName {
    fn method_name(&self) -> ReturnType { ... }
    fn static_method() -> Self { ... }
}
```

### 枚举语法
```rust
enum EnumName {
    Variant1,
    Variant2(DataType),
    Variant3 { field: Type },
}
```

### Option 和 Result
- `Option<T>`：表示值可能存在（`Some(T)`）或不存在（`None`）
- `Result<T, E>`：表示操作成功（`Ok(T)`）或失败（`Err(E)`）

## 📚 今日总结

今天我们学习了：
1. ✅ 结构体定义与实例化
2. ✅ 结构体方法实现
3. ✅ 枚举定义和用法
4. ✅ Option 枚举处理
5. ✅ Result 枚举和错误处理

## 🎯 明日预告

明天我们将学习 Rust 的错误处理，包括：
- panic! 宏的使用
- Result 类型详解
- 错误传播操作符
- 自定义错误类型

## 💡 小贴士

- 结构体是 Rust 中组织数据的主要方式
- 使用 `impl` 块为结构体和枚举添加方法
- `Option` 和 `Result` 是 Rust 错误处理的核心
- 枚举可以包含数据，使其非常灵活
- 练习创建包含方法的自定义类型

---

**恭喜你完成了第七天的学习！明天见！** 🎉
