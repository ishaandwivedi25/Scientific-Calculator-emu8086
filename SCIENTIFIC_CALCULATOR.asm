; Scientific calculator
;******* MACRO *******
; this macro get character input without echo to AL
GETCH	MACRO
	mov ah, 7
	int 21h
ENDM

; this macro prints a char in AL and advances
; the current cursor position:
PUTC    MACRO   char
	push    ax
	mov     al, char
	mov     ah, 0eh
	int     10h     
	pop     ax
ENDM
org 100h

.data
	ten	dw	10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.
	
	ToO	db	"Table of Operation:",0dh,0ah
		db	"	Sum (+): 0",0dh,0ah
		db	"	Sub (-): 1",0dh,0ah
		db	"	Mul (*): 2",0dh,0ah
		db	"	Div (/): 3",0dh,0ah
		db	"	X^Y (^): 4",0dh,0ah
		db	"	And (&): 5",0dh,0ah
		db	"	Or  (|): 6",0dh,0ah
		db	"	XOR (^): 7",0dh,0ah
		db	"	Not (~): 8",0dh,0ah
		db	"	Sin (x): 9",0dh,0ah
		db	"	Cos (x): 10",0dh,0ah
		db	"	Tan (x): 11",0dh,0ah
		db	"	Fact(!): 12",0dh,0ah
		db	"	Sqr (^2): 13",0dh,0ah
		db	"	Cube(^3): 14",0dh,0ah
		db	"	BMI: 15",0dh,0ah,24h

	msg_wel db "********* SCIENTIFIC CALCULATOR *********",0dh,0ah
			db "Note: It takes only integer number as input.",0dh,0ah
			db "For trignometry, angle is in Degree unit.",0dh,0ah
			db "For BMI, first number is weight in kilograms and second is Height in meters.",0dh,0ah,24h
	msg_agn db "Press any key to use again or press E to exit.",0dh,0ah,24h
	msg_bye	db "Thank you for using the calculator.$"
	msg_fn	db "Enter first number: $"
	msg_sn	db "Enter second number: $"
	msg_on	db "Enter the operation number [0-15]: $"
	msg_r	db "The result is: $"
	msg_und	db "Infinity.$"
	
	msg_on_i db "Invalid operation number. See Table of Operation for more information.$"
	
	operand1 dw ?
	operand2 dw ?
	operator db ?
	result	 dw ?,?,?		;store upto 32-bit
	
	;lookup table for Trigonometric functions, made using excel, giving a formula and extending the table
	sin	dw 0000,0175,0349,0523,0698,0872,1045,1219,1392,1564,1736,1908,2079,2250,2419,2588,2756,2924,3090,3256,3420,3584,3746,3907,4067,4226,4384,4540,4695,4848,5000,5150,5299,5446,5592,5736,5878,6018,6157,6293,6428,6561,6691,6820,6947,7071,7193,7314,7431,7547,7660,7771,7880,7986,8090,8192,8290,8387,8480,8572
		dw 8660,8746,8829,8910,8988,9063,9135,9205,9272,9336,9397,9455,9511,9563,9613,9659,9703,9744,9781,9816,9848,9877,9903,9925,9945,9962,9976,9986,9994,9998,0000,9998,9994,9986,9976,9962,9945,9925,9903,9877,9848,9816,9781,9744,9703,9659,9613,9563,9511,9455,9397,9336,9272,9205,9135,9063,8988,8910,8829,8746
		dw 8660,8572,8480,8387,8290,8192,8090,7986,7880,7771,7660,7547,7431,7314,7193,7071,6947,6820,6691,6561,6428,6293,6157,6018,5878,5736,5592,5446,5299,5150,5000,4848,4695,4540,4384,4226,4067,3907,3746,3584,3420,3256,3090,2924,2756,2588,2419,2250,2079,1908,1736,1564,1392,1219,1045,0872,0698,0523,0349,0175
		dw 0000,0175,0349,0523,0698,0872,1045,1219,1392,1564,1736,1908,2079,2250,2419,2588,2756,2924,3090,3256,3420,3584,3746,3907,4067,4226,4384,4540,4695,4848,5000,5150,5299,5446,5592,5736,5878,6018,6157,6293,6428,6561,6691,6820,6947,7071,7193,7314,7431,7547,7660,7771,7880,7986,8090,8192,8290,8387,8480,8572
		dw 8660,8746,8829,8910,8988,9063,9135,9205,9272,9336,9397,9455,9511,9563,9613,9659,9703,9744,9781,9816,9848,9877,9903,9925,9945,9962,9976,9986,9994,9998,0000,9998,9994,9986,9976,9962,9945,9925,9903,9877,9848,9816,9781,9744,9703,9659,9613,9563,9511,9455,9397,9336,9272,9205,9135,9063,8988,8910,8829,8746
		dw 8660,8572,8480,8387,8290,8192,8090,7986,7880,7771,7660,7547,7431,7314,7193,7071,6947,6820,6691,6561,6428,6293,6157,6018,5878,5736,5592,5446,5299,5150,5000,4848,4695,4540,4384,4226,4067,3907,3746,3584,3420,3256,3090,2924,2756,2588,2419,2250,2079,1908,1736,1564,1392,1219,1045,0872,0698,0523,0349,0175
	tan dw 0,0000,0,0175,0,0349,0,0524,0,0699,0,0875,0,1051,0,1228,0,1405,0,1584,0,1763,0,1944,0,2126,0,2309,0,2493,0,2679,0,2867,0,3057,0,3249,0,3443,0,3640,0,3839,0,4040,0,4245,0,4452,0,4663,0,4877,0,5095,0,5317,0,5543
		dw 0,5774,0,6009,0,6249,0,6494,0,6745,0,7002,0,7265,0,7536,0,7813,0,8098,0,8391,0,8693,0,9004,0,9325,0,9657,1,0000,1,0355,1,0724,1,1106,1,1504,1,1918,1,2349,1,2799,1,3270,1,3764,1,4281,1,4826,1,5399,1,6003,1,6643
		dw 1,7321,1,8040,1,8807,1,9626,2,0503,2,1445,2,2460,2,3559,2,4751,2,6051,2,7475,2,9042,3,0777,3,2709,3,4874,3,7321,4,0108,4,3315,4,7046,5,1446,5,6713,6,3138,7,1154,8,1443,9,5144,11,4301,14,3007,19,0811,28,6363,57,2900
		dw 65535,0000
	
.code
main PROC
	mov ax,@data
	mov ds,ax
	
	call welcome
start_again:
	xor ax,ax
	mov result,ax
	mov [result+2],ax
	mov [result+4],ax
	call print_ToO
	call input_op1
	call input_operator
	
	;checks for unary operator
	mov al,operator
	cmp al,8
	je c8
	cmp al,9
	je c9
	cmp al,10
	je c10
	cmp al,11
	je c11
	cmp al,12
	je c12
	cmp al,13
	je c13
	cmp al,14
	je c14
binary_operator:
	call input_op2
	;checks for binary operator
	mov al,operator
	cmp al,0
	je c0
	cmp al,1
	je c1
	cmp al,2
	je c2
	cmp al,3
	je c3
	cmp al,4
	je c4
	cmp al,5
	je c5
	cmp al,6
	je c6
	cmp al,7
	je c7
	cmp al,15
	je c15
	
c0:
	call addition
	jmp ans
c1:
	call substract
	jmp ans
c2:
	call multiply
	jmp ans
c3:
	call divide
	jmp ans
c4:
	call power
	jmp ans
c5:
	call anding
	jmp ans
c6:
	call oring
	jmp ans
c7:
	call xoring
	jmp ans
c8:
	call complement
	jmp ans
c9:
	call sine
	jmp ans
c10:
	call cosine
	jmp ans
c11:
	call tangent
	jmp ans
c12:
	call factorial
	jmp ans
c13:
	mov cx,2
	mov operand2, cx
	call power
	jmp ans
c14:
	mov cx,3
	mov operand2, cx
	call power
	jmp ans
c15:
	call bmi
	jmp ans
ans:
	call print_result
	GETCH
	cmp al,'e'
	je exit
	cmp al,'E'
	je exit
	jmp start_again
	
exit:	
	call good_bye
;Exit the program
    mov     ax,4c00h
    int     21h
main endp

;******** Procedures ********

;function to print messages at start of calculator done by 18BCE0658
welcome PROC
	mov dx, offset msg_wel
	mov ah, 9
	int 21h
	ret
welcome endp

good_bye PROC
	call new_line
	mov dx, offset msg_bye
	mov ah, 9
	int 21h
	ret
good_bye endp

;function to print table of operation
print_ToO PROC
	call new_line
	mov dx, offset ToO
	mov ah, 9
	int 21h
	ret
print_ToO endp

print_result PROC
	call new_line
	mov dx, offset msg_r
	mov ah, 9
	int 21h
	
	cmp operator,9
	jl r_simple
	cmp operator,15
	je r_simple
	cmp [result+4],1
	jne r_simple
	PUTC '-'	
r_simple:		;simple result
	mov ax, result
	cmp ax,65535
	jne r_num
	cmp operator,11
	jne r_num
	;print infinity only if tan(90)
	mov dx, offset msg_und
	mov ah, 9
	int 21h
	jmp r_done
r_num:
	call print_num
	
	cmp [result+2],0
	je r_done
	PUTC '.'
	mov ax,[result+2]
	cmp ax,999
	jg r_dec
	cmp operator,9
	jl r_dec
	cmp operator,15
	je r_dec
	PUTC '0'
r_dec:	
	call print_num
	
r_done:
	call new_line
	mov dx, offset msg_agn
	mov ah, 9
	int 21h
	ret
print_result endp

;function to move cursor to new line
new_line PROC
	putc 0Dh
	putc 0Ah
	ret
new_line endp

;function to input first operand
input_op1 PROC
	call new_line
	mov dx, offset msg_fn
	mov ah, 9
	int 21h
	
	call scan_num
	mov operand1, cx
	
	ret
input_op1 endp

;function to input second operand
input_op2 PROC
	call new_line
	mov dx, offset msg_sn
	mov ah, 9
	int 21h
	
	call scan_num
	mov operand2, cx
	
	ret
input_op2 endp

;function to input operator
input_operator PROC
	call new_line
	mov dx, offset msg_on
	mov ah, 9
	int 21h
	
	call scan_num
	mov operator, cl
	
	cmp cl,16
	jb return_io

	call new_line
	mov dx, offset msg_on_i
	mov ah, 9
	int 21h
	call input_operator
	
return_io:	
	ret             
	
input_operator endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;CALCULATIONS OF ALL THE OPERATORS DONE BY 18BCE0658, 18BCE0717;;;;;;;;;;;;;;;;;;;;;;;;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;function to add two operand
;and store in result variable
addition PROC
	mov ax,operand1
	add ax,operand2
	mov result,ax
	ret
addition endp

;function to subtract two operand
;and store in result variable
substract PROC
	mov ax,operand1
	sub ax,operand2
	mov result,ax
	ret
substract endp

;function to calculate product of two operand
;and store in result variable
multiply PROC
	mov ax,operand1
	imul operand2
	mov result,ax
	ret
multiply endp

;function to divide of two operand
;and store in result variable
divide PROC
	xor dx,dx
	mov ax,operand1
	idiv operand2
	mov result,ax
	cmp dx,0
	je div_r
	mov ax,dx
	mov bx,10
	mul bx
	idiv operand2
	mov [result+2],ax
div_r:
	ret
divide endp

;function to calculate exponent of two operand
;and store in result variable
power PROC
	mov ax,operand1
	mov cx,operand2
	cmp cx,0
	je power_sc
	power_l:
		dec cx
		cmp cx,1
		jl power_r
		imul operand1
	jmp power_l
	power_sc:
		mov ax,1
	power_r:
		mov result,ax
	ret
power endp

;function to find AND of two operand
;and store in result variable
anding PROC
	mov ax,operand1
	and ax,operand2
	mov result,ax
	ret
anding endp

;function to find OR of two operand
;and store in result variable
oring PROC
	mov ax,operand1
	or ax,operand2
	mov result,ax
	ret
oring endp

;function to find XOR of two operand
;and store in result variable
xoring PROC
	mov ax,operand1
	xor ax,operand2
	mov result,ax
	ret
xoring endp

;function to find complement(additive inverse) of operand1
;and store in result variable
complement PROC
	mov ax,operand1
	not ax
	inc ax
	mov result,ax
	ret
complement endp

;function to find sine of operand1
;and store in result variable
sine PROC
	mov bx,operand1
	cmp bx,0
	jl sine_in
	
	sine_ip:		;invalid positive angle
		cmp bx,360
		jl sine_v
		sub bx,360
	jmp sine_ip
	sine_in:		;invalid negative angle
		cmp bx,0
		jge sine_v
		add bx,360
	jmp sine_in
	
	
	sine_v:			;valid angle (0 >= angle < 360)
		cmp bx,90
		je sine1
		cmp bx,270
		je sine1
		jmp sine0
		sine1:
			mov ax,1
			mov result,ax		
		sine0:
			mov ax,bx
			mov cx,2
			mul cx
			mov bx,ax
			mov ax,[sin+bx]
			mov [result+2],ax
			cmp bx,360
			jle sine_r
			mov ax,1
			mov [result+4],ax
	sine_r:	
	ret
sine endp

;function to find cosine of operand1
;and store in result variable
cosine PROC
	add operand1,90
	call sine
	ret
cosine endp

;function to find tangent of operand1
;and store in result variable
tangent PROC
	mov bx,operand1
	cmp bx,0
	jl tan_in
	
	tan_ip:		;invalid positive angle
		cmp bx,180
		jl tan_v
		sub bx,180
	jmp tan_ip
	tan_in:		;invalid negative angle
		cmp bx,0
		jge tan_v
		add bx,180
	jmp tan_in
		
tan_v:			;valid angle (0 >= angle < 180)
	cmp bx,90
	jle tan_p
	mov ax,180
	sub ax,bx
	mov bx,ax
	mov ax,1
	mov [result+4],ax
	tan_p:
		mov ax,bx
		mov cx,4
		mul cx
		mov bx,ax
		mov ax,[tan+bx]
		mov result,ax
		add bx,2
		mov ax,[tan+bx]
		mov [result+2],ax
	ret
tangent endp

;Function to calculate factorial of operand1
factorial PROC
	; factorial of 0 = 1:
	mov ax, 1
	cmp operand1, 0
	je fact_ret

	; move the number to bx:
	; cx will be a counter:

	mov cx, operand1
	mov ax, 1
	mov bx, 1
	fact_calc:
		mul bx
		inc bx
	loop fact_calc

	fact_ret:
	mov result, ax
	ret
factorial endp

;Function to calculate BMI
bmi PROC
	;BMI = weight/(height)^2
	mov ax,operand1
	push ax			;store weight into stack
	mov ax,operand2
	mov operand1,ax
	mov cx,2
	mov operand2, cx
	call power		;get height square in result
	mov ax,result
	mov operand2,ax
	pop ax			;restore weight from stack
	mov operand1,ax
	call divide
	ret
bmi endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; These functions are copied from emu8086.inc and added in order by 18BCE2027 ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP


; this procedure prints number in AX,
; used with PRINT_NUM_UNS to print signed numbers:
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; the check SIGN of AX,
        ; make absolute if it's negative:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP


; this procedure prints out an unsigned
; number in AX (not just a single digit)
; allowed values are from 0 to 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP

END main