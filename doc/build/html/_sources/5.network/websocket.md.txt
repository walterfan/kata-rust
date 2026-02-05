# WebSocket

## tokio-tungstenite

```toml
[dependencies]
tokio-tungstenite = "0.21"
tokio = { version = "1", features = ["full"] }
futures-util = "0.3"
```

### WebSocket 服务器

```rust
use futures_util::{SinkExt, StreamExt};
use tokio::net::TcpListener;
use tokio_tungstenite::accept_async;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:8080").await.unwrap();
    
    while let Ok((stream, _)) = listener.accept().await {
        tokio::spawn(async move {
            let ws_stream = accept_async(stream).await.unwrap();
            let (mut write, mut read) = ws_stream.split();
            
            while let Some(msg) = read.next().await {
                if let Ok(msg) = msg {
                    if msg.is_text() || msg.is_binary() {
                        write.send(msg).await.unwrap();
                    }
                }
            }
        });
    }
}
```

### WebSocket 客户端

```rust
use futures_util::{SinkExt, StreamExt};
use tokio_tungstenite::connect_async;

#[tokio::main]
async fn main() {
    let (ws_stream, _) = connect_async("ws://127.0.0.1:8080")
        .await
        .unwrap();
    
    let (mut write, mut read) = ws_stream.split();
    
    // 发送消息
    write.send(Message::Text("Hello".to_string())).await.unwrap();
    
    // 接收消息
    if let Some(msg) = read.next().await {
        println!("Received: {:?}", msg);
    }
}
```

## Axum WebSocket

```rust
use axum::{
    extract::ws::{Message, WebSocket, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};

async fn ws_handler(ws: WebSocketUpgrade) -> impl IntoResponse {
    ws.on_upgrade(handle_socket)
}

async fn handle_socket(mut socket: WebSocket) {
    while let Some(msg) = socket.recv().await {
        if let Ok(msg) = msg {
            if let Message::Text(text) = msg {
                if socket.send(Message::Text(format!("Echo: {}", text))).await.is_err() {
                    break;
                }
            }
        } else {
            break;
        }
    }
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/ws", get(ws_handler));
    
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```
