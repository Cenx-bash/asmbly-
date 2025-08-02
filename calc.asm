section .data
    msg1 db "Enter first number: ",0
    msg2 db "Enter second number: ",0
    msg3 db "Enter operation (+ - * /): ",0
    resMsg db "Result: ",0
    newline db 10,0

section .bss
    num1 resb 16
    num2 resb 16
    op   resb 4
    outbuf resb 32

section .text
    global _start

;-----------------------------------
; Print string (RDI = address)
;-----------------------------------
print:
    push rdi
    mov rsi, rdi
    mov rax, 0
.len:
    cmp byte [rsi], 0
    je .got_len
    inc rsi
    inc rax
    jmp .len
.got_len:
    mov rdx, rax
    pop rsi
    mov rax, 1
    mov rdi, 1
    syscall
    ret

;-----------------------------------
; Read input (RDI = buffer)
;-----------------------------------
read_input:
    mov rax, 0
    mov rdi, 0
    mov rsi, rdi
    mov rdx, 16
    syscall
    ret

;-----------------------------------
; Convert ASCII to int
;-----------------------------------
atoi:
    xor rax, rax
.next:
    mov bl, [rsi]
    cmp bl, 10
    je .done
    cmp bl, 0
    je .done
    sub bl, '0'
    imul rax, rax, 10
    add rax, rbx
    inc rsi
    jmp .next
.done:
    ret

;-----------------------------------
; Convert int to ASCII
;-----------------------------------
itoa:
    mov rcx, outbuf+31
    mov byte [rcx], 0
    mov rbx, 10
    cmp rdi, 0
    jge .pos
    neg rdi
    mov bl, '-'
    push rbx
.pos:
    mov rax, rdi
.convert:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .convert
    mov rsi, rcx
    ret

;-----------------------------------
; Main program
;-----------------------------------
_start:
    ; Ask first number
    mov rdi, msg1
    call print
    mov rdi, num1
    call read_input
    mov rsi, num1
    call atoi
    mov r8, rax

    ; Ask second number
    mov rdi, msg2
    call print
    mov rdi, num2
    call read_input
    mov rsi, num2
    call atoi
    mov r9, rax

    ; Ask operation
    mov rdi, msg3
    call print
    mov rdi, op
    call read_input
    mov al, [op]

    ; Compute
    cmp al, '+'
    je .add
    cmp al, '-'
    je .sub
    cmp al, '*'
    je .mul
    cmp al, '/'
    je .div

.add:
    mov rax, r8
    add rax, r9
    jmp .print_res

.sub:
    mov rax, r8
    sub rax, r9
    jmp .print_res

.mul:
    mov rax, r8
    imul rax, r9
    jmp .print_res

.div:
    mov rax, r8
    xor rdx, rdx
    idiv r9
    jmp .print_res

.print_res:
    mov rdi, resMsg
    call print
    mov rdi, rax
    call itoa
    mov rdi, rsi
    call print
    mov rdi, newline
    call print

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
:---------------------
: nasm -f elf64 calc.asm -o calc.o
: ld calc.o -o calc
: ./calc
:---------------------