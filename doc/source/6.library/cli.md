# 命令行工具

## clap

```toml
[dependencies]
clap = { version = "4", features = ["derive"] }
```

### 基本用法

```rust
use clap::Parser;

#[derive(Parser)]
#[command(name = "myapp")]
#[command(about = "A sample application")]
struct Args {
    /// Name of the person to greet
    #[arg(short, long)]
    name: String,
    
    /// Number of times to greet
    #[arg(short, long, default_value_t = 1)]
    count: u8,
    
    /// Verbose mode
    #[arg(short, long, action = clap::ArgAction::SetTrue)]
    verbose: bool,
}

fn main() {
    let args = Args::parse();
    
    for _ in 0..args.count {
        println!("Hello, {}!", args.name);
    }
}
```

### 子命令

```rust
use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Add a new item
    Add {
        #[arg(short, long)]
        name: String,
    },
    /// List all items
    List {
        #[arg(short, long)]
        all: bool,
    },
}

fn main() {
    let cli = Cli::parse();
    
    match cli.command {
        Commands::Add { name } => println!("Adding: {}", name),
        Commands::List { all } => println!("Listing (all={})", all),
    }
}
```

## 进度条 indicatif

```toml
[dependencies]
indicatif = "0.17"
```

```rust
use indicatif::{ProgressBar, ProgressStyle};

let pb = ProgressBar::new(100);
pb.set_style(ProgressStyle::default_bar()
    .template("{spinner:.green} [{bar:40.cyan/blue}] {pos}/{len} ({eta})")
    .unwrap()
    .progress_chars("#>-"));

for _ in 0..100 {
    pb.inc(1);
    std::thread::sleep(std::time::Duration::from_millis(50));
}

pb.finish_with_message("Done!");
```

## 彩色输出 colored

```rust
use colored::*;

println!("{}", "This is red".red());
println!("{}", "This is bold blue".blue().bold());
println!("{}", "Green on yellow".green().on_yellow());
```
