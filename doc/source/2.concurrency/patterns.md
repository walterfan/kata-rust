# 并发模式

本节介绍 Rust 中常用的并发设计模式。

## 生产者-消费者模式

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();
    
    // 生产者
    let producer = thread::spawn(move || {
        for i in 0..10 {
            tx.send(i).unwrap();
            thread::sleep(Duration::from_millis(100));
        }
    });
    
    // 消费者
    let consumer = thread::spawn(move || {
        for received in rx {
            println!("Consumed: {}", received);
        }
    });
    
    producer.join().unwrap();
    consumer.join().unwrap();
}
```

## 工作线程池

```rust
use std::sync::{mpsc, Arc, Mutex};
use std::thread;

type Job = Box<dyn FnOnce() + Send + 'static>;

struct ThreadPool {
    workers: Vec<Worker>,
    sender: Option<mpsc::Sender<Job>>,
}

struct Worker {
    id: usize,
    thread: Option<thread::JoinHandle<()>>,
}

impl ThreadPool {
    fn new(size: usize) -> ThreadPool {
        let (sender, receiver) = mpsc::channel();
        let receiver = Arc::new(Mutex::new(receiver));
        
        let mut workers = Vec::with_capacity(size);
        
        for id in 0..size {
            workers.push(Worker::new(id, Arc::clone(&receiver)));
        }
        
        ThreadPool {
            workers,
            sender: Some(sender),
        }
    }
    
    fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let job = Box::new(f);
        self.sender.as_ref().unwrap().send(job).unwrap();
    }
}

impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
        let thread = thread::spawn(move || loop {
            let job = receiver.lock().unwrap().recv();
            
            match job {
                Ok(job) => {
                    println!("Worker {} got a job", id);
                    job();
                }
                Err(_) => {
                    println!("Worker {} shutting down", id);
                    break;
                }
            }
        });
        
        Worker {
            id,
            thread: Some(thread),
        }
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        drop(self.sender.take());
        
        for worker in &mut self.workers {
            if let Some(thread) = worker.thread.take() {
                thread.join().unwrap();
            }
        }
    }
}
```

## Actor 模式

```rust
use tokio::sync::mpsc;

// Actor 消息
enum Message {
    Increment,
    Decrement,
    GetValue(tokio::sync::oneshot::Sender<i32>),
}

// Actor
struct Counter {
    value: i32,
    receiver: mpsc::Receiver<Message>,
}

impl Counter {
    fn new(receiver: mpsc::Receiver<Message>) -> Self {
        Counter { value: 0, receiver }
    }
    
    async fn run(&mut self) {
        while let Some(msg) = self.receiver.recv().await {
            match msg {
                Message::Increment => self.value += 1,
                Message::Decrement => self.value -= 1,
                Message::GetValue(reply) => {
                    let _ = reply.send(self.value);
                }
            }
        }
    }
}

// Actor Handle
#[derive(Clone)]
struct CounterHandle {
    sender: mpsc::Sender<Message>,
}

impl CounterHandle {
    fn new() -> Self {
        let (sender, receiver) = mpsc::channel(100);
        let mut actor = Counter::new(receiver);
        tokio::spawn(async move { actor.run().await });
        CounterHandle { sender }
    }
    
    async fn increment(&self) {
        self.sender.send(Message::Increment).await.unwrap();
    }
    
    async fn decrement(&self) {
        self.sender.send(Message::Decrement).await.unwrap();
    }
    
    async fn get_value(&self) -> i32 {
        let (tx, rx) = tokio::sync::oneshot::channel();
        self.sender.send(Message::GetValue(tx)).await.unwrap();
        rx.await.unwrap()
    }
}

#[tokio::main]
async fn main() {
    let counter = CounterHandle::new();
    
    counter.increment().await;
    counter.increment().await;
    counter.decrement().await;
    
    println!("Value: {}", counter.get_value().await);  // 1
}
```

## Fan-out/Fan-in 模式

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (result_tx, mut result_rx) = mpsc::channel(100);
    
    // Fan-out: 分发任务给多个 worker
    for i in 0..4 {
        let tx = result_tx.clone();
        tokio::spawn(async move {
            // 模拟工作
            let result = i * 10;
            tx.send(result).await.unwrap();
        });
    }
    
    drop(result_tx);  // 关闭原始发送端
    
    // Fan-in: 收集所有结果
    let mut results = vec![];
    while let Some(result) = result_rx.recv().await {
        results.push(result);
    }
    
    println!("Results: {:?}", results);
}
```

## 管道模式

```rust
use tokio::sync::mpsc;

async fn stage1(input: mpsc::Receiver<i32>, output: mpsc::Sender<i32>) {
    let mut input = input;
    while let Some(x) = input.recv().await {
        output.send(x * 2).await.unwrap();
    }
}

async fn stage2(input: mpsc::Receiver<i32>, output: mpsc::Sender<i32>) {
    let mut input = input;
    while let Some(x) = input.recv().await {
        output.send(x + 1).await.unwrap();
    }
}

#[tokio::main]
async fn main() {
    let (tx1, rx1) = mpsc::channel(100);
    let (tx2, rx2) = mpsc::channel(100);
    let (tx3, mut rx3) = mpsc::channel(100);
    
    tokio::spawn(stage1(rx1, tx2));
    tokio::spawn(stage2(rx2, tx3));
    
    // 发送数据进入管道
    for i in 1..=5 {
        tx1.send(i).await.unwrap();
    }
    drop(tx1);
    
    // 收集结果
    while let Some(result) = rx3.recv().await {
        println!("{}", result);  // 3, 5, 7, 9, 11
    }
}
```

## 超时和取消

```rust
use tokio::time::{timeout, Duration};
use tokio::select;

#[tokio::main]
async fn main() {
    // 使用 timeout
    let result = timeout(Duration::from_secs(1), async {
        tokio::time::sleep(Duration::from_secs(2)).await;
        "done"
    }).await;
    
    match result {
        Ok(value) => println!("Completed: {}", value),
        Err(_) => println!("Timeout!"),
    }
    
    // 使用 select 实现取消
    let (cancel_tx, mut cancel_rx) = tokio::sync::oneshot::channel();
    
    let task = tokio::spawn(async move {
        select! {
            _ = async { 
                tokio::time::sleep(Duration::from_secs(10)).await;
                "task completed"
            } => {
                println!("Task finished");
            }
            _ = &mut cancel_rx => {
                println!("Task cancelled");
            }
        }
    });
    
    // 取消任务
    tokio::time::sleep(Duration::from_millis(100)).await;
    let _ = cancel_tx.send(());
    
    task.await.unwrap();
}
```

## 读写锁优化模式

```rust
use std::sync::Arc;
use tokio::sync::RwLock;

struct Cache {
    data: Arc<RwLock<std::collections::HashMap<String, String>>>,
}

impl Cache {
    fn new() -> Self {
        Cache {
            data: Arc::new(RwLock::new(std::collections::HashMap::new())),
        }
    }
    
    async fn get(&self, key: &str) -> Option<String> {
        let data = self.data.read().await;
        data.get(key).cloned()
    }
    
    async fn set(&self, key: String, value: String) {
        let mut data = self.data.write().await;
        data.insert(key, value);
    }
    
    // 双检锁模式
    async fn get_or_insert<F>(&self, key: String, f: F) -> String
    where
        F: FnOnce() -> String,
    {
        // 先尝试读取
        {
            let data = self.data.read().await;
            if let Some(value) = data.get(&key) {
                return value.clone();
            }
        }
        
        // 不存在，获取写锁
        let mut data = self.data.write().await;
        // 再次检查（可能其他线程已经插入）
        if let Some(value) = data.get(&key) {
            return value.clone();
        }
        
        let value = f();
        data.insert(key, value.clone());
        value
    }
}
```
