.model small
.386
locals

extrn memcpy: far

public parse_jxx

data segment para public 'data' use16
    ; [70h, 7Fh] + [0Fh 80h, 0Fh 8Fh] + {E3h}
    op_str db 1 dup('jo', 'jno', 'jb', 'jae', 'je', 'jnz', 'jbe', 'ja', \
                    'js', 'jns', 'jp', 'jpo', 'jl', 'jge', 'jle', 'jg')
    op_shifts db 1 dup (0, 2, 5, 7, 10, 12, 15, 18, 20, 22, 25, 27, 30, \ 
                       32, 35, 38)
    op_lens db 1 dup (2, 3, 2, 3, 2, 3, 3, 2, 2, 3, 2, 3, 2, 3, 3, 2) 
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
uses ax, bx, dx
    movzx ax, byte ptr [si]
    cmp al, oc_near_prefix
    je short @@near
    cmp al, oc_short_lbound
    jl short @@exit
    cmp al, oc_short_hbound
    jg short @@exit
@@short:
    push si
    sub al, oc_short_lbound
    movzx si, al
    movzx bx, op_lens[si]
    movzx si, op_shifts[si]
    lea si, op_str[si]
    mov cx, bx
    call memcpy
    add di, bx
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
