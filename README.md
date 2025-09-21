# Assembly Learning Project

A comprehensive development environment for learning x86-64 assembly language with support for both NASM and GCC assemblers. This project provides organized compilation workflows, interactive execution tools, and proper debugging support.

## 🏗️ Project Structure

```
learn-asm/
├── Makefile           # Comprehensive build system
├── build.sh           # Interactive build and execution script  
├── setup.sh           # Project initialization with examples
├── .gitignore         # Git ignore rules for assembly projects
├── src/               # Source code directory
│   ├── nasm/          # NASM assembly files (.asm)
│   └── gcc/           # GCC assembly files (.s)
├── debug/             # Debug builds (with debug symbols)
│   ├── nasm/          # NASM debug executables
│   └── gcc/           # GCC debug executables
└── release/           # Release builds (optimized)
    ├── nasm/          # NASM release executables
    └── gcc/           # GCC release executables
```

## 🚀 Quick Start

### 1. Initial Setup

```bash
# Clone or create the project directory
mkdir learn-asm && cd learn-asm

# Copy the Makefile, build.sh, and setup.sh files
# Make scripts executable
chmod +x build.sh setup.sh

# Create example files and directory structure
./setup.sh

# Initialize git repository (optional)
git init
git remote add origin git@github.com:yourusername/learn-asm.git
```

### 2. Build Everything

```bash
# Build all files (debug + release)
./build.sh build

# OR use Makefile directly
make all-debug    # Build all files in debug mode
make all-release  # Build all files in release mode
```

### 3. Run Executables

```bash
# Interactive execution with search/filter
./build.sh display

# Or run directly
./debug/nasm/hello_nasm
./release/gcc/hello_gcc
```

## 📁 File Organization

### Source Files

- **NASM files**: Place `.asm` files in `src/nasm/`
- **GCC Assembly files**: Place `.s` files in `src/gcc/`

### File Naming Conventions

- NASM assembly: `filename.asm` (Intel syntax)
- GCC assembly: `filename.s` (AT&T syntax)
- No spaces in filenames (use underscores: `hello_world.asm`)

## 🔨 Makefile Usage

### Batch Compilation

```bash
# Compile all files
make all-debug          # Everything in debug mode
make all-release        # Everything in release mode

# Compile by assembler type
make nasm-debug         # All NASM files (debug)
make nasm-release       # All NASM files (release)
make gcc-debug          # All GCC files (debug)
make gcc-release        # All GCC files (release)
```

### Single File Compilation

```bash
# Explicit method
make compile-nasm-debug FILE=hello_world
make compile-nasm-release FILE=calculator
make compile-gcc-debug FILE=hello_world
make compile-gcc-release FILE=string_ops

# Convenient shortcuts
make nasm FILE=hello_world MODE=debug      # Default: debug
make nasm FILE=hello_world MODE=release
make gcc FILE=string_ops MODE=debug

# Auto-detection (finds .asm or .s automatically)
make debug FILE=hello_world       # Auto-detects file type
make release FILE=calculator      # Auto-detects file type

# Full path specification
make single FILE=src/nasm/hello.asm MODE=debug
make single FILE=src/gcc/string.s MODE=release
```

### Utility Commands

```bash
make clean              # Remove all build files
make dirs               # Create directory structure
make help               # Show all available commands
make status             # Show project information
make debug-vars         # Debug Makefile variables
```

## 🎯 Build Script Usage

The `build.sh` script provides an interactive interface for building and running assembly programs.

### Available Commands

```bash
./build.sh build       # Build all files (debug + release)
./build.sh display     # Interactive executable search/runner
./build.sh clean       # Clean all build directories
./build.sh format      # Format source code
./build.sh help        # Show help information
```

### Interactive Display Mode

The `display` command provides a powerful search and execution interface:

```bash
./build.sh display
```

**Filter Options:**
- `nasm` - Show only NASM executables
- `gcc` - Show only GCC executables
- `debug` - Show only debug builds
- `release` - Show only release builds
- `hello` - Search for files containing "hello"
- `*` - Show all executables

**Execution Options:**
- Select numbered item to run single executable
- Type `a` to run all filtered executables
- Type `s` to search again
- Press Enter to just list without execution

## 📝 Setup Script

The `setup.sh` script creates example assembly files to get you started:

```bash
./setup.sh
```

**Creates:**
- `src/nasm/hello_nasm.asm` - Simple NASM hello world
- `src/gcc/hello_gcc.s` - Simple GCC assembly hello world  
- `src/nasm/calculator_nasm.asm` - NASM example with functions

## 🔧 Compilation Details

### Debug Builds

**NASM Debug Flags:**
- `-f elf64` - 64-bit ELF output format
- `-g` - Generate debugging information
- `-F dwarf` - Use DWARF debugging format

**GCC Debug Flags:**
- `-g` - Generate debugging information
- `-gdwarf-4` - Use DWARF-4 format
- `-c` - Compile only, don't link

**Linker Debug Flags:**
- `-g` - Preserve debugging information

### Release Builds

**NASM Release Flags:**
- `-f elf64` - 64-bit ELF output format
- `-O2` - Enable optimizations

**GCC Release Flags:**
- `-O2` - Enable optimizations
- `-c` - Compile only, don't link

**Linker Release Flags:**
- `-s` - Strip symbol table
- `--strip-all` - Remove all symbols

## 🐛 Debugging

### Using GDB

```bash
# Compile in debug mode
make debug FILE=my_program

# Debug with GDB
gdb ./debug/nasm/my_program

# GDB commands
(gdb) break _start          # Set breakpoint at _start
(gdb) run                   # Run program
(gdb) stepi                 # Step one instruction
(gdb) info registers        # Show register values
(gdb) x/10i $rip           # Disassemble around current instruction
```

### Assembly-Specific Debugging

```bash
# View disassembly
objdump -d ./debug/nasm/my_program

# View symbols
nm ./debug/nasm/my_program

# View file information
file ./debug/nasm/my_program
```

## 📚 Example Workflows

### Workflow 1: Quick Testing

```bash
# Create a new assembly file
vim src/nasm/test.asm

# Compile and test
make debug FILE=test
./debug/nasm/test
```

### Workflow 2: Comprehensive Development

```bash
# Build everything
./build.sh build

# Interactive testing
./build.sh display
# Filter by 'debug' to see all debug builds
# Run and test different executables
```

### Workflow 3: Performance Comparison

```bash
# Build both debug and release versions
make debug FILE=algorithm
make release FILE=algorithm

# Compare performance
time ./debug/nasm/algorithm
time ./release/nasm/algorithm
```

### Workflow 4: Assembly Learning

```bash
# Create examples for both assemblers
vim src/nasm/example.asm    # Intel syntax
vim src/gcc/example.s       # AT&T syntax

# Build and compare
make nasm FILE=example MODE=debug
make gcc FILE=example MODE=debug

# Examine generated code
objdump -d debug/nasm/example
objdump -d debug/gcc/example
```

## 🔍 Troubleshooting

### Common Issues

**"No rule to make target" error:**
```bash
# Check file exists and is in correct directory
ls -la src/nasm/yourfile.asm
make debug-vars  # Check what Makefile detects
```

**Permission denied when running executables:**
```bash
# Check file is executable
ls -la debug/nasm/yourfile
chmod +x debug/nasm/yourfile  # If needed
```

**Build fails:**
```bash
# Check for syntax errors in assembly
make clean
make debug FILE=yourfile  # Build single file to isolate issue
```

### Getting Help

```bash
make help           # Makefile options
./build.sh help     # Build script options
make status         # Project status information
```

## 🎓 Learning Resources

### Assembly Syntax Differences

**NASM (Intel Syntax):**
```nasm
mov rax, 42         ; destination, source
mov [rbp-8], rax    ; memory addressing
```

**GAS (AT&T Syntax):**
```gas
movq $42, %rax      ; source, destination (note $ and %)
movq %rax, -8(%rbp) ; memory addressing
```

### Useful Commands for Learning

```bash
# Compare assembly output
make debug FILE=example
objdump -d debug/nasm/example > nasm_output.txt
objdump -d debug/gcc/example > gcc_output.txt
diff nasm_output.txt gcc_output.txt

# Analyze performance
perf stat ./release/nasm/example
perf stat ./release/gcc/example
```

## 🤝 Contributing

1. Create feature branches for new functionality
2. Test with both NASM and GCC assembly files
3. Update documentation for new features
4. Ensure compatibility with both debug and release builds

## 📄 License

This project template is provided as-is for educational purposes. Use and modify freely for learning assembly language programming.

---

**Happy Assembly Programming! 🚀**

For questions or issues, refer to the troubleshooting section or check the Makefile help: `make help`
