.model small
.386
locals

extrn byte2hex: far

public parse_addition

data segment para public 'data' use16
    sBytePtr db 'byte ptr '
    sWordPtr db 'word ptr '
    sReg8 db 1 dup ('al', 'cl', 'dl', 'bl', 'ah', 'ch', 'dh', 'bh')
    sReg16 db 1 dup ('ax', 'cx', 'dx', 'bx', 'sp', 'bp', 'si', 'di')
    sAddrReg db 1 dup('bx + si', 'bx + di', 'bp + si', 'bp + di', 'si', 'di', 'bp', 'bx')

    bAddrShift db 1 dup(0, 7, 14, 21, 28, 30, 32, 34)
    bAddrLen db 1 dup(7, 7, 7, 7, 2, 2, 2, 2)

    bDirection db ?
    bModMod db ?
    bModReg db ?
    bModRm db ?
data ends

code segment para public 'code' use16
assume cs: code, ds: data

parseModRm proc pascal
uses ax
    mov al, [si+1]

    mov bModRm, al
    and bModRm, 7h

    mov bModReg, al
    shr bModReg, 3h
    and bModReg, 7h

    mov bModMod, al
    shr bModMod, 6h
    and bModMod, 3h

    ret   
parseModRm endp

printAdd proc pascal
    mov byte ptr [di],   'a'
    mov byte ptr [di+1], 'd'
    mov byte ptr [di+2], 'd'
    mov byte ptr [di+3], ' '
    add si, 1h
    add di, 4h
    ret
printAdd endp

printAdc proc pascal
    mov byte ptr [di],   'a'
    mov byte ptr [di+1], 'd'
    mov byte ptr [di+2], 'c'
    mov byte ptr [di+3], ' '
    add si, 1h
    add di, 4h
    ret
printAdc endp

printAlImm proc pascal
uses ax
    mov al, sReg8
    mov [di], al
    mov al, [sReg8+1]
    mov [di+1], al
    mov byte ptr [di+2], ','
    mov byte ptr [di+3], ' '
    mov byte ptr[di+4], '0'
    mov al, [si]
    call byte2hex
    mov [di+5], ah
    mov [di+6], al
    mov byte ptr [di+7], 'h'
    mov byte ptr [di+8], 10
    add si, 1h
    add di, 9h
    ret
printAlImm endp

printAxImm proc pascal
uses ax, cx
    mov al, sReg16
    mov [di], al
    mov al, [sReg16+1]
    mov [di+1], al    
    mov byte ptr [di+2], ','
    mov byte ptr [di+3], ' '
    mov byte ptr [di+4], '0'
    mov al, [si+1]
    call byte2hex
    mov [di+5], ah
    mov [di+6], al
    mov al, [si]
    call byte2hex
    mov [di+7], ah
    mov [di+8], al
    mov byte ptr [di+9], 'h'
    mov byte ptr [di+0Ah], 10
    add si, 2h
    add di, 0Bh
    ret
printAxImm endp

printReg proc pascal pString:word, bRegNum:byte
uses ax, bx
    mov al, 2h
    mov bl, bRegNum
    mul bl
    mov bx, ax
    add bx, pString
    
    mov dl, [bx]
    mov [di], dl
    mov dl, [bx+1]
    mov [di+1], dl

    ret
printReg endp

printRegReg proc pascal pString:word
uses ax
    test bDirection, -1
    jz short @@print
    mov al, bModReg
    mov ah, bModRm
    mov bModReg, ah
    mov bModRm, al

@@print:
    push pString
    push word ptr bModRm
    call printReg

    mov byte ptr [di+2], ','
    mov byte ptr [di+3], ' '
    add di, 4h

    push pString
    push word ptr bModReg
    call printReg

    mov byte ptr [di+2], 0Ah
    add di, 3h
    add si, 1h
        
    ret
printRegReg endp

printReg8Reg8 proc pascal
    push offset sReg8
    call printRegReg
    ret
printReg8Reg8 endp

printReg16Reg16 proc pascal
    push offset sReg16
    call printRegReg
    ret
printReg16Reg16 endp

printReg8Imm proc pascal
uses ax
    push offset sReg8
    push word ptr bModRm
    call printReg

    mov byte ptr [di+2], ','
    mov byte ptr [di+3], ' '
    mov byte ptr [di+4], '0'

    mov al, [si+1]
    call byte2hex
    mov [di+5], ah
    mov [di+6], al

    mov byte ptr [di+7], 'h'
    mov byte ptr [di+8], 0Ah

    add si, 2h
    add di, 9h
    ret
printReg8Imm endp

printReg16Imm proc pascal
uses ax
    push offset sReg16
    push word ptr bModRm
    call printReg

    mov byte ptr [di+2], ','
    mov byte ptr [di+3], ' '
    
    test bDirection, -1h
    jz short @@imm_is_word

    mov byte ptr [di+4], '+'
    mov byte ptr [di+5], '0'

    mov al, [si+1]
    call byte2hex
    mov [di+6], ah
    mov [di+7], al

    mov byte ptr [di+8], 'h'
    mov byte ptr [di+9], 0Ah

    add si, 2h
    add di, 0Ah

    jmp short @@end

@@imm_is_word:
    mov byte ptr [di+4], '0'
    mov al, [si+2]
    call byte2hex
    mov [di+5], ah
    mov [di+6], al
    
    mov al, [si+1]
    call byte2hex
    mov [di+7], ah
    mov [di+8], al

    mov byte ptr [di+9], 'h'
    mov byte ptr [di+0Ah], 0Ah

    add si, 3h
    add di, 0Bh

@@end:
    ret
printReg16Imm endp

; bPrintType = 0; don't print type
; bPrintType = 1; print 'byte ptr'
; bPrintTYpe = 2; print 'word ptr'
printAddress proc pascal far bPrintType:word
uses ax, cx, dx
    cmp bPrintType, 0h
    je short @@print_address
    cmp bPrintType, 1h
    jne short @@print_word_ptr_prefix
    push si
    lea si, sBytePtr
    mov cx, 9h
    rep movsb
    pop si
    jmp short @@print_address

@@print_word_ptr_prefix:
    push si
    lea si, sWordPtr
    mov cx, 9h
    rep movsb
    pop si

@@print_address:
    mov byte ptr [di], '['

    cmp bModRm, 6h
    jne short @@address_with_registers
    cmp bModMod, 0h
    jne short @@address_with_registers
    mov al, [si+2]
    mov byte ptr [di+1], '0'
    call byte2hex
    mov [di+2], ah
    mov [di+3], al
    mov al, [si+1]
    call byte2hex
    mov [di+4], ah
    mov [di+5], al
    mov byte ptr [di+6], 'h'
    mov byte ptr [di+7], ']'
    add si, 3h
    add di, 8h
    jmp @@end

@@address_with_registers:
    add di, 1h
    push si
    movzx si, bModRm
    movzx cx, [si+bAddrLen]
    mov dx, cx
    movzx si, [si+bAddrShift]
    lea si, [si+sAddrReg]
    rep movsb
    pop si

    cmp bModMod, 0h
    jne short @@shift_is_byte
    mov byte ptr [di], ']'
    add si, 1h
    add di, 1h
    jmp short @@end
    
@@shift_is_byte:
    cmp bModMod, 1h
    jne short @@shift_is_word
    mov al, [si+1]
    call byte2hex
    mov byte ptr [di], ' '
    mov byte ptr [di+1], '+'
    mov byte ptr [di+2], ' '
    mov byte ptr [di+3], '0'
    mov [di+4], ah
    mov [di+5], al
    mov byte ptr [di+6], 'h'
    mov byte ptr [di+7], ']'
    add si, 2h
    add di, 8h
    jmp short @@end

@@shift_is_word:
    mov al, [si+2]
    call byte2hex
    mov byte ptr [di], ' '
    mov byte ptr [di+1], '+'
    mov byte ptr [di+2], ' '
    mov byte ptr [di+3], '0'
    mov [di+4], ah
    mov [di+5], al
    mov al, [si+1]
    call byte2hex
    mov [di+6], ah
    mov [di+7], al
    mov byte ptr [di+8], 'h'
    mov byte ptr [di+9], ']'
    add si, 3h
    add di, 0Ah

@@end:
    ret
printAddress endp

printAddrImm8 proc pascal
uses ax
    push word ptr 1h
    call printAddress
    mov byte ptr [di], ','
    mov byte ptr [di+1], ' '
    mov al, [si]
    mov byte ptr [di+2], '0'
    call byte2hex
    mov [di+3], ah
    mov [di+4], al
    mov byte ptr [di+5], 'h'
    mov byte ptr [di+6], 0Ah
    add si, 1h
    add di, 7h
    ret
printAddrImm8 endp

printAddrImm16 proc pascal
uses ax
    push word ptr 2h
    call printAddress
    mov byte ptr [di], ','
    mov byte ptr [di+1], ' '
    
    cmp bDirection, 0h
    jne short @@imm_is_byte
    mov al, [si+1]
    mov byte ptr [di+2], '0'
    call byte2hex
    mov [di+3], ah
    mov [di+4], al
    mov al, [si]
    call byte2hex
    mov [di+5], ah
    mov [di+6], al
    mov byte ptr [di+7], 'h'
    mov byte ptr [di+8], 0Ah
    add si, 2h
    add di, 9h
    jmp short @@end

@@imm_is_byte:
    mov byte ptr [di+2], '+'
    mov byte ptr [di+3], '0'
    mov al, [si]
    call byte2hex
    mov [di+4], ah
    mov [di+5], al
    mov byte ptr [di+6], 'h'
    mov byte ptr [di+7], 0Ah
    add si, 1h
    add di, 8h

@@end:
    ret
printAddrImm16 endp

printRegAddr proc pascal sReg:word
uses ax
    test bDirection, -1h
    jz short @@reverse_order
    push sReg
    push word ptr bModReg
    call printReg
    mov byte ptr [di+2], ','
    mov byte ptr [di+3], ' '
    add di, 4h
    push word ptr 0h
    call printAddress
    mov byte ptr [di], 0Ah
    add di, 1h
    jmp short @@end

@@reverse_order:
    push word ptr 0h
    call printAddress
    mov byte ptr [di], ','
    mov byte ptr [di+1], ' '
    add di, 2h
    push sReg
    push word ptr bModReg
    call printReg
    mov byte ptr [di+2], 0Ah
    add di, 3h

@@end:
    ret
printRegAddr endp

printReg8Addr proc pascal
    push offset sReg8
    call printRegAddr
    ret
printReg8Addr endp

printReg16Addr proc pascal
    push offset sReg16
    call printRegAddr
    ret
printReg16Addr endp

parse_addition proc pascal far
uses ax, cx, dx, bx
    mov al, [si]
    mov bDirection, al
    and bDirection, 2h
    sub al, bDirection

    call parseModRm
    
    cmp al, 4h
    jne short @@add_ax_imm
    test bDirection, -1h
    jnz short @@add_ax_imm
    call printAdd
    call printAlImm
    jmp @@exit

@@add_ax_imm:
    cmp al, 5h
    jne short @@add_reg8_reg8
    test bDirection, -1h
    jnz short @@add_reg8_reg8
    call printAdd
    call printAxImm
    jmp @@exit

@@add_reg8_reg8:
    cmp al, 0h
    jne short @@add_reg16_reg16
    cmp bModMod, 3h
    jne short @@add_reg16_reg16
    call printAdd
    call printReg8Reg8
    jmp @@exit

@@add_reg16_reg16:
    cmp al, 1h
    jne short @@add_reg8_imm
    cmp bModMod, 3h
    jne short @@add_reg8_imm
    call printAdd
    call printReg16Reg16
    jmp @@exit

@@add_reg8_imm:
    cmp al, 80h
    jne short @@add_reg16_imm
    cmp bModMod, 3h
    jne short @@add_reg16_imm
    cmp bModReg, 0h
    jne short @@add_reg16_imm
    call printAdd
    call printReg8Imm
    jmp @@exit
@@add_reg16_imm:
    cmp al, 81h
    jne short @@add_addr_imm8
    cmp bModMod, 3h
    jne short @@add_addr_imm8
    cmp bModReg, 0h
    jne short @@add_addr_imm8
    call printAdd
    call printReg16Imm
    jmp @@exit

@@add_addr_imm8:
    cmp al, 80h
    jne short @@add_addr_imm16
    cmp bModReg, 0h
    jne short @@add_addr_imm16
    call printAdd
    call printAddrImm8
    jmp @@exit

@@add_addr_imm16:
    cmp al, 81h
    jne short @@add_reg8_addr
    cmp bModReg, 0h
    jne short @@add_reg8_addr
    call printAdd
    call printAddrImm16
    jmp @@exit

@@add_reg8_addr:
    cmp al, 0h
    jne short @@add_reg16_addr
    call printAdd
    call printReg8Addr
    jmp @@exit

@@add_reg16_addr:
    cmp al, 1h
    jne short @@adc_al_imm
    cmp bModMod, 3h
    je short @@adc_al_imm
    call printAdd
    call printReg16Addr
    jmp @@exit

@@adc_al_imm:
    cmp al, 14h
    jne short @@adc_ax_imm
    test bDirection, -1h
    jnz short @@adc_ax_imm
    call printAdc
    call printAlImm
    jmp @@exit

@@adc_ax_imm:
    cmp ax, 15h
    jne short @@adc_reg8_reg8
    test bDirection, -1h
    jnz short @@adc_reg8_reg8
    call printAdc
    call printAxImm
    jmp @@exit

@@adc_reg8_reg8:
    cmp al, 10h
    jne short @@adc_reg16_reg16
    cmp bModMod, 3h
    jne short @@adc_reg16_reg16
    call printAdc
    call printReg8Reg8
    jmp @@exit

@@adc_reg16_reg16:
    cmp al, 11h
    jne short @@adc_reg8_imm
    cmp bModMod, 3h
    jne short @@adc_reg8_imm
    call printAdc
    call printReg16Reg16
    jmp short @@exit

@@adc_reg8_imm:
    cmp al, 80h
    jne short @@adc_reg16_imm
    cmp bModMod, 3h
    jne short @@adc_reg16_imm
    cmp bModReg, 2h
    jne short @@adc_reg16_imm
    call printAdc
    call printReg8Imm
    jmp short @@exit

@@adc_reg16_imm:
    cmp al, 81h
    jne short @@adc_addr_imm8
    cmp bModMod, 3h
    jne short @@adc_addr_imm8
    cmp bModReg, 2h
    jne short @@adc_addr_imm8
    call printAdc
    call printReg16Imm
    jmp short @@exit

@@adc_addr_imm8:
    cmp al, 80h
    jne short @@adc_addr_imm16
    cmp bModReg, 2h
    jne short @@adc_addr_imm16
    call printAdc
    call printAddrImm8
    jmp short @@exit

@@adc_addr_imm16:
    cmp al, 81h
    jne short @@adc_reg8_addr
    cmp bModReg, 2h
    jne short @@adc_reg8_addr
    call printAdc
    call printAddrImm16
    jmp short @@exit

@@adc_reg8_addr:
    cmp al, 10h
    jne short @@adc_reg16_addr
    call printAdc
    call printReg8Addr
    jmp short @@exit

@@adc_reg16_addr:
    cmp al, 11h
    jne short @@exit
    cmp bModMod, 3h
    je short @@exit
    call printAdc
    call printReg16Addr

@@exit:
    ret
parse_addition endp

code ends
end
