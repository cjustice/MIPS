.data

newline: .asciiz "\n"
insert: .asciiz "Insert"
delete:  .asciiz "Delete"
find:  .asciiz "Find"
size:  .asciiz "Size"
print:  .asciiz "Print"
quit:  .asciiz "Quit"
whatnumber: .asciiz "Enter number to insert: "
command: .asciiz "Command: "
mistake: .asciiz "You've entered an invalid command. Valid commands are: \n Insert, Delete, Find, Size, Print, and Quit\n"
goodbye: .asciiz "Good-bye!\n"
input_string: .space 6 #make space for 6 characters from input command
input_int: 	.word 0 #make space for 32-bit integer
int_list: .space 1000 #make space for 250 integer list
list_size: .word 0 #size of the list is 0 at first
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
	la 		$a0, whatnumber
	jal 	printstring
	jal 	readint				#read an int from the console and store in input_int
	lw 		$a0, input_int		#load input_int as an argument
	jal 	addtolist			#put the int in the sorted list
	lw		$t0, list_size
	addi 	$t0, $t0, 1
	sw 		$t0, list_size
	lw 		$a0, list_size
	jal 	printint
	lw 		$ra, 0($sp)			#bring back return address
	addiu 	$sp, $sp, 4
	jr 		$ra

#takes int in $a0 as an argument, inserts it into int_list
addtolist:
	move	$s0, $a0			#make copy of argument in $s0
	lw 		$t0, list_size		#load the size of the list in t0
	li 		$t1, 4
	mult 	$t0, $t1
	mflo 	$a0					#move result to $t0. $t0 is the size of the list in bytes
	j 		printint  			

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
	la 		$a0, input_string
	j 		printstring

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
	la 		$a0, input_string
	j 		printstring

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
	la 		$a0, input_string
	j 		printstring

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