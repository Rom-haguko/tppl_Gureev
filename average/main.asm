global _start

section .data
    msg_err:    db ": файл испорчен", 10
    len_err:    equ $ - msg_err
    colon_sep:  db ": "
    minus_char: db '-'

section .bss
    buf:        resb 4096
    out_buf:    resb 32
    fname_ptr:  resq 1
    fname_len:  resq 1

section .text
_start:
    mov rax, [rsp]
    cmp rax, 2
    jl exit_silent

    mov rsi, [rsp + 16]
    mov [fname_ptr], rsi

    xor rcx, rcx
.len_loop:
    cmp byte [rsi + rcx], 0
    je .len_done
    inc rcx
    jmp .len_loop
.len_done:
    mov [fname_len], rcx

    mov rax, 2
    mov rdi, [fname_ptr]
    xor rsi, rsi
    xor rdx, rdx
    syscall
    test rax, rax
    js print_corrupted
    mov r8, rax

    xor rax, rax
    mov rdi, r8
    mov rsi, buf
    mov rdx, 4096
    syscall
    test rax, rax
    jle print_corrupted
    mov r9, rax

    mov rax, 3
    mov rdi, r8
    syscall

    mov rsi, buf
    lea r10, [buf + r9]

    xor r12, r12
    xor r13, r13
    xor r14, r14

loop_x:
    call skip_spaces
    cmp rsi, r10
    jae print_corrupted

    call parse_num
    jc print_corrupted
    add r12, rax
    inc r13

    call skip_spaces
    cmp rsi, r10
    jae print_corrupted

    mov al, [rsi]
    cmp al, 10
    je end_x
    cmp al, ','
    jne print_corrupted
    inc rsi
    jmp loop_x

end_x:
    inc rsi
    test r13, r13
    jz print_corrupted

loop_y:
    call skip_spaces
    cmp rsi, r10
    jae check_end_y
    cmp byte [rsi], 10
    je check_end_y

    call parse_num
    jc print_corrupted
    sub r12, rax
    inc r14

    call skip_spaces
    cmp rsi, r10
    jae check_end_y
    mov al, [rsi]
    cmp al, 10
    je check_end_y
    cmp al, ','
    jne print_corrupted
    inc rsi
    jmp loop_y

check_end_y:
    cmp r13, r14
    jne print_corrupted

    mov rax, r12
    cqo
    idiv r13

    push rax

    mov rax, 1
    mov rdi, 1
    mov rsi, [fname_ptr]
    mov rdx, [fname_len]
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, colon_sep
    mov rdx, 2
    syscall

    pop rax
    call print_num

    mov rax, 60
    xor rdi, rdi
    syscall

print_corrupted:
    mov rax, 1
    mov rdi, 1
    mov rsi, [fname_ptr]
    mov rdx, [fname_len]
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, msg_err
    mov rdx, len_err
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

exit_silent:
    mov rax, 60
    mov rdi, 1
    syscall

parse_num:
    xor r8, r8
    cmp rsi, r10
    jae .err
    cmp byte [rsi], '-'
    jne .check_digits
    inc r8
    inc rsi

.check_digits:
    cmp rsi, r10
    jae .err
    movzx rcx, byte [rsi]
    cmp cl, '0'
    jb .err
    cmp cl, '9'
    ja .err

    xor rax, rax
.loop:
    cmp rsi, r10
    jae .finish
    movzx rcx, byte [rsi]
    cmp cl, '0'
    jb .finish
    cmp cl, '9'
    ja .finish
    sub cl, '0'
    imul rax, 10
    add rax, rcx
    inc rsi
    jmp .loop

.finish:
    test r8, r8
    jz .done
    neg rax
.done:
    clc
    ret
.err:
    stc
    ret

skip_spaces:
.loop:
    cmp rsi, r10
    jae .out
    mov al, [rsi]
    cmp al, ' '
    je .skip
    cmp al, 9
    je .skip
    ret
.skip:
    inc rsi
    jmp .loop
.out:
    ret

print_num:
    test rax, rax
    jns .pos
    push rax
    mov rax, 1
    mov rdi, 1
    mov rsi, minus_char
    mov rdx, 1
    syscall
    pop rax
    neg rax

.pos:
    mov rbx, 10
    mov rdi, out_buf + 30
    mov byte [out_buf + 31], 10
.conv:
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .conv

    inc rdi
    mov rax, 1
    mov rsi, rdi
    mov rdx, out_buf + 32
    sub rdx, rdi
    mov rdi, 1
    syscall
    ret