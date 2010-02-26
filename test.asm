.model tiny
.386

generate_void macro
    rept 500
        nop
    endm
endm

.DATA
    wordvar dw 1000
    bytevar db 19
    db 0DEh,0ADh,0BEh,0EFh

.code
    org 100h
start:
    ; ближние переходы
    jo exit
    nop
    jno exit
    nop
    jb exit
    jc exit
    jnae exit
    nop
    jae exit
    jnb exit
    jnc exit
    nop
    je exit
    jz exit
    nop
    jnz exit
    jne exit
    nop
    jbe exit
    jna exit
    nop
    ja exit
    jnbe exit
    nop
    js exit
    nop
    jns exit
    nop
    jp exit
    jpe exit
    nop
    jpo exit
    jnp exit
    nop
    jl exit
    jnge exit
    nop
    jge exit
    jnl exit
    nop
    jle exit
    jng exit
    nop
    jg exit
    jnle exit

    nop
    nop
    nop

    and al,1
    and ch,255
    or dl,55
    xor dh,32
    test bl,58
    test cl,0
    or bh,2
    xor ah,254

    nop
    nop
    nop

    and ax,1000h
    or cx,2000h
    test dx,1111h
    xor bx,5678h
    and sp,0EFABh
    or bp,0A000h
    xor si,0BBBBh
    test di,0DDCh


    nop
    nop
    nop


    and byte ptr [bx+si],3h
    or byte ptr [bx+di],5h
    xor byte ptr [bp+si],7h
    test byte ptr [bp+di],9h
    and byte ptr [si],0Ah
    or byte ptr [di],0Bh
    xor byte ptr ds:0050h,0Ch
    test byte ptr [bx],0Dh

    nop
    nop
    nop

    and word ptr [bx+si]+09h,333h
    or word ptr [bx+di]+78h,531h
    xor word ptr [bp+si]+91h,312h
    test word ptr [bp+di]+0AAh,0ABCDh
    and word ptr [si]+0FFh,0EEFh
    xor word ptr [di]+0EDh,0ABCh
    test word ptr [bp]+0BDh,0BCAFh
    or word ptr [bx]+0AFh,073Ah

    nop
    nop
    nop


    test word ptr [bx+si]+0991h,33h
    or word ptr [bx+di]+7813h,53h
    xor word ptr [bp+si]+91Ah,31h
    and word ptr [bp+di]+0ABAh,0ABh
    or word ptr [si]+0FEEFh,0EEh
    test word ptr [di]+0E6Dh,0ABh
    or word ptr [bp]+0B12Dh,0BCh
    xor word ptr [bx]+0A00Fh,07Ah


    nop
    nop
    nop

    test [bx+si]+0991h,al
    or [bx+di]+7813h,ah
    xor [bp+si]+91Ah,bl
    and [bp+di]+0ABAh,bh
    or [si]+0FEEFh,cl
    test [di]+0E6Dh,ch
    or [bp]+0B12Dh,dl
    xor [bx]+0A00Fh,dh


    nop
    nop
    nop

    xor [bx+si]+09h,ax
    xor [bx+di]+73h,bx
    or [bp+si]+9h,cx
    or [bp+di]+0Ah,dx
    test [si]+0FEh,si
    test [di]+0EDh,di
    and [bp]+0B1h,bp
    and [bx]+0AFh,sp

    nop
    nop
    nop

    and dl,[bx]
    test dh,[bx+si]
    test ch,[bx+di]
    and cl,[bp+si]
    or bl,[bp+di]
    xor bh,[di]
    xor ah,[si]
    or al,ds:0aaah

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
    and cx,wordvar

    ;Следующие две команды эквивалентны.
    and ds:014Ah,cx ;m16 r16
    and wordvar,cx

    ;Следующие две команды эквивалентны.
    and cl,ds:014Ch ;r8 m8
    and cl,bytevar

    ;Следующие две команды эквивалентны.
    and ds:014Ch,cl ;m8 r8
    and bytevar,cl

    and ds:0109h,word ptr 100 ;m16 i16

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

    ;Арифметические сдвиги
    ;General Purpose Registers
        ;mod = 11
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
         ; Косвенная адрессация
             ;mod = 00
    sar word ptr [bx][si], cl
    sal byte ptr [bx][di], 4
    sar word ptr [bp][si], 1
    sal word ptr [bp][di], 10
    sal byte ptr [si], cl
    sar word ptr [di], 11
    sal wordvar, 15
    sar bytevar, 0EEh
    sal byte ptr [bx], 8
             ;mod=01
    sal byte ptr [bx][si][15], 14
    sar byte ptr [bx][di][11], cl
    sal word ptr [bp][si][4], cl
    sar byte ptr [bp][di][9], cl
    sar word ptr [si][1][1][1], cl
    sal byte ptr [di][4][2], 15
    sar word ptr [bp][17], 1
    sal byte ptr [bx][1], 1
             ;mod=10
    sal byte ptr [bx][si][1500], 14
    sar byte ptr [bx][di][1001], cl
    sal word ptr [bp][si][400], cl
    sar byte ptr [bp][di][9000], cl
    sar word ptr [si][100][100][100], cl
    sal byte ptr [di][400][20], 15
    sar word ptr [bp][1700], 1
    sal byte ptr [bx][10000], 1

    nop
    nop
    nop

    ; сложение
    add al,12h
    adc al,23h
    nop
    add ax,3412h
    adc ax,9A78h
    nop
    add cl,al
    add bh,bl
    add al,bl
    add bl,al
    adc dl,dh
    nop
    add bx,dx
    add ax,cx
    adc ax,ax
    adc dx,si
    nop
    add bl,42h
    adc dh,76h
    nop
    add cx,7856h
    add bx,37h
    adc dx,8709h
    adc bx,59h
    nop
    add byte ptr [bp+si],34h
    adc byte ptr [bx+3412h],56h
    nop
    add word ptr [si+67h],8589h
    add word ptr [bx+si],+32h
    adc word ptr [si+67h],8589h
    adc word ptr [bx+si],9032h
    nop
    add dl,[bp+di]
    add [bp+si+12h],dh
    adc [bx+5634h],bh
    adc al,[bp+di]
    nop
    add dx,[bp+di]
    add [bp+si+12h],si
    adc [bx+5634h],di
    adc ax,[ds:3412h]

    nop
    nop
    nop

    ; деление
    div al
    div cl
    div dl
    div bl
    div ah
    div ch
    div dh
    div bh
    idiv al
    idiv cl
    idiv dl
    idiv bl
    idiv ah
    idiv ch
    idiv dh
    idiv bh

    nop
    nop
    nop

    div ax
    div cx
    div dx
    div bx
    div sp
    div bp
    div si
    div di
    idiv ax
    idiv cx
    idiv dx
    idiv bx
    idiv sp
    idiv bp
    idiv si
    idiv di

    nop
    nop
    nop

    div byte ptr [si]
    idiv byte ptr [si]
    div word ptr [si]
    idiv word ptr [si]
    nop
    div byte ptr [di]
    idiv byte ptr [di]
    div word ptr [di]
    idiv word ptr [di]
    nop
    div byte ptr [bx]
    idiv byte ptr [bx]
    div word ptr [bx]
    idiv word ptr [bx]
    nop
    div byte ptr [bp]
    idiv byte ptr [bp]
    div word ptr [bp]
    idiv word ptr [bp]

    nop
    nop
    nop

    div byte ptr [si][3]
    idiv byte ptr [si][3]
    div word ptr [si][3]
    idiv word ptr [si][3]
    nop
    div byte ptr [di][3]
    idiv byte ptr [di][3]
    div word ptr [di][3]
    idiv word ptr [di][3]
    nop
    div byte ptr [bx][3]
    idiv byte ptr [bx][3]
    div word ptr [bx][3]
    idiv word ptr [bx][3]
    nop
    div byte ptr [bp][3]
    idiv byte ptr [bp][3]
    div word ptr [bp][3]
    idiv word ptr [bp][3]

    nop
    nop
    nop

    div byte ptr [bx + si]
    idiv byte ptr [bx + si]
    div word ptr [bx + si]
    idiv word ptr [bx + si]
    nop
    div byte ptr [bx + di]
    idiv byte ptr [bx + di]
    div word ptr [bx + di]
    idiv word ptr [bx + di]
    nop
    div byte ptr [bp + si]
    idiv byte ptr [bp + si]
    div word ptr [bp + si]
    idiv word ptr [bp + si]
    nop
    div byte ptr [bp + di]
    idiv byte ptr [bp + di]
    div word ptr [bp + di]
    idiv word ptr [bp + di]

    nop
    nop
    nop

    div byte ptr [bx][si][15]
    idiv byte ptr [bx][si][15]
    div word ptr [bx][si][4]
    idiv word ptr [bx][si][4]
    nop
    div byte ptr [bx][di][11]
    idiv byte ptr [bx][di][11]
    div word ptr [bx][di][11]
    idiv word ptr [bx][di][11]
    nop
    div byte ptr [bp][si][4]
    idiv byte ptr [bp][si][4]
    div word ptr [bp][si][4]
    idiv word ptr [bp][si][4]
    nop
    div byte ptr [bp][di][9]
    idiv byte ptr [bp][di][9]
    div word ptr [bp][di][9]
    idiv word ptr [bp][di][9]

    nop
    nop
    nop

    div bytevar
    idiv bytevar
    div wordvar
    idiv wordvar

    nop
    nop
    nop

    div bytevar[si]
    idiv bytevar[si]
    div wordvar[si]
    idiv wordvar[si]
    nop
    div bytevar[di]
    idiv bytevar[di]
    div wordvar[di]
    idiv wordvar[di]
    nop
    div bytevar[bp]
    idiv bytevar[bp]
    div wordvar[bp]
    idiv wordvar[bp]
    nop
    div bytevar[bx]
    idiv bytevar[bx]
    div wordvar[bx]
    idiv wordvar[bx]

    nop
    nop
    nop

    div bytevar[bx + si]
    idiv bytevar[bx + si]
    div wordvar[bx + si]
    idiv wordvar[bx + si]
    nop
    div bytevar[bx + di]
    idiv bytevar[bx + di]
    div wordvar[bx + di]
    idiv wordvar[bx + di]
    nop
    div bytevar[bp + si]
    idiv bytevar[bp + si]
    div wordvar[bp + si]
    idiv wordvar[bp + si]
    nop
    div bytevar[bp + di]
    idiv bytevar[bp + di]
    div wordvar[bp + di]
    idiv wordvar[bp + di]

    nop
    nop
    nop

    div bytevar[bx + si + 10]
    idiv bytevar[bx + si + 10]
    div wordvar[bx + si + 10]
    idiv wordvar[bx + si + 10]
    nop
    div bytevar[bx + di + 10]
    idiv bytevar[bx + di + 10]
    div wordvar[bx + di + 10]
    idiv wordvar[bx + di + 10]
    nop
    div bytevar[bp + si + 10]
    idiv bytevar[bp + si + 10]
    div wordvar[bp + si + 10]
    idiv wordvar[bp + si + 10]
    nop
    div bytevar[bp + di + 10]
    idiv bytevar[bp + di + 10]
    div wordvar[bp + di + 10]
    idiv wordvar[bp + di + 10]

    nop
    nop
    nop

    ; короткие переходы
    jo short exit
    nop
    jno short exit
    nop
    jb short exit
    jc short exit
    jnae short exit
    nop
    jae short exit
    jnb short exit
    jnc short exit
    nop
    je short exit
    jz short exit
    nop
    jnz short exit
    jne short exit
    nop
    jbe short exit
    jna short exit
    nop
    ja short exit
    jnbe short exit
    nop
    js short exit
    nop
    jns short exit
    nop
    jp short exit
    jpe short exit
    nop
    jpo short exit
    jnp short exit
    nop
    jl short exit
    jnge short exit
    nop
    jge short exit
    jnl short exit
    nop
    jle short exit
    jng short exit
    nop
    jg short exit
    jnle short exit
    nop
    jcxz exit
    jecxz exit
exit:
    ret
end start
