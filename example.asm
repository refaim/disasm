.model small
.386
locals

extrn memcpy: far

public parse

data segment para public 'data' use16
    ; your data
data ends

code segment para public 'code' use16
assume cs: code

parse proc pascal far
;uses ax, bx, cx

    ; your code

@@exit:
    ret
parse endp

code ends
end
