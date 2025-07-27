.section .note.GNU-stack,"",%progbits

.global main

@ External functions used
.extern printf
.extern scanf
.extern sscanf
.extern system
.extern getchar

.section .data	@ Initialised data memory

@------------------------------------------------------------------------
@ Greeting messages----------------------------

welcome: 	.asciz "====================================================\n================Welcome to G88 Shell================\n====================================================\nEnter 'start' to start the shell session...\n"
leave:		.asciz "====================================================\n============Thank you for using G88 Shell===========\n====================================================\n"

@------------------------------------------------------------------------

getstr:		.asciz "%199[^\n]"
shellstart: 	.asciz "start"
invstart:	.asciz "Invalid command.\nEnter 'start' to start PeraCom shell or 'exit' to exit the program\n"
invcmd:		.asciz "Invalid command\n"
shellexit:	.asciz "exit"
prompt: 	.asciz "shell> "

@--------------------------------Hello-----------------------------------
hello:		.asciz "hello"
say_hello:	.asciz "Hello user!\n"

@------------------------------Show time---------------------------------

time_cmd:    	.asciz "time"

@--------------------------------Help------------------------------------

help_cmd:    	.asciz "help"
help_list:   	.asciz "clear:\t\tClear shell\nexit:\t\tExit shell\nhello:\t\tGreetings!\nhelp:\t\tHelp menu\nhex n:\t\tGet the hexadecimal value of an integer n (0 < n < 2,147,483,646)\ntime:\t\tShow current system time\nfact n:\t\tFactorial of integer n (0 < n < 13)\nlen string:\tShow the number of characters in the string excluding spaces\n"

@------------------------------Clear shell-------------------------------

clear_cmd:  	.asciz "clear"
clear_path: 	.asciz "/usr/bin/clear"

@-------------------------------Factorial--------------------------------

fact_cmd:	.asciz "%s %d"
fact_str:	.asciz "fact"
fact_result:	.asciz "%d\n"
inv_fact_str:	.asciz "Integer should be in range [0, 12]\n"

@---------------------------------Length---------------------------------

len_cmd:	.asciz "%s %199[^\n]"
len_str:	.asciz "len"
length_result:	.asciz "There are %d characters in the string\n"

@-------------------------------Hexadecimal------------------------------

hex_cmd:	.asciz "%s %d"
hex_str:	.asciz "hex"
hex_result:	.asciz "0x%s\n"
inv_hex_str:	.asciz "Integer should be in range [0, 2147483647]\n"

@------------------------------------------------------------------------
@------------------------------------------------------------------------

.section  .bss	@ Uninitialised data memory

str:		.space 200	@ Make space for the input in bss
first_str:	.space 5	@ Store first command
second_int:  	.space 4	@ Store Second argument
num:		.space 4	@ Store integers
hex_num:	.space 9	@ Store hexadecimal number
hex_num_rv:	.space 9	@ Store reversed hexadecimal number
line:		.space 200	@ Store line of 200 characters
time_val:	.space 4	@ Store time

@------------------------------------------------------------------------
@------------------------------------------------------------------------

.section  .text	@ Text instructions memory

@ ------------------------Start of the shell-----------------------------
main:
	PUSH {r10, lr}	@ Stack is decreased and registers pushed
	LDR r0, =welcome	@ Welcome message
	BL printf

Start:

	LDR r0, =str
	BL ClearStr		@ Clear str data

	LDR r0, =getstr		@ Get the input
	LDR r1, =str
	BL scanf

	MOV r10, r0		@ Get the return the number of inputs into r10
	BL getchar		@ Consume the newline character

	CMP r10, #1
	BNE Start   		@ If input was empty, loop back to the start.
 
	LDR r1, =str
	LDR r2, =shellstart
	BL FuncStrCompare

	CMP r10, #1		@ If input is start go to shell
	BEQ InsideShell

@ Check for exit command
	LDR r1, =str
	LDR r2, =shellexit
	BL FuncStrCompare	@ Compare strings

	CMP r10, #1
	BEQ Exit		@ Branch to the exit

	CMP r10, #0		@ Output of the str comparison
	LDREQ r0, =invstart
	BEQ do_printf

do_printf:
	BL printf
	B Start
		
@--------------------------------------------------------------------------
@----------------------Looping inside the shell----------------------------

InsideShell:

@ Clear all the data before another loop
	LDR r0, =str
	BL ClearStr		
	LDR r0, =first_str
	BL ClearStr	
	LDR r0, =second_int
	BL ClearNum	
	LDR r0, =num
	BL ClearNum		
	LDR r0, =hex_num
	BL ClearNum	
	LDR r0, =hex_num_rv
	BL ClearNum		
	LDR r0, =line
	BL ClearStr		

@ Show prompt
	BL Prompt

@ Get the input string
	LDR r0, =getstr
	LDR r1, =str
	BL scanf	

	MOV r10, r0		@ Get the return the number of inputs into r10
	BL getchar		@ Consume the newline character

	CMP r10, #1
	BNE InsideShell   	@ If input was empty, loop back to the start of the shell
	

@ Check for factorial command
    	@ Parse the input using sscanf(str, "%s %d", first_str, &second_int)
    	LDR r0, =str
    	LDR r1, =fact_cmd
    	LDR r2, =first_str
    	LDR r3, =second_int
    	BL sscanf	

	LDR r1, =first_str
	LDR r2, =fact_str
	BL FuncStrCompare
	CMP r10, #1
	LDREQ r0, =second_int
	BEQ do_Fact

@ Check for hello
	LDR r1, =str
	LDR r2, =hello
	BL FuncStrCompare
	CMP r10, #1
	BEQ do_SayHello

@ Check for clear command
	LDR r1, =str
	LDR r2, =clear_cmd
	BL FuncStrCompare
	CMP r10, #1
	BEQ do_FuncClear

@ Check for help command
	LDR r1, =str
	LDR r2, =help_cmd
	BL FuncStrCompare
	CMP r10, #1
	BEQ do_ShowHelp

@ Check for time command
	LDR r1, =str
	LDR r2, =time_cmd
	BL FuncStrCompare
	CMP r10, #1
	BEQ do_ShowTime
 
@ Check for length command
    	@ Parse the input using sscanf(str, "%s %s", first_str, line)
    	LDR r0, =str
    	LDR r1, =len_cmd
    	LDR r2, =first_str
    	LDR r3, =line
    	BL sscanf	

	LDR r1, =first_str
	LDR r2, =len_str
	BL FuncStrCompare
	CMP r10, #1
	LDREQ r1, =line
	BEQ do_FindLength

@ Check for hex command
    	@ Parse the input using sscanf(str, "%s %d", first_str, &second_int)
    	LDR r0, =str
    	LDR r1, =hex_cmd
    	LDR r2, =first_str
    	LDR r3, =second_int
    	BL sscanf	

	LDR r1, =first_str
	LDR r2, =hex_str
	BL FuncStrCompare
	CMP r10, #1
	LDREQ r0, =second_int
	BEQ do_GetHex


@ Check for exit command
	LDR r1, =str
	LDR r2, =shellexit
	BL FuncStrCompare
	CMP r10, #1
	BEQ Exit

	BL Invalid
	
	B InsideShell

@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@Function Calling if correct commands are given------------------------------
	
do_SayHello:			@ Printing "hello user!"
	LDR r0, =say_hello
	BL printf
	B InsideShell

do_ShowTime:			@ Calling Showtime function
	BL ShowTime
	B InsideShell

do_FuncClear:			@ Calling Clear function
	BL FuncClear
	B InsideShell

do_ShowHelp:
	BL Help
	B InsideShell

do_Fact:
	LDR r0, [r0, #0]
	CMP r0, #13		@ Check if integer if it is larger than 12
	BGE InvFact

	CMP r0, #0		@ Check if a negative integer comes
	BLT InvFact

	BL Fact
	MOV r1, r0
	@MOV r2, r0
	LDR r0, =fact_result
	@LDR r1, =second_int
	@LDR r1, [r1, #0]
	BL printf
	
	B InsideShell
InvFact:
	LDR r0, =inv_fact_str
	BL printf
	B InsideShell

do_GetHex:
	LDR r0, [r0, #0]
	CMP r0, #2147483646	@ Check if integer if it is larger than the limit
	BGT InvHex

	CMP r0, #0		@ Check if a negative integer comes
	BLT InvHex

	BL GetHex

	LDR r0, =hex_result
	LDR r1, =hex_num
	BL printf
	
	B InsideShell
InvHex:
	LDR r0, =inv_hex_str
	BL printf
	B InsideShell

do_FindLength:
	LDR r1, =line
	BL FindLength
	LDR r0, =length_result
	MOV r1, r7
	BL printf
	
	B InsideShell

@--------------------------------------------------------------------------

@ If invalid command comes
Invalid:
	PUSH {lr}
	BL Prompt		@ Printing prompt
	LDREQ r0, =invcmd	
	BEQ do_Invprintf

do_Invprintf:
	BL printf		@ Printing invalid message
	POP {lr}
	BX lr			@ Return back

@----------------------------------------------------------------------------
Exit:
	LDR r0, =leave
	BL printf

    	MOV r0, #0          	@ Return 0 
	POP {r10, lr}	@ Release stack
	BX lr			@ Return (mov pc,lr)

@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Function to show the current time using a direct system call-------------
ShowTime:
    	PUSH {r7, lr}

    	LDR r0, =time_val       @ address of where to store the time
    	MOV r7, #13             @ Move syscall number for time() , 13
    	SVC #0                  @ Kernel trap to execute the system call


    	LDR r0, =time_val       @ r0 = address of the time value (argument for ctime)
    	BL ctime                @ Call the ctime function
    	BL printf		@ Print time

    	POP {r7, lr}
    	BX lr
@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Function to clear screen
FuncClear:
        PUSH   {lr}
        LDR    r0, =clear_path   @ pointer to "/usr/bin/clear"
        BL     system            @ System call
        POP    {lr}
        BX     lr

@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Functions to clear strings and numbers-------------------------------------
ClearStr:    	
	@ Clear str buffer
	PUSH {r5, r6, r7, lr}
    	MOV r5, #0              	@ Pointer r5 for clearing

LoopClearStr:
   	ADD r6, r5, r0	 		@ r6 address = r0 base address + pointer  
    	MOV r7, #0
    	STRB r7, [r6, #0]		@ 0 is stored in the first byte of r6	
    	ADD r5, r5, #1	 		@ pointer ++
    	CMP r5, #200            	@ assuming str size is 200
    	BLT LoopClearStr		@ If pointer < 200 ; loops through 

ExitLoopStr:
	POP {r5, r6, r7, lr}
	BX lr

ClearNum:    	
	@ Clear num buffer
	PUSH {r5, r6, r7, lr}
    	MOV r5, #0              	@ Pointer r9 for clearing

LoopClearNum:
   	ADD r6, r5, r0	 		@ r6 address = r0 base address + pointer  
    	MOV r7, #0
    	STRB r7, [r6, #0]		@ 0 is stored in the first byte of r6	
    	ADD r5, r5, #1	 		@ pointer ++
    	CMP r5, #10              	@ assuming str size is 10
    	BLT LoopClearNum		@ If pointer < 10 ; loops through 
ExitLoopNum:
	POP {r5, r6, r7, lr}
	BX lr

@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Function to compare commands-----------------------------------------------
FuncStrCompare:
	PUSH {r4-r7, lr}	
	MOV r4, #0
LoopCompare:
	ADD r5, r1, r4		
	LDRB r6, [r5, #0]	@ Load byte from str1
	
	ADD r3, r2, r4
	LDRB r7, [r3, #0]	@ Load byte from str2

	CMP r6, r7		@ Compare bytes
	BNE NotEqual

	CMP r6, #0
	ADD r4, r4, #1
	BNE LoopCompare

Equal:
	MOV r10, #1		@ r10 = 1 if equal
	POP {r4-r7, lr}
	BX lr

NotEqual:
	@ If invalid start command comes	
	MOV r10, #0		@ r10 = 0 if invalid
	POP {r4-r7, lr}
	BX lr
		
@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Function to print prompt
Prompt:
	PUSH {lr}
	@ Print prompt (shell >) in every command line
	LDR r0, =prompt
	BL printf

	POP {lr}
	BX lr


@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@Function to calculate factorial---------------------------------------------
Fact:
	PUSH {r4, r5, r6, lr}		

	MOV r4, #1		@ fact(1) is 1	
	MOV r6, #1		@ i = 1
	
	CMP r0, #1		@ if num < 1 
	BLT Else
For:	
	CMP r6, r0		@ Enter the for loop
	BGT Endfor

	MUL r5, r4, r6		@ Multiply fact(n) by n-1
	MOV r4, r5
	ADD r6, r6, #1

	B For

Else:
	MOV r0, #1		@ If num < 1 result is 1
	B ExitFact

Endfor:
	MOV r0, r4		@ Return the result 
	B ExitFact

ExitFact:
	
	POP {r4, r5, r6, lr}
	BX lr			@ Return to the caller

@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Help Function--------------------------------------------------------------

Help:
	PUSH {lr}
	LDR r0, =help_list	@ Loading the text
	BL printf		@ calling printf
	POP {lr}
	BX lr
@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Function to find the length of an input string-------------------------
FindLength:
	PUSH {r5, r6, lr}
    	MOV r5, #0 		@ Pointer r5
	MOV r7, #0		@ count of characters without spaces

LoopFindLength:		
	ADD r2, r5, r1		@ r2 address = r1 base address + pointer 
	LDRB r6, [r2, #0]	@ First byte of r2 is loaded to r6
	
	CMP r6, #' '		
	ADDNE r7, r7, #1	@ Count only increases if the character is not a space

	CMP r6, #0
	BEQ Length 		@ If r6 = 0 ; then calculate the length


	ADD r5, r5, #1		@ Otherwise pointer ++
	B LoopFindLength	@ Loops through FindLength

Length:				@ Calculate the length

	SUB r7, r7, #1		@ Remove the length of null terminator
	POP {r5, r6, lr}
	MOV pc, lr

@--------------------------------------------------------------------------
@--------------------------------------------------------------------------

@ Function to get the hexadecimal value------------------------------------

GetHex:
	PUSH {r4-r10, lr}
	MOV r1, #16		@ Divider is 16

	MOV r9, #0		@ Outer loop count (Hex byte position)
OuterLoop:
	MOV r2, #0		@ Temp Quotient
	MOV r7, r0		@ Making a copy of r0 for the division

LoopDivision:
	CMP r7, r1		@ Exit diviion if r7 < r1
	BLT ExitDiv
	
	SUB r7, r7, r1
	ADD r2, r2, #1
	B LoopDivision		@ loop division

ExitDiv:
	MOV r6, r2		@ Return quotient
	
	MUL r4, r6, r1
	SUB r5, r0, r4		@ Remainder

	BL SetHex		@ Set the qoutient to the corresponding byte of the hexa number
	
	CMP r6, #0
	MOVGT r0, r6		@ Set quotient to divide again by 16
	ADDGT r9, r9, #1
	BGT OuterLoop		@ Find next hex character by looping

	BL ReverseHex		@ Get the correct hexadecimal string

	POP {r4-r10, lr}	
	BX lr			@ Return to the caller of GetHex

@ Reverse the string to get the hexadecimal string-------------------------

ReverseHex:
    	PUSH {r4-r8, lr}

    	LDR r0, =hex_num_rv	    @ base address of string to be reversed
    	LDR r1, =hex_num	    @ base address of destination string

    	@ First, find the end of the source string by finding its length

    	MOV r2, r0                  @ r2 = temporary pointer to find the end
FindEnd:
   	LDRB r3, [r2], #1           @ Load a byte and advance the pointer
   	CMP r3, #0                  @ Check if it is a null pointer to get the end of the string
   	BNE FindEnd                 
   	SUB r2, r2, #2              @ Point r2 to the last character (before the null ternimator)

	@ r0 points to the start of the hex_num_rv, r1 to the start of the destination, hex_num
	@ r2 points to the last character of the hex_num_rv.

ReverseLoop:
   	LDRB r3, [r2], #-1          @ Load a character from the source and move source pointer back
    	STRB r3, [r1], #1           @ Store it in the destination and move destination pointer forward
    	CMP r2, r0                  @ check if finished reversing
    	BGE ReverseLoop             

    	@ Add the final null terminator to the new string in hex_num
    	MOV r3, #0
    	STRB r3, [r1]

    	POP {r4-r8, lr}
    	BX lr
@------------------------------------
SetHex:
    	CMP r5, #10
    	BLT SetNum		@ If number is less than 10 set itself to the hexanumber

    	@ r5 is 10–15: Convert to 'A'–'F'
    	ADD r8, r5, #'A' - 10  	@ r8 = ASCII hex letter
    	B StoreHex

SetNum:
    	ADD r8, r5, #'0'      	@ r8 = ASCII of digit 0–9

StoreHex:
    	LDR r10, =hex_num_rv	@ Where to store the hex result
    	ADD r10, r10, r9      	@ r9 works as the byte pointer
    	STRB r8, [r10, #0]	@ Store the byte in the string
    	BX lr			@ Return to the caller of SetHex
