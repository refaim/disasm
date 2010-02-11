.model small
.386
locals
; WARNING! IF YOU WANT TO ADD YOUR OWN FUNCTION TO DISASM YOU DON'T
; NEED TO TOUCH THIS FILE

OUT_BUFF_MARGIN equ 235
IN_BUFF_MARGIN  equ 240

invoke macro func ; This macro is NECESSARY to use by users
    call func     ; it calls func, and performs all necessary checks
    mov bp, sp   
    cmp si, word ptr [bp]
    ja @@restart  ; Very dangerous to make it SHORT - cause main cycle will grow
    jne @@error
endm

extrn print: far, byte2hex: far, memcpy: far
;extrn parse: far - students need to add their functions in this form

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
data ends

code segment para public 'code' use16
assume cs: code, ds: data, ss: stk ; No one knows why TASM requires this
; Reads [count] bytes from file 
; dx - offset of buffer, cx - count to read
; **File handler implictly will be set without any side help
read proc pascal
uses bx
    mov bx, filehandle
    mov ah, 3Fh
    int 21h
    ret
read endp

main proc
    mov ax, data
    mov ds, ax
    ; Display message for input
    lea dx, input_msg
    call print
    ; Get console input and store in buffer [only 254bytes will be read for this moment]
    mov ah, 0Ah
    mov dx, offset in_buff - 2   ; the last symbol always will be 0Dh
    int 21h
    mov al, [offset in_buff - 1] ; get the count of read bytes
    xor ah, ah
    mov si, ax
    mov in_buff[si], 0           ; prepare filename for retrieving a filehandler
    ; Open file for read
    mov ax, 3D00h
    lea dx, in_buff
    int 21h
    jc @@error                   ; dummy error handling
    mov filehandle, ax
    ; 1st initialization of commands buffer - reading from file
    mov cx, 255
    lea dx, in_buff
    call read
    jc @@error
    mov in_buff_size, ax ; actual bytes read
    
    lea si, in_buff      ; preconditions for users : si - start of commands buffer
    lea di, out_buff     ;                           di - start of output   buffer
@@main_cycle:
    push si ; It's necessary to know entry state, because this is the only way to determine
    ; whether the command recognized
    ; The lines with invoke must be placed in some .inc file
    ;invoke parse ; - in this form users will enter commands
    ;If no command was recognized - simply output it
    mov al, byte ptr [si]
    call byte2hex    
    mov [di], ah
    mov [di + 1], al
    mov byte ptr [di + 2], ' '
    add di, 3 ; two hex digits and one space
    inc si    ; one unrecognized byte
@@restart: ; Post iteration actions
    ; Check if in_buff need to be flushed
    sub sp, 2 ; Same to pop the si 
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
    je short @@cout           ; Buffer wasn't fully loaded, and all commands were processed - finishing work
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
    call memcpy    ; copy tail to the begin of buffer
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
    cmp bp, 0  ; If new buffer size = 0 (the rare situation, when length of file = k*max_buff_size)
    jne @@main_cycle ; But if != 0 we're ready to move on
@@cout:
    ; flush buffer and exit
    mov byte ptr [di], '$'
    lea dx, out_buff
    call print
@@exit: ; Normal exit
    mov ax, 4C00h
    int 21h
@@error: ; Dummy error handling
    mov ax, 4C01h
    int 21h
main endp
code ends
end main
