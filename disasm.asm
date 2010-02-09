; main control module
.model small
locals

public print

extrn parse: far

stk segment stack use16
    db 256 dup(0)
stk ends

data segment para public 'data' use16
    input_msg db 'Input filename: $'
    db 254 
    db 0 
    buff db 255 dup (?)
    out_buff db 255 dup (?)
    filehandle dw 0
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
    mov cx, 253
    lea dx, buff
    int 21h

    ; now we have a buffer, will control it at further

exit:
    mov ax, 4c00h
    int 21h
main endp
code ends
end main