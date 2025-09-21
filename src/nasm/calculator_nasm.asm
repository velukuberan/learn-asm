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
