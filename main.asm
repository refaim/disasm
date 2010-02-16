; WARNING!
; IF YOU WANT TO ADD YOUR OWN FUNCTION TO DISASM YOU DON'T NEED TO TOUCH THIS FILE!
.model small
.386
locals

extrn print: far, byte2hex: far

include funcs.inc
irp parse_func, <FUNCS>
    extrn parse_func: far
endm

OUT_BUFF_MARGIN equ 235
IN_BUFF_MARGIN  equ 240

throw macro msg
    lea dx, msg
    call print
    jmp fatal_error
endm

stk segment stack use16
    db 256 dup (0)
stk ends

data segment para public 'data' use16
    input_msg db 'Input filename: $'
    filehandle dw 0

    db 254
    db 0
    in_buff db 255 dup (?)
    in_buff_size dw 0
    out_buff db 255 dup (?)

    e_fopen db 10, 'file opening failed$'
    e_fread db 10, 'file reading failed$'
    e_si_dec db 10, 'si has been reduced during the parsing, it is forbidden$'

    funcs label dword
    irp parse_func, <FUNCS>
        dd parse_func
    endm
    funcs_end label dword
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

; reads [count] bytes from file
; dx - offset of buffer, cx - count to read
; **filehandler implictly will be set without any side help
read proc pascal
uses bx
    mov bx, filehandle
    mov ah, 3Fh
    int 21h
    jnc short @@exit
    throw e_fread
@@exit:
    ret
read endp

main proc
    mov ax, data
    mov ds, ax
    push ds
    pop es
    ; Display message for input
    lea dx, input_msg
    call print
    ; Get console input and store in buffer [only 254 bytes will be read for this moment]
    mov ah, 0Ah
    mov dx, offset in_buff - 2 ; the last symbol always will be 0Dh
    int 21h
    mov al, in_buff - 1 ; get the count of read bytes
    movzx si, al
    mov in_buff[si], 0           ; prepare filename for retrieving a filehandler
    ; Open file for read
    mov ax, 3D00h
    lea dx, in_buff
    int 21h
    jnc short @@initial_read
    throw e_fopen
@@initial_read:
    ; initialization of commands buffer - reading from file
    mov filehandle, ax
    mov cx, 255
    lea dx, in_buff
    call read
    test ax, ax
    jz @@exit ; zero-length file
    mov in_buff_size, ax ; actual bytes read
    ; prepare cycle
    lea si, in_buff      ; preconditions for users : si - start of commands buffer
    lea di, out_buff     ;                           di - start of output   buffer
    mov byte ptr [di], 10 ; LF
    inc di
@@main_cycle:
    push si
    ; It's necessary to know entry state, because this is the only way to determine
    ; whether the command recognized
    lea bx, funcs
@@launcher:
    call dword ptr [bx]
    mov bp, sp
    cmp si, word ptr [bp]
    ja short @@restart
    je short @@continue
    throw e_si_dec
@@continue:
    add bx, 4
    cmp bx, offset funcs_end
    jne @@launcher
    ; if no command was recognized - simply output it
    mov al, byte ptr [si]
    call byte2hex
    xchg al, ah
    mov [di], ax
    mov byte ptr [di + 2], ' '
    add di, 3 ; two hex digits and one space
    inc si    ; one unrecognized byte
@@restart: ; Post iteration actions
    ; Check if in_buff need to be flushed
    add sp, 2 ; Same to pop the si
    lea ax, out_buff
    mov bx, di
    sub bx, ax
    cmp bx, OUT_BUFF_MARGIN
    jb short @@in_buff_check ; We didn't exceed the constraints for output buffer
    mov byte ptr [di], '$'   ; NEVAR forget, that print accepts the $-terminated strings
    mov di, ax ; The out_buff offset still in ax, we won one memmory access operation :)
    mov dx, di
    call print
@@in_buff_check:
    mov ax, in_buff_size      ; Its possible, that we read less than buffer size
    cmp ax, 255               ; and we check for this case
    je short @@refill         ; and if its happened - we know that EOF reached
    add ax, offset in_buff
    cmp si, ax
    jb @@main_cycle           ; Buffer wasn't fully loaded, but there is still some commands to process
    je short @@finish           ; Buffer wasn't fully loaded, and all commands were processed - finishing work
@@refill: ; Here we will fill buffer with new bytes from file
    lea ax, in_buff
    mov bx, si
    sub bx, ax              ; We have simpy margin - at least 15 bytes from the end of buffer(it equals to the MAX length of Intel
    cmp bx, IN_BUFF_MARGIN  ; instruction)
    jb @@main_cycle ; If space is enough - continue cycle
    push di        ; save di - we still need to know where we stayed in output buffer after memory manipulations.
    mov cx, 255
    sub cx, bx     ; length of tail
    mov bp, cx
    lea di, in_buff
    pusha ; temporary
    cld
    rep movsb ; copy tail to the begin of buffer
    popa ; temporary
    mov si, di 
    pop di
    mov dx, si
    add dx, cx
    mov bx, 255
    sub bx, cx
    mov cx, bx
    call read     ; and now in place after copied tail
    add bp, ax ; Evaluate the new buffer size (sizeof Tail + sizeof Actual Read)
    mov in_buff_size, bp
    test bp, bp ; If new buffer size = 0 (the rare situation, when length of file = k*max_buff_size)
    jne @@main_cycle ; But if != 0 we're ready to move on
@@finish:
    ; flush buffer and exit
    mov byte ptr [di], '$'
    lea dx, out_buff
    call print
@@exit: ; normal exit
    mov ah, 3Eh ; close file
    mov bx, filehandle
    int 21h
    mov ax, 4C00h
    int 21h
fatal_error: ; error handling
    mov ax, 4C01h
    int 21h
main endp
code ends
end main
