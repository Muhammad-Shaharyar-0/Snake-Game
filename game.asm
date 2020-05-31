[org 0x0100]
jmp start
well: db 'WELCOME TO SNAKE GAME'
S: dw 21
oldisr: dd 0
choose: db 'WHICH LEVEL DO YOU WANT TO PLAY?'
S1: dw 32
choose1: db 'PRESS L\SHIFT FOR EASY OR R\SHIFT FOR HARD'
S2: dw 42
livesleft: db"Lives Left ="
scorestr: db"Score ="
failure: db"You failed try next time"
snakehead: db '@'
snakebody: db '#'
snakesize:dw 20
flag: db 0
movement: db 0
row: dw 0xb
column: dw 0x22
space: db ' '
spacerow: dw 0
spacecolumn: dw 0
rows: times 250 dw 0
columns: times 250 dw 0
collsion: dw 0
lives: dw 3
eaten: dw 1
fruitposition: dw 0
expand: dw 0
speed: dw 180
random: dw 326
oldtimer: dd 0
tickcount: dw 0
seconds: dw 0
minutes: dw 0
fruite: dw 97
count: dw 0
completed: dw 0
level: dw 0
score: dw 24000
speedcount: dw 0
sound_index: dw 0
sound_data: incbin "kingsv.wav" ; 51.529 bytes

sound:
	; send DSP Command 10h
	mov dx, 22ch
	mov al, 10h
	out dx, al

	; send byte audio sample
	mov si, [sound_index]
	mov al, [sound_data + si]
	out dx, al

	mov cx, 800
.delay:
	
	loop .delay
	
	inc word [sound_index]
	cmp word [sound_index], 51528
	jne .exit
	mov word [sound_index], 0
.exit:
	ret

clrscr: 
push es
push ax
push di
mov ax, 0xb800
mov es, ax 					; point es to video base
mov di, 0 					; point di to top left column
nextloc: 
mov word [es:di], 0x0720 	; clear next char on screen
add di, 2 					; move to next screen location
cmp di, 4000 				; has the whole screen cleared
jne nextloc 				; if no clear next position

pop di
pop ax
pop es
ret

printnum: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, [bp+6] ; point di to top left column
nextpos: pop dx ; remove a digit from the stack
mov dh, 0x05 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

printwell:

call clrscr

mov ax, 0xb800
mov es, ax 					; point es to video base
mov di, 1980 					; point di to top left column
mov si, well 				; point si to string
mov cx, [S] 				; load length of string in cx
mov ah, 0xc9 				; normal attribute fixed in al

nextchar: 
mov al, [si] 				; load next char of string
mov [es:di], ax 			; show this char on screen
add di, 2 					; move to next screen location
add si, 1 					; move to next char in string

loop nextchar

mov bx,150

delay:
mov cx,60000

avi:
loop avi
dec bx
cmp bx,0
jnz delay

ret

astericks:

mov ax, 0xb800
mov es, ax
mov di, 160

nextloc1: 
mov word [es:di], 0x0923
add di, 2 				
cmp di,  322
jne nextloc1 			

mov di, 3838

nextloc2: 
mov word [es:di], 0x0923
add di, 2 				
cmp di, 4000 
jne nextloc2 

mov bx,23
mov di,160
looop:
add di,158
mov cx,2

loop1:
mov word [es:di], 0x0923
add di, 2 				
loop loop1
sub di,2
dec bx
jnz looop

ret

astericks1:

mov ax, 0xb800
mov es, ax
mov di, 160

nextloc11: 
mov word [es:di], 0x0b23
add di, 2 				
cmp di,  322
jne nextloc11 			

mov di, 3838

nextloc21: 
mov word [es:di], 0x0b23
add di, 2 				
cmp di, 4000 
jne nextloc21 

mov bx,23
mov di,160
looop1:
add di,158
mov cx,2

loop11:
mov word [es:di], 0x0b23
add di, 2 				
loop loop11
sub di,2
dec bx
jnz looop1

mov di,200
mov bx,10
major:
add di,320
mov cx,15

loopforh:
mov word [es:di],0x0b23
add di,2
loop loopforh
dec bx
jnz major

mov di,260
mov bx,10
major1:
add di,320
mov cx,15

loopforh1:
mov word [es:di],0x0b23
add di,2
loop loopforh1
dec bx
jnz major1

ret

easylevel:

call clrscr

call astericks			;to print boundary

ret

hardlevel:

call clrscr

call astericks1			;to print boundary

ret


kbisr: 
push ax
push es

cmp byte[flag],0
jne nomatch
in al, 0x60 ; read a char from keyboard port
cmp al, 42 ; has the left shift pressed
jne nextcmp ; no, try next comparison
mov byte [cs:flag],1
mov word [level],0
call easylevel
jmp exit

nextcmp: 
cmp al, 54 ; has the right shift pressed
jne exit ; no, try next comparison
mov byte [cs:flag],1
mov word [level],1
call hardlevel
jmp exit

nomatch:
in al,0x60
cmp al,0x48
jne nextcmp1      ;up
cmp byte[cs:movement],3
je exit
mov byte[cs:movement],2
jmp exit

nextcmp1:
cmp al,0x50      ;down
jne nextcmp2
cmp byte[cs:movement],2
je exit
mov byte[cs:movement],3
jmp exit

nextcmp2:
cmp al,0x4b        ;left
jne nextcmp3
cmp byte[cs:movement],0
je exit
mov byte[cs:movement],1
jmp exit

nextcmp3:
cmp al,0x4d  ;right
jne nextcmp4
cmp byte[cs:movement],1
je exit
mov byte[cs:movement],0
jmp exit

nextcmp4:
cmp al,0x2a
jne exit
jmp terminate
exit:
mov al, 0x20
out 0x20, al ; send EOI to PIC
pop es
pop ax
iret


options:

mov ax, 0xb800
mov es, ax 					; point es to video base
mov di, 2290 				; point di to top left column
mov si, choose 				; point si to string
mov cx, [S1] 				; load length of string in cx
mov ah, 0x09 				; normal attribute fixed in al

nextchar1: 
mov al, [si] 				; load next char of string
mov [es:di], ax 			; show this char on screen
add di, 2 					; move to next screen location
add si, 1 					; move to next char in string

loop nextchar1

mov ax, 0xb800
mov es, ax 					; point es to video base
mov di, 2604 				; point di to top left column
mov si, choose1 				; point si to string
mov cx, [S2] 				; load length of string in cx
mov ah, 0x89 				; normal attribute fixed in al

nextchar2: 
mov al, [si] 				; load next char of string
mov [es:di], ax 			; show this char on screen
add di, 2 					; move to next screen location
add si, 1 					; move to next char in string

loop nextchar2

ret

printsnake:
push bp
mov bp,sp
push ax
push bx
push dx
push cx
push es
push si
push di
mov ah, 0x13 ; 
mov al, 0 ; 
mov bh, 0 ; 
mov bl, 4 ; 
mov dh,[rows]
mov dl,[columns]
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, snakehead ; offset of string
int 0x10 ; call BIOS video servicemov 
mov si,2
mov di,[snakesize]
add di,[snakesize]
mov bl, 4
l6:
mov dh,[rows+si]
mov dl,[columns+si]
mov bp, snakebody
int 0x10 
add si,2
cmp si,di
jl l6
pop di
pop si
pop es
pop cx
pop dx
pop bx
pop ax
pop bp
ret 4

updatesnake:
push bp
mov bp,sp
push ax
push bx
push dx
push cx
push es
push si
push di

mov si,0
mov ax,[rows+si]
mov bx,[columns+si]
mov cx,[row]
mov dx,[column]
mov [rows+si],cl
mov [columns+si],dl
mov si,2
mov di,[snakesize]
add di,[snakesize]
l5:
mov cx,ax
mov dx,bx
mov ax,[rows+si]
mov bx,[columns+si]
mov [rows+si],cl
mov [columns+si],dl
add si,2
cmp si,di
jl l5
mov [spacerow],al
mov [spacecolumn],bl

pop di
pop si
pop es
pop cx
pop dx
pop bx
pop ax
pop bp
ret 4

printspace:
push bp
mov bp,sp
push ax
push bx
push dx
push cx
push es
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 7 ; normal attrib
mov dh,[bp+6]
mov dl,[bp+4]
mov cx, 1 ; length of string
push cs
pop es ; segment of string
mov bp, space ; offset of string
int 0x10 ; call BIOS video servicemov dh,[bp+6]
pop es
pop cx
pop dx
pop bx
pop ax
pop bp
ret 4

collide:
push bp
mov bp,sp
push ax
push bx
push dx
push cx
push es
push si
push di

mov ax,[row]
mov dx,160
mul dx
mov di,[column]
add di,di
add di,ax
mov ax,0xb800
mov es,ax
cmp word [es:di],0x0720
je skip1
mov word[collsion],1
skip1:
cmp di,[fruitposition]
jne skip6
mov word[collsion],0
mov word[eaten],1
add word [snakesize],4
cmp word[snakesize],120
jl skip12
mov word[completed],1
skip12
skip6
pop di
pop si
pop es
pop cx
pop dx
pop bx
pop ax
pop bp
ret

set:
push ax
push bx
push cx
mov ax,0x22
mov bx,0
mov cx,[snakesize]
add cx,[snakesize]
l4:
mov word[rows+bx],0xb
mov word[columns+bx],ax
dec ax
add bx,2
cmp bx,cx
jl l4

pop cx
pop ax
pop bx
ret

timer:
push ax
push bx
push cx
push dx
inc word[speedcount]
cmp word[speedcount],2000
jne skip15
mov word[speedcount],0
sub word[speed],10
skip15:
dec word[score]
inc word [tickcount]
add word [count],10
inc word [fruite]
cmp word [fruite],123
jl skip5
mov word [fruite],97 
skip5
add  word[random],10
cmp word [random],3820
jl skip2
mov word[random],326
skip2:
cmp word[tickcount],100
jne skip3
inc word[seconds]
mov word[tickcount],0
mov cx,60
sub cx,[seconds]
cmp cx,10
jge skip22
push 158
jmp skip23
skip22:
push 156
skip23:
push cx
call printnum
push 0
push word [score]
call printnum
mov di,154
mov word [es:di],0x053a
push 152
mov cx,3
sub cx,[minutes]
push cx
call printnum
cmp word[seconds],60
jne skip3
mov word[seconds],0
inc word[minutes]
sub word[speed],5
cmp word[minutes],4
jl skip3
mov word[collsion],1
skip3:
mov ax,1100
out 0x40,al
mov al,ah
mov al,0x20
out 0x40,al
mov al,0x20
out 0x20,al
pop dx
pop cx
pop bx
pop ax
iret

genaratefruite:
push es
push di
push bx
push ax
cmp word[eaten],0
je exit1
cmp word[eaten],0
je exit1
mov ax,0xb800
mov es,ax
mov di,[random]
l7:
cmp word [es:di],0x0720
je Skip
add di,50
cmp di,3830
jne Skip1
mov di,326
Skip1:
jmp l7
Skip
mov bx,[fruite]
mov bh,06
mov [es:di],bx
mov word[eaten],0
mov word[fruitposition],di
exit1:
pop ax
pop bx
pop di
pop es
ret

reset:
mov cx,[snakesize]
add cx,[snakesize]
l8:
mov word[rows+bx],0
mov word[columns+bx],0
dec ax
add bx,2
cmp bx,cx
jl l8
mov word [snakesize],20
mov word [movement],0
mov word [row],0xb
mov word [column],0x22
mov word [speed],180
mov word [spacerow],0
mov word [spacecolumn],0
mov word [collsion],0
mov word [eaten],1
mov word[score],24000
mov ax,0xb800
mov es,ax
mov di,156
mov word [es:di],0x0530
call set
call printlives
mov word [count],0
mov word [tickcount],0
mov word [seconds],0
mov word [minutes],0
mov word [speedcount],0
ret

printlives:
push di
push ax
push bx
push dx
push cx
push es
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 5 ; normal attrib
mov dx,0x002a
mov cx, 12 ; length of string
push cs
pop es ; segment of string
mov bp, livesleft ; offset of string
int 0x10 ; call BIOS video servicemov dh,[bp+6]
mov ax,0xb800
mov es,ax
mov ax,[lives]
add ax,48
mov di,108
mov ah,5
mov [es:di],ax
pop es
pop cx
pop dx
pop bx
pop ax
pop di
ret 

printscore:
push di
push ax
push bx
push dx
push cx
push es
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 5 ; normal attrib
mov dx,0x0a28
mov cx, 7 ; length of string
push cs
pop es ; segment of string
mov bp, scorestr ; offset of string
int 0x10 ; call BIOS video servicemov dh,[bp+6]
pop es
pop cx
pop dx
pop bx
pop ax
pop di
ret

printfail:
push di
push ax
push bx
push dx
push cx
push es
mov ah, 0x13 ; service 13 - print string
mov al, 0 ; subservice 01 – update cursor
mov bh, 0 ; output on page 0
mov bl, 5 ; normal attrib
mov dx,0x0a1d
mov cx, 24 ; length of string
push cs
pop es ; segment of string
mov bp, failure ; offset of string
int 0x10 ; call BIOS video servicemov dh,[bp+6]
pop es
pop cx
pop dx
pop bx
pop ax
pop di
ret  


start:

call printwell
;call clrscr
call options


mov ax,0
mov es,ax
mov ax,[es:8*4]
mov bx,[es:8*4+2]
mov [oldtimer],ax
mov [oldtimer+2],bx

mov ax,[es:9*4]
mov bx,[es:9*4+2]
mov [oldisr],ax
mov [oldisr+2],bx

cli
mov word [es:9*4],kbisr
mov word [es:9*4+2],cs
mov word [es:8*4],timer
mov word [es:8*4+2],cs
sti

l1:
cmp byte[flag],0
je l1

call set
call printlives
mov word [count],0
mov word [tickcount],0
mov word [seconds],0
mov word [minutes],0
mov word [speedcount],0
mov ax,0xb800
mov es,ax
mov di,156
mov word [es:di],0x0530
mov word [score],24000

mainloop:
call sound	
call genaratefruite
push word [rows]
push word [columns]
call printsnake
l9:
mov ax,[speed]
cmp word [count],ax
jl l9
mov word [count],0
push word [spacerow]
push word [spacecolumn]
call printspace

cmp byte [movement],0
jne nxt1
inc word [column]
jmp skip

nxt1:
cmp byte [movement],1
jne nxt2
dec word [column]
jmp skip

nxt2:
cmp byte [movement],2
jne nxt3
dec word [row]
jmp skip

nxt3:
cmp byte [movement],3
jne nxt3
inc word [row]
jmp skip

skip:
call collide
cmp word [collsion],1
jne skip13
dec word[lives]
cmp word[lives],0
je terminate
cmp word [level],1
je skip14
call easylevel
call reset
jmp mainloop
skip14:
call hardlevel
call reset
jmp mainloop

skip13:
cmp word[completed],1
je succses
push word [row]
push word [column]
call updatesnake
jmp mainloop

terminate:
mov ax,0
mov es,ax
mov ax,[oldtimer]
mov bx,[oldtimer+2]
cli
mov [es:8*4],ax
mov [es:8*4+2],bx
sti

mov ax,[oldisr]
mov bx,[oldisr+2]
cli
mov [es:9*4],ax
mov [es:9*4+2],bx
sti

mov ax,0xb800
mov es,ax
mov di,0
mov ax,0x720
mov cx,2000
cld
rep stosw
call printfail
mov ah,0
int 0x16
jmp end1
succses:
mov ax,0
mov es,ax
mov ax,[oldtimer]
mov bx,[oldtimer+2]
cli
mov [es:8*4],ax
mov [es:8*4+2],bx
sti
mov ax,[oldisr]
mov bx,[oldisr+2]
cli
mov [es:9*4],ax
mov [es:9*4+2],bx
sti
mov ax,0xb800
mov es,ax
mov di,0
mov ax,0x720
mov cx,2000
cld
rep stosw
mov ax,[score]
mov dx,[lives]
mul dx
call printscore
push 2000
push ax
call printnum
mov ah,0
int 0x16
end1:

mov ax,0x4c00
int 21h
