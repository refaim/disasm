.model small                                                     
.386                                                             
locals                                                           

public parse_salr
extrn byte2hex:far

data segment para public 'data' use16
irp reg, <ax,cx,dx,bx,sp,bp,si,di, al,cl,dl,bl,ah,ch,dh,bh>
    r_&reg db "&reg"                                        
endm                                                       
    m_sal db "sal"                                             
    m_sar db "sar"                                             

    m_byte db "byte"
    m_word db "word"

    wbhandler dw offset m_byte, offset m_word

    m_offset_override db " ptr ["
    m_comma_space db ", "        

    offset_array_top dw offset array_00_hndl, offset array_01_hndl, offset array_10_hndl

    m_00_000 db "bx + si"
    m_00_001 db "bx + di"
    m_00_010 db "bp + si"
    m_00_011 db "bp + di"
    m_00_100 db "si"     
    m_00_101 db "di"     
    m_00_110 db ""       
    m_00_111 db "bx"     

    m_01_000 db "bx + si + "
    m_01_001 db "bx + di + "
    m_01_010 db "bp + si + "
    m_01_011 db "bp + di + "
    m_01_100 db "si + "     
    m_01_101 db "di + "     
    m_01_110 db "bp + "     
    m_01_111 db "bx + "     

    array_00_hndl dw offset array_00_size, array_00_content
    array_01_hndl dw offset array_01_size, array_01_content
    array_10_hndl dw offset array_10_size, array_10_content
 
    array_00_size db 1 dup(7,7,7,7,2,2,0,2)
    array_01_size db 1 dup(10,10,10,10,5,5,5,5)
    array_10_size db 1 dup(10,10,10,10,5,5,5,5)

    array_00_content dw offset m_00_000, offset m_00_001, offset m_00_010, offset m_00_011, offset m_00_100, offset m_00_101, offset m_00_110, offset m_00_111
    array_01_content dw offset m_01_000, offset m_01_001, offset m_01_010, offset m_01_011, offset m_01_100, offset m_01_101, offset m_01_110, offset m_01_111
    array_10_content dw offset m_01_000, offset m_01_001, offset m_01_010, offset m_01_011, offset m_01_100, offset m_01_101, offset m_01_110, offset m_01_111

    array_11 dw offset array_11_8, offset array_11_16 

    ; fixed name size
    array_11_8 dw offset r_al, offset r_cl, offset r_dl, offset r_bl, offset r_ah, offset r_ch, offset r_dh, offset r_bh
    array_11_16 dw offset r_ax, offset r_cx, offset r_dx, offset r_bx, offset r_sp, offset r_bp, offset r_si, offset r_di
data ends                                                                                                            

; snd_op_type   = 0 - incorrect                  1 - for one, 2 - for cl, 3 - for imm
; size          = 0 - if 8bit,                   1 - if 16bit                
; rdoffst       = 0 - don't need to read offset, 1 - otherwise
; offst_sz      = 0 - offset is 8bit,            1 - 16bit               
flags record snd_op_type:2 = 0, size:1 = 0, rdoffst:1=0, offst_sz:1=0

get_field macro field, dst, src
    mov dst, src
    and dst, mask field
    shr dst, field
endm

set_field macro field, dst, src
    and dst, not mask field
    shl src, field
    or dst, src
    shr src, field
endm

EXIT_SUCCESS equ 0

code segment para public 'code' use16
assume cs: code, ds: data            

; Returns in ax error code if mnemonics is wrong
mnemonics proc pascal                           
uses si                                         
    mov al, [si]                                
    and al, 00111000b                           
    shr al, 3                                   
    cmp al, 4                                   
    je short @@sal                              
    cmp al, 7                                   
    je short @@sar                              
    mov ax, 01h                                 
    jmp short @@exit                            
@@sal:                                          
    lea si, m_sal                               
    jmp short @@common                          
@@sar:                                          
    lea si, m_sar                               
@@common:                                       
    xor ax, ax                                  
    mov cx, 3                                   
    cld                                         
    rep movsb                                   
@@exit:                                         
    ret                                         
mnemonics endp                                  

; parse mod r/m to get a full vision about first op
; also there are some mismatchs, so ax will be non-zero in that case
fst_op proc pascal                                                  
uses cx, dx                                                         
    mov ah, [si]                                                    
    mov al, ah                                                      
    shr al, 6 ; mod                                                 
    mov dl, al; mod                                                 
    mov al, ah                                                      
    and al, 00000111b; r/m                                          
    mov dh, al; r/m                                                 
    get_field size cl, bl                                            
    inc si                                                          
    push si                                                         
    cmp dl, 11b                                                     
    je @@gpreg                                                      
    shl cx, 1                                                       
    mov si, cx                                                      
    mov si, [si + wbhandler]                                        
    mov cx, 4                                                       
    cld                                                             
    rep movsb                                                       
    lea si, m_offset_override                                       
    mov cx, 6                                                       
    cld                                                             
    rep movsb                                                       
    cmp dl, 00b                                                     
    je short @@mod_00_rm_110                                        
    mov cl, dl                                                      
    dec cl                                                          
    set_field offst_sz bl, cl                                        
    mov cl, 1                                                       
    jmp short @@set_rdoffst                                         
@@mod_00_rm_110:                                                    
    mov cl, 1                                                       
    set_field offst_sz bl, cl                                        
    cmp dh, 110b                                                    
    sete cl                                                         
@@set_rdoffst:                                                      
    set_field rdoffst bl, cl                                         
    movzx si, dl                                                    
    shl si, 1                                                       
    mov si, [si + offset_array_top]                                 
    push bx                                                         
    mov bx, [si]                                                    
    push di                                                         
    movzx di, dh                                                    
    movzx cx, [bx + di]                                             
    mov bx, [si + 2]                                                
    shl di, 1                                                      
    mov si, [bx + di]
    pop di
    cld
    rep movsb
    pop bx
    pop si
    get_field rdoffst cl, bl
    cmp cl, 1
    jne short @@close_bracket
    mov byte ptr [di], '0'
    inc di
    mov al, [si]
    call byte2hex
    xchg al, ah
    get_field offst_sz cl, bl
    cmp cl, 0
    jne short @@offset_16
    mov [di], ax
    mov byte ptr [di + 2], 'h' 
    add di, 3 
    inc si  
    jmp short @@close_bracket
@@offset_16: 
    mov [di + 2], ax    
    mov al, [si + 1]  
    call byte2hex    
    xchg al, ah   
    mov [di], ax
    mov byte ptr [di + 4], 'h'  
    add si, 2  
    add di, 5    
@@close_bracket:
    mov byte ptr [di], ']'  
    inc di    
    jmp short @@post  
@@gpreg:     
    get_field size al, bl   
    shl al, 1    
    movzx si, al   
    mov si, [array_11 + si]    
    push bx    
    movzx bx, dh    
    shl bx, 1    
    mov si, [si + bx]
    mov cx, 2      
    cld   
    rep movsb
    pop bx
    pop si
@@post:
    push si  
    lea si, m_comma_space
    mov cx, 2
    cld
    rep movsb 
    pop si
    xor ax, ax  
    jmp short @@exit 
@@exit: 
    ret
fst_op endp

snd_op proc pascal
    get_field snd_op_type al, bl 
    cmp al, 1
    je short @@print_1
    cmp al, 2 
    je short @@print_cl
    jmp short @@print_imm
@@print_1:
    mov dword ptr [di], "h100"
    add di, 2
    jmp short @@exit
@@print_cl:
    mov word ptr [di], "lc"
    jmp short @@exit 
@@print_imm:
    mov al, [si] 
    inc si 
    call byte2hex 
    xchg al, ah
    mov byte ptr [di], '0' 
    mov word ptr [di + 1], ax
    mov byte ptr [di + 3], 'h'
    add di, 2 
@@exit: 
    add di, 2 
    ret  
snd_op endp

parse_salr proc pascal far
uses ax, bx, cx, dx, bp 
    mov al, [si] 
    mov bl, flags<>
    cmp al, 0D0h
    je short @@one_8
    cmp al, 0D1h
    je short @@one_16
    cmp al, 0D2h
    je short @@cl_8
    cmp al, 0D3h
    je short @@cl_16
    cmp al, 0C0h
    je short @@imm_8
    cmp al, 0C1h
    je short @@imm_16
    jmp short @@exit
@@one_16:
    mov cl, 1
    set_field size bl, cl
@@one_8:
    mov cl, 1
    set_field snd_op_type bl, cl
    jmp short @@common 
@@cl_16:
    mov cl, 1
    set_field size bl, cl
@@cl_8: 
    mov cl, 2
    set_field snd_op_type bl, cl
    jmp short @@common
@@imm_16: 
    mov cl, 1
    set_field size bl, cl
@@imm_8: 
    mov cl, 3 
    set_field snd_op_type bl, cl
    jmp short @@common 
@@common:
    push si
    inc si
    call mnemonics 
    cmp ax, EXIT_SUCCESS 
    jne short @@mismatch
    mov byte ptr [di], ' ' 
    inc di 
    call fst_op
    call snd_op 
    ; final stroke 
    add sp, 2
    mov byte ptr [di], 10 
    inc di 
    jmp short @@exit 
@@mismatch: 
    pop si 
@@exit: 
    ret 
parse_salr endp 
code ends
end
