org 0x7C00

mov ah, 0
int 0x13 ; 


mov al, 3 		  
mov ch, 0          
mov dh, 0          
mov cl, 2d          
mov ah, 2 

mov bx, 0x8000 
     
int 0x13   		  
jmp 0x8000

times 510-($-$$) db 0
;Begin MBR Signature
db 0x55 ;byte 511 = 0x55
db 0xAA ;byte 512 = 0xAA
