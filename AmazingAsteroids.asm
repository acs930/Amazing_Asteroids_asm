TITLE MASM TEMPLATE					(main.asm)

INCLUDE Irvine32.inc
;INCLUDE Macros.inc
CHAR_VAL = '*'
COUNT = 50
.data
promptwelcome BYTE "			      Welcome To..                             ",0
prompt2 BYTE  "                                                                ",0
prompt3 BYTE  "            _____                                                ",0     
prompt4 BYTE  "           //   \\		                                       ",0
prompt5 BYTE  "          //     \\                                              ",0                  
prompt6 BYTE  "         //_______\\    ___  ___  ___  ___   __  ___  _    __    ",0                  
prompt7 BYTE  "        //         \\  |___   |   |__  |__| |  |  |  |  \ |__    ",0                  
prompt8 BYTE  "       //           \\  ___|  |   |__  | \  |__| _|_ |__/  __|   ",0                  
prompt9 BYTE  "      ________________________________________________________   ",0                 
prompt10 BYTE "  --------------------------------------------------------------------- ",0

menuprompt Byte "			Please choose an option: ",0

playprompt Byte "			1. Play  ",0
exitprompt Byte "	2. Exit  ",0
pprompt Byte  "  ----------",0
pprompt1 Byte " At any time to bring up the exit menu press 'p' ",0
pprompt2 Byte "----------",0
hprompt Byte "  ---------- ",0
hprompt1 Byte "At any time to bring up the help menu press 'h' ",0
hprompt2 Byte "----------",0


helpprompt1 byte  "-----------------Help Menu---------------",0
helpprompt0 byte  " The Object of the game is to blow up as many asteroids with your bombs",0
helpprompt00 byte " to get more bombs pass over the right side of the screen! ",0
helpprompt01 Byte " During gameplay, your allowed 5 bombs, and have 1 minute to survive.",0
helpprompt02 Byte " Your scored will be displayed on the bottom left of the screen." ,0
helpprompt03 byte "To enable cheats press m then go wild, my highest was 39 trillion." , 0
helpprompt byte   " _______________________________",0
helpprompt2 Byte  "| Button |     What is does     |",0
helpprompt3 Byte  "|________|______________________|",0
helpprompt4 Byte  "|  'W'   |  Accelerates         |",0
helpprompt5 Byte  "| 'A'/'D'|  Rotates Ship        |",0
helpprompt6 Byte  "|  'S'   |  Decelerate          |",0
helpprompt7 Byte  "| 'space'|  Shoot Bullets       |",0
helpprompt8 Byte  "|  'P'   |  Exit Menu           |",0
helpprompt9 Byte  "|  'H'   |  Help Menu           |",0
helpprompt10 Byte "|  'B'   |  Bomb                |",0
helpprompt11 Byte "|________|______________________|",0
spaceprompt Byte "     ",0

overprompt0 Byte   " --------------------Exit Menu-----------------------",0
overprompt Byte    " I'm Sorry but you have either ",0
overprompt1 Byte   "quit",0
overprompt10 Byte  " or ",0
overprompt11 Byte  "lost",0
overprompt12 Byte  " the game!!", 0
overprompt2 Byte   " Do you want to play again?",0
overprompt3 Byte   " 1. Yes  2. No",0

overpromptnew2 BYTE "Do you want to Restart, or exit?",0
overpromptnew3 BYTE "1. Restart  2. Exit ",0

gameOverScore	byte	"Your score was: ", 0


endval BYTE 70h
helpval BYTE 68h

asteroid1		byte	10		dup(0)	; layout of asteroid array
asteroid2		byte	10		dup(0)	; byte1 = xCoord		byte2 = yCoord
asteroid3		byte	10		dup(0)	; byte3 = xVel			byte4 = yVel
asteroid4		byte	10		dup(0)	; byte5 = isDestroyed   byte6 = hasCollieded
asteroid5		byte	10		dup(0)	; byte7 = width			byte8 = height
asteroid6		byte	10		dup(0)	; byte9 = isBroken		
asteroid7		byte	10		dup(0)
asteroid8		byte	10		dup(0)
asteroid9		byte	10		dup(0)
bossStroid		byte	10		dup(0)
numRange		dd	?

playerShip		byte	10		dup(0)	;layout of ship array
										;byte1 = xCoord			byte2 = yCoord
										;byte3 = direction		byte4 = velocity
										;byte5 = isDestroyed	byte6 = hasCollided
										;byte7 = width			byte8 = height

bullet1			byte	10		dup(0)	;layout of bullet
bullet2			byte	10		dup(0)	;byte1 = xCoord			byte2 = yCoord
										;byte3 = direction		byte4 = velocity
										;byte5 = isFired		byte6 = hasCollided
										;byte7 = width			byte8 = height

SCREEN_HEIGHT	dd	40
SCREEN_WIDTH	dd	80

asteroidsOnField byte	0

topOfBigAsteroid	byte	" ***** ",0
midOfBigAsteroid	byte	"*     *",0
botOfBigAsteroid	byte	" ***** ",0

topOfSmallAsteroid	byte	" *** ",0
midOfSmallAsteroid	byte	"*   *",0
botOfSmallAsteroid	byte	" *** ",0

tempByte	byte	0
tempWord	dw		0
tempDWord	dd		0

up    byte 77h		;stores 'w' into up
down  byte 73h		;stores 's' into down
left  byte 61h		;stores 'a' into left
right byte 64h		;storea 'd' into right
space byte 20h		;stores 'space' into space

north	byte	0
east	byte	1
south	byte	2
west	byte	3

asteroidsOnScreen byte 2

expL1	byte	"*   *", 0
expL2	byte	"  *  ", 0
expL3	byte	"*   *", 0

bombCount byte  5

timeLeft dd 1000

score  dd  0


outHandle HANDLE 0
windowRect	SMALL_RECT	<0,0,79, 40>




.code
main PROC
call randomize

invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outHandle, eax
invoke SetConsoleWindowInfo, outHandle, TRUE, ADDR windowRect
	
call splashScreen
call choose
cmp tempWord, 1111
je GAMETIME
jmp done

GAMETIME:
	call initialize

	call gameLoop





done:


exit
main ENDP

initialize PROC
mov eax, 500
mov timeLeft, eax
call getNextAvailableAsteroid
call initializeAsteroid
call getNextAvailableAsteroid
call initializeAsteroid
call initializeShip
call initializeBullet

ret
initialize ENDP

gameLoop PROC

begin:

call handleInput
call logic
call render
call moreAsteroids				;checks if there are 1 asteroid and adds another
dec timeLeft
inc score
inc score


jmp begin


gameLoop ENDP

logic PROC						;astroids are wonky 

mov eax, timeLeft
cmp eax, 0
je gameOver
call updateShip
call updateBullets
call updateAllAsteroids
jmp done


gameOver:
call exitGame
call gameoverproc

done:

ret
logic ENDP

render PROC

call clrscr

call drawAllAsteroids
call drawBullets
call drawShip
call drawHUD

invoke SetConsoleWindowInfo, outHandle, TRUE, ADDR windowRect

ret
render	ENDP

moreAsteroids PROC
mov al, asteroidsOnScreen
cmp al, 0
je putMore
jmp done

putMore:

call getNextAvailableAsteroid
call initializeAsteroid
inc asteroidsOnScreen

jmp done

done:

ret
moreAsteroids ENDP

drawHUD PROC
mov dl, 10
mov dh, 39
call gotoxy
mov eax, score
call writeDec
add dl, 10
call gotoxy
mov eax, 0
mov al, bombCount
call writeDec
add dl, 10
call gotoxy
mov eax, 0
mov eax, timeLeft
call writeDec
mov dl, 9
mov dh, 38
call gotoxy
mov eax, 0
mov eax, 83
call writeChar

add dl, 10
call gotoxy
mov eax, 0
mov eax, 66
call WriteChar

add dl, 10
call gotoxy
mov eax,  0
mov eax, 84
call writeChar



ret
drawHUD ENDP

splashscreen Proc
;------------------------------------------------------------------------------------------------------------------------------------------------------
;Splashscreen displays the splash screen
;
;
	
	call crlf
	mov eax, lightGray
	call SetTextColor
	mov	 edx,OFFSET promptwelcome
	call WriteString
	call crlf
	
	mov eax, 750
	call delay

	mov eax, cyan
	call SetTextColor
	
	mov	 edx,OFFSET prompt2
	call WriteString
	call crlf

	mov	 edx,OFFSET prompt2
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt3
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt4
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt5
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt6
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt7
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt8
	call WriteString
	call crlf
	
	mov	 edx,OFFSET prompt9
	call WriteString
	call crlf
	call crlf
	call crlf
	mov eax, lightGray
	call SetTextColor
	
	mov eax, 600
	call delay
	mov	 edx,OFFSET menuprompt
	call WriteString
	call crlf
	call crlf
	
	mov eax, 300
	call delay
	mov	 edx,OFFSET playprompt
	call WriteString
	mov eax, 300
	call delay
	mov	 edx,OFFSET exitprompt
	call WriteString
	call crlf
	call crlf
	call crlf
	call crlf  
	mov eax, lightRed
	call SetTextColor
	mov	 edx,OFFSET prompt10
	call WriteString
	call crlf
	mov	 edx,OFFSET pprompt
	call WriteString
	mov eax, white
	call SetTextColor
	mov edx, OFFSET pprompt1
	call writestring
	mov eax, lightRed
	call SetTextColor
	mov edx, OFFSET pprompt2
	call writestring
	call crlf
	mov	 edx,OFFSET hprompt
	call WriteString
	mov eax, white
	call SetTextColor
	mov	 edx,OFFSET hprompt1
	call WriteString
	mov eax, lightRed
	call SetTextColor
	mov edx, OFFSET hprompt2
	call writestring
	call crlf
	mov	 edx,OFFSET prompt10
	call WriteString
	call crlf
	call crlf
	call crlf
	call crlf
	mov eax, white
	call SetTextColor

ret
splashscreen endp

choose PROC
;------------------------------------------------------------------------------------------------------------------------------------------------------
;;here the user will enter a number 1 or 2 for either play or exit
;;then it will jump to another proc where it is either play or exit
;;if play the game will run. if exit the game will close

read:
	mov eax, 0
	call readint
	cmp al, 1
	je playseq
	cmp al, 2
	je endseq
	mov eax, white
	call SetTextColor

		
playseq:
	call clrscr
	mov tempWord, 1111
	jmp e
	
endseq:
	call gameoverproc
	jmp e
e:
	
ret
choose endp

gameoverproc PROC

call clrscr
call crlf
mov eax, white 
call SetTextColor
mov edx, offset overprompt0
call writestring
call crlf
call crlf
mov eax, gray 
call SetTextColor
mov edx, offset overprompt
call writestring
mov eax, lightRed 
call SetTextColor
mov edx, offset overprompt1
call writestring
mov eax, gray 
call SetTextColor
mov edx, offset overprompt10
call writestring
mov eax, lightRed
call SetTextColor
mov edx, offset overprompt11
call writestring
mov eax, gray 
call SetTextColor
mov edx, offset overprompt12
call writestring
call crlf
mov edx, offset overprompt2
call writestring
call crlf
call crlf
mov edx, offset overprompt3
call writestring
call crlf
call crlf
mov edx, offset gameOverScore
call writeString
mov eax, score
call writeDec
call crlf
mov eax, white 
call SetTextColor

mov eax,0
call readint
cmp al, 1
	je playseq
	cmp al, 2
	je endseq
		
playseq:
	mov eax, white 
	call SetTextColor
	call clrscr
	mov tempWord, 1111
	mov eax, 250
	jmp e
	
endseq:
	
	call exitgame
	exit
	jmp e
e:





ret
gameoverproc ENDP

helpproc PROC

	call clrscr
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov eax, lightRed
	call SetTextColor
	mov edx, offset helpprompt1
	call writestring
	call crlf
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray
	call SetTextColor
	mov edx, offset helpprompt0
	call writestring
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov edx, offset helpprompt00
	call writestring
	call crlf
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov edx, offset helpprompt01
	call writestring
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov edx, offset helpprompt02
	call writestring
	call crlf
	mov edx, offset helpprompt03
	call writestring
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov edx, offset helpprompt
	call writestring
	call crlf
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt2
	call writestring
	call crlf
	mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt3
	call writestring
	call crlf
	mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt4
	call writestring
	call crlf
		mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt5
	call writestring
	call crlf
		mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt6
	call writestring
	call crlf
	mov eax, gray
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt7
	call writestring
	call crlf
	mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt8
	call writestring
	call crlf
	mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt9
	call writestring
	call crlf
	mov eax, gray
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt10
	call writestring
	call crlf
	mov eax, gray
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray + (blue * 16)
	call SetTextColor
	mov edx, offset helpprompt11
	call writestring
	call crlf
	call crlf
	
	mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray
	call SetTextColor
	mov edx, offset overpromptnew2
	call writestring
	call crlf
	call crlf
	mov eax, gray 
	call SetTextColor
	mov edx, offset spaceprompt
	call writestring
	mov eax, gray 
	call SetTextColor
	mov edx, offset overpromptnew3
	call writestring
	call crlf
	mov eax, white 
	call SetTextColor
	mov eax,0
call readint
cmp al, 1
	je playseq
	cmp al, 2
	je endseq
		
playseq:
	call clrscr
	mov tempWord, 1111
	jmp e
	
endseq:
	call clrscr
	exit
	jmp e
e:




ret
helpproc endp


handleInput PROC

mov eax, 0
call readKey
cmp al, up
je upMove
cmp al, down
je downMove
cmp al, left
je leftRotate
cmp al, right
je rightRotate
cmp al, space
je shoot
cmp al, 113
je stopGame
cmp al, endval
je ending
cmp al, helpval
je help
cmp al, 98
je killAsteroid
cmp al, 109
je killShip

jmp noInput

help:
	call helpproc
	jmp done

ending:
	call gameoverproc
	jmp done

upMove:
mov esi, offset playerShip
call get3rd
mov al, 1
add [esi], al
jmp done

downMove:
	mov esi, offset playerShip
	call get3rd
	;mov al, 1
	;sub [esi], 1
	mov al, 0
	mov [esi], al
	jmp done


leftRotate:
	mov esi, offset playerShip
	call get2nd
	mov al, 0
	cmp [esi], al		;if our ship is north	dir = 0
	je westFace

	mov bl, 1
	sub [esi], bl			;if its not north (dir != 0)
	jmp doneLeftRotate
	westFace:
		mov al, west
		mov [esi], al		;dir = 3
		jmp doneLeftRotate

	doneLeftRotate:
	jmp done
	

rightRotate:
	mov esi, offset playerShip
	call get2nd
	mov al, 3
	cmp [esi], al		;if our ship is west	dir = 3
	je northFace
	
	mov bl, 1
	add [esi], bl		;if its not north (dir != 3)
	jmp doneRightRotate
	northFace:
		mov al, north
		mov [esi], al		;dir = 0
		jmp doneRightRotate

	doneRightRotate:
	jmp done


shoot:
	mov esi, offset bullet1

	call get4th
	mov al, 1
	cmp [esi], al
	je checkBullet2
	jmp fireBullet1

	checkBullet2:
		mov esi, offset bullet2
		call get4th
		mov al, 1
		cmp [esi], al
		je noBullets
		jmp fireBullet2

	fireBullet1:
		mov esi, offset bullet1
		call get3rd
		mov al, 2
		add [esi], al
		mov esi, offset bullet1	;velocity = 2
		call get4th
		mov al, 1
		mov [esi], al			;bullet1 is fired set to 1
		jmp done

	fireBullet2:
		mov esi, offset bullet2
		call get3rd
		mov al, 2
		add [esi], al
		mov esi, offset bullet2	;velocity = 1
		call get4th
		mov al, 1
		mov [esi], al			;bullet2 is fired
		jmp done


	noBullets:
		jmp done

	killAsteroid:
		call knockOutAsteroids
		jmp done

	killShip:
		mov bl, 99
		mov bombCount, bl
		jmp done



stopGame:
	mov tempByte, 44
	jmp done
noInput:
	;nothing

mov eax, 100
call delay

done:


ret
handleInput ENDP

knockOutAsteroids PROC

mov bl, bombCount
cmp bl, 0
je done

mov eax, score
add score, eax

mov eax, 4
call randomRange
inc eax
mov cl, al	
cmp cl, 1
je blowUp1
cmp cl, 2
je blowUp2
cmp cl, 3
je blowUp3
cmp cl, 4
je blowUp4	;picks a random one to destroy

jmp done

blowUp1:
mov esi, offset asteroid1
call get5th
mov al, 1
mov [esi], al
dec asteroidsOnScreen
dec bombCount


jmp done

blowUp2:
mov esi, offset asteroid2
call get5th
mov al, 1
mov [esi], al
dec asteroidsOnScreen
dec bombCount

jmp done

blowUp3:
mov esi, offset asteroid2
call get5th
mov al, 1
mov [esi], al
dec asteroidsOnScreen
dec bombCount

jmp done

blowUp4:
mov esi, offset asteroid1
call get5th
mov al, 1
mov [esi], al
dec asteroidsOnScreen
dec bombCount

jmp done

done:





ret
knockOutAsteroids ENDP




initializeShip		PROC	;sets up playership
mov esi, offset playerShip
mov al, 10
mov [esi], al	;x and y start at 40
inc esi
mov [esi], al
inc esi
mov al, north
mov [esi], al	;north = 0
inc esi
mov al, 0
mov [esi], al	;velocity = 0
inc esi
mov al, 0
mov [esi], al	; is Destroyed = 0
inc esi
mov [esi], al	;hasCollided = 0
inc esi
mov al, 2
mov [esi], al	;width = 2
inc esi
mov al, 2
mov [esi], al	; height = 2


ret
initializeShip ENDP

updateShip PROC

mov esi, offset playerShip
call get3rd
mov al, 0
cmp [esi], al
jg moveShip
jmp done

moveShip:
	mov esi, offset playerShip
	call get2nd
	mov al, 0
	cmp [esi], al		;if north 0
	je moveNorth
	inc al
	cmp [esi], al		;if east 1
	je moveEast
	inc al
	cmp [esi], al
	je moveSouth
	inc al
	cmp [esi], al
	je moveWest
	jmp done

	moveNorth:
		mov esi, offset playerShip
		call get1st
		mov al, 1
		add [esi], al
		call collisionWithScreenEdgeShip
		jmp done
		
	moveEast:
		mov esi, offset playerShip
		mov al, 1
		add [esi], al
		mov al, 79
		cmp [esi], al
		je wrapAroundXRight
		jmp done
		
	moveSouth:
		mov esi, offset playerShip
		call get1st
		mov al, 1
		sub [esi], al
		mov al, 5
		cmp [esi], al
		call collisionWithScreenEdgeShip
		;je wrapAroundYTop
		jmp done
		
		
	moveWest:
		mov esi, offset playerShip
		mov al, 1
		sub [esi], al
		mov al, 0
		cmp [esi], al
		je wrapAroundXLeft
		jmp done


	WrapAroundYTop:			;looks wierd dosn't work well oussama had same issue
		mov al, 0
		mov [esi], al
		jmp done

	wrapAroundYBot:
		mov al, 5
		mov [esi], al
		inc bombCount
		inc bombCount
		jmp done


	wrapAroundXRight:
		mov al, 0
		mov [esi], al
		inc bombCount
		jmp done

	wrapAroundXLeft:
		mov al, 79
		mov [esi], al
		jmp done



done:
	
ret
updateShip ENDP

drawShip PROC

mov esi, offset playerShip	;goes to ships coordinates
mov dl, [esi]
inc esi
mov dh, [esi]
call gotoxy
inc esi

mov bl, north	;finds the direction ship is pointing in
cmp [esi], bl
je northDir

mov bl, east
cmp [esi], bl
je eastDir

mov bl, south
cmp [esi], bl
je southDir

mov bl, west
cmp [esi], bl
je westDir

northDir:
	mov eax, 86		;V
	call writeChar
	jmp done

eastDir:
	mov eax, 62		;>
	call writeChar
	jmp done

southDir:
	mov eax, 94		;^
	call writeChar
	jmp done

westDir:
	mov eax, 60		;<
	call writeChar
	jmp done

done:


ret
drawShip ENDP

initializeBullet	PROC
mov esi, offset bullet1
mov edi, offset playerShip

setBullet1:
	mov al, [edi]
	mov [esi], al	;bulletx = shipx

	inc edi
	inc esi

	mov al, [edi]
	mov [esi], al	;bullety = shipy initially

	inc esi
	inc edi

	mov al, [edi]	;direction is the same
	mov [esi], al

	inc esi
	mov al, 0
	mov [esi], al	;velocity = 0

	inc esi
	mov [esi], al	;isFired = 0

	inc esi
	mov [esi], al	;Collided = 0

	inc esi
	mov al, 1
	mov [esi], al	;width =1

	inc esi
	mov[esi], al	;height = 1

setBullet2:
	mov esi, offset bullet2
	mov edi, offset playerShip
	mov al, [edi]
	mov [esi], al	;bulletx = shipx

	inc edi
	inc esi

	mov al, [edi]
	mov [esi], al	;bullety = shipy initially

	inc esi
	inc edi

	mov al, [edi]	;direction is the same
	mov [esi], al

	inc esi
	mov al, 0
	mov [esi], al	;velocity = 0

	inc esi
	mov [esi], al	;isFired = 0

	inc esi
	mov [esi], al	;Collided = 0

	inc esi
	mov al, 1
	mov [esi], al	;width =1

	inc esi
	mov[esi], al	;height = 1
	

ret
initializeBullet	ENDP

updateBullets PROC		;checks if bullets are fired
				;if they are then it updates their positions
				;then it checks if they go off the screen
				;if either do then it gets reset

checkBullet1:
mov esi, offset bullet1
call get4th
mov al, 1
cmp [esi], al			;checks if bullet 1 is fired
je updateBullet1		;if its fired jump to update it
mov esi, offset bullet1
call resetBullet		;else update where it should be and check bullet2
jmp checkBullet2

checkBullet2:
mov esi, offset bullet2
call get4th
mov al, 1
cmp [esi], al
je updateBullet2
mov esi, offset bullet2
call resetBullet			;if the bullet isn't fired
jmp checkCollisions

updateBullet1:
	mov esi, offset bullet1
	call get2nd
	mov al, 0
	cmp [esi], al		;if north 0
	je bullet1North
	inc al
	cmp [esi], al		;if east 1
	je bullet1East
	inc al
	cmp [esi], al
	je bullet1South
	inc al
	cmp [esi], al
	je bullet1West

	bullet1North:
		mov esi, offset bullet1
		call get1st
		mov al, 2
		add [esi], al
		jmp checkBullet2	
	bullet1East:
		mov esi, offset bullet1
		mov al, 2
		add [esi], al
		jmp checkBullet2
	bullet1South:
		mov esi, offset bullet1
		call get1st
		mov al, 2
		sub[esi], al
		jmp checkBullet2
	bullet1West:
		mov esi, offset bullet1
		mov al, 2
		sub[esi], al
		jmp checkBullet2

jmp checkBullet2

updateBullet2:
	mov esi, offset bullet2
	call get2nd
	mov al, 0
	cmp [esi], al		;if north 0
	je bullet2North
	inc al
	cmp [esi], al		;if east 1
	je bullet2East
	inc al
	cmp [esi], al
	je bullet2South
	inc al
	cmp [esi], al
	je bullet2West

	bullet2North:
		mov esi, offset bullet2
		call get1st
		mov al, 2
		add [esi], al	
		jmp checkCollisions
	bullet2East:
		mov esi, offset bullet2
		mov al, 2
		add [esi], al
		jmp checkCollisions
	bullet2South:
		mov esi, offset bullet2
		call get1st
		mov al, 2
		sub[esi], al
		jmp checkCollisions
	bullet2West:
		mov esi, offset bullet2
		mov al, 2
		sub[esi], al

jmp checkCollisions

checkCollisions:

call collisionWithScreenEdgeBullets		;checks and resets bullets if they are offscreen


ret
updateBullets ENDP

drawBullets	PROC

checkBullet1:
mov esi, offset bullet1
call get4th			;checks if bullet is fired
mov al, 1
cmp [esi], al
je drawBullet1
jmp checkBullet2

checkBullet2:
mov esi, offset bullet2
call get4th			;checks if bullet is fired
mov al, 1
cmp [esi], al
je drawBullet2

jmp done

drawBullet1:
	mov esi, offset bullet1
	mov dl, [esi]
	inc esi
	mov dh, [esi]
	call gotoxy
	mov eax, 39
	call writeChar
	jmp checkBullet2

drawBullet2:
	mov esi, offset bullet2
	mov dl, [esi]
	inc esi
	mov dh, [esi]
	call gotoxy
	mov eax, 39
	call writeChar
	jmp done

done:

ret
drawBullets ENDP

initializeAsteroid	PROC	;asteroid in esi

mov eax, SCREEN_WIDTH
call RandomRange
mov [edi], al
inc edi			;x coord starts between 0 and 79 or close

mov eax, SCREEN_HEIGHT
call RandomRange
mov [edi], al
inc edi			;y coord between 0 and 40

mov al, 8		;direction set between 1 and 8
call RandomRange
mov [edi], al
inc edi

mov al, 2		; velocity between 1 and 2
call RandomRange
inc al
mov [edi], al
inc edi

mov al, 1
mov [edi], al
inc edi			;drawToScreen = 1

mov al, 0
mov [edi], al
inc edi			;Collision = 0

mov al, 5
mov [edi], al		;width = 5
inc edi

mov [edi], al		;height = 5
inc edi

mov al, 0		;isBroken = 0
mov [edi], al


ret
initializeAsteroid	ENDP

updateAsteroid	PROC		;in edi so I can decrement it
inc edi
inc edi
inc edi
inc edi		;goes to byte4
mov bl, [edi]
dec edi
dec edi
dec edi
dec edi
mov al, 1
cmp bl, al		;checks to see if it should update
je update
jmp done

update:


mov dl, [edi]		;xcoord
inc edi
mov dh, [edi]		;ycoord
inc edi
mov al, [edi]		;direction
inc edi
mov ah, [edi]		;velocity

dec edi
dec edi
dec edi			; back to 0th byte

cmp al, 0
je moveNorth
cmp al, 1
je moveNorthEast
cmp al, 2
je moveEast
cmp al, 3
je moveSouthEast
cmp al, 4
je moveSouth
cmp al, 5
je moveSouthWest
cmp al, 6
je moveWest
cmp al, 7
je moveNorthWest

moveNorth:
	inc edi
	add [edi], ah
	jmp checkCollisions

moveNorthEast:
	add [edi], ah
	inc edi
	add [edi], ah
	jmp checkCollisions

moveEast:
	add [edi], ah
	inc edi
	jmp checkCollisions

moveSouthEast:
	add [edi], ah
	inc edi
	sub [edi], ah
	jmp checkCollisions

moveSouth:
	inc edi
	sub [edi], ah
	jmp checkCollisions

moveSouthWest:
	sub [edi], ah
	inc edi
	sub [edi], ah
	jmp checkCollisions

moveWest:
	sub [edi], ah
	inc edi
	jmp checkCollisions

moveNorthWest:
	sub [edi], ah
	inc edi
	add [edi], ah
	jmp checkCollisions


checkCollisions:


dec edi		;asteroid should be at 0th spot

mov esi, offset asteroid1
call collisionWithScreenEdgeAsteroid
mov esi, offset asteroid2
call collisionWithScreenEdgeAsteroid

inc edi
inc edi
inc edi
inc edi
inc edi			; at byte5
mov al, 1
cmp [edi], al
je breakAsteroid
jmp done

breakAsteroid:
inc edi
inc edi
inc edi			;at is broken
mov al, 1
cmp [edi], al
je destroyAsteroid		;if its already a small one
mov al, 0
cmp [edi], al
je destroyAsteroid			;if its not a small one
jmp done

destroyAsteroid:

dec edi
dec edi
dec edi
dec edi	;at isDestroyed byte 4
mov al, 0
mov [edi], al
jmp done






;call collisionWithBullet
;call collisionWithShip
;call collisionWithEdge
done:

ret
updateAsteroid	ENDP

drawAsteroid	PROC	;asteroid must be in edi to decrement
inc edi
inc edi
inc edi
inc edi		;goes to byte4
mov bl, [edi]
inc edi
mov cl, [edi]	;hasCollidied in cl
dec edi
dec edi
dec edi
dec edi
dec edi
mov al, 1
cmp bl, al
je draw
cmp cl, al
je drawExp
jmp done

drawExp:
mov bl, [edi]
inc edi
mov bh, [edi]
push ebx
pop edx
call gotoxy
mov edx, offset expL1
call writeString
push ebx
pop edx
inc dh
call gotoxy
mov edx, offset expL2
call writeString
push ebx
pop edx
inc dh
inc dh
call gotoxy
mov edx, offset expL3
call writeString
jmp done


draw:
mov bl, [edi]		;xcoord
inc edi
mov bh, [edi]		;ycoord
inc edi
inc edi
inc edi
inc edi
inc edi
inc edi
inc edi		;at isBroken
mov al, 1
cmp [edi], al

je drawSmallAsteroid
jmp drawBigAsteroid


drawSmallAsteroid:
			;puts the correct coordinates into dl and dh
push ebx
pop edx
call gotoxy
mov edx, offset topOfSmallAsteroid
call writeString
push ebx
pop edx
inc dh
call gotoxy
mov edx, offset midOfSmallAsteroid
call writeString
push ebx
pop edx
inc dh
inc dh
call gotoxy
mov edx, offset botOfSmallAsteroid
call writeString
jmp done


drawBigAsteroid:
push ebx			;puts the correct coordinates into dl and dh
pop edx
call gotoxy
mov edx, offset topOfBigAsteroid
call writeString
push ebx
pop edx
inc dh
call gotoxy
mov edx, offset midOfBigAsteroid
call writeString
push ebx
pop edx
inc dh
inc dh
call gotoxy
mov edx, offset botOfBigAsteroid
call writeString

;mov eax, 1000
;call delay

jmp done


done:

ret
drawAsteroid ENDP


getRandom PROC

mov eax, numRange
call RandomRange
push eax

ret
getRandom ENDP




get0th	PROC	;moves offset to the byte1 of object before calling these push the offset to the stack


;mov eax, [esi]



ret
get0th	ENDP

get1st	PROC


inc esi
;mov al, [esi]

ret
get1st	ENDP

get2nd		PROC


inc esi
inc esi
;mov al, [esi]

ret
get2nd		ENDP

get3rd		PROC

inc esi
inc esi
inc esi
;mov al, [esi]

ret
get3rd		ENDP

get4th	PROC


inc esi
inc esi
inc esi
inc esi
;mov al, [esi]
ret
get4th ENDP

get5th PROC

inc esi
inc esi
inc esi
inc esi
inc esi
;mov al, [esi]
ret
get5th ENDP

get6th PROC

inc esi
inc esi
inc esi
inc esi
inc esi
inc esi
;mov al, [esi]
ret
get6th ENDP

get7th PROC

inc esi
inc esi
inc esi
inc esi
inc esi
inc esi
inc esi
;mov al, [esi]
ret
get7th ENDP

get8th PROC

inc esi
inc esi
inc esi
inc esi
inc esi
inc esi
inc esi
;mov al, [esi]
ret
get8th ENDP


printVals PROC

mov bl, 10

printValLoop:

	mov eax, 0
	mov al, [esi]
	call writeDec
	call crlf
	inc esi
	dec bl
	cmp bl, 0
	je done
	jmp printValLoop

done:

ret
printVals ENDP

collisionWithScreenEdgeShip PROC	

mov esi, offset playerShip
call get1st
mov al, 41
cmp [esi], al
jg wrapAroundBot
mov al, 0
cmp [esi], al
jl wrapAroundTop
jmp done

wrapAroundTop:

	mov al, 40
	mov [esi], al	;yCoord = 45
	jmp done

wrapAroundBot:

	mov al, 0
	mov [esi], al
	jmp done
done:

ret
collisionWithScreenEdgeShip ENDP

collisionWithScreenEdgeBullets PROC


checkBullet1:
mov esi, offset bullet1		;this is for the first bullet to check if it should be destroyed
mov al, 0
cmp [esi], al
jl resetBullet1
mov al, 79
cmp [esi], al
jg resetBullet1				;these 2 check the x coords

inc esi
mov al, 0
cmp [esi], al
jl resetBullet1
mov al, 40
cmp [esi], al
jg resetBullet1		;these 2 compare y coords to the screen edge


checkBullet2:

mov esi, offset bullet2		;this is for the first bullet to check if it should be destroyed
mov al, 0
cmp [esi], al
jl resetBullet2

mov al, 79
cmp [esi], al
jg resetBullet2			;these 2 check the x coords

inc esi
mov al, 0
cmp [esi], al
jl resetBullet2
mov al, 40
cmp [esi], al
jg resetBullet2		;check y coords

jmp done


resetBullet1:
mov esi, offset bullet1
call resetBullet
jmp checkBullet2

resetBullet2:
mov esi, offset bullet2		;resets all vals of bullet to initial vals
call resetBullet
jmp done


done:


ret
collisionWithScreenEdgeBullets ENDP

collisionWithScreenEdgeAsteroid PROC		;asteroid in esi


checkX:			;checks if the right edge of the asteroid is left of 0
mov al, 1
cmp [esi], al
jl wrapToRight

mov al, 80
cmp [esi], al
jg wrapToLeft

checkY:
inc esi
mov al, 0
cmp [esi], al
jl wrapToBot

mov al, 40
cmp [esi], al
jg wrapToTop



jmp done

wrapToRight:
	mov al, 80
	mov [esi], al
	jmp done

wrapToLeft:
	mov al, 0
	mov [esi], al
	jmp done

wrapToBot:
	mov al, 40
	mov [esi], al
	jmp done
wrapToTop:
	mov al, 0
	mov [esi], al
	jmp done


done:
;call dumpregs

ret
collisionWithScreenEdgeAsteroid ENDP


collisionBulletAndAsteroid PROC

ret
collisionBulletAndAsteroid ENDP

collisionShipAndAsteroid PROC

ret
collisionShipAndAsteroid ENDP

resetBullet	PROC		;bullet offset must be in esi
mov edi, offset playerShip

mov al, [edi]
mov [esi], al		;resets x coord to shipx

inc esi
inc edi

mov al, [edi]
mov [esi], al		;ycoord to shipy

inc esi
inc edi

mov al, [edi]
mov [esi], al		;direction reset to ships

inc esi
mov al, 0
mov [esi], al		;resets velocity to 0

inc esi
mov [esi], al		;resets isFired to 0

ret
resetBullet ENDP

updateAllAsteroids	PROC

mov edi, offset asteroid1
call updateAsteroid
mov edi, offset asteroid2
call updateAsteroid
mov edi, offset asteroid3
call updateAsteroid
mov edi, offset asteroid4
call updateAsteroid
mov edi, offset asteroid5
call updateAsteroid
mov edi, offset asteroid6
call updateAsteroid
mov edi, offset asteroid7
call updateAsteroid
mov edi, offset asteroid8
call updateAsteroid
mov edi, offset asteroid9
call updateAsteroid


ret
updateAllAsteroids ENDP

drawAllAsteroids	PROC
mov edi, offset asteroid1
call drawAsteroid
mov edi, offset asteroid2
call drawAsteroid
mov edi, offset asteroid3
call drawAsteroid
mov edi, offset asteroid4
call drawAsteroid
mov edi, offset asteroid5
call drawAsteroid
mov edi, offset asteroid6
call drawAsteroid
mov edi, offset asteroid7
call drawAsteroid
mov edi, offset asteroid8
call drawAsteroid
mov edi, offset asteroid9
call drawAsteroid



ret
drawAllAsteroids	ENDP

getNextAvailableAsteroid	PROC	;this will be used whenever an asteroid needs to be created

mov al, 0

checkA1:
mov esi, offset asteroid1
call get4th
cmp [esi], al
je init1

checkA2:
mov esi, offset asteroid2
call get4th
cmp [esi], al
je init2

checkA3:
mov esi, offset asteroid3
call get4th
cmp [esi], al
je init3

checkA4:
mov esi, offset asteroid4
call get4th
cmp [esi], al
je init4

checkA5:
mov esi, offset asteroid5
call get4th
cmp [esi], al
je init5

checkA6:
mov esi, offset asteroid6
call get4th
cmp [esi], al
je init6

checkA7:
mov esi, offset asteroid7
call get4th
cmp [esi], al
je init7

checkA8:
mov esi, offset asteroid8
call get4th
cmp [esi], al
je init8

checkA9:
mov esi, offset asteroid9
call get4th
cmp [esi], al
je init9

jmp done

init1:
	mov edi, offset asteroid1		;sets edi to the next available asteroid
	jmp done

init2:
	mov edi, offset asteroid2
	jmp done

init3:
	mov edi, offset asteroid3
	jmp done

init4:
	mov edi, offset asteroid4
	jmp done

init5:
	mov edi, offset asteroid5
	jmp done

init6:
	mov edi, offset asteroid6
	jmp done

init7:
	mov edi, offset asteroid7
	jmp done

init8:
	mov edi, offset asteroid8
	jmp done

init9:
	mov edi, offset asteroid9
	jmp done


done:

ret
getNextAvailableAsteroid	ENDP

exitgame PROC
call Clrscr
	mov  ecx,COUNT	

bamboo:	mov  eax,25	
	call RandomRange
	mov  dh,al
	mov  eax,120
	call RandomRange
	mov  dl,al
	call Gotoxy	
	mov  al,CHAR_VAL	
	call WriteChar
	call RandomDelay	
	loop bamboo	

	mov dx,0	
	call Gotoxy

	ret
exitgame ENDP
RandomDelay PROC
push eax

			
add  eax,1	
call Delay	

pop  eax
ret
RandomDelay ENDP

initializeSmallAsteroid PROC

pop ebx

mov [edi], bl
inc edi			;x coord starts between 0 and 79 or close


mov [edi], bh
inc edi			;y coord between 0 and 40

mov al, 8		;direction set between 1 and 8
call RandomRange
mov [edi], al
inc edi

mov al, 2		; velocity between 1 and 2
call RandomRange
inc al
mov [edi], al
inc edi

mov al, 1
mov [edi], al
inc edi			;drawToScreen = 1

mov al, 0
mov [edi], al
inc edi			;Collision = 0

mov al, 6
mov [edi], al		;width = 5
inc edi

mov al, 3
mov [edi], al		;height = 5
inc edi

mov al, 1		;isBroken = 0
mov [edi], al


ret
initializeSmallAsteroid ENDP



END main