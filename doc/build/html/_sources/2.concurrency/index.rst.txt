########################
2. 并发编程
########################

Rust 的并发模型被称为 **Fearless Concurrency**（无畏并发），
通过类型系统在编译期消除数据竞争。

.. note::

   Rust 的并发安全是通过两个核心 trait 实现的：

   - ``Send``: 类型可以安全地跨线程传递所有权
   - ``Sync``: 类型可以安全地在多线程间共享引用

   大多数类型自动实现这两个 trait，编译器会在你尝试不安全操作时报错。

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   threads
   message_passing
   shared_state
   async_await
   tokio
   patterns
