.model small
.386
locals

extrn memcpy: far

public parse_nop

data segment para public 'data' use16
    nop_msg db 'nop', 10
data ends

code segment para public 'code' use16
assume cs: code

parse_nop proc pascal far
uses cx
    cmp byte ptr [si], 90h
    jne short @@exit
    push si
    lea si, nop_msg
    mov cx, 4
    call memcpy
    pop si
    inc si
    add di, 4
@@exit:
    ret
parse_nop endp

code ends
end
