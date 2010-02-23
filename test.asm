.model tiny
.386
 
generate_void macro
    rept 500
        nop
    endm
endm
 
.DATA
    w1 dw 1000
    b1 db 19
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

    
    test word ptr [bp+di]+0AAh,0ABCDh
 
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
    div b1[si]
    div b1
    div al
    div cl
    div dl
    div bl
    div ax
    div cx
    div dx
    div bx
    sal byte ptr [si + 123], cl
    sar word ptr [di], 1
    sal byte ptr [si], 10
    sar word ptr [bx][1], 8
exit:
    ret
end start
