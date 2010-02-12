.model tiny
.386

generate_void macro
    rept 127
        nop
    endm
endm

num equ 111111111111111b ; 42975

.data
    db 0DEh,0ADh,0BEh,0EFh
.code
    org 100h
start:
    jz exit
    nop
    nop
    mov ax, num
    and ax, ax
    jz exit

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
    ;generate_void
exit:
    ret
end start
