.model tiny
.386

generate_void macro
    rept 500
        nop
    endm
endm

.DATA
    w1  dw  1000
    b1  db  19
    db 0DEh,0ADh,0BEh,0EFh

.code
    org 100h
start:
    test    word ptr [bp+di]+0AAh,0ABCDh

    and al,1
    and ch,255
    or  dl,55
    xor dh,32
    test    bl,58
    test    cl,0
    or  bh,2
    xor ah,254

    nop
    nop
    nop 

    and ax,1000h
    or  cx,2000h
    test    dx,1111h
    xor bx,5678h
    and sp,0EFABh
    or  bp,0A000h
    xor si,0BBBBh
    test    di,0DDCh


    nop
    nop
    nop


    and byte ptr [bx+si],3h
    or  byte ptr [bx+di],5h
    xor byte ptr [bp+si],7h
    test    byte ptr [bp+di],9h
    and byte ptr [si],0Ah
    or  byte ptr [di],0Bh
    xor byte ptr ds:0050h,0Ch
    test    byte ptr [bx],0Dh   

    nop
    nop
    nop
    
    and word ptr [bx+si]+09h,333h 
    or  word ptr [bx+di]+78h,531h
    xor word ptr [bp+si]+91h,312h
    test    word ptr [bp+di]+0AAh,0ABCDh
    and word ptr [si]+0FFh,0EEFh
    xor word ptr [di]+0EDh,0ABCh
    test    word ptr [bp]+0BDh,0BCAFh
    or  word ptr [bx]+0AFh,073Ah

    nop
    nop
    nop

    
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
    ;; ������ ��������� ;;
    ;;;;;;;;;;;;;;;;;;;;;;

    ;��������� ��� ������� ������������.
    and cx,ds:014Ah ;r16 m16
    and cx,w1

    ;��������� ��� ������� ������������.
    and ds:014Ah,cx ;m16 r16
    and w1,cx

    ;��������� ��� ������� ������������.
    and cl,ds:014Ch ;r8 m8
    and cl,b1

    ;��������� ��� ������� ������������.
    and ds:014Ch,cl ;m8 r8
    and b1,cl

    and ds:0109h,word ptr 100   ;m16 i16

    and ds:0109h,byte ptr 5 ;m8 i8

    nop
    nop
    nop

    ;��������� ���������
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

    ;��������� �� ���� �� �������
    ;��������� ��� ������� ������������.
    and ax,[bx+2]
    and ax,[bx]+2
    and ax,2[bx]

    and [bx+2],ax
    and [bx+2],word ptr 10
    and [bx+2],byte ptr 10

    ; ������ ���� � �������� �������
    jz short exit
    jcxz cycle
    nop
    mov ax, 123
    and ax, ax
    jz short exit

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


exit:
    ret
end start
