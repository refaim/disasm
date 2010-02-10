.model small
locals

public print

code segment para public 'code' use16
assume cs: code

; print string ended by $ to stdout
; string address must be in dx
print proc far
    mov ah, 09h
    int 21h
    ret
print endp

code ends
end
