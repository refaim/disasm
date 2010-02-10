.model small
locals

extrn print: far, byte2hex: far
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
    out_buff db 255 dup (?)

    test_str db 3 dup (?)
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

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
    jc @@error
    mov filehandle, ax

    mov bx, ax
    mov ah, 3Fh
    mov cx, 255 - 2
    lea dx, in_buff
    int 21h
    jc @@error

    xor si, si
@@cout:
    mov al, in_buff[si]
    call byte2hex
    mov test_str[0], ah
    mov test_str[1], al
    mov test_str[2], '$'
    lea dx, test_str
    call print
    inc si
    cmp si, 100
    jl @@cout

    ; Now we have a buffer, will control it at further
    ; Then here will be a main cycle, where each student function
    ; will be called. The buffer of commands will be managed, to have
    ; length at any time >= 15bytes. If no command were recognized, we simply
    ; output one byte in HEX, and run cycle again, until EOF reached.
    ; Students must provide object files, that exports their functions.
    ; Also there will be some convenient mechanism, that allow students to add their functions,
    ; without touching this file
    ; @kravitz 08.02.10 22:39
@@exit:
    mov ax, 4C00h
    int 21h
@@error:
    mov ax, 4C01h
    int 21h
main endp
code ends
end main
