# TCP/UDP 编程

## 标准库 TCP

### TCP 服务器

```rust
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

fn handle_client(mut stream: TcpStream) {
    let mut buffer = [0; 1024];
    
    loop {
        match stream.read(&mut buffer) {
            Ok(0) => break,  // 连接关闭
            Ok(n) => {
                // Echo
                stream.write_all(&buffer[..n]).unwrap();
            }
            Err(_) => break,
        }
    }
}

fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080")?;
    
    for stream in listener.incoming() {
        let stream = stream?;
        thread::spawn(|| handle_client(stream));
    }
    
    Ok(())
}
```

### TCP 客户端

```rust
use std::io::{Read, Write};
use std::net::TcpStream;

fn main() -> std::io::Result<()> {
    let mut stream = TcpStream::connect("127.0.0.1:8080")?;
    
    stream.write_all(b"Hello, server!")?;
    
    let mut buffer = [0; 1024];
    let n = stream.read(&mut buffer)?;
    
    println!("Received: {}", String::from_utf8_lossy(&buffer[..n]));
    
    Ok(())
}
```

## 异步 TCP（Tokio）

```rust
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:8080").await?;
    
    loop {
        let (socket, _) = listener.accept().await?;
        
        tokio::spawn(async move {
            handle_connection(socket).await;
        });
    }
}

async fn handle_connection(mut socket: TcpStream) {
    let mut buf = [0; 1024];
    
    loop {
        match socket.read(&mut buf).await {
            Ok(0) => return,
            Ok(n) => {
                if socket.write_all(&buf[..n]).await.is_err() {
                    return;
                }
            }
            Err(_) => return,
        }
    }
}
```

## UDP

```rust
use std::net::UdpSocket;

// 服务器
fn udp_server() -> std::io::Result<()> {
    let socket = UdpSocket::bind("127.0.0.1:8080")?;
    let mut buf = [0; 1024];
    
    loop {
        let (len, src) = socket.recv_from(&mut buf)?;
        socket.send_to(&buf[..len], src)?;
    }
}

// 客户端
fn udp_client() -> std::io::Result<()> {
    let socket = UdpSocket::bind("127.0.0.1:0")?;
    socket.connect("127.0.0.1:8080")?;
    
    socket.send(b"Hello, UDP!")?;
    
    let mut buf = [0; 1024];
    let len = socket.recv(&mut buf)?;
    
    println!("Received: {}", String::from_utf8_lossy(&buf[..len]));
    
    Ok(())
}
```

## 设置选项

```rust
use std::net::TcpStream;
use std::time::Duration;

let stream = TcpStream::connect("127.0.0.1:8080")?;

// 设置读超时
stream.set_read_timeout(Some(Duration::from_secs(5)))?;

// 设置写超时
stream.set_write_timeout(Some(Duration::from_secs(5)))?;

// 设置 nodelay（禁用 Nagle 算法）
stream.set_nodelay(true)?;

// 获取本地/远程地址
let local = stream.local_addr()?;
let peer = stream.peer_addr()?;
```
