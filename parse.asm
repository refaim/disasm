.model small
locals

extrn print: far

public parse

data segment para public 'data' use16
    test_msg db "Hello World!$"
data ends

code segment para public 'code' use16
assume cs: code

parse proc far
    lea dx, test_msg
    call print
    ret
parse endp

code ends
end
