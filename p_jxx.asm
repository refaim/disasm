; Conditional jumps disassembler
; Author: Kharitonov Roman
.model small
.386
locals

extrn byte2hex: far
extrn get_cur_byte_num: far

public parse_jxx

short_flag equ 0
near_flag equ 1

check_opcode macro jxx_type, flag, next_target
    cmp al, jxx_type[0]
    jl short next_target
    cmp al, jxx_type[1]
    jg short next_target
    sub al, jxx_type[0]
    mov dx, flag ; short/near flag
    call write_cmd
    jmp short @@operand
endm

output_char macro ch
    mov byte ptr [di], ch
    inc di  
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
    inc si ; first opcode byte
    cmp dx, near_flag
    jne short @@exit
    inc si ; second opcode byte, for near jumps
@@exit:
    ret
write_cmd endp

write_byte proc pascal
uses ax
    call byte2hex
    xchg al, ah
    mov [di], ax
    add di, 2
    ret
write_byte endp

parse_jxx proc pascal far
uses ax, cx, dx
    xor ax, ax
    mov al, [si]
    cmp al, oc_near_prefix
    je short @@near
@@short:
    check_opcode oc_short, short_flag, @@jcxz
@@near:
    mov al, [si + 1]
    check_opcode oc_near, near_flag, @@exit
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
    output_char ' '
    cmp dx, near_flag
    jne short @@op_short
@@op_near:
    mov ax, word ptr [si]
    add si, 2
    jmp short @@write_operand
@@op_short:
    movsx ax, [si]
    inc si
@@write_operand:
    call get_cur_byte_num
    add cx, ax
    mov al, ch
    call write_byte
    mov al, cl
    call write_byte
    output_char 'h'
    output_char 10
@@exit:
    ret
parse_jxx endp

code ends
end
