.model tiny   

.data
	db 0DEh,0ADh,0BEh,0EFh
num equ 111111111111111b ; 42975

.code
    org 100h
start:
	jne exit
	mov ax, num
    and ax, ax
    jz exit

    mov cx, 16
    xor bx, bx
    xor dx, dx
    cycle:
		shl ax, 1
		jc found
		xor bx, bx
		jmp next
		found:
			inc bx
			cmp bx, 4
			jl next
			inc dx
		next:
    loop cycle
exit:
	ret
end start