.model small
.386
locals

extrn byte2hex: far

public parse_jxx

short_flag equ 0
near_flag equ 1

check_opcode macro jxx_type, flag
    cmp al, jxx_type[0]
    jl short @@jcxz
    cmp al, jxx_type[1]
    jg short @@jcxz
    sub al, jxx_type[0]
    call write_cmd
    mov dx, flag ; short/near flag
    jmp short @@operand
endm

data segment para public 'data' use16
    ; [70h, 7Fh] + [0Fh 80h, 0Fh 8Fh] + {E3h}
    op_str db 1 dup('jo', 'jno', 'jb', 'jae', 'je', 'jnz', 'jbe', 'ja', \
                    'js', 'jns', 'jp', 'jpo', 'jl', 'jge', 'jle', 'jg')
    op_shifts db 0, 2, 5, 7, 10, 12, 15, 18, 20, 22, 25, 27, 30, 32, 35, 38
    op_lens db 2, 3, 2, 3, 2, 3, 3, 2, 2, 3, 2, 3, 2, 3, 3, 2

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
    cld
    rep movsb
    pop si
    inc si
    ret
write_cmd endp

write_byte proc pascal
uses ax
    mov al, byte ptr [si]
    inc si
    call byte2hex
    xchg al, ah
    mov [di], ax
    add di, 2
    ret
write_byte endp

parse_jxx proc pascal far
uses ax, cx, dx
    xor ax, ax
    mov al, byte ptr [si]
    cmp al, oc_near_prefix
    je short @@near
@@short:
    check_opcode oc_short, short_flag
@@near:
    inc si
    mov al, byte ptr [si]
    check_opcode oc_near, near_flag
@@jcxz:
    cmp al, jcxz_oc
    jne short @@exit
    push si
    lea si, jcxz_str
    movzx cx, jcxz_len
    cld
    rep movsb
    pop si
    inc si
    movzx ax, jcxz_len
@@operand:
    mov byte ptr [di], ' '
    inc di
    call write_byte
    cmp dx, near_flag
    jne short @@finalize
    call write_byte
@@finalize:
    mov byte ptr [di], 'h'
    mov byte ptr [di + 1], 10
    add di, 2
@@exit:
    ret
parse_jxx endp

code ends
end
