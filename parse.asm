.model small
locals

public parse
extrn print: far

data segment para public 'data' use16
    a db "ONOTOLE!11$"
data ends

code segment para public 'code' use16
assume cs:code, ds:data

parse proc far
    mov dx, offset a
    call print
    ret
parse endp
    
code ends
end
