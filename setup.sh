#!/bin/bash
# Project setup script for assembly learning environment

echo "Setting up Assembly Learning Project..."

# Create directory structure
mkdir -p src/nasm
mkdir -p src/gcc
mkdir -p debug/{nasm,gcc}
mkdir -p release/{nasm,gcc}

# Create a simple NASM hello world example
cat >src/nasm/hello_nasm.asm <<'EOF'
section .data
    msg db 'Hello World from NASM!', 0xA, 0
    msg_len equ $ - msg

section .text
    global _start

_start:
    ; write system call
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; message to write
    mov rdx, msg_len    ; message length
    syscall             ; call kernel

    ; exit system call
    mov rax, 60         ; sys_exit
    mov rdi, 0          ; exit status
    syscall             ; call kernel
EOF

# Create a simple GCC assembly example
cat >src/gcc/hello_gcc.s <<'EOF'
.section .data
    msg: .ascii "Hello World from GCC Assembly!\n"
    msg_len = . - msg

.section .text
    .global _start

_start:
    # write system call
    movq $1, %rax       # sys_write
    movq $1, %rdi       # stdout
    movq $msg, %rsi     # message to write
    movq $msg_len, %rdx # message length
    syscall             # call kernel

    # exit system call
    movq $60, %rax      # sys_exit
    movq $0, %rdi       # exit status
    syscall             # call kernel
EOF

# Create a more complex example with functions
cat >src/nasm/calculator_nasm.asm <<'EOF'
section .data
    num1 dq 42
    num2 dq 24
    result dq 0

section .text
    global _start

add_numbers:
    ; Function to add two numbers
    ; Parameters: rdi = first number, rsi = second number
    ; Returns: rax = sum
    mov rax, rdi
    add rax, rsi
    ret

_start:
    ; Load numbers
    mov rdi, [num1]
    mov rsi, [num2]
    
    ; Call add function
    call add_numbers
    
    ; Store result
    mov [result], rax
    
    ; Exit program
    mov rax, 60
    mov rdi, 0
    syscall
EOF

echo "Project structure created!"
echo ""
echo "Files created:"
echo "  src/nasm/hello_nasm.asm     - Simple NASM hello world"
echo "  src/gcc/hello_gcc.s         - Simple GCC assembly hello world"
echo "  src/nasm/calculator_nasm.asm - NASM example with functions"
echo ""
echo "Now you can use the Makefile with commands like:"
echo "  make nasm-debug        # Compile NASM files in debug mode"
echo "  make gcc-release       # Compile GCC files in release mode"
echo "  make all-debug         # Compile everything in debug mode"
echo "  make help              # Show all available commands"
echo ""
echo "To run a compiled program:"
echo "  ./debug/nasm/hello_nasm"
echo "  ./release/gcc/hello_gcc"
