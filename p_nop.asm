.model small
.386
locals

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
    cld
    rep movsb
    pop si
    inc si
@@exit:
    ret
parse_nop endp

code ends
end
