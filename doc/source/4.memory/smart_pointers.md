# 智能指针

## Box<T>

堆上分配数据，独占所有权。

```rust
// 递归类型必须使用 Box
enum List {
    Cons(i32, Box<List>),
    Nil,
}

let list = List::Cons(1,
    Box::new(List::Cons(2,
        Box::new(List::Cons(3,
            Box::new(List::Nil))))));
```

## Rc<T>

引用计数，允许多个所有者。**单线程**使用。

```rust
use std::rc::Rc;

let a = Rc::new(5);
let b = Rc::clone(&a);  // 引用计数 +1
let c = Rc::clone(&a);

println!("count: {}", Rc::strong_count(&a));  // 3
```

## Arc<T>

原子引用计数，**线程安全**版本的 Rc。

```rust
use std::sync::Arc;
use std::thread;

let data = Arc::new(vec![1, 2, 3]);

let handles: Vec<_> = (0..3).map(|_| {
    let data = Arc::clone(&data);
    thread::spawn(move || {
        println!("{:?}", data);
    })
}).collect();

for h in handles {
    h.join().unwrap();
}
```

## Weak<T>

弱引用，不增加引用计数，用于打破循环引用。

```rust
use std::rc::{Rc, Weak};
use std::cell::RefCell;

struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>,
    children: RefCell<Vec<Rc<Node>>>,
}

let leaf = Rc::new(Node {
    value: 3,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![]),
});

let branch = Rc::new(Node {
    value: 5,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![Rc::clone(&leaf)]),
});

*leaf.parent.borrow_mut() = Rc::downgrade(&branch);

// 使用 upgrade() 获取强引用
if let Some(parent) = leaf.parent.borrow().upgrade() {
    println!("Parent value: {}", parent.value);
}
```

## 与 C++ 智能指针对比

| Rust | C++ | 说明 |
|------|-----|------|
| `Box<T>` | `unique_ptr<T>` | 独占所有权 |
| `Rc<T>` | `shared_ptr<T>` | 共享所有权（单线程）|
| `Arc<T>` | `shared_ptr<T>` + 原子 | 线程安全共享 |
| `Weak<T>` | `weak_ptr<T>` | 弱引用 |

## 何时使用哪种指针

```{note}
决策流程：

1. 需要堆分配？
   - 否 → 使用栈上值
   - 是 → 继续
2. 需要多个所有者？
   - 否 → `Box<T>`
   - 是 → 继续
3. 需要跨线程？
   - 否 → `Rc<T>`
   - 是 → `Arc<T>`
4. 有循环引用？
   - 是 → 使用 `Weak<T>` 打破循环
```

## Deref Trait

智能指针实现 `Deref`，允许自动解引用：

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;
    
    fn deref(&self) -> &T {
        &self.0
    }
}

let x = MyBox(5);
assert_eq!(5, *x);  // 自动调用 deref
```

## Drop Trait

离开作用域时自动调用：

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping: {}", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer { data: String::from("hello") };
    // 提前释放
    drop(c);  // 或 std::mem::drop(c)
    // c 在这里已经无效
}
```
