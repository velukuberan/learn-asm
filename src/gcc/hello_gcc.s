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
