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
bomsymbol BYTE 19,' ',0
rowText BYTE 'Enter row number: ', 0
colText BYTE 'Enter column number: ', 0
invalidInput BYTE 'Err! Invalid input please enter valid value',0
i DWORD 0
j DWORD 0
k DWORD 0
play_rows DWORD 9
play_cols DWORD 9
playsize DWORD 9*9
numOfBombs DWORD 9
rowSize	DWORD 11

.code
main PROC

call addBombs
call addNums
call display
gameloop:;
call input
call check
cmp dl, 1
je lost
call display
jmp gameloop

lost:
mov edx, offset losttext
call writestring
call crlf
call showall
call display

exit
main ENDP

;-----------------------------------------------|
check PROC uses eax;                            |
;checks the chell corresponding the value of eax|
;-----------------------------------------------|
mov esi, offset disp	;if already displayed, dont check again
add esi, eax
cmp BYTE PTR [esi], 1
je ex

movzx esi, al			;if cell contains zero
add esi, offset field
cmp BYTE PTR [esi], 0
jne i1 ;jump to else if

mov dl, 0				;set corresponding display val to 1
mov esi, offset disp
add esi, eax
mov BYTE PTR [esi], 1

;now recursively check row above current cell for zeroes
push eax	;saving eax value
sub eax, 1 	;moving to top left element
sub eax, rowSize
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
add eax, rowSize	;moving to bottom left element
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

;checking left and right element for zeroes
sub eax, 3	;move to left of current element
sub eax, rowSize
call check
add eax, 2	;move to right
call check
jmp ex
;end if

;else if contains a mine
i1:
cmp BYTE PTR [esi], 9
jne ee	;jump to else
mov dl, 1	;if mine, set player lost flag to 1,
jmp ex		
;end elseif

;else
ee:	;must be a number, display it
mov esi, offset disp
add esi, eax
mov BYTE PTR [esi], 1
;end else

ex:
ret
check ENDP
;----------------------------------------------------------------------

;----------------------------------------------------------|
input PROC;                                                |
;takes row and column input, stores as single number in eax|
;-----------------------------------------------------------
inputStart:
mov edx, offset rowText
call crlf
call writestring
call readint
cmp eax, play_rows
ja invalid
mov bl, al
mov edx, offset colText
call writestring
call readint
cmp eax, play_cols
ja invalid
mov bh, al
mov al, BYTE PTR rowSize
imul bl
add al, bh
jmp endInput

invalid:
mov edx, offset invalidInput
call writestring
jmp inputStart

endInput:
RET
input ENDP
;------------------------------------------------------------

;-------------------------|
display proc;             |
;displays field to player |
;-------------------------|
call crlf
mov edx, offset space
call writestring
call writestring
call writestring
mov i, 1
topLoop:
mov eax, i
call writedec
call writestring
inc i
cmp i,9
jle topLoop
call crlf
call crlf

mov i, 1
L1:
	mov eax, i
	call writedec
	mov edx, offset space
	call writestring
	call writestring
	mov j, 1
	L2:
		mov eax, rowSize
		mov bl, BYTE PTR i
		imul bl
		add al, BYTE PTR j
		mov esi, offset disp
		add esi, eax
		cmp BYTE PTR [esi], 0
		je nosho
		mov esi, offset field
		add esi, eax
		cmp BYTE PTR [esi], 9
		je bombsho
		movzx eax, BYTE PTR [esi]
		call writedec
		mov edx, offset space
		call writestring
		jmp e
		nosho:
		mov edx, offset ast
		call writestring
		jmp e
		bombsho:
		mov edx, offset bomsymbol
		call writestring
		e:
	inc j
	mov eax, play_rows
	cmp j, eax
	jle L2
call crlf
inc i
mov eax, play_cols
cmp i, eax
jle L1
ret
display endp
;-----------------------------------------------------------------

;------------------------------------------|
showall PROC;                              |
;sets the display value to 1 for all cells |
;----------------------------------------- |
mov i, 1
row:

	mov j, 1
	col:
		mov eax, rowSize
		mov bl, BYTE PTR i
		imul bl
		add al, BYTE PTR j
		mov esi, offset disp
		add esi, eax
		mov BYTE PTR [esi], 1
	inc j
	mov eax, play_cols
	cmp j, eax
	jle col
inc i
mov eax, play_rows
cmp i, eax
jle row
ret
showall endp

;========================|
addBombs proc;           |
;adds bombs to the field |
;========================|
mov eax, 1
mov ebx, 1
call randomize
mov ecx, numOfBombs

loop1:
	mov esi, offset field
	push ecx
	
	mov eax, playsize
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
addBombs endp

;---------------------------------------------------------------------------
addNums proc;                                                              |
;adds numbers to each cell indicating the number of bombs around that cell |
;--------------------------------------------------------------------------
mov esi, offset field

mov i, 1
addNumsL1:

	mov j, 1
	addNumsL2:
		mov eax, i
		mov ebx, rowSize
		imul ebx
		add eax, j
		cmp BYTE PTR[esi + eax], 9
		je bomb
		mov ebx, eax
		
		sub eax, rowSize
		sub eax, 1

		mov k, 0
		addTopRow:
			cmp BYTE PTR [esi + eax], 9
			jne noBomb1
			inc BYTE PTR [esi + ebx]
		noBomb1:
		inc eax
		inc k
		cmp k, 3
		loopnz addTopRow
		dec eax

		add eax, rowSize
		
		mov k, 0
		addSameRow:
			cmp BYTE PTR [esi + eax], 9
			jne noBomb2
			inc BYTE PTR [esi + ebx]
		noBomb2:
		sub eax, 2
		inc k
		cmp k, 2
		jne addSameRow

		add eax, 2
		add eax, rowSize
		mov k, 0
		addBottomRow:
			cmp BYTE PTR [esi + eax], 9
			jne noBomb3
			inc BYTE PTR [esi + ebx]
		noBomb3:
		inc eax
		inc k
		cmp k, 3
		jne addBottomRow

	bomb:
	inc j
	cmp j, 10
	jne addNumsL2
inc i
cmp i, 10
jne addNumsL1

ret
addNums endp


end main