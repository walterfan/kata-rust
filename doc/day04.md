# 第4天：函数与模块

## 🎯 今日目标

- 掌握函数定义与调用
- 理解参数与返回值
- 学会使用模块系统
- 了解可见性规则

## 🔧 函数基础

### 函数定义

Rust 使用 `fn` 关键字定义函数：

```rust
fn main() {
    // 调用函数
    greet("世界");
    
    let result = add(5, 3);
    println!("5 + 3 = {}", result);
}

// 无返回值的函数
fn greet(name: &str) {
    println!("你好，{}！", name);
}

// 有返回值的函数
fn add(a: i32, b: i32) -> i32 {
    a + b  // 最后一个表达式是返回值
}
```

### 函数参数

函数可以有多个参数，每个参数都需要类型注解：

```rust
fn main() {
    print_sum(10, 20);
    print_info("张三", 25, 175.5);
}

fn print_sum(a: i32, b: i32) {
    println!("{} + {} = {}", a, b, a + b);
}

fn print_info(name: &str, age: u32, height: f64) {
    println!("姓名: {}, 年龄: {}, 身高: {}cm", name, age, height);
}
```

### 函数返回值

函数可以返回单个值，类型在 `->` 后指定：

```rust
fn main() {
    let result1 = multiply(4, 5);
    let result2 = divide(10, 2);
    let result3 = get_status(85);
    
    println!("4 * 5 = {}", result1);
    println!("10 / 2 = {}", result2);
    println!("状态: {}", result3);
}

fn multiply(a: i32, b: i32) -> i32 {
    a * b  // 隐式返回
}

fn divide(a: i32, b: i32) -> i32 {
    return a / b;  // 显式返回
}

fn get_status(score: u32) -> &'static str {
    if score >= 90 {
        "优秀"
    } else if score >= 80 {
        "良好"
    } else if score >= 60 {
        "及格"
    } else {
        "不及格"
    }
}
```

### 早期返回

函数可以在任何地方使用 `return` 提前返回：

```rust
fn main() {
    let result = check_number(0);
    println!("结果: {}", result);
}

fn check_number(n: i32) -> &'static str {
    if n == 0 {
        return "零";  // 早期返回
    }
    
    if n < 0 {
        return "负数";
    }
    
    "正数"  // 默认返回
}
```

## 📦 模块系统

### 模块基础

模块是 Rust 中组织代码的方式，使用 `mod` 关键字定义：

```rust
// 在 main.rs 中
mod math {
    pub fn add(a: i32, b: i32) -> i32 {
        a + b
    }
    
    pub fn subtract(a: i32, b: i32) -> i32 {
        a - b
    }
}

fn main() {
    let result = math::add(10, 5);
    println!("10 + 5 = {}", result);
    
    let result = math::subtract(10, 5);
    println!("10 - 5 = {}", result);
}
```

### 模块嵌套

模块可以嵌套定义：

```rust
mod math {
    pub mod basic {
        pub fn add(a: i32, b: i32) -> i32 {
            a + b
        }
        
        pub fn subtract(a: i32, b: i32) -> i32 {
            a - b
        }
    }
    
    pub mod advanced {
        pub fn power(base: i32, exponent: u32) -> i32 {
            base.pow(exponent)
        }
        
        pub fn factorial(n: u32) -> u32 {
            if n <= 1 {
                1
            } else {
                n * factorial(n - 1)
            }
        }
    }
}

fn main() {
    let sum = math::basic::add(5, 3);
    let power = math::advanced::power(2, 8);
    let fact = math::advanced::factorial(5);
    
    println!("5 + 3 = {}", sum);
    println!("2^8 = {}", power);
    println!("5! = {}", fact);
}
```

### 使用 use 导入

`use` 关键字可以简化模块路径：

```rust
mod math {
    pub mod basic {
        pub fn add(a: i32, b: i32) -> i32 {
            a + b
        }
    }
    
    pub mod advanced {
        pub fn power(base: i32, exponent: u32) -> i32 {
            base.pow(exponent)
        }
    }
}

fn main() {
    // 导入特定函数
    use math::basic::add;
    use math::advanced::power;
    
    let result1 = add(10, 20);
    let result2 = power(2, 10);
    
    println!("10 + 20 = {}", result1);
    println!("2^10 = {}", result2);
    
    // 导入整个模块
    use math::basic;
    let result3 = basic::add(5, 5);
    println!("5 + 5 = {}", result3);
}
```

### 可见性规则

Rust 使用 `pub` 关键字控制可见性：

```rust
mod library {
    // 私有函数，只能在模块内部使用
    fn private_function() {
        println!("这是私有函数");
    }
    
    // 公共函数，可以在模块外部使用
    pub fn public_function() {
        println!("这是公共函数");
        private_function();  // 可以调用私有函数
    }
    
    pub mod nested {
        pub fn nested_function() {
            println!("这是嵌套模块的函数");
        }
    }
}

fn main() {
    library::public_function();
    library::nested::nested_function();
    
    // 这行会编译错误
    // library::private_function();
}
```

## 🗂️ 文件组织

### 分离到不同文件

可以将模块分离到不同的文件中：

**src/main.rs:**
```rust
mod math;
mod utils;

fn main() {
    let result = math::add(10, 5);
    println!("10 + 5 = {}", result);
    
    let text = utils::format_text("Hello");
    println!("{}", text);
}
```

**src/math.rs:**
```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

pub fn subtract(a: i32, b: i32) -> i32 {
    a - b
}

pub fn multiply(a: i32, b: i32) -> i32 {
    a * b
}
```

**src/utils.rs:**
```rust
pub fn format_text(text: &str) -> String {
    format!("[{}]", text)
}

pub fn reverse_string(text: &str) -> String {
    text.chars().rev().collect()
}
```

### 目录模块

对于更复杂的项目，可以使用目录组织模块：

**src/lib.rs:**
```rust
pub mod math;
pub mod utils;
pub mod models;
```

**src/math/mod.rs:**
```rust
pub mod basic;
pub mod advanced;

pub use basic::*;
pub use advanced::*;
```

**src/math/basic.rs:**
```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

## 💻 动手实践

### 练习 1：数学函数库

创建一个数学函数库：

```rust
mod math {
    pub fn add(a: f64, b: f64) -> f64 {
        a + b
    }
    
    pub fn subtract(a: f64, b: f64) -> f64 {
        a - b
    }
    
    pub fn multiply(a: f64, b: f64) -> f64 {
        a * b
    }
    
    pub fn divide(a: f64, b: f64) -> Option<f64> {
        if b == 0.0 {
            None
        } else {
            Some(a / b)
        }
    }
    
    pub fn power(base: f64, exponent: f64) -> f64 {
        base.powf(exponent)
    }
    
    pub fn sqrt(value: f64) -> Option<f64> {
        if value < 0.0 {
            None
        } else {
            Some(value.sqrt())
        }
    }
}

fn main() {
    let a = 10.0;
    let b = 3.0;
    
    println!("{} + {} = {}", a, b, math::add(a, b));
    println!("{} - {} = {}", a, b, math::subtract(a, b));
    println!("{} * {} = {}", a, b, math::multiply(a, b));
    
    match math::divide(a, b) {
        Some(result) => println!("{} / {} = {:.2}", a, b, result),
        None => println!("除零错误"),
    }
    
    println!("{} ^ {} = {}", a, b, math::power(a, b));
    
    match math::sqrt(a) {
        Some(result) => println!("√{} = {:.2}", a, result),
        None => println!("无法计算负数的平方根"),
    }
}
```

### 练习 2：字符串工具库

创建一个字符串处理工具库：

```rust
mod string_utils {
    pub fn reverse(text: &str) -> String {
        text.chars().rev().collect()
    }
    
    pub fn count_chars(text: &str) -> usize {
        text.chars().count()
    }
    
    pub fn count_words(text: &str) -> usize {
        text.split_whitespace().count()
    }
    
    pub fn is_palindrome(text: &str) -> bool {
        let cleaned: String = text.chars()
            .filter(|c| c.is_alphanumeric())
            .collect();
        let reversed: String = cleaned.chars().rev().collect();
        cleaned.eq_ignore_ascii_case(&reversed)
    }
    
    pub fn capitalize_first(text: &str) -> String {
        let mut chars = text.chars();
        match chars.next() {
            None => String::new(),
            Some(first) => first.to_uppercase().chain(chars).collect(),
        }
    }
}

fn main() {
    let test_text = "Hello World";
    
    println!("原文: {}", test_text);
    println!("反转: {}", string_utils::reverse(test_text));
    println!("字符数: {}", string_utils::count_chars(test_text));
    println!("单词数: {}", string_utils::count_words(test_text));
    println!("首字母大写: {}", string_utils::capitalize_first(test_text));
    
    let palindrome = "A man a plan a canal Panama";
    println!("'{}' 是回文: {}", palindrome, string_utils::is_palindrome(palindrome));
}
```

### 练习 3：温度转换器模块

创建一个温度转换模块：

```rust
mod temperature {
    pub struct Celsius(pub f64);
    pub struct Fahrenheit(pub f64);
    pub struct Kelvin(pub f64);
    
    impl Celsius {
        pub fn to_fahrenheit(&self) -> Fahrenheit {
            Fahrenheit(self.0 * 9.0 / 5.0 + 32.0)
        }
        
        pub fn to_kelvin(&self) -> Kelvin {
            Kelvin(self.0 + 273.15)
        }
    }
    
    impl Fahrenheit {
        pub fn to_celsius(&self) -> Celsius {
            Celsius((self.0 - 32.0) * 5.0 / 9.0)
        }
        
        pub fn to_kelvin(&self) -> Kelvin {
            self.to_celsius().to_kelvin()
        }
    }
    
    impl Kelvin {
        pub fn to_celsius(&self) -> Celsius {
            Celsius(self.0 - 273.15)
        }
        
        pub fn to_fahrenheit(&self) -> Fahrenheit {
            self.to_celsius().to_fahrenheit()
        }
    }
}

fn main() {
    use temperature::{Celsius, Fahrenheit, Kelvin};
    
    let celsius = Celsius(25.0);
    let fahrenheit = celsius.to_fahrenheit();
    let kelvin = celsius.to_kelvin();
    
    println!("{}°C = {:.1}°F", celsius.0, fahrenheit.0);
    println!("{}°C = {:.1}K", celsius.0, kelvin.0);
    
    let fahrenheit = Fahrenheit(98.6);
    let celsius = fahrenheit.to_celsius();
    println!("{}°F = {:.1}°C", fahrenheit.0, celsius.0);
}
```

## 🔍 代码解释

### 函数语法
```rust
fn function_name(param1: Type1, param2: Type2) -> ReturnType {
    // 函数体
    expression  // 最后一个表达式是返回值
}
```

### 模块语法
```rust
mod module_name {
    pub fn public_function() { ... }
    fn private_function() { ... }
}
```

### 可见性
- `pub`：公共，可以在模块外部访问
- 无修饰符：私有，只能在模块内部访问

## 📚 今日总结

今天我们学习了：
1. ✅ 函数定义与调用语法
2. ✅ 函数参数与返回值
3. ✅ 模块系统的基础用法
4. ✅ 使用 use 导入模块
5. ✅ 可见性规则和文件组织

## 🎯 明日预告

明天我们将学习 Rust 的所有权系统，包括：
- 所有权概念
- 移动语义
- 借用规则
- 生命周期基础

## 💡 小贴士

- 函数参数必须指定类型
- 最后一个表达式自动成为返回值
- 使用 `pub` 控制模块和函数的可见性
- 模块可以嵌套和分离到不同文件
- `use` 可以简化模块路径

---

**恭喜你完成了第四天的学习！明天见！** 🎉
