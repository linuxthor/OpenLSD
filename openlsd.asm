BITS 64

global _start
_start:

    mov  rax,6           ; OpenBSD: sys_close / Linux: sys_lstat
    mov  rdi,arky
    mov  rsi,statz 
    syscall    
 
    cmp  rax,0
    je   linux

    ;  
    ; OpenBSD code 
    ;
    mov rdi,1
    mov rsi,obsd
    mov rdx,obyte
    mov rax,4            ; sys_write
    syscall

    mov rdi,69
    mov rax,1            ; sys_exit
    syscall      
 
linux:
    ;
    ; Linux code
    ;
    mov rdi,1
    mov rsi,linz
    mov rdx,lbyte
    mov rax,1            ; sys_write
    syscall

    mov rax, 60          ; sys_exit 
    mov rdi, 42        
    syscall

section .data
    arky db '/proc/self/stat',0 
    abyte equ $-arky
    obsd db 'OpenBSD',0x0a
    obyte equ $-obsd
    linz db 'Linux',0x0a
    lbyte equ $-linz
    statz db 144 ; sizeof(struct stat)

section .note.openbsd.ident 
    align 2 
    dd 8 
    dd 4 
    dd 1 
    db 'OpenBSD',0 
    dd 0 
    align 2 
