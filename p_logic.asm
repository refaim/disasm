; ������������ ���������� ������ (AND, OR, XOR, TEST, NOT).
; �����: �. ������� (236 ������)

.model small
.386
locals

extrn byte2hex: far

public parse_logic

data segment para public 'data' use16

    cmd8_n      equ 22
    cmd8_opcode db  24h, 25h, 20h, 21h, 22h, 23h    ;AND
            db  0Ch, 0Dh, 08h, 09h, 0Ah, 0Bh    ;OR
            db  34h, 35h, 30h, 31h, 32h, 33h    ;XOR
            db  0A8h, 0A9h, 84h, 85h        ;TEST
    cmd8_name_offset dw offset str_and, offset str_and, offset str_and, offset str_and, offset str_and, offset str_and
             dw offset str_or,  offset str_or,  offset str_or,  offset str_or,  offset str_or,  offset str_or
             dw offset str_xor, offset str_xor, offset str_xor, offset str_xor, offset str_xor, offset str_xor
             dw offset str_test, offset str_test, offset str_test, offset str_test
    cmd8_call_offset dw offset al_imm8, offset ax_imm16, offset rm8_r8, offset rm16_r16, offset r8_rm8, offset r16_rm16
             dw offset al_imm8, offset ax_imm16, offset rm8_r8, offset rm16_r16, offset r8_rm8, offset r16_rm16
             dw offset al_imm8, offset ax_imm16, offset rm8_r8, offset rm16_r16, offset r8_rm8, offset r16_rm16
             dw offset al_imm8, offset ax_imm16, offset rm8_r8, offset rm16_r16

    cmd11_n     equ     13
    cmd11_opcode    dw  0480h, 0481h, 0483h     ;AND
            dw  0180h, 0181h, 0183h     ;OR
            dw  0680h, 0681h, 0683h     ;XOR
            dw  00F6h, 00F7h            ;TEST
            dw  02F6h, 02F7h            ;NOT
    cmd11_name_offset dw    offset str_and, offset str_and, offset str_and
             dw offset str_or,  offset str_or,  offset str_or
             dw offset str_xor, offset str_xor, offset str_xor
             dw offset str_test, offset str_test
             dw offset str_not, offset str_not
    cmd11_call_offset dw    offset rm8_imm8, offset rm16_imm16, offset rm16_imm8
             dw offset rm8_imm8, offset rm16_imm16, offset rm16_imm8
             dw offset rm8_imm8, offset rm16_imm16, offset rm16_imm8
             dw offset rm8_imm8, offset rm16_imm16
             dw offset rm8, offset rm16

    reg8_name_offset dw offset str_al, offset str_cl, offset str_dl, offset str_bl
             dw offset str_ah, offset str_ch, offset str_dh, offset str_bh
    reg16_name_offset dw    offset str_ax, offset str_cx, offset str_dx, offset str_bx
              dw    offset str_sp, offset str_bp, offset str_si, offset str_di

    base_index_name_offset dw offset str_bx_si_, offset str_bx_di_, offset str_bp_si_, offset str_bp_di_
                   dw offset str_si_, offset str_di_, offset str_bp_, offset str_bx_

    str_and     db  "and $"
    str_or      db  "or $"
    str_xor     db  "xor $"
    str_test    db  "test $"
    str_not     db  "not $"
    str_al      db  "al$"
    str_cl      db  "cl$"
    str_dl      db  "dl$"
    str_bl      db  "bl$"
    str_ah      db  "ah$"
    str_ch      db  "ch$"
    str_dh      db  "dh$"
    str_bh      db  "bh$"
    str_ax      db  "ax$"
    str_cx      db  "cx$"
    str_dx      db  "dx$"
    str_bx      db  "bx$"
    str_sp      db  "sp$"
    str_bp      db  "bp$"
    str_si      db  "si$"
    str_di      db  "di$"
    str_byte_ptr    db  "byte ptr $"
    str_word_ptr    db  "word ptr $"
    str_bx_si_  db  "[bx + si]$"
    str_bx_di_  db  "[bx + di]$"
    str_bp_si_  db  "[bp + si]$"
    str_bp_di_  db  "[bp + di]$"
    str_si_     db  "[si]$"
    str_di_     db  "[di]$"
    str_bp_     db  "[bp]$"
    str_bx_     db  "[bx]$"

data ends

code segment para public 'code' use16
assume cs: code

parse_logic proc pascal far
uses ax, bx, cx, dx

    mov al,[si] ; � �������� AL ������ ���� ���.
    inc si

    ; �������� �� ������ 8-��������� ���...
    lea bx,cmd8_opcode
    xor cx,cx   ; � �������� CX ���������� ����� 8-���������� ���.
@@cmd8_loop:
    cmp [bx],al
    je  short @@cmd8_work
    inc bx
    inc cx
    cmp cx,cmd8_n
    jne @@cmd8_loop

    ; ������ ����� mod r/m � ���������� ���� reg/���...
    mov ah,[si] ; � �������� AH �������� ����� mod r/m.
    push    ax
    call    extract_reg_field
    mov dl,al   ; � �������� DL �������� ���� reg/���.
    pop ax

    ; �������� �� ������ 11-��������� ���...
    lea bx,cmd11_opcode
    xor cx,cx   ; � �������� CX ���������� ����� 11-���������� ���.
@@cmd11_loop:
    cmp [bx],al
    jne short @@cmd11_next
    cmp [bx+1],dl
    je  short @@cmd11_work
@@cmd11_next:
    add bx,2
    inc cx
    cmp cx,cmd11_n
    jne @@cmd11_loop

    ; ������� � ����� ��� �� �������.
    dec si
    jmp short @@exit

@@cmd8_work:
    ; ��������� ������� � 8-��������� ���...
    ; � �������� CX ���������� ����� 8-���������� ���.
    imul    cx,2
    lea bx,cmd8_name_offset
    add bx,cx
    mov dx,[bx] ; � �������� DX �������� ������ (�������� �������).
    call    output_str
    lea bx,cmd8_call_offset
    add bx,cx
    ; ����� ���������� ���� ���������, ����� AH, SI � DI, ������ �� �����.
    call    [bx]    ; ����� ��������� ��������� ���������.
    call    output_lf
    jmp short @@exit

@@cmd11_work:
    ; ��������� ������� � 11-��������� ���...
    ; � �������� CX ���������� ����� 11-���������� ���.
    ; � �������� AH �������� ����� mod r/m.
    ; SI ��������� �� �������� ����� mod r/m.
    inc si
    imul    cx,2
    lea bx,cmd11_name_offset
    add bx,cx
    mov dx,[bx] ; � �������� DX �������� ������ (�������� �������).
    call    output_str
    lea bx,cmd11_call_offset
    add bx,cx
    ; ����� ���������� ���� ���������, ����� AH, SI � DI, ������ �� �����.
    call    [bx]    ; ����� ��������� ��������� ���������.
    call    output_lf   

@@exit:
    ret
parse_logic endp

al_imm8 proc pascal
uses ax
    mov al,0
    call    output_reg8
    call    output_comma
    call    imm8
    ret
al_imm8 endp

ax_imm16 proc pascal
uses ax
    mov al,0
    call    output_reg16
    call    output_comma
    call    imm16
    ret               
ax_imm16 endp

rm8_r8 proc pascal
    mov ah,[si] ; � �������� AH �������� ����� mod r/m.
    inc si
    call    rm8
    call    output_comma
    call    r8
    ret
rm8_r8 endp

rm16_r16 proc pascal
    mov ah,[si] ; � �������� AH �������� ����� mod r/m.
    inc si
    call    rm16
    call    output_comma
    call    r16
    ret       
rm16_r16 endp

r8_rm8 proc pascal
    mov ah,[si] ; � �������� AH �������� ����� mod r/m.
    inc si
    call    r8
    call    output_comma
    call    rm8
    ret
r8_rm8 endp

r16_rm16 proc pascal
    mov ah,[si] ; � �������� AH �������� ����� mod r/m.
    inc si
    call    r16
    call    output_comma
    call    rm16
    ret       
r16_rm16 endp 

rm8_imm8 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
    call    rm8
    call    output_comma
    call    imm8
    ret
rm8_imm8 endp

rm16_imm16 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
    call    rm16
    call    output_comma
    call    imm16
    ret
rm16_imm16 endp

rm16_imm8 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
    call    rm16
    call    output_comma
    call    imm8
    ret
rm16_imm8 endp

rm8 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
uses ax, cx, dx
    call    extract_mod_field   ; � �������� CH �������� ���� mod.
    call    extract_rm_field    ; � �������� AL �������� ���� r/m.
    cmp ch,11b
    jne short @@lbl1
    call    output_reg8
    jmp short @@exit
@@lbl1:
    ; mod != 11
    lea dx,str_byte_ptr 
    call    output_str  ; ����� ������ "BYTE PTR ".
    call    mem
@@exit:
    ret
rm8 endp

rm16 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
uses ax, cx, dx
    call    extract_mod_field   ; � �������� CH �������� ���� mod.
    call    extract_rm_field    ; � �������� AL �������� ���� r/m.
    cmp ch,11b
    jne short @@lbl1
    call    output_reg16
    jmp short @@exit
@@lbl1:
    ; mod != 11
    lea dx,str_word_ptr 
    call    output_str  ; ����� ������ "WORD PTR ".
    call    mem
@@exit:
    ret
rm16 endp

mem proc pascal
; ����� �������� � ������ (mod != 11).
; ����. ������� CH -- �������� ���� mod.
;       ������� AL -- �������� ���� r/m.
; ��������� �� �������� �������� ���������.
    cmp ch,00b
    jne short @@lbl2
    ; mod == 00
    cmp al,110b
    jne short @@lbl3
    ; mod == 00 && r/m == 110
    call    disp16
    jmp short @@exit
@@lbl3:
    ; mod == 00 && r/m != 110
    call    output_base_index
    jmp short @@exit  
@@lbl2:
    ; mod != 00 && mod != 11
    call    output_base_index   ; ����� [...].
    cmp ch,01b
    jne short @@lbl4
    ; mod == 01
    call    output_plus
    call    disp8
    jmp short @@exit
@@lbl4:
    ; mod == 10
    call    output_plus
    call    disp16
@@exit:
    ret
mem endp

r8 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
    call    extract_reg_field
    call    output_reg8 
    ret
r8 endp

r16 proc pascal
; ����. ������� AH -- �������� ����� mod r/m.
    call    extract_reg_field
    call    output_reg16
    ret                
r16 endp

imm8 proc pascal
uses ax
    mov al,[si] ; � �������� AL ���� ����������������� ��������.
    inc si
    call    output_zero
    call    output_byte
    call    output_h
    ret
imm8 endp

imm16 proc pascal
uses ax, cx
    mov cl,[si] ; � �������� CL ������ ���� ����������������� ��������.
    inc si
    mov al,[si] ; � �������� AL ������ ���� ����������������� ��������.
    inc si
    call    output_zero
    call    output_byte
    mov al,cl   ; � �������� AL ������ ���� ����������������� ��������.
    call    output_byte
    call    output_h
    ret
imm16 endp

disp8 proc pascal
    call    imm8
    ret
disp8 endp

disp16 proc pascal
    call    imm16
    ret
disp16 endp

extract_reg_field proc pascal
; ��������� ���� reg/��� �� ����� mod r/m.
; ����. ������� AH -- �������� ����� mod r/m.
; �����. ������� AL -- �������� ���� reg/���.
; ������ �������� �� ������������.
    mov al,ah
    and al,00111000b
    shr al,3
    ret
extract_reg_field endp

extract_rm_field proc pascal
; ��������� ���� r/m �� ����� mod r/m.
; ����. ������� AH -- �������� ����� mod r/m.
; �����. ������� AL -- �������� ���� r/m.
; ������ �������� �� ������������.
    mov al,ah
    and al,00000111b
    ret
extract_rm_field endp

extract_mod_field proc pascal
; ��������� ���� mod �� ����� mod r/m.
; ����. ������� AH -- �������� ����� mod r/m.
; �����. ������� CH -- �������� ���� mod.
; ������ �������� �� ������������.
    mov ch,ah
    and ch,11000000b
    shr ch,6
    ret
extract_mod_field endp

output_base_index proc pascal
; ����� [...].
; ����. ������� AL -- �������� ���� r/m.
uses bx, cx, dx
    mov cl,al
    xor ch,ch
    imul    cx,2
    lea bx,base_index_name_offset
    add bx,cx
    mov dx,[bx]
    call    output_str
    ret
output_base_index endp

output_reg8 proc pascal
; ����� �������� 8-���������� ��������.
; ����. ������� AL -- ��� ��������.
uses bx, cx, dx
    mov cl,al
    xor ch,ch
    imul    cx,2
    lea bx,reg8_name_offset
    add bx,cx
    mov dx,[bx]
    call    output_str  
    ret
output_reg8 endp

output_reg16 proc pascal
; ����� �������� 16-���������� ��������.
; ����. ������� AL -- ��� ��������.
uses bx, cx, dx
    mov cl,al
    xor ch,ch
    imul    cx,2
    lea bx,reg16_name_offset
    add bx,cx
    mov dx,[bx]
    call    output_str  
    ret
output_reg16 endp

output_byte proc pascal
; ����� �����.
; ����. ������� AL -- �������� �����.
uses ax
    call    byte2hex
    xchg    al,ah
    mov [di],ax
    add di,2
    ret
output_byte endp

output_char macro ch
    mov byte ptr [di],ch
    inc di  
endm

output_str proc pascal
; ����� ������ � �������� �����.
; ����: �������� ������� ����� ������ � �������� DX.
uses ax, bx
    mov bx,dx
@@loop:
    mov al,[bx]
    cmp al,'$'
    je short @@exit
    output_char al
    inc bx
    jmp @@loop
@@exit:
    ret
output_str endp

output_lf proc pascal
        output_char 10
    ret
output_lf endp

output_comma proc pascal
        output_char ','
    output_char ' '
    ret
output_comma endp

output_zero proc pascal
        output_char '0'
    ret
output_zero endp

output_h proc pascal
        output_char 'h'
    ret
output_h endp

output_plus proc pascal
    output_char ' '
        output_char '+'
    output_char ' '
    ret
output_plus endp

code ends
end
