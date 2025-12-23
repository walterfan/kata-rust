# 第3天：控制流

## 🎯 今日目标

- 掌握 if 表达式的使用
- 理解 Rust 的循环语法
- 学会使用 match 模式匹配
- 了解控制流表达式

## 🔀 if 表达式

### 基本 if 语句

Rust 中的 `if` 是一个表达式，不是语句，这意味着它可以返回值：

```rust
fn main() {
    let number = 7;
    
    if number < 5 {
        println!("数字小于 5");
    } else if number < 10 {
        println!("数字在 5 到 10 之间");
    } else {
        println!("数字大于等于 10");
    }
}
```

### if 表达式返回值

```rust
fn main() {
    let number = 7;
    
    // if 表达式可以赋值给变量
    let result = if number < 5 {
        "小于 5"
    } else if number < 10 {
        "5 到 10 之间"
    } else {
        "大于等于 10"
    };
    
    println!("结果: {}", result);
    
    // 更复杂的例子
    let is_even = if number % 2 == 0 { true } else { false };
    println!("{} 是偶数: {}", number, is_even);
}
```

### 条件必须是布尔值

Rust 不会自动转换类型为布尔值：

```rust
fn main() {
    let number = 5;
    
    // 正确：明确的布尔表达式
    if number != 0 {
        println!("数字不为零");
    }
    
    // 错误：不能直接使用数字作为条件
    // if number { ... }  // 编译错误！
}
```

## 🔁 循环

### loop 循环

`loop` 创建无限循环，直到遇到 `break`：

```rust
fn main() {
    let mut count = 0;
    
    loop {
        count += 1;
        println!("计数: {}", count);
        
        if count >= 5 {
            break;  // 跳出循环
        }
    }
    
    println!("循环结束，最终计数: {}", count);
}
```

### loop 返回值

`loop` 也可以返回值：

```rust
fn main() {
    let mut counter = 0;
    
    let result = loop {
        counter += 1;
        
        if counter == 10 {
            break counter * 2;  // 返回 20
        }
    };
    
    println!("结果: {}", result);
}
```

### while 循环

`while` 循环在条件为真时执行：

```rust
fn main() {
    let mut number = 3;
    
    while number != 0 {
        println!("{}!", number);
        number -= 1;
    }
    
    println!("发射！");
}
```

### for 循环

`for` 循环用于遍历集合：

```rust
fn main() {
    // 遍历范围
    for number in 1..=5 {
        println!("数字: {}", number);
    }
    
    // 遍历数组
    let fruits = ["苹果", "香蕉", "橙子"];
    for fruit in fruits.iter() {
        println!("水果: {}", fruit);
    }
    
    // 使用索引遍历
    for (index, fruit) in fruits.iter().enumerate() {
        println!("{}: {}", index, fruit);
    }
    
    // 反向遍历
    for number in (1..=5).rev() {
        println!("倒计时: {}", number);
    }
}
```

## 🎭 match 模式匹配

### 基本 match 语法

`match` 是 Rust 中强大的模式匹配工具：

```rust
fn main() {
    let number = 13;
    
    match number {
        1 => println!("一"),
        2 => println!("二"),
        3 => println!("三"),
        4 | 5 | 6 => println!("四到六"),
        7..=12 => println!("七到十二"),
        13..=19 => println!("十三到十九"),
        _ => println!("其他数字"),
    }
}
```

### match 返回值

`match` 也是表达式，可以返回值：

```rust
fn main() {
    let number = 5;
    
    let result = match number {
        1 => "一",
        2 => "二",
        3 => "三",
        4 | 5 | 6 => "四到六",
        7..=12 => "七到十二",
        13..=19 => "十三到十九",
        _ => "其他数字",
    };
    
    println!("数字 {} 的中文表示: {}", number, result);
}
```

### 绑定值的模式

```rust
fn main() {
    let x = Some(5);
    
    match x {
        Some(value) => println!("值是: {}", value),
        None => println!("没有值"),
    }
    
    // 更复杂的例子
    let point = (0, 7);
    
    match point {
        (0, y) => println!("在 Y 轴上，y = {}", y),
        (x, 0) => println!("在 X 轴上，x = {}", x),
        (x, y) => println!("在其他位置: ({}, {})", x, y),
    }
}
```

### 守卫条件

使用 `if` 条件进一步过滤匹配：

```rust
fn main() {
    let number = Some(4);
    
    match number {
        Some(x) if x < 5 => println!("小于 5: {}", x),
        Some(x) if x > 5 => println!("大于 5: {}", x),
        Some(x) => println!("等于 5: {}", x),
        None => println!("没有值"),
    }
}
```

## 🔄 控制流表达式

### if let 表达式

`if let` 是 `match` 的简化形式，用于只关心一个模式的情况：

```rust
fn main() {
    let some_value = Some(3);
    
    // 使用 match
    match some_value {
        Some(x) => println!("值是: {}", x),
        None => {},
    }
    
    // 使用 if let（更简洁）
    if let Some(x) = some_value {
        println!("值是: {}", x);
    }
    
    // 带 else 的 if let
    if let Some(x) = some_value {
        println!("值是: {}", x);
    } else {
        println!("没有值");
    }
}
```

### while let 循环

`while let` 在模式匹配成功时继续循环：

```rust
fn main() {
    let mut stack = Vec::new();
    
    stack.push(1);
    stack.push(2);
    stack.push(3);
    
    // 使用 while let 弹出所有元素
    while let Some(top) = stack.pop() {
        println!("弹出: {}", top);
    }
}
```

## 💻 动手实践

### 练习 1：数字分类器

创建一个程序，根据输入的数字进行分类：

```rust
fn main() {
    let numbers = vec![1, 5, 10, 15, 20, 25];
    
    for &number in &numbers {
        let category = match number {
            1..=5 => "小数字",
            6..=15 => "中等数字",
            16..=25 => "大数字",
            _ => "超大数字",
        };
        
        println!("{} 是 {}", number, category);
    }
}
```

### 练习 2：FizzBuzz 游戏

实现经典的 FizzBuzz 游戏：

```rust
fn main() {
    for number in 1..=100 {
        let result = match (number % 3, number % 5) {
            (0, 0) => "FizzBuzz",
            (0, _) => "Fizz",
            (_, 0) => "Buzz",
            _ => &number.to_string(),
        };
        
        println!("{}", result);
    }
}
```

### 练习 3：温度转换器

创建一个温度转换程序：

```rust
fn main() {
    let temperatures = vec![0.0, 25.0, 100.0];
    
    for &celsius in &temperatures {
        let fahrenheit = celsius * 9.0 / 5.0 + 32.0;
        
        let description = match celsius {
            t if t < 0.0 => "结冰",
            t if t < 20.0 => "凉爽",
            t if t < 30.0 => "温暖",
            t if t < 100.0 => "炎热",
            _ => "沸腾",
        };
        
        println!("{}°C = {:.1}°F ({})", celsius, fahrenheit, description);
    }
}
```

### 练习 4：简单计算器

使用 match 实现简单的四则运算：

```rust
fn main() {
    let operations = vec![
        ('+', 10, 5),
        ('-', 10, 5),
        ('*', 10, 5),
        ('/', 10, 5),
        ('%', 10, 3),
    ];
    
    for &(op, a, b) in &operations {
        let result = match op {
            '+' => Some(a + b),
            '-' => Some(a - b),
            '*' => Some(a * b),
            '/' => if b != 0 { Some(a / b) } else { None },
            '%' => if b != 0 { Some(a % b) } else { None },
            _ => None,
        };
        
        match result {
            Some(value) => println!("{} {} {} = {}", a, op, b, value),
            None => println!("{} {} {} = 错误", a, op, b),
        }
    }
}
```

## 🔍 代码解释

### 范围语法
```rust
1..5    // 1, 2, 3, 4 (不包含 5)
1..=5   // 1, 2, 3, 4, 5 (包含 5)
```

### 模式匹配语法
```rust
4 | 5 | 6     // 匹配 4、5 或 6
7..=12         // 匹配 7 到 12（包含）
_               // 通配符，匹配所有其他情况
```

### 守卫条件
```rust
Some(x) if x < 5 => // 只有当 x < 5 时才匹配
```

## 📚 今日总结

今天我们学习了：
1. ✅ if 表达式及其返回值
2. ✅ 三种循环：loop、while、for
3. ✅ match 模式匹配的强大功能
4. ✅ if let 和 while let 表达式
5. ✅ 控制流表达式的使用

## 🎯 明日预告

明天我们将学习 Rust 的函数和模块系统，包括：
- 函数定义与调用
- 参数与返回值
- 模块系统基础
- 可见性规则

## 💡 小贴士

- `if` 和 `match` 都是表达式，可以返回值
- 使用 `break` 可以跳出 loop 循环
- `for` 循环是遍历集合的最佳选择
- `match` 必须穷尽所有可能的情况
- `if let` 和 `while let` 可以简化某些模式匹配

---

**恭喜你完成了第三天的学习！明天见！** 🎉
