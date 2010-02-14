.model small
.386
locals

public print, byte2hex

code segment para public 'code' use16
assume cs: code

; print '$'-terminated string addressed by dx
print proc pascal far
uses ax
    mov ah, 09h
    int 21h
    ret
print endp

; convert byte in al to its ASCII hex representation
; ax contains the result
byte2hex proc pascal far
uses bx, cx, dx
    movzx bx, al
    mov cx, 2
@@get_digit:
    mov dx, bx
    shr bx, 4
    and dx, 0Fh
    cmp dx, 0Ah
    jae short @@set_letter
    add dx, '0'
    jmp short @@write
@@set_letter:
    add dx, 'A' - 0Ah
@@write:
    cmp cx, 2
    jl short @@second
    mov al, dl
    jmp short @@next
@@second:
    mov ah, dl
@@next:
    dec cx
    jnz @@get_digit
    ret
byte2hex endp

code ends
end
