org 0x8000
bits 16   

;----------------
;CLEAR THE SCREEN
;----------------

jmp clearScreen

;------------
;START OF CLI
;------------

    WelcomeBash:

;-------------------
;PRINT THE BASH TEXT
;-------------------

mov si, msg
call write_string

;-------------------
;RESETS INPUT BUFFER
;-------------------

    xor ax,ax
    xor bx,bx
    xor di, di
    xor si, si

    cleanbuffer:
      cmp byte[userpass + si], 0
      je scanloop
      mov byte[userpass + si], 0
      inc si
      jmp cleanbuffer
 
;---------------------------------
;BEGIN SCANNING ONE CHAR AT A TIME
;---------------------------------

behind_bash:

  cmp di,0
  je scanloop
  jmp move_cursor

move_new_line:

  mov ah,0x02
  dec dh
  mov dl, 80
  int 10h
  jmp move_cursor

backspace:

  mov ah, 0x03
  int 10h

  cmp dl, 0
  je move_new_line
  
  cmp dl, 5d
  je behind_bash

move_cursor:

  mov ah, 0x0e
  mov al, 0x08
  int 10h
  mov al, ' '
  int 10h
  dec dl
  mov ah, 0x02
  int 10h
  dec di
  mov byte[userpass + di], 0
	
scanloop:

    mov ah,0x00
    int 16h
    cmp ah, 0x0e
    je backspace
    cmp ah, 0x1c
    je print

cmp di, 256
je scanloop

    mov byte[userpass+di], al
    inc di 
    mov ah,0x0E
    int 0x10
    jmp scanloop

;------------------------
;PRINT THE SCANNED BUFFER
;------------------------

print:
    mov ah,0x03
    int 10h
    cmp dl, 0
    jz dec_row

    mov ah,0x0E
    mov al, 0x0a
    int 10h

    mov ah,0x0E
    mov al, 0x0a
    int 10h
    xor di,di
    mov al, 0x0d
    int 10h

    backloop:
	cmp byte[userpass+di], 0
        je compare
	mov al, byte[userpass+di]
        inc di
        int 10h
        jmp backloop

;----------------------------------------
;COMPARE THE BUFFER TO A LIST OF COMMANDS
;----------------------------------------
        
    compare:
cmp di,0
je WelcomeBash
mov ah,0x0e
mov al, 0x0a
int 10h
mov al, 0x0d
int 10h
                

;-----------------------------
;CHECK IF THE BUFFER = "user"
;-----------------------------

		is_it_me:
			xor di,di
			is_it_me_loop:
			mov bh, byte[me+di]
                        cmp byte[userpass+di], bh
                        jne is_it_clear
                        inc di
                        cmp byte[me+di], 0
                        jne is_it_me_loop      	      
			xor di,di

;------------------------------------
;RESPONSE IN CASE THE BUFFER = "user"
;------------------------------------

		print_is_it_me:
			pusha
			mov si, meresponse
			call write_string
			popa
			jmp WelcomeBash

;-----------------------------
;CHECK IF THE BUFFER = "clear"
;-----------------------------

		is_it_clear:
			xor di,di
			is_it_clear_loop:
			mov bh, byte[clear+di]
                        cmp byte[userpass+di], bh
                        jne is_it_draw
                        inc di
                        cmp byte[clear+di], 0
                        jne is_it_clear_loop      	      
			xor di,di

;------------------------------------
;RESPONSE IN CASE THE BUFFER = "clear"
;------------------------------------

		clearScreen:
			mov     al, 02h		
      			mov     ah, 00h		
       		int     10h	
			jmp WelcomeBash
			
			
;-----------------------------
;CHECK IF THE BUFFER = "draw"
;-----------------------------

		is_it_draw:
			xor di,di
			is_it_draw_loop:
			mov bh, byte[draw+di]
                        cmp byte[userpass+di], bh
                        jne WelcomeBash
                        inc di
                        cmp byte[draw+di], 0
                        jne is_it_draw_loop      	      
			xor di,di

;------------------------------------
;RESPONSE IN CASE THE BUFFER = "draw"
;------------------------------------

mov cx,[x]
mov dx,[y]
call drawFunction	

;----------------
;EXIT THE PROGRAM
;----------------

exit: 
hlt		
ret  

dec_row:

	mov ah, 0x02
        dec dh
        mov dl, 80
        int 10h
        jmp print

;---------  
;FUNCTIONS
;---------

write_string:                   ; output string located in si
    mov ah, 0x0e                ; the 'print char' function of int 0x10
.repeat:                
    lodsb                       ; get character from the string
    cmp al, 0                   ; check if it is zero   
    je .done                    ; if it is, jump to .done and finish the function
    int 10h                     ; call interrupt 10h    
    jmp .repeat                 ; repeat for every char in the string
.done:                  
    ret

drawFunction:
	mov ah,00h
	mov al,13h
	int 10h
	mov ah,0Ch; configuration to writing pixel
	mov al,0Fh; choose color
	mov bh,00h; set page number
	int 10h
	ret

;-------------
;DECLARED DATA
;-------------

x dw 1
y dw 1

msg db "cat$>",0
userpass times 1000 db 0
exitf db 'exit', 0xa  ,0xd,0
exitlen equ $ - exitf
me db "user" , 0
meresponse db "Catalin", 0xa,0xd,0
clear db "clear", 0
draw db "draw", 0
