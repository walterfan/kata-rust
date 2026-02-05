# Web 服务器

## Axum（推荐）

```toml
[dependencies]
axum = "0.7"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

### 基本服务器

```rust
use axum::{
    routing::{get, post},
    Router,
    Json,
};
use serde::{Deserialize, Serialize};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/users", post(create_user));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn root() -> &'static str {
    "Hello, World!"
}

#[derive(Deserialize)]
struct CreateUser {
    name: String,
}

#[derive(Serialize)]
struct User {
    id: u64,
    name: String,
}

async fn create_user(Json(payload): Json<CreateUser>) -> Json<User> {
    let user = User {
        id: 1,
        name: payload.name,
    };
    Json(user)
}
```

### 路径参数

```rust
use axum::extract::Path;

async fn user(Path(user_id): Path<u64>) -> String {
    format!("User: {}", user_id)
}

let app = Router::new()
    .route("/users/:id", get(user));
```

### 查询参数

```rust
use axum::extract::Query;

#[derive(Deserialize)]
struct Pagination {
    page: Option<u32>,
    per_page: Option<u32>,
}

async fn list_users(Query(pagination): Query<Pagination>) -> String {
    let page = pagination.page.unwrap_or(1);
    let per_page = pagination.per_page.unwrap_or(10);
    format!("Page: {}, Per Page: {}", page, per_page)
}
```

### 共享状态

```rust
use std::sync::Arc;
use tokio::sync::RwLock;

type SharedState = Arc<RwLock<AppState>>;

struct AppState {
    counter: u64,
}

async fn increment(state: axum::extract::State<SharedState>) -> String {
    let mut state = state.write().await;
    state.counter += 1;
    format!("Counter: {}", state.counter)
}

#[tokio::main]
async fn main() {
    let state = Arc::new(RwLock::new(AppState { counter: 0 }));
    
    let app = Router::new()
        .route("/increment", get(increment))
        .with_state(state);
    
    // ...
}
```

## Actix-web

```toml
[dependencies]
actix-web = "4"
```

```rust
use actix_web::{get, post, web, App, HttpResponse, HttpServer};

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[post("/echo")]
async fn echo(req_body: String) -> impl Responder {
    HttpResponse::Ok().body(req_body)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(echo)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
```
