// 第1天示例：Hello Rust
// 运行方式：rustc hello_rust.rs && ./hello_rust

fn main() {
    println!("Hello, Rust!");
    
    // 使用变量
    let name = "世界";
    println!("你好，{}！", name);
    
    // 数学运算
    let a = 10;
    let b = 5;
    println!("{} + {} = {}", a, b, a + b);
    println!("{} - {} = {}", a, b, a - b);
    println!("{} * {} = {}", a, b, a * b);
    println!("{} / {} = {}", a, b, a / b);
}
