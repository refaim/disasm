.model small
.386
locals

OUT_BUFF_MARGIN equ 235
IN_BUFF_MARGIN  equ 240

invoke macro func
    call func 
    mov bp, sp   
    cmp si, word ptr [bp]
    ja @@restart ; Very dangerous to make it SHORT - cause main cycle will grow
    jne @@error
endm

extrn print: far, byte2hex: far, memcpy: far
extrn parse: far

stk segment stack use16
    db 256 dup (0)
stk ends

data segment para public 'data' use16
    input_msg db 'Input filename: $'
    filehandle dw 0

    db 254
    db 0
    in_buff db 255 dup (?)
    in_buff_size dw 0
    out_buff db 255 dup (?)
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

; dx - offset of buffer, cx - count to read
read proc pascal
uses bx
    mov bx, filehandle
    mov ah, 3Fh
    int 21h
    ret
read endp

main proc
    mov ax, data
    mov ds, ax

    lea dx, input_msg
    call print

    mov ah, 0Ah
    mov dx, offset in_buff - 2 ; the last symbol always will be 0Dh
    int 21h
    mov al, byte ptr [offset in_buff - 1] ; get the count of read bytes
    xor ah, ah
    mov si, ax
    mov in_buff[si], 0 ; now we have a nasty buff

    mov ax, 3D00h
    lea dx, in_buff
    int 21h
    jc near ptr @@error
    mov filehandle, ax

    ;mov bx, ax
    ;mov ah, 3Fh
    ;mov cx, 255
    ;lea dx, in_buff
    ;int 21h
    mov cx, 255
    lea dx, in_buff
    call read
    jc @@error
    mov in_buff_size, ax
    
    lea si, in_buff
    lea di, out_buff    
@@main_cycle label near
    push si
    ;push di ; - deprecated
    
    invoke parse ; - in this form users will enter commands
    ;If no command was recognized - simply output it
    mov al, byte ptr [si]
    call byte2hex    
    mov [di], ah
    mov [di + 1], al
    mov byte ptr [di + 2], ' '
    add di, 3 ; two hex digits and one space
    add si, 1 ; one unrecognized byte
@@restart label near
    ;check if in_buff need to be flushed
    ;sub sp, 2 ;clean space for stored in 
    lea ax, out_buff
    mov bx, di
    sub bx, ax
    cmp bx, OUT_BUFF_MARGIN
    jb short @@in_buff_check 
    mov byte ptr [di], '$'
    mov di, ax
    mov dx, di
    call print
@@in_buff_check label near
    mov ax, in_buff_size
    cmp ax, 255
    je short @@refill
    add ax, offset in_buff
    cmp si, ax
    jb @@main_cycle
    je short @@cout
    
@@refill: 
    sub sp, 2 ;si
    lea ax, in_buff
    mov bx, si
    sub bx, ax
    cmp bx, IN_BUFF_MARGIN
    jb @@main_cycle
    push di ; save
    mov cx, 255
    sub cx, bx; length of tail
    mov bp, cx
    lea di, in_buff
    call memcpy
    mov si, di
    pop di
    mov dx, si
    add dx, cx
    mov bx, 255
    sub bx, cx
    mov cx, bx
    call read
    add bp, ax
    mov in_buff_size, bp
    cmp bp, 0
    jne @@main_cycle 

    ;check if out_buff need to be flushed


@@cout:
    ; flush buffer and exit
    mov byte ptr [di], '$'
    lea dx, out_buff
    call print
    ;mov test_str[0], ah
    ;mov test_str[1], al
    ;mov test_str[2], '$'
    ;lea dx, test_str
    ;call print
    ;inc si
    ;cmp si, 100
    ;jl @@cout

    ; Now we have a buffer, will control it at further
    ; Then here will be a main cycle, where each student function
    ; will be called. The buffer of commands will be managed, to have
    ; length at any time >= 15bytes. If no command were recognized, we simply
    ; output one byte in HEX, and run cycle again, until EOF reached.
    ; Students must provide object files, that exports their functions.
    ; Also there will be some convenient mechanism, that allow students to add their functions,
    ; without touching this file
    ; @kravitz 08.02.10 22:39
@@exit label near
    mov ax, 4C00h
    int 21h
@@error label near
    lea dx, input_msg
    call print
    mov ax, 4C01h
    int 21h
main endp
code ends
end main
