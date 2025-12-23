// 第3天示例：控制流
// 运行方式：rustc control_flow.rs && ./control_flow

fn main() {
    // 1. if 表达式
    let number = 7;
    
    if number < 5 {
        println!("数字小于 5");
    } else if number < 10 {
        println!("数字在 5 到 10 之间");
    } else {
        println!("数字大于等于 10");
    }
    
    // if 表达式返回值
    let result = if number < 5 {
        "小于 5"
    } else if number < 10 {
        "5 到 10 之间"
    } else {
        "大于等于 10"
    };
    println!("结果: {}", result);
    
    // 2. loop 循环
    let mut count = 0;
    let loop_result = loop {
        count += 1;
        if count >= 5 {
            break count * 2;  // 返回值
        }
    };
    println!("loop 结果: {}", loop_result);
    
    // 3. while 循环
    let mut number = 3;
    while number != 0 {
        println!("{}!", number);
        number -= 1;
    }
    println!("发射！");
    
    // 4. for 循环
    println!("遍历范围:");
    for number in 1..=5 {
        println!("数字: {}", number);
    }
    
    let fruits = ["苹果", "香蕉", "橙子"];
    println!("遍历数组:");
    for fruit in fruits.iter() {
        println!("水果: {}", fruit);
    }
    
    println!("反向遍历:");
    for number in (1..=5).rev() {
        println!("倒计时: {}", number);
    }
    
    // 5. match 模式匹配
    let value = 13;
    match value {
        1 => println!("一"),
        2 => println!("二"),
        3 => println!("三"),
        4 | 5 | 6 => println!("四到六"),
        7..=12 => println!("七到十二"),
        13..=19 => println!("十三到十九"),
        _ => println!("其他数字"),
    }
    
    // match 返回值
    let result = match value {
        1 => "一",
        2 => "二",
        3 => "三",
        4 | 5 | 6 => "四到六",
        7..=12 => "七到十二",
        13..=19 => "十三到十九",
        _ => "其他数字",
    };
    println!("数字 {} 的中文表示: {}", value, result);
    
    // 6. 绑定值的模式
    let point = (0, 7);
    match point {
        (0, y) => println!("在 Y 轴上，y = {}", y),
        (x, 0) => println!("在 X 轴上，x = {}", x),
        (x, y) => println!("在其他位置: ({}, {})", x, y),
    }
    
    // 7. 守卫条件
    let number = Some(4);
    match number {
        Some(x) if x < 5 => println!("小于 5: {}", x),
        Some(x) if x > 5 => println!("大于 5: {}", x),
        Some(x) => println!("等于 5: {}", x),
        None => println!("没有值"),
    }
    
    // 8. if let 表达式
    let some_value = Some(3);
    if let Some(x) = some_value {
        println!("值是: {}", x);
    }
    
    // 9. while let 循环
    let mut stack = Vec::new();
    stack.push(1);
    stack.push(2);
    stack.push(3);
    
    println!("弹出栈元素:");
    while let Some(top) = stack.pop() {
        println!("弹出: {}", top);
    }
}
