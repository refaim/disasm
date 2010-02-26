; div and idiv disassembler
; Author: Pinchuk Oleg

.model small
.386
locals

extrn byte2hex:far

public parse_div
public parse_idiv

data segment para public'data' use16
    ; your data
    div_msg db'div '
    idiv_msg db'idiv '
    byte_msg db'byte '
    word_msg db'word '
    ptr_msg db'ptr '
    ls_msg db'['
    rs_msg db']'

    adr0_msg db'0'
    adrh_msg db'h'

    regs db 1 dup(  'al','cl','dl','bl','ah','ch','dh','bh',\
                    'ax','cx','dx','bx','sp','bp','si','di',\
                    '[bx + si]','[bx + di]','[bp + si]','[bp + di]',\
                    '[si]','[di]','[bx]',\
                    '[bx][si]','[bx][di]', '[bp][si]','[bp][di]',\
                    '[si]','[di]','[bp]', '[bx]',\
                    '[bx + si + ','[bx + di + ','[bp + si + ', '[bp + di + ', \
                    '[di + ','[si + ','[bp + ','[bx + ' )

    endr db 10
     ends

code segment para public'code' use16
assume cs: code


WriteBytePref proc pascal far
uses cx, si

    cmp al, 0h
        jne short @@hexbit
        lea si, byte_msg
        jmp short @@write
    @@hexbit:
    cmp al, 1h
        lea si, word_msg
        jmp short @@write
    @@write:
    mov cx, 5h
    rep movsb

    lea si, ptr_msg
    mov cx, 4h
    rep movsb

    ret
WriteBytePref endp

WriteKosfExp proc pascal far
uses si
    call  WriteBytePref
    lea si, regs[bx]
    rep movsb
    ret
WriteKosfExp endp

WriteAdr proc pascal far
uses ax

    push si
    lea si, adr0_msg
    mov cx, 1h
    rep movsb
    pop si

    push bx
    cmp bh, 2h
    jne short @@cic
    add si, 1


    @@cic:
    cmp bh, 0h
    je short @@exit
    mov al, [si]
    call byte2hex
    xchg al, ah
    mov [di], ax
    add di, 2
    dec si
    dec bh
    jmp short @@cic


@@exit:

    pop bx
    cmp bh, 2h
    jne short @@l2
    add si, 3
    jmp short @@cic2
    @@l2:
    add si, 2

    @@cic2:
    push si
    lea si, adrh_msg
    mov cx, 1h
    rep movsb
    pop si
ret
WriteAdr endp

WriteScAdr proc pascal far
    call  WriteKosfExp

    push si
    lea si, ls_msg
    mov cx, 1h
    rep movsb
    pop si

    mov bh, 1
    call  WriteAdr

    push si
    lea si, rs_msg
    mov cx, 1h
    rep movsb
    pop si


ret
WriteScAdr endp

WriteDivOperand proc pascal far
    ;если регистры
    cmp ah, 0h
    jne short @@adr_mem
        push si
        lea si, regs[bx]
        mov cx, 2h
        rep movsb
        pop si
        jmp short @@end

    @@adr_mem:
    cmp ah, 1h
    jne short @@short_adr_mem
        mov cx, 9h
        jmp short @@write_adr_mem

    @@short_adr_mem:
    cmp ah, 2h
    jne short @@wVar
        mov cx, 4h
        @@write_adr_mem:
        call  WriteKosfExp
        jmp short @@end

    @@wVar:
    cmp ah, 3h
    jne short @@mLongAdrEx

        mov bh, 2h
        call  WriteAdr
        jmp short @@end
    @@mLongAdrEx:
    cmp ah, 4h
        jne  short @@WWWW
        mov cx, 8h
        jmp  short @@WriteLongAdrw
    @@WWWW:
    cmp ah, 5h
        jne  short @@hzcho
        mov cx, 4h
        @@WriteLongAdrw:
        call WriteScAdr
        jmp short @@end

    @@hzcho: ;  b1[bx + si  + 0]
    cmp ah, 6h
        jne  short @@minihachto
        mov cx, 0Bh
        call  WriteKosfExp

        mov bh, 2
        call  WriteAdr

        push si
        lea si, rs_msg
        mov cx, 1h
        rep movsb
        pop si
        jmp short @@end

    @@minihachto:
    cmp ah, 7h
        ;jne  short @@hzcho
        mov cx, 06h
        call  WriteKosfExp

        mov bh, 2
        call  WriteAdr

        push si
        lea si, rs_msg
        mov cx, 1h
        rep movsb
        pop si
        jmp short @@end
@@end:
    ret
WriteDivOperand endp

parse_div proc pascal far
uses ax, bx, cx, dx
    ; your code
    ;храним какая память
    ; храним ккой регистр

    cmp byte ptr [si], 0F6h ; if(si==f7)
        je short @@bit8
    cmp byte ptr [si], 0F7h
        je short @@bit16

    jmp @@exit
    @@bit8:
        mov al, 0
        jmp short @@operand
    @@bit16:
        mov al, 1
        jmp short @@operand


    @@operand:

        inc si
        mov bx, 0h

        cmp al, 1h
            jne short @@regs
            mov bx, 8h*2h   ;если 16 бит, тосмещаем всё ето чудо на 8*2 байт (для строк 8 битных регистров)

        @@regs:
        ;если регистр
            mov ah, 0

            cmp byte ptr [si], 0F0h ;al ax
                jne short @@reg_1
                add bx, 0h
                jmp short @@endReg
            @@reg_1:
            cmp byte ptr [si], 0F1h ;cl cx
                jne short @@reg_2
                add bx, 1h*2
                jmp short @@endReg
            @@reg_2:
            cmp byte ptr [si], 0F2h ;dl dx
                jne short @@reg_3
                add bx, 2h*2
                jmp short @@endReg
            @@reg_3:
            cmp byte ptr [si], 0F3h ;bl bx
                jne short @@reg_4
                add bx, 3h*2
                jmp short @@endReg
            @@reg_4:
            cmp byte ptr [si], 0F4h ;ah sp
                jne short @@reg_5
                add bx, 4h*2
                jmp short @@endReg
            @@reg_5:
            cmp byte ptr [si], 0F5h ;ch bp
                jne short @@reg_6
                add bx, 5h*2
                jmp short @@endReg
            @@reg_6:
            cmp byte ptr [si], 0F6h ;dh si
                jne short @@reg_7
                add bx, 6h*2
                jmp short @@endReg
            @@reg_7:
            cmp byte ptr [si], 0F7h ;bh di
                jne short @@mem
                add bx, 7h*2
                jmp short @@endReg
            @@endReg:
                jmp @@write
        @@mem:

            mov bx, 10h*2h ;переносим начало после тупо регистров
            mov ah, 1h ;cl == 1 зна косв выраж, причем блинные
            cmp byte ptr [si], 030h ;[bx + si]
                jne short @@mBxDi
                add bx, 0h*9
                jmp @@write
            @@mBxDi:
            cmp byte ptr [si], 031h ;[bx +  di]
                jne short @@mBpSi
                add bx, 1h*9
                jmp @@write
            @@mBpSi:
            cmp byte ptr [si], 032h ;[bp +  si]
                jne short @@mBpDi
                add bx, 2h*9
                jmp  @@write
            @@mBpDi:
            cmp byte ptr [si], 033h ;[bp +  di]
                jne short @@mSi
                add bx, 3h*9
                jmp @@write
            @@mSi:
            add bx, 4h*9h ;если ето не длинные байды, то снова перемещаемначало что бы удобнеесчитать было
            mov ah, 2h
            cmp byte ptr [si], 034h ;[si]
                jne short @@mDi
                add bx, 0h*4
                jmp @@write
            @@mDi:
            cmp byte ptr [si], 035h ;[di]
                jne short @@mBx
                add bx, 1h*4
                jmp @@write
            @@mBx:
            cmp byte ptr [si], 037h ;[bx]
                jne short @@var
                add bx, 2h*4
                jmp @@write

            @@var:
            mov ah, 3h ;3  - переменная
            cmp byte ptr [si], 036h ; Var
                je @@write
                jne short @@mBxSi

            @@mBxSi:
            mov ah, 4h ;4 - хзчто за хрень 2 регистра а потом адрес
            add bx, 3h*4h ;ещё раз передвинули, чёт мнекажеться могет 2 бат и нехватить

            cmp byte ptr [si], 070h ;[bx][si]
                jne short @@mmBxDi
                add bx, 0h*8h
                jmp @@write
            @@mmBxDi:
            cmp byte ptr [si], 071h ;[bx][di]
                jne short @@mmBpSi
                add bx, 1h*8h
                jmp @@write
            @@mmBpSi:
            cmp byte ptr [si], 072h ;[bp][si]
                jne short @@mmBpDi
                add bx, 2h*8h
                jmp @@write
            @@mmBpDi:
            cmp byte ptr [si], 073h ;[bp][di]
                jne short @@mmSi
                add bx, 3h*8h
                jmp @@write

            @@mmSi:
            mov ah, 5h ;4 - хзчто за хрень 2 регистра а потом адрес
            add bx, 4h*8h ;ещё раз передвинули, чёт мнекажеться могет 2 бат и нехватить

            cmp byte ptr [si], 074h ;[si ]  []
                jne short @@mmDi
                add bx, 0h*4
                jmp short @@write
            @@mmDi:
            cmp byte ptr [si], 075h ;[di ]  []
                jne short @@mBp
                add bx, 1h*4
                jmp short @@write

            @@mBp:
            cmp byte ptr [si], 076h ;[bp ]  []
                jne short @@mmBx
                add bx, 2h*4
                jmp short  @@write
            @@mmBx:
            cmp byte ptr [si], 077h ;[bx ]  []
                jne short @@SumRegsAdr
                add bx, 3h*4
                jmp short  @@write

        @@SumRegsAdr:
            mov ah, 6h ;6 - выражения вида:[ bx + si    + адрес]
            add bx, 4h*4h
            @@mSumBxSi:
            cmp byte ptr [si], 0B0h ;[bx + si + adr ]   []
                jne short @@mSumBxDi
                add bx, 0h*0Bh
                jmp short  @@write
            @@mSumBxDi:
            cmp byte ptr [si], 0B1h ;[bx + di + adr ]   []
                jne short @@mSumBpSi
                add bx, 1h*0Bh
                jmp short  @@write
            @@mSumBpSi:
            cmp byte ptr [si], 0B2h ;[bp + si + adr ]   []
                jne short @@mSumBpDi
                add bx, 2h*0Bh
                jmp short  @@write
            @@mSumBpDi:
            cmp byte ptr [si], 0B3h ;[bp + di + adr ]   []
                jne short @@RegAndVar
                add bx, 3h*0Bh
                jmp short  @@write
        @@RegAndVar:
            mov ah, 7h ;6 - выражения вида:b1[si]
            add bx, 4h*0Bh
            @@mRegSi:
            cmp byte ptr [si], 0B4h ;[si]
                jne short @@mRegDi
                add bx, 0h*6
                jmp short  @@write
            @@mRegDi:
            cmp byte ptr [si], 0B5h ;[di]
                jne short @@mRegBp
                add bx, 1h*6
                jmp short  @@write
            @@mRegBp:
            cmp byte ptr [si], 0B6h ;[bp]
                jne short @@mRegBx
                add bx, 2h*6
                jmp short  @@write
            @@mRegBx:
            cmp byte ptr [si], 0B7h ;[bx]
                jne short @@unknow
                add bx, 3h*6
                jmp short  @@write

    @@unknow:
        dec si
        jmp short @@exit

    @@write:
    ;вывод div
    push cx
    push si
    lea si, div_msg
    mov cx, 4h
    rep movsb
    pop si
    pop cx

    inc si
    ;выводим операнд

    call WriteDivOperand

    ;вывод \n
    @@endwrite:
    push si
    lea si, endr
    mov cx, 1h
    rep movsb
    pop si

    jmp short @@exit

    @@exit:
    ret
parse_div endp

parse_idiv proc pascal far
uses ax, bx, cx
    ; your code
    ;храним какая память
    ; храним ккой регистр

    cmp byte ptr [si], 0F6h ; if(si==f7)
        je short @@bit8
    cmp byte ptr [si], 0F7h
        je short @@bit16

    jmp  @@exit
    @@bit8:
        mov al, 0
        jmp short @@operand
    @@bit16:
        mov al, 1
        jmp short @@operand

    @@operand:

        inc si
        mov bx, 0h

        cmp al, 1h
            jne short @@regs
            mov bx, 8h*2h   ;если 16 бит, тосмещаем всё ето чудо на 8*2 байт (для строк 8 битных регистров)

        @@regs:
        ;если регистр
            mov ah, 0

            cmp byte ptr [si], 0F8h ;al ax
                jne short @@reg_1
                add bx, 0h
                jmp short @@endReg
            @@reg_1:
            cmp byte ptr [si], 0F9h ;cl cx
                jne short @@reg_2
                add bx, 1h*2
                jmp short @@endReg
            @@reg_2:
            cmp byte ptr [si], 0FAh ;dl dx
                jne short @@reg_3
                add bx, 2h*2
                jmp short @@endReg
            @@reg_3:
            cmp byte ptr [si], 0FBh ;bl bx
                jne short @@reg_4
                add bx, 3h*2
                jmp short @@endReg
            @@reg_4:
            cmp byte ptr [si], 0FCh ;ah sp
                jne short @@reg_5
                add bx, 4h*2
                jmp short @@endReg
            @@reg_5:
            cmp byte ptr [si], 0FDh ;ch bp
                jne short @@reg_6
                add bx, 5h*2
                jmp short @@endReg
            @@reg_6:
            cmp byte ptr [si], 0FEh ;dh si
                jne short @@reg_7
                add bx, 6h*2
                jmp short @@endReg
            @@reg_7:
            cmp byte ptr [si], 0FFh ;bh di
                jne short @@mem
                add bx, 7h*2
                jmp short @@endReg
            @@endReg:
                jmp @@write
        @@mem:

            mov bx, 10h*2h ;переносим начало после тупо регистров
            mov ah, 1h ;cl == 1 зна косв выраж, причем блинные
            cmp byte ptr [si], 038h ;[bx + si]
                jne short @@mBxDi
                add bx, 0h*9
                jmp @@write
            @@mBxDi:
            cmp byte ptr [si], 039h ;[bx +  di]
                jne short @@mBpSi
                add bx, 1h*9
                jmp @@write
            @@mBpSi:
            cmp byte ptr [si], 03Ah ;[bp +  si]
                jne short @@mBpDi
                add bx, 2h*9
                jmp  @@write
            @@mBpDi:
            cmp byte ptr [si], 03Bh ;[bp +  di]
                jne short @@mSi
                add bx, 3h*9
                jmp @@write
            @@mSi:
            add bx, 4h*9h ;если ето не длинные байды, то снова перемещаемначало что бы удобнеесчитать было
            mov ah, 2h
            cmp byte ptr [si], 03Ch ;[si]
                jne short @@mDi
                add bx, 0h*4
                jmp @@write
            @@mDi:
            cmp byte ptr [si], 03Dh ;[di]
                jne short @@mBx
                add bx, 1h*4
                jmp @@write
            @@mBx:
            cmp byte ptr [si], 03Fh ;[bx]
                jne short @@var
                add bx, 2h*4
                jmp @@write

            @@var:
            mov ah, 3h ;3  - переменная
            cmp byte ptr [si], 03Eh ; Var
                je @@write
                jne short @@mBxSi

            @@mBxSi:
            mov ah, 4h ;4 - хзчто за хрень 2 регистра а потом адрес
            add bx, 3h*4h ;ещё раз передвинули, чёт мнекажеться могет 2 бат и нехватить

            cmp byte ptr [si], 078h ;[bx][si]
                jne short @@mmBxDi
                add bx, 0h*8h
                jmp @@write
            @@mmBxDi:
            cmp byte ptr [si], 079h ;[bx][di]
                jne short @@mmBpSi
                add bx, 1h*8h
                jmp @@write
            @@mmBpSi:
            cmp byte ptr [si], 07Ah ;[bp][si]
                jne short @@mmBpDi
                add bx, 2h*8h
                jmp @@write
            @@mmBpDi:
            cmp byte ptr [si], 07Bh ;[bp][di]
                jne short @@mmSi
                add bx, 3h*8h
                jmp @@write

            @@mmSi:
            mov ah, 5h ;4 - хзчто за хрень 2 регистра а потом адрес
            add bx, 4h*8h ;ещё раз передвинули, чёт мнекажеться могет 2 бат и нехватить

            cmp byte ptr [si], 07Ch ;[si ]  []
                jne short @@mmDi
                add bx, 0h*4
                jmp short @@write
            @@mmDi:
            cmp byte ptr [si], 07Dh ;[di ]  []
                jne short @@mBp
                add bx, 1h*4
                jmp short @@write

            @@mBp:
            cmp byte ptr [si], 07Eh ;[bp ]  []
                jne short @@mmBx
                add bx, 2h*4
                jmp short  @@write
            @@mmBx:
            cmp byte ptr [si], 07Fh ;[bx ]  []
                jne short @@SumRegsAdr
                add bx, 3h*4
                jmp short  @@write

        @@SumRegsAdr:
            mov ah, 6h ;6 - выражения вида:[ bx + si    + адрес]
            add bx, 4h*4h
            @@mSumBxSi:
            cmp byte ptr [si], 0B8h ;[bx + si + adr ]   []
                jne short @@mSumBxDi
                add bx, 0h*0Bh
                jmp short  @@write
            @@mSumBxDi:
            cmp byte ptr [si], 0B9h ;[bx + di + adr ]   []
                jne short @@mSumBpSi
                add bx, 1h*0Bh
                jmp short  @@write
            @@mSumBpSi:
            cmp byte ptr [si], 0BAh ;[bp + si + adr ]   []
                jne short @@mSumBpDi
                add bx, 2h*0Bh
                jmp short  @@write
            @@mSumBpDi:
            cmp byte ptr [si], 0BBh ;[bp + di + adr ]   []
                jne short @@RegAndVar
                add bx, 3h*0Bh
                jmp short  @@write
        @@RegAndVar:
            mov ah, 7h ;7 - выражения вида:b1[si]
            add bx, 4h*0Bh
            @@mRegSi:
            cmp byte ptr [si], 0BCh ;[si]
                jne short @@mRegDi
                add bx, 0h*6
                jmp short  @@write
            @@mRegDi:
            cmp byte ptr [si], 0BDh ;[di]
                jne short @@mRegBp
                add bx, 1h*6
                jmp short  @@write
            @@mRegBp:
            cmp byte ptr [si], 0BEh ;[bp]
                jne short @@mRegBx
                add bx, 2h*6
                jmp short  @@write
            @@mRegBx:
            cmp byte ptr [si], 0BFh ;[bx]
                jne short @@unknow
                add bx, 3h*6
                jmp short  @@write
    @@unknow:
        dec si
        jmp short @@exit

    @@write:
    ;вывод div
    push cx
    push si
    lea si, idiv_msg
    mov cx, 5h
    rep movsb
    pop si
    pop cx

    inc si
    ;выводим операнд
    call WriteDivOperand

    ;вывод \n
    @@endwrite:
    push si
    lea si, endr
    mov cx, 1h
    rep movsb
    pop si

    jmp short @@exit

    @@exit:
    ret
parse_idiv endp

code ends
end
