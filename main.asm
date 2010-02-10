.model small
locals

public print

extrn parse: far

stk segment stack use16
    db 256 dup (?)
stk ends

data segment para public 'data' use16
    input_msg db 'Input filename: $'
    filehandle dw 0
    db 254 
    db 0 
    buff db 255 dup (?)
    out_buff db 255 dup (?)
data ends

code segment para public 'code' use16
assume cs:code, ds:data, ss:stk

print proc far
    mov ah, 09h
    int 21h
    ret
print endp

main proc
    mov ax, data
    mov ds, ax
    
    mov dx, offset input_msg
    call print
    
    mov ah, 0Ah
    mov dx, offset buff - 2; the last symbol always will be 0Dh 
    int 21h
    
    mov al, byte ptr [offset buff - 1]; get the count of read bytes
    xor ah, ah
    mov si, ax
    mov buff[si], 0; now we have a nasty buff

    mov ax, 3D00h
    lea dx, buff
    int 21h
    mov filehandle, ax
                
    mov bx, ax
    mov ah, 3Fh
    mov cx, 255 - 2
    lea dx, buff
    int 21h

    ; Now we have a buffer, will control it at further
    ; Then here will be a main cycle, where each student function
    ; will be called. The buffer of commands will be managed, to have
    ; length at any time >= 15bytes. If no command were recognized, we simply
    ; output one byte in HEX, and run cycle again, until EOF reached.
    ; Students must provide object files, that exports their functions.
    ; Also there will be some convenient mechanism, that allow students to add their functions,
    ; without touching this file 
    ; @kravitz 08.02.10 22:39
exit:
    mov ax, 4C00h
    int 21h
main endp
code ends
end main
