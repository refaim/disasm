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

safecall macro user_func
local @@regs_changed, @@endcall
    irp reg, <ax, bx, cx, dx, bp>
        push reg
    endm
    call dword ptr user_func
    irp reg, <bp, dx, cx, bx, ax>
        pop tmp
        cmp reg, tmp
        jne short @@regs_changed
    endm
    jmp short @@endcall
@@regs_changed:
    throw e_regs_changed
@@endcall:
endm

throw macro msg
    lea dx, msg
    call print
    jmp fatal_error
endm

error_check macro errcode, errmsg
local @@pass    
    cmp ax, errcode
    jne short @@pass
    throw errmsg
@@pass:
endm

stk segment stack use16
    db 256 dup (0)
stk ends

IN_BUFF_MARGIN  equ 240
OUT_BUFF_MARGIN equ 200

data segment para public 'data' use16
    filehandle dw ?

    in_buff db 255 dup (?)
    in_buff_size dw 0
    user_buff db 80 dup (?)
    out_buff db 255 dup (?)
    out_cursor db 0

    tmp dw ?

    funcs label dword
    irp parse_func, <FUNCS>
        dd parse_func
    endm
    funcs_end label dword

    ; messages
    m_usage db 'Usage: disasm [filename]', '$'
    ; file errors
    e_access_denied  db 'Access denied', '$'
    e_file_not_found db 'File not found', '$'
    e_invalid_handle db 'Invalid handle', '$'
    e_path_not_found db 'Path not found', '$'
    ; register errors
    e_regs_changed db 'Your function has changed one or more general purpose registers', '$'
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk

; get filename from command line arguments and stor in buffer
; out: ax -- error code (01h if command line is empty)
get_filename proc pascal
uses cx, si, di
    push ds
    xor ax, ax
    mov ah, 62h ; get psp address
    int 21h
    mov ds, bx ; load psp to data segment (for movsb)
    movzx cx, ds:80h ; real command line length
    test cx, cx
    jz short @@usage
    dec cx ; skip leading space
    mov ax, cx ; save length
    mov si, 82h ; first char in command line
    lea di, in_buff
    cld
    rep movsb
    pop ds
    mov si, ax
    mov in_buff[si], 0 ; make ASCIZ string for fopen
@@exit:
    xor ax, ax
    ret
@@usage:
    pop ds
    mov ax, 01h
    ret
get_filename endp

; open file for read
; in: dx -- filename offset
; out: ax -- file handle
fopen proc
    mov ax, 3D00h
    int 21h
    jnc short @@exit
    error_check 02h, e_file_not_found
    error_check 03h, e_path_not_found
    error_check 05h, e_access_denied
@@exit:
    ret
fopen endp

; read bytes from file
; in: dx -- buffer offset, cx -- count to read
; out: ax -- number of bytes read
; file handle implictly will be set without any side help
fread proc pascal
uses bx
    mov bx, filehandle
    mov ah, 3Fh
    int 21h
    jnc short @@exit
    error_check 05h, e_access_denied
    error_check 06h, e_invalid_handle
@@exit:
    ret
fread endp

check_buff proc pascal
uses bx, dx, di
    movzx bx, out_cursor
    cmp bx, OUT_BUFF_MARGIN
    jb short @@exit ; we didn't exceed the constraints for output buffer
    mov byte ptr [bx + out_buff], '$' ; NEVER forget, that print accepts the $-terminated strings
    mov out_cursor, 0
    lea dx, out_buff
    call print
@@exit:
    ret
check_buff endp

main proc
    mov ax, data
    mov ds, ax ; load data segment
    push ds
    pop es ; set es = ds (for movsb)

    call get_filename
    error_check 01h, m_usage

    lea dx, in_buff
    call fopen
    mov filehandle, ax

    mov cx, 255
    lea dx, in_buff
    call fread
    test ax, ax
    jz @@exit ; zero-length file
    mov in_buff_size, ax

    ; prepare cycle
    lea si, in_buff      ; preconditions for users : si - start of commands buffer
    mov cx, 1            ; 1 - last iteration wasn't unrecognized, 0 - otherwise
@@main_cycle:
    push si
    lea di, user_buff     ; di - start of output   buffer
    ; It's necessary to know entry state, because this is the only way to determine
    ; whether the command were recognized
    lea bx, funcs
@@launcher:
    safecall [bx]
    mov bp, sp
    cmp si, word ptr [bp]
    ja short @@restart
    je short @@continue
@@continue:
    add bx, 4 ; next parse function
    cmp bx, offset funcs_end
    jne @@launcher ; only when we tried every func, we can declare byte as unrecognized
    ; if no command was recognized - simply output it
    add sp, 2
    mov al, byte ptr [si]
    call byte2hex
    xchg al, ah
    movzx bx, out_cursor
    test cx, cx
    je short @@write_byte
    mov byte ptr [out_buff + bx], '['
    inc bx
@@write_byte:
    test cx, cx
    jne short @@skip_whitespace
    mov byte ptr [out_buff + bx], ' '
    inc bx
@@skip_whitespace:
    mov cx, 0
    mov word ptr [out_buff + bx], ax
    ;mov byte ptr [out_buff + bx + 2], ' '
    add bx, 2 ; two hex digits and one space
    mov out_cursor, bl
    lea di, user_buff
    inc si ; one unrecognized byte
    call check_buff
    jmp @@in_buff_check
@@restart: ; post successful-iteration actions
    movzx bx, out_cursor
    test cx, cx
    jne short @@skip_unrecognize_ending
    mov byte ptr [out_buff + bx], ']'
    mov byte ptr [out_buff + bx + 1], 10
    add bx, 2
@@skip_unrecognize_ending:
    mov byte ptr [out_buff + bx], '['
    inc bx
    mov out_cursor, bl
    mov cx, si
    pop dx ; old si
    sub cx, dx
    mov si, dx
    sub cx, 1
    jz short @@print_last_byte
    mov out_cursor, bl
@@hex_print:
    mov al, [si]
    movzx bx, out_cursor
    call byte2hex
    xchg al, ah
    mov word ptr [out_buff + bx], ax
    mov [out_buff + bx + 2], ' '
    add bx, 3
    inc si
    mov out_cursor, bl
    call check_buff
    loop short @@hex_print
@@print_last_byte:
    movzx bx, out_cursor
    mov al, [si]
    inc si
    call byte2hex
    xchg al, ah
    mov word ptr [out_buff + bx], ax
    mov byte ptr [out_buff + bx + 2], ']'
    mov byte ptr [out_buff + bx + 3], ' '
    add bx, 4
    mov out_cursor, bl
    call check_buff

    movzx bx, out_cursor
    mov cx, di
    sub cx, offset user_buff
    add bx, cx
    movzx di, out_cursor
    add di, offset out_buff
    push si
    lea si, user_buff
    cld
    rep movsb
    pop si
    mov out_cursor, bl
    call check_buff
    mov cx, 1
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
    push cx
    push di        ; save di - we still need to know where we stayed in output buffer after memory manipulations.
    mov cx, 255
    sub cx, bx     ; length of tail
    mov bp, cx
    lea di, in_buff
    push cx
    cld
    rep movsb ; copy tail to the begin of buffer
    pop cx
    lea si, in_buff
    pop di
    mov dx, si
    add dx, cx
    mov bx, 255
    sub bx, cx
    mov cx, bx
    call fread     ; and now in place after copied tail
    add bp, ax ; Evaluate the new buffer size (sizeof Tail + sizeof Actual Read)
    mov in_buff_size, bp
    pop cx
    test bp, bp ; If new buffer size = 0 (the rare situation, when length of file = k*max_buff_size)
    jne @@main_cycle ; But if != 0 we're ready to move on
@@finish:
    ; flush buffer and exit
    movzx bx, out_cursor
    test cx, cx ; if last command wasn't recognized
    jne short @@finish_lastrecognized
    mov byte ptr [bx + out_buff], ']'
    inc bx
@@finish_lastrecognized:
    cmp byte ptr [bx + out_buff - 1], 10 ; check for odd LF
    jne short @@finalize
    dec bx ; remove odd LF
@@finalize:
    mov byte ptr [bx + out_buff], '$'
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
