.model small
.386

public parse_nop 

code segment para public 'code' use16
assume cs:code
parse_nop proc pascal far
	cmp byte ptr [si], 90h
	jne short @@exit
        mov byte ptr [di], 'n'
        mov byte ptr [di + 1], 'o'
        mov byte ptr [di + 2], 'p'
        mov byte ptr [di + 3], 10
	inc si
	add di, 4
@@exit:
	ret
parse_nop endp
code ends
end
