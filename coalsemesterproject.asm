INCLUDE IRVINE32.inc

.data
;field is the backend record of the value of all cells
field BYTE 1,1,1,1,1,1,1,1,1,1,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,0,0,0,0,0,0,0,0,0,1
	  BYTE 1,1,1,1,1,1,1,1,1,1,1

;boolean grid that indicates whether the player has uncovered the corresponding cell
disp BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0
	 BYTE 0,0,0,0,0,0,0,0,0,0,0

;character to represent covered cell
ast BYTE 254,' ',0
space BYTE ' ',0
losttext BYTE 'You lost the game :(',0
i DWORD 0
j DWORD 0
k BYTE 0

.code
main PROC

;call display
;gameloop:
;call input
;call check
;cmp dl, 1
;je lost
;call display
;jmp gameloop

;lost:
call putbombs
call showall
call display
;mov edx, offset losttext
;call writestring

exit
main ENDP

;----------------------------------------------------------------
check PROC uses eax
;------------------------------------------------
;checks the chell corresponding the value of eax|
;------------------------------------------------

;if already displayed, dont check again
mov esi, offset disp
add esi, eax
cmp BYTE PTR [esi], 1
je ex

;if cell contains zero
movzx esi, al
add esi, offset field
cmp BYTE PTR [esi], 0

jne i1 ;jump to else if

;if cell contains zero
;set corresponding display cell to 1
mov dl, 0
mov esi, offset disp
add esi, eax
mov BYTE PTR [esi], 1

;now recursively check row above current cell for zeroes
push eax	;saving eax value
;moving to top left element
sub eax, 1 
sub eax, 11
mov i, 0

upper_row:
	push i
	call check
	pop i
	inc eax
	inc i
	cmp i,3
	jne upper_row

;now revursively check bottom row for zeroes
pop eax
;moving to bottom left element
add eax, 11
sub eax, 1
mov i, 0
ZL2:
	push i
	call check
	pop i
	inc eax
	inc i
	cmp i, 3
	jne ZL2

jmp ex	;end if

;else if contains a mine
i1:
cmp BYTE PTR [esi], 9

jne ee	;jump to else

mov dl, 1	;if mine, set player lost flag to 1,
jmp ex		;end if

ee:	;else, must be a number, display it
mov esi, offset disp
add esi, eax
mov BYTE PTR [esi], 1
;end else

ex:
ret
check ENDP
;----------------------------------------------------------------------

;----------------------------------------------------------------------
input PROC
;-----------------------------------------------------------
;takes row and column input, stores as single number in eax|
;-----------------------------------------------------------
call readint
mov bl, al
call readint
mov bh, al
mov al, 11
imul bl
add al, bh
RET
input ENDP
;------------------------------------------------------------

display proc
;-------------------------------
;displays field to player      |
;-------------------------------
mov i, 1
L1:

	mov j, 1
	L2:
		mov eax, 11
		mov bl, BYTE PTR i
		imul bl
		add al, BYTE PTR j
		mov esi, offset disp
		add esi, eax
		cmp BYTE PTR [esi], 1
		jne nosho
		sho:
		mov esi, offset field
		add esi, eax
		movzx eax, BYTE PTR [esi]
		call writedec
		mov edx, offset space
		call writestring
		jmp e
		nosho:
		mov edx, offset ast
		call writestring
		e:
	inc j
	cmp j, 10
	jne L2
call crlf
inc i
cmp i, 10
jne L1
ret
display endp
;-----------------------------------------------------------------

showall PROC
mov i, 1
row:

	mov j, 1
	col:
		mov eax, 11
		mov bl, BYTE PTR i
		imul bl
		add al, BYTE PTR j
		mov esi, offset disp
		add esi, eax
		mov BYTE PTR [esi], 1
	inc j
	cmp j, 10
	jne col
inc i
cmp i, 10
jne row
ret
showall endp

putbombs proc
mov eax,1
mov ebx,1
call randomize
mov ecx,9

loop1:
	mov esi, offset field
	push ecx
	
	mov eax,121
	;call delay 13
	;nop
	
	call randomrange
	
	pop ecx
	add esi,eax
	cmp byte ptr [esi],0
	je placebomb

	jmp loop1

	placebomb:
	mov byte ptr[esi],9
loop loop1
ret
putbombs endp

addNums proc
mov esi, offset field
mov i, 1
addNumsL1:
	mov j, 1

	addNumsL2:
	mov al, i
	mov ah, 11
	imul ah
	add al, j

	sub al, 11
	sub al, 1

	mov k, 0
	addNumsL3:
		

ret
addNums endp


end main