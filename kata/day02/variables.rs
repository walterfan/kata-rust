// 第2天示例：变量与数据类型
// 运行方式：rustc variables.rs && ./variables

fn main() {
    // 1. 变量与可变性
    let x = 5;
    println!("x = {}", x);
    
    // x = 6;  // 编译错误！x 是不可变的
    
    let mut y = 5;
    println!("y = {}", y);
    y = 6;  // 可以修改
    println!("修改后 y = {}", y);
    
    // 2. 变量遮蔽
    let z = 5;
    println!("z = {}", z);
    
    let z = z + 1;
    println!("遮蔽后 z = {}", z);
    
    let z = z * 2;
    println!("再次遮蔽后 z = {}", z);
    
    // 3. 基本数据类型
    let integer: i32 = 42;
    let float: f64 = 3.14;
    let boolean: bool = true;
    let character: char = 'A';
    
    println!("整数: {}", integer);
    println!("浮点: {}", float);
    println!("布尔: {}", boolean);
    println!("字符: {}", character);
    
    // 4. 类型转换
    let int_to_float = integer as f64;
    let float_to_int = float as i32;
    
    println!("整数转浮点: {}", int_to_float);
    println!("浮点转整数: {}", float_to_int);
    
    // 5. 常量和静态变量
    const MAX_POINTS: u32 = 100_000;
    static PROGRAM_NAME: &str = "Rust Tutorial";
    
    println!("最大点数: {}", MAX_POINTS);
    println!("程序名称: {}", PROGRAM_NAME);
    
    // 6. 字面量
    let decimal = 98_222;
    let hex = 0xff;
    let octal = 0o77;
    let binary = 0b1111_0000;
    let byte = b'A';
    
    println!("十进制: {}", decimal);
    println!("十六进制: 0x{:x} = {}", hex, hex);
    println!("八进制: 0o{:o} = {}", octal, octal);
    println!("二进制: 0b{:b} = {}", binary, binary);
    println!("字节: {}", byte);
}
