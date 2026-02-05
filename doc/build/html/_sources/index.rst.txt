.. Rust 实战开发指南 documentation master file

Rust 实战开发指南
=======================================

.. image:: https://www.rust-lang.org/logos/rust-logo-512x512.png
   :alt: Rust Logo
   :width: 150px
   :align: center

.. include:: links.ref
.. include:: tags.ref
.. include:: abbrs.ref

============= ==============================================================
**Abstract**  Rust 实战开发指南 - 专注于易错和易忽略的知识点
**Authors**   Walter Fan
**Category**  learning note
**Status**    WIP
**Updated**   |date|
**License**   |CC-BY-NC-ND|
============= ==============================================================

欢迎阅读 **Rust 实战开发指南**！本文档专注于 Rust 开发中程序员 **易错** 和 **易忽略** 的知识点，
以及 Rust 相比其他语言 **特殊** 的地方，尤其是 Rust 独有的 **所有权系统、借用检查、生命周期** 等核心特性。

.. note::

   本指南特别面向 **C++/Java 程序员**，帮助你快速理解 Rust 的独特设计理念，
   避免将其他语言的思维习惯错误地带入 Rust 开发中。

目标读者
--------

- 有 C++/Java/Python 等编程经验，想学习 Rust 的开发者
- 希望理解 Rust 核心概念（所有权、借用、生命周期）的程序员
- 想要编写高性能、内存安全代码的工程师
- 对并发编程和系统编程感兴趣的开发者

文档特点
--------

- **从 C++/Java 视角出发**：对比分析，帮助快速理解 Rust 设计哲学
- **避坑指南**：重点讲解编译器常见错误、易混淆的概念
- **所有权深入**：彻底搞懂 Rust 最独特也最难的核心概念
- **并发优先**：重点讲解 Rust 的 "fearless concurrency"
- **实战代码**：可直接编译运行的完整示例

为什么学 Rust？
---------------

.. list-table::
   :widths: 20 40 40
   :header-rows: 1

   * - 对比项
     - C++
     - Rust
   * - 内存安全
     - 手动管理，易出错
     - 编译期保证，零成本抽象
   * - 并发安全
     - 需要程序员保证
     - 类型系统强制保证
   * - 空指针
     - 需要运行时检查
     - Option<T> 编译期消除
   * - 数据竞争
     - 运行时可能崩溃
     - 编译期阻止

.. toctree::
   :maxdepth: 2
   :caption: 目录
   :numbered:

   1.basic/index
   2.concurrency/index
   3.performance/index
   4.memory/index
   5.network/index
   6.library/index
   7.cheatsheet/index
   references

快速导航
--------

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: 🦀 基础与所有权
      :link: 1.basic/index
      :link-type: doc

      Rust 核心概念，所有权系统深入理解，借用与生命周期，从 C++/Java 迁移指南，常见编译错误解决。

   .. grid-item-card:: ⚡ 并发编程
      :link: 2.concurrency/index
      :link-type: doc

      Fearless Concurrency 理念，std::thread、Channel、Mutex、Arc，async/await 与 Tokio 异步运行时。

   .. grid-item-card:: 📊 性能调优
      :link: 3.performance/index
      :link-type: doc

      零成本抽象原理，cargo bench 基准测试，flamegraph 性能分析，编译器优化，SIMD 向量化。

   .. grid-item-card:: 🧠 内存管理
      :link: 4.memory/index
      :link-type: doc

      所有权与借用深入，智能指针 Box/Rc/Arc/RefCell，unsafe Rust 使用场景，内存布局与对齐。

   .. grid-item-card:: 🌐 网络编程
      :link: 5.network/index
      :link-type: doc

      std::net 基础，Tokio 异步网络，reqwest HTTP 客户端，hyper/axum Web 框架。

   .. grid-item-card:: 📦 常用库
      :link: 6.library/index
      :link-type: doc

      serde 序列化、tokio 异步运行时、clap 命令行、anyhow/thiserror 错误处理、tracing 日志。

经典资源
--------

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - 资源名称
     - 说明
   * - `The Rust Book <https://doc.rust-lang.org/book/>`_
     - 官方入门书籍，必读
   * - `Rust by Example <https://doc.rust-lang.org/rust-by-example/>`_
     - 通过示例学习 Rust
   * - `Rustlings <https://github.com/rust-lang/rustlings>`_
     - 交互式练习题
   * - `crates.io <https://crates.io/>`_
     - Rust 包管理中心
   * - `docs.rs <https://docs.rs/>`_
     - 所有 crate 的文档
   * - `Rust Playground <https://play.rust-lang.org/>`_
     - 在线运行 Rust 代码
   * - `This Week in Rust <https://this-week-in-rust.org/>`_
     - 每周 Rust 新闻


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
