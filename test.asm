.model tiny
.386

.code
    org 100h
start:
    sal ax, 1
    sal bx, 2
    sal cx, 3
    sal dx, 4
    sal sp, 5
    sal bp, 6
    sal si, 7
    sal di, cl
    
    sal al, 1   
    sal cl, 2
    sal dl, 3
    sal bl, 4
    sal ah, 5
    sal ch, 6
    sal dh, 7
    sal bh, cl
    
    test    word ptr [bx+si]+0991h,33h 
    or  word ptr [bx+di]+7813h,53h
    xor word ptr [bp+si]+91Ah,31h
    and word ptr [bp+di]+0ABAh,0ABh
    or  word ptr [si]+0FEEFh,0EEh
    test    word ptr [di]+0E6Dh,0ABh
    or  word ptr [bp]+0B12Dh,0BCh
    xor word ptr [bx]+0A00Fh,07Ah


    nop
    nop
    nop

    test    [bx+si]+0991h,al 
    or  [bx+di]+7813h,ah
    xor [bp+si]+91Ah,bl
    and [bp+di]+0ABAh,bh
    or  [si]+0FEEFh,cl
    test    [di]+0E6Dh,ch
    or  [bp]+0B12Dh,dl
    xor [bx]+0A00Fh,dh


    nop
    nop
    nop

    xor [bx+si]+09h,ax 
    xor [bx+di]+73h,bx
    or  [bp+si]+9h,cx
    or  [bp+di]+0Ah,dx
    test    [si]+0FEh,si
    test    [di]+0EDh,di
    and [bp]+0B1h,bp
    and [bx]+0AFh,sp

    nop
    nop
    nop

    and dl,[bx]
    test    dh,[bx+si]
    test    ch,[bx+di]
    and cl,[bp+si]
    or  bl,[bp+di]
    xor bh,[di]
    xor ah,[si]
    or  al,ds:0aaah

    nop
    nop
    nop

    not al
    not bl
    not cl
    not dl
    not ax
    not bx
    not cx
    not dx
    not ah
    not bh
    not ch
    not dh
    not sp
    not bp
    not si
    not di

    nop
    nop
    nop
        ;;;;;;;;;;;;;;;;;;;;;;
    ;; Прямая адресация ;;
    ;;;;;;;;;;;;;;;;;;;;;;

    ;Следующие две команды эквивалентны.
    and cx,ds:014Ah ;r16 m16
    and cx,w1

    ;Следующие две команды эквивалентны.
    and ds:014Ah,cx ;m16 r16
    and w1,cx

    ;Следующие две команды эквивалентны.
    and cl,ds:014Ch ;r8 m8
    and cl,b1

    ;Следующие две команды эквивалентны.
    and ds:014Ch,cl ;m8 r8
    and b1,cl

    and ds:0109h,word ptr 100   ;m16 i16

    and ds:0109h,byte ptr 5 ;m8 i8

    nop
    nop
    nop

    ;Косвенная адресация
    and cx,[bx]
    and dx,[bp]
    and ax,[si]
    and bx,[di]
    and [bx],cx
    and [bp],dx
    and [si],ax
    and [di],bx

    nop
    nop
    nop

    ;Адресация по базе со сдвигом
    ;Следующие три команды эквивалентны.
    and ax,[bx+2]
    and ax,[bx]+2
    and ax,2[bx]

    and [bx+2],ax
    and [bx+2],word ptr 10
    and [bx+2],byte ptr 10

    ; старый файл с простыми тестами
    ololo:
    jz short exit
    jcxz cycle
    nop
    mov ax, 123
    and ax, ax
    jz short exit
    jne ololo

    mov cx, 16
    xor bx, bx
    xor dx, dx
    cycle:
        shl ax, 1
        jc short found
        xor bx, bx
        jmp short next
        found:
            inc bx
            cmp bx, 4
            jl short next
            inc dx
        next:
    loop cycle
    nop
    nop

    sar al, cl   
    sar cl, 7
    sar dl, 6
    sar bl, 5
    sar ah, 4
    sar ch, 3
    sar dh, 2
    sar bh, 1

    sar ax, cl
    sar bx, 7
    sar cx, 6
    sar dx, 5
    sar sp, 4
    sar bp, 3
    sar si, 2
    sar di, 1

    sal byte ptr [bp+di+8], 4
    sal byte ptr [ds:1000], cl
    sal word ptr [ds:1000], cl
    sar byte ptr [ds:8], cl
    sar word ptr [ds:10], cl
    sal ax, 1
    sal bh, cl
    sal ax, 3
    sar byte ptr [si+300], 4
exit:
    ret
end start
