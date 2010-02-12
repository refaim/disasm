.model small
.386
locals

extrn memcpy: far

public parse_jxx

check_opcode macro jxx_type
    cmp al, jxx_type[0]
    jl short @@jcxz
    cmp al, jxx_type[1]
    jg short @@jcxz
    sub al, jxx_type[0]
    call write_cmd
    jmp short @@exit
endm

data segment para public 'data' use16
    ; [70h, 7Fh] + [0Fh 80h, 0Fh 8Fh] + {E3h}
    op_str db 1 dup('jo', 'jno', 'jb', 'jae', 'je', 'jnz', 'jbe', 'ja', \
                    'js', 'jns', 'jp', 'jpo', 'jl', 'jge', 'jle', 'jg')
    op_shifts db 1 dup (0, 2, 5, 7, 10, 12, 15, 18, 20, 22, 25, 27, 30, \
                       32, 35, 38)
    op_lens db 1 dup (2, 3, 2, 3, 2, 3, 3, 2, 2, 3, 2, 3, 2, 3, 3, 2)

    jcxz_str db 'jcxz'
    jcxz_oc db 0E3h
    jcxz_len db 4

    oc_short db 70h, 7Fh
    oc_near db 80h, 8Fh
    oc_near_prefix equ 0Fh
data ends

code segment para public 'code' use16
assume cs: code, ds: data

write_cmd proc pascal
uses ax, bx, cx
    push si
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
    ret
write_cmd endp

parse_jxx proc pascal far
uses ax, cx
    movzx ax, byte ptr [si]
    cmp al, oc_near_prefix
    je short @@near
@@short:
    check_opcode oc_short
@@near:
    inc si
    movzx ax, byte ptr [si]
    check_opcode oc_near
@@jcxz:
    cmp al, jcxz_oc
    jne short @@exit
    push si
    lea si, jcxz_str
    movzx cx, jcxz_len
    call memcpy
    pop si
    inc si
    movzx ax, jcxz_len
    add di, ax
    mov byte ptr [di], 10
    inc di
@@exit:
    ret
parse_jxx endp

code ends
end
