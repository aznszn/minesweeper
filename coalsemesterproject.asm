INCLUDE IRVINE32.inc

.data
;field is the backend record of the value of all cells
field BYTE 32 DUP(32 DUP(1))
	  
;boolean grid that indicates whether the player has uncovered the corresponding cell
disp BYTE 32 DUP(32 DUP(0))

;character to represent covered cell
ast BYTE 254,' ',0
space BYTE ' ',0
losttext BYTE 'You lost the game :(',0
wontext BYTE 'LFG YOU WIN!!!!', 0
bomsymbol BYTE 19,' ',0
rowText BYTE 'Enter row number: ', 0
colText BYTE 'Enter column number: ', 0
flagText BYTE 'Check or place/remove flag? enter 1 to check, enter 2 to add/remove flag: ',0
invldflag BYTE 'Please enter 1 or 2 only',0
invalidInput BYTE 'Err! Invalid input please enter valid value',0
flag BYTE 232, ' ',0
difficultyText BYTE 'Select difficulty level, press 1 for easy, press 2 for intermediate, press 3 for hard: ',0
i DWORD 0
j DWORD 0
k DWORD 0
play_rows DWORD ?
play_cols DWORD ?
playsize DWORD ?
numOfmines DWORD ?
rowSize	DWORD 32

.code
main PROC

getDifficulty:
mov edx, offset difficultyText
call writestring
call readint
cmp eax, 0
jna getDifficulty
cmp eax, 4
jnb getDifficulty
call setUpGame
call display
call input
push eax
mov ebx, eax
call addmines
call addNums
pop eax
call check

gameloop:;
call display
call input
cmp dh, 1
je gameloop
call check
cmp dl, 1
je lost
call checkWin
cmp dl, 2
je won
;call display
jmp gameloop

lost:
call crlf
call crlf
mov edx, offset losttext
mov eax, red
call setTextColor
call writestring
call crlf
call showall
call display
jmp endgame

won:
call crlf
call crlf
mov edx, offset wontext
mov eax, cyan
call setTextColor
call writestring
mov eax, white
call setTextColor
call crlf
call display

endgame:

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

mov esi, eax	;if cell contains zero			
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
ee:	
mov esi, offset disp	;must be a number, display it
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
imul rowSize
mov ebx, eax
mov edx, offset colText
call writestring
call readint
cmp eax, play_cols
ja invalid
;mov bh, al
add eax, ebx
jmp endInput

invalid:
mov edx, offset invalidInput
call writestring
jmp inputStart

endInput:
mov edx, offset flagText
call writestring
push eax
call readint
cmp eax, 2
ja invalidflagchoice
cmp eax, 1
jb invalidflagchoice
cmp eax, 1
je notflag
mov dh, 1
pop eax
mov esi, offset disp
add esi, eax
cmp BYTE PTR [esi], 1
je endall
cmp BYTE PTR [esi], 2
jne placeflag
mov BYTE PTR [esi], 0
jmp endall
placeflag:
mov BYTE PTR [esi], 2
jmp endall
invalidflagchoice:
mov edx, offset invldflag
call writestring
call crlf
pop eax
jmp endInput

notflag:
mov dh, 0
pop eax

endall:

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

mov eax, yellow
call setTextColor
mov i, 1
topLoop:
mov eax, i
call writedec
call writestring
cmp eax, 9
ja here
call writestring
here:
inc i
mov eax, i
cmp eax, play_cols
jbe topLoop

call crlf
call crlf
mov esi, rowSize
mov ecx, 1
L1:	
	mov eax, yellow
	call setTextColor
	mov eax, ecx
	call writedec

	mov eax, white
	call setTextColor
	mov edx, offset space
	call writestring
	cmp ecx, 9
	push ecx
	mov ecx, 1
	ja L2
	call writestring
	L2:
		inc esi
		mov eax, esi
		add eax, offset disp
		
		cmp BYTE PTR [eax], 0
		je nosho
		
		cmp BYTE PTR [eax], 2
		je flagsho
		
		sub eax, offset disp
		add eax, offset field
		
		cmp BYTE PTR [eax], 9
		je minesho
		
		movzx eax, BYTE PTR [eax]
		push eax
		
		cmp eax, 0
		je zero_
		mov eax, lightgreen
		call setTextColor
		jmp numsho
		
		zero_:
		mov eax, gray
		call setTextColor
		
		numsho:
		pop eax
		call writedec
		mov eax, white
		call setTextColor
		mov edx, offset space
		call writestring
		call writestring
		jmp e
		
		nosho:
		mov edx, offset ast
		call writestring
		mov edx, offset space
		call writestring
		jmp e
		
		flagsho:
		mov eax, red
		call setTextColor
		mov edx, offset flag
		call writestring
		mov eax, white
		call setTextColor
		mov edx, offset space
		call writestring
		jmp e
		
		minesho:
		mov eax, red
		call settextcolor
		mov edx, offset bomsymbol
		call writestring
		mov eax, white
		call setTextColor
		mov edx, offset space
		call writestring
		e:
	inc ecx
	cmp ecx, play_rows
	jbe L2
call crlf
call crlf
sub esi, play_cols
add esi, rowSize
pop ecx
inc ecx
cmp ecx, play_cols
jbe L1
ret
display endp
;-----------------------------------------------------------------

;------------------------------------------|
showall PROC;                              |
;sets the display value to 1 for all cells |
;----------------------------------------- |
mov esi, rowSize
mov ecx, 1
row:
	push ecx
	mov ecx, 1
	col:
		inc esi
		;mov eax, rowSize
		;mov ebx, i
		;imul ebx
		;add eax, j
		mov eax, esi
		add eax, offset disp
		mov BYTE PTR [eax], 1
	inc ecx
	cmp ecx, play_cols
	jbe col
sub esi, play_cols
add esi, rowSize
pop ecx
inc ecx
cmp ecx, play_rows
jbe row
ret
showall endp

;========================|
addmines proc;           |
;adds mines to the field |
;========================|
call randomize
mov ecx, numOfmines
loop1:
	mov eax, play_rows
	inc eax
	call randomrange
	mov ebx, rowSize
	imul ebx
	
	mov ebx, eax
	mov eax, play_cols
	inc eax
	call randomrange
	add ebx, eax
	mov eax, ebx
	
	add eax, offset field
	cmp byte ptr [eax], 0
	jne loop1
	cmp eax, ebx
	je loop1
	mov byte ptr[eax], 9
loop loop1
ret
addmines endp

;---------------------------------------------------------------------------
addNums proc;                                                              |
;adds numbers to each cell indicating the number of mines around that cell |
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
		je mine
		mov ebx, eax
		
		sub eax, rowSize
		sub eax, 1
		mov k, 0
		addTopRow:
			cmp BYTE PTR [esi + eax], 9
			jne nomine1
			inc BYTE PTR [esi + ebx]
		nomine1:
		inc eax
		inc k
		cmp k, 3
		jne addTopRow
		
		dec eax

		add eax, rowSize
		mov k, 0
		addSameRow:
			cmp BYTE PTR [esi + eax], 9
			jne nomine2
			inc BYTE PTR [esi + ebx]
		nomine2:
		sub eax, 2
		inc k
		cmp k, 2
		jne addSameRow

		add eax, 2
		add eax, rowSize
		mov k, 0
		addBottomRow:
			cmp BYTE PTR [esi + eax], 9
			jne nomine3
			inc BYTE PTR [esi + ebx]
		nomine3:
		inc eax
		inc k
		cmp k, 3
		jne addBottomRow

	mine:
	inc j
	mov eax, j
	cmp eax, play_cols
	jbe addNumsL2
inc i
mov eax, i
cmp eax, play_rows
jbe addNumsL1

ret
addNums endp

checkWin proc
mov ecx, 0

mov i, 1
winL1:
	mov j, 1
	winL2:
		mov eax, rowSize
		mov ebx, i
		imul ebx
		add eax, j
		mov esi, offset disp
		add esi, eax
		cmp BYTE PTR [esi], 1
		je not_covered
		inc ecx
	not_covered:
	inc j
	mov eax, play_cols
	cmp j, eax
	jbe winL2
inc i
mov eax, play_rows
cmp i, eax
jbe winL1

mov eax, ecx
cmp ecx, numOfmines
jne notwin
mov dl, 2

notwin:
ret 
checkWin endp

setUpGame proc

cmp eax, 3
je hard
cmp eax, 2
je med

easy:
mov play_rows, 9
mov play_cols, 9
mov numOfmines, 9
jmp endSetup

med:
mov play_rows, 16
mov play_cols, 16
mov numOfmines, 40
jmp endSetup

hard:
mov play_rows, 30
mov play_cols, 30
mov numOfmines, 160

endSetup:
mov eax, play_rows
mov ebx, play_cols
imul ebx
mov playsize, eax

mov i, 1
L1:
	
	mov j, 1
	L2:
		mov eax, i
		mov ebx, rowSize
		imul ebx
		add eax, j
		mov edi, offset field
		add edi, eax
		mov BYTE PTR [edi], 0
	inc j
	mov eax, j
	cmp eax, play_cols
	jbe L2
inc i
mov eax, i
cmp eax, play_rows
jbe L1
ret
setUpGame endp

end main