.data

newline: .asciiz "\n"
commandprompt: .asciiz "Command: "
comma: .asciiz ","
goodbye: .asciiz "Good-bye!\n"
input_int: 	.word 0 #make space for 32-bit integer
int_list: .space 1000 #make space for 250 integer list
list_size: .word 0 #size of the list is 0 at first
sizeof: .asciiz "Size of list = "
mistake: .asciiz "You've entered an invalid command. Valid commands are: \n Insert, Delete, Find, Size, Print, and Quit\n"
command: .word 4

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
	jal 	printcommandprompt 		#print "Command: "
	jal 	readcommand 			#read the command input
	jal 	execcommand				#go to the command exec function
	j 		programloop 			#begin program again

printcommandprompt:
	la 		$a0, commandprompt
	li 		$v0, 4
	syscall
	jr		$ra

readcommand:
	li 		$v0, 5
	syscall
	sw 		$v0, command
	jr 		$ra

execcommand:
	li 		$t0, 60
	lw 		$a0, command
	beq 	$t0, $a0, endcode
	li 		$t0, 50
	beq 	$t0, $a0, execprint
	li 		$t0, 40
	beq 	$t0, $a0, execsize
	li 		$t0, 10
	div 	$a0, $t0
	mflo 	$t0
	mfhi 	$a0 					#move the remainder into the argument -- this is the number to deal with
	li 		$t2, 1
	beq 	$t2, $t0, execinsert
	li 		$t2, 2
	beq 	$t2, $t0, execdelete
	li 		$t2, 3
	beq 	$t2, $t0, printfind
	li 		$v0, 4
	la 		$a0, mistake
	syscall

execsize:
	la 		$a0, sizeof
	li 		$v0, 4
	syscall
	lw 		$a0, list_size
	li 		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0, 4
	syscall
	j 		programloop

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
	li 		$v0, 4
	syscall
	j 		printloop

endprintloop:
	la 		$a0, newline
	li 		$v0, 4
	syscall
	j 		programloop

# takes $a0, number between 1 and 9 to search for.  
# Outputs $v0, position of $a0 in int_list.
# If $v0 is not in int_list, outputs position
# to insert $a0 after to maintain sorted list. 
# Outputs boolean $v1, true if $a0 was in list.
# Side effect -- Prints numbers to console
printfind:
	#prepare arguments for helper function
	jal 	execfind
	move	$a0, $v0
	li 		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0, 4
	syscall
	move	$a0, $v1
	li 		$v0, 1
	syscall
	la 		$a0, newline
	li 		$v0, 4
	syscall
	j 		programloop

execfind:
	subu 	$sp, $sp, 4
	sw 		$ra, 0($sp)
	la 		$a1, int_list
	lw 		$t0, list_size
	beqz 	$t0, listempty
	li 		$t1, 4
	mult 	$t0, $t1
	mflo 	$t0
	add 	$a2, $t0, $a1
	sub 	$a2, $a2, 4
	jal 	search
	lw 		$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr 		$ra

listempty:
	li 		$v0, 0
	li 		$v1, 0
	jr 		$ra

#a0 is what you're looking for, $a1 is current lower bound, $a2 is upper bound
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

notfound:
	la 		$t1, int_list
	sub 	$t0, $a1, $t1
	li 		$t1, 4
	div 	$t0, $t1
	mflo 	$t0
	add 	$v0, $t0, $zero
	li 		$v1, 0
	add 	$a0, $zero, $v0
	jr 		$ra

found:
	la 	 	$t2, int_list
	sub 	$t0, $t0, $t2 		#store (middle address - beginning add. of int_list) in $t0
	li 		$t1, 4
	div 	$t0, $t1 			#calculate index of found
	mflo 	$v0 				#store here
	addi 	$v0, $v0, 1
	li 		$v1, 1
	add 	$a0, $v0, $zero
	jr		$ra 

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

#takes $a0 between 0 and 9. 
execinsert:
	li 		$v0, 1
	syscall
	li 		$v0, 0
	add 	$s5, $a0, $zero
	jal 	execfind
	add 	$a0, $s5, $zero 			#bring back correct argument
	lw 		$t0, list_size
	move 	$a1, $v0
	move 	$a2, $v1
	beq 	$a1, $t0, insert_at_end 	#a1 is index from find. If equal to size of list, insert_at_end
	beqz	$a1, insert_at_beginning 	#if the index is 0, insert you thingy at the beginning
	j 		insert_in_middle

insert_at_end:
	lw 		$t0, list_size 				#t0 gets the size of the list (t0 = 4)
	la 		$t1, int_list 				#t1 gets the beginning address of int_list
	li 		$t2, 4 						#t2 gets 4
	mult 	$t0, $t2 					#lo gets size of list * 4 (byte offset) (16)
	mflo 	$t2 						#t2 gets lo (t2 = 16)
	add 	$t1, $t1, $t2 				#t1 is offset by 16
	sw 		$a0, 0($t1) 				#put argument into last place
	lw 		$t0, list_size
	addi 	$t0, $t0, 1 				#increase size of list by 1 (4+1)
	sw 		$t0, list_size 				#store in list_size
	j 		programloop

insert_at_beginning:
	add 	$t0, $a0, $zero
	la 		$t1, int_list
	lw 		$a0, ($t1)
	sw 		$t0, ($t1)
	j 		execinsert

#a0 is number to insert, a1 is location from execfind, a2 is if it was found
insert_in_middle:
	la 		$s0, int_list
	lw 		$s1, list_size
	beqz 	$a2, first_time
	#find max address for int_list



first_time:
	li 		$t0, 4
	mult 	$a1, $t0
	mflo 	$t1
	add 	$t1, $s0, $t1
	lw 		$t2, 0($t1)
	sw 		$a0, 0($t1)
	move 	$a0, $t2
	j 		execinsert

execdelete:








	