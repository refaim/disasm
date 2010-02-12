.model small
.386
locals

extrn memcpy: far

public parse_jxx

data segment para public 'data' use16
    ; [70h, 7Fh] + [0Fh 80h, 0Fh 8Fh] + {E3h}
    elm_sz db 4
    oss db 1 dup('jo  ', 'jno ', 'jb  ', 'jae ', 'je  ', 'jnz ', 'jbe ', \
                 'ja  ', 'js  ', 'jns ', 'jp  ', 'jpo ', 'jl  ', 'jge ', \
                 'jle ', 'jg  ')
    os_jcxz db 'jcxz$'
    oc_jcxz db 0E3h

    oc_short_lbound equ 70h
    oc_short_hbound equ 7Fh
    oc_near_prefix equ 0Fh
    oc_near_lbound equ 80h
    oc_near_hbound equ 8Fh
data ends

code segment para public 'code' use16
assume cs: code, ds: data

parse_jxx proc pascal far
uses ax, cx, dx
    xor ax, ax
    mov al, byte ptr [si]
    cmp al, oc_near_prefix
    je short @@near
    cmp al, oc_short_lbound
    jl short @@exit
    cmp al, oc_short_hbound
    jg short @@exit
@@short:
    push si
    sub al, oc_short_lbound
    mul elm_sz
    mov si, ax
    lea si, oss[si]
    mov cl, elm_sz
    call memcpy
    add di, 4
    mov byte ptr [di], 10
    inc di
    pop si
    inc si
@@near:
@@exit:
    ret
parse_jxx endp

code ends
end
