.data

newline: .asciiz "\n"
insert: .asciiz "Insert"
delete:  .asciiz "Delete"
find:  .asciiz "Find"
size:  .asciiz "Size"
print:  .asciiz "Print"
quit:  .asciiz "Quit"
whatnumberinsert: .asciiz "Enter number to insert: "
whatnumberfind: .asciiz "Enter number to find: "
whatnumberdelete: .asciiz "Enter number to delete: "
command: .asciiz "Command: "
mistake: .asciiz "You've entered an invalid command. Valid commands are: \n Insert, Delete, Find, Size, Print, and Quit\n"
goodbye: .asciiz "Good-bye!\n"
comma: .asciiz ","
input_string: .space 6 #make space for 6 characters from input command
input_int: 	.word 0 #make space for 32-bit integer
int_list: .word -1, 2, 3, 4 #make space for 250 integer list
list_size: .word 4 #size of the list is 0 at first
sizeof: .asciiz "Size of list = "

.text

main:
	jal programloop
	j endcode

endcode:
	li 		$v0, 4
	la 		$a0, goodbye
	syscall
	li 		$v0, 10
	syscall

programloop:
	jal 	printcommandstring 		#print "Command: "
	jal 	readstring 				#read the input string and save in input_string
	jal 	execcommand				#go to the command exec function
	j 		programloop 			#begin program again

execcommand:
	subu 	$sp, $sp, 4 			#allocate 5 words on the stack
	sw	 	$ra, 0($sp)	 			#save return address
	jal		whichcommand
	lw	 	$ra, 0($sp)
	addiu 	$sp, $sp, 4				#clear the stack space
	jr		$ra 					#go back to execcommand

whichcommand:
	la 		$t0, input_string
	lb 		$t1, 0($t0)
	la 		$t2, insert
	lb 		$t3, 0($t2)
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	beq 	$t1, $t3, matchinsert
	la 		$t2, delete
	lb 		$t3, 0($t2)
	addi 	$t2, $t2, 1
	beq 	$t1, $t3, matchdelete
	la 		$t2, find
	lb 		$t3, 0($t2)
	addi 	$t2, $t2, 1
	beq 	$t1, $t3, matchfind
	la 		$t2, size
	lb 		$t3, 0($t2)
	addi 	$t2, $t2, 1
	beq		$t1, $t3, matchsize
	la 		$t2, print
	lb 		$t3, 0($t2)
	addi 	$t2, $t2, 1
	beq		$t1, $t3, matchprint
	la 		$t2, quit
	lb 		$t3, 0($t2)
	addi 	$t2, $t2, 1
	beq		$t1, $t3, matchquit

matchinsert:
	li 		$t4, 5
	j 		matchinsertloop

matchinsertloop:
	beq 	$t4, $zero, execinsert
	lb 		$t1, 0($t0)
	lb 		$t3, 0($t2)
	bne 	$t1, $t3, nomatch
	sub 	$t4, $t4, 1
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	j 		matchinsertloop

execinsert:
	subu 	$sp, $sp, 4
	sw 		$ra, 0($sp) 		#store return address on the stack
	la 		$a0, whatnumberinsert
	jal 	printstring
	jal 	readint				#read an int from the console and store in input_int
	lw 		$a0, input_int		#load input_int as an argument
	jal 	afterreadint 		
	lw 		$ra, 0($sp)			#bring back return address
	addiu 	$sp, $sp, 4
	jr 		$ra

#takes int in $a0 as an argument, inserts it into int_list
addtolist:

matchdelete:
	li 		$t4, 5
	j 		matchdeleteloop

matchdeleteloop:
	beq 	$t4, $zero, execdelete
	lb 		$t1, 0($t0)
	lb 		$t3, 0($t2)
	bne 	$t1, $t3, nomatch
	sub 	$t4, $t4, 1
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	j 		matchdeleteloop

execdelete:
	subu	$sp, $sp, 4
	sw		$ra, 0($sp)
	la 		$a0, whatnumberdelete
	jal 	printstring
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr		$ra

matchfind:
	li 		$t4, 3
	j 		matchfindloop

matchfindloop:
	beq 	$t4, $zero, execfind
	lb 		$t1, 0($t0)
	lb 		$t3, 0($t2)
	bne 	$t1, $t3, nomatch
	sub 	$t4, $t4, 1
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	j 		matchfindloop

execfind:
	subu	$sp, $sp, 4
	sw		$ra, 0($sp)
	la 		$a0, whatnumberfind
	jal 	printstring
	jal 	readint				#read an int from the console and store in input_int
afterreadint:
	lw 		$a0, input_int		#load input_int as an argument
	la 		$a1, int_list 		#lower address of list
	lw 		$t0, list_size		#load the size of the list
	beqz 	$t0, listempty		#list is empty, answer is zero
	li 		$t4, 4
	mult 	$t0, $t4			#size of the list in bytes
	mflo 	$t0					#move size of list in bytes to t0
	add 	$a2, $t0, $a1		#add that many bytes to the address of the lower bound
	sub 	$a2, $a2, 4 		#but subtract 4
	jal 	search
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr		$ra

listempty:
	li 		$v0, 0
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr		$ra

#a0 is int you're trying to find, a1 is lower address of list, a2 is upper address. Returns index $v0
search:
	sub 	$t0, $a2, $a1		#t0 is size of list (in bytes) between bounds
	bltz	$t0, notfound 		#if the size is negative then number isn't in list
	add 	$t1, $a1, $a2		#t1 is upper bound + lower bound
	sra 	$t0, $t0, 3 		#divide size of list by 8
	sll 	$t0, $t0, 2 		#multiply size by 4 (this is equal to # of bytes to mid from bounds)
	addu 	$t0, $a1, $t0 		#equal to address of middle number
	lw 		$t1, 0($t0) 		#equal to int_list[middle]
	beq 	$t1, $a0, found 	#go to found procedure if int_list[middle] is the number
	j 		notequal 			

found:
	la 	 	$t2, int_list
	sub 	$t0, $t0, $t2 		#store (middle address - beginning add. of int_list) in $t0
	li 		$t1, 4
	div 	$t0, $t1 			#calculate index of found
	mflo 	$v0 				#store here
	addi 	$v0, $v0, 1
	add 	$a0, $v0, $zero
	jal 	printint
	j 		programloop

notfound:
	la 		$t1, int_list
	sub 	$t0, $a1, $t1
	li 		$t1, 4
	div 	$t0, $t1
	mflo 	$t0
	add 	$v0, $t0, $zero
	add 	$a0, $zero, $v0
	jal		printint
	j 		programloop 				#go back to main proc.

notequal:
	blt 	$t1, $a0, midless	#if midpoint is less than what you're searching for, go to less than function
	bgt		$t1, $a0, midgreater #if midpoint is greater than what you're searching for, go to grtr than funct

midless:
	move 	$a1, $t0 			#move the midpoint to the lowerbound
	addi    $a1, $a1, 4 		#move up the midpoint by one address
	j 		search

midgreater:
	move 	$a2, $t0
	sub 	$a2, $a2, 4
	j 		search

matchsize:
	li 		$t4, 3
	j 		matchsizeloop

matchsizeloop:
	beq 	$t4, $zero, execsize
	lb 		$t1, 0($t0)
	lb 		$t3, 0($t2)
	bne 	$t1, $t3, nomatch
	sub 	$t4, $t4, 1
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	j 		matchsizeloop

execsize:
	subu	$sp, $sp, 4
	sw 		$ra, 0($sp)
	la 		$a0, sizeof
	jal 	printstring
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	lw 		$a0, list_size
	j 		printint

matchprint:
	li 		$t4, 4
	j 		matchprintloop

matchprintloop:
	beq 	$t4, $zero, execprint
	lb 		$t1, 0($t0)
	lb 		$t3, 0($t2)
	bne 	$t1, $t3, nomatch
	sub 	$t4, $t4, 1
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	j 		matchprintloop

execprint:
	la 		$t0, int_list
	lw 		$t1, list_size
	li 		$t2, 4
	mult 	$t1, $t2
	mflo 	$t1
	sub 	$t1, $t1, $t2
	li 		$t2, 0

printloop:
	lw 		$a0, 0($t0)
	addi 	$t0, 4
	addi 	$t2, 4
	li 		$v0, 1
	syscall
	bgt 	$t2, $t1, endprintloop
	la 		$a0, comma
	jal 	printstring
	j 		printloop

endprintloop:
	la 		$a0, newline
	jal 	printstring
	j 		programloop

matchquit:
	li 		$t4, 3
	j 		matchquitloop

matchquitloop:
	beq 	$t4, $zero, endcode
	lb 		$t1, 0($t0)
	lb 		$t3, 0($t2)
	bne 	$t1, $t3, nomatch
	sub 	$t4, $t4, 1
	addi 	$t2, $t2, 1
	addi 	$t0, $t0, 1
	j 		matchquitloop

nomatch:
	la 		$a0, mistake
	li 		$v0, 4
	syscall
	jr 		$ra

printcommandstring:
	li 		$v0, 4
	la 		$a0, command 
	syscall 
	jr 		$ra

readint:
	li 		$v0, 5
	syscall
	sw 		$v0, input_int
 	jr 		$ra

readstring:
	li 		$v0, 8
	la 		$a0, input_string
	li 		$a1, 32 			#max of 32 bytes
	syscall
	nop
	jr 		$ra

printstring:
	li 		$v0, 4
	syscall
	jr		$ra

printint:
	li 		$v0, 1
	syscall
	la 		$a0, newline
	j 		printstring
	jr 		$ra