.data

newline: .asciiz "\n"
insert: .asciiz "Insert"
delete:  .asciiz "Delete"
find:  .asciiz "Find"
size:  .asciiz "Size"
print:  .asciiz "Print"
quit:  .asciiz "Quit"
command: .asciiz "Command: "
mistake: .asciiz "You've entered an invalid command. Valid commands are: \n Insert, Delete, Find, Size, Print, and Quit\n"
goodbye: .asciiz "Good-bye!\n"
input_string: .space 32 #make space for input string w/ at most 6 characters
input_int: 	.space 256 #make space for 32-bit integer
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
	add 	$s2, $ra, $zero 		#save return address
	jal		whichcommand
	add 	$ra, $s2, $zero
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
	la 		$a0, input_string
	j 		printstring

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
	j 		matchfindloop

execsize:
	la 		$a0, input_string
	j 		printstring

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
	add 	$a1, $v0, $zero
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
