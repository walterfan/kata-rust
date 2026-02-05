########################
1. 基础与所有权
########################

本章介绍 Rust 的核心概念，重点讲解 **所有权系统** —— Rust 最独特也是最重要的特性。
对于 C++/Java 程序员来说，理解所有权是掌握 Rust 的关键。

.. note::

   如果你是 C++ 程序员，你会发现 Rust 的所有权概念与 C++ 的 RAII、移动语义有相似之处，
   但 Rust 在 **编译期** 就强制执行这些规则。

   如果你是 Java 程序员，你需要转变思维：Rust 没有垃圾回收器，
   但通过所有权系统保证内存安全。

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   overview
   ownership
   borrowing
   lifetime
   traits
   error_handling
   from_cpp
   from_java
   common_errors
