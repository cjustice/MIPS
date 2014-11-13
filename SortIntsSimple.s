#Connor Justice
#Maintain a list of sorted integers
#MIPS ASSEMBLY
#Due 11-13-2014

.data
#all the strings for prompts on the console
newline: .asciiz "\n"
commandprompt: .asciiz "Command: "
comma: .asciiz ","
goodbye: .asciiz "Good-bye!\n"
sizeof: .asciiz "Size of list = "
mistake: .asciiz "You've entered an invalid command. Valid commands are: \n Insert, Delete, Find, Size, Print, and Quit\n"
input_int: 	.word 0 #make space for 32-bit integer holds the user's input
int_list: .space 1000 #make space for 250 integer list
list_size: .word 0 #make space for 32-bit int that holds the current size of the list

#stores all the code for the program
.text

#goes directly to program loop. Used by QtSpim
main:
	jal programloop

# Main loop of program. Loops through prompting the user for input, 
# reading in the user's input, and executing the appropriate command. 
programloop:
	jal 	printcommandprompt 		#print "Command: "
	jal 	readcommand 			#read the command input
	jal 	execcommand				#go to the command exec function
	j 		programloop 			#begin program again

# Gets called when user enters '60'. Quits the program with a syscall
endcode:
	li 		$v0, 4 				#Load the string print immediate
	la 		$a0, goodbye 		#Load the address of the string saying "Good-bye!"
	syscall  					#Syscall to print
	li 		$v0, 10 			#load the exit syscall number
	syscall 					#perform exit

# Prints the "Command: " string every time input is needed from a user
printcommandprompt:
	la 		$a0, commandprompt 	#load the commandprompt string ("Command: ")
	li 		$v0, 4 				#Load the string print immediate
	syscall 					#Perform the syscall
	jr		$ra  				#return to the programloop

#Reads the user-inputted integer and stores it in the word referenced by input_int label
readcommand: 				
	li 		$v0, 5 				#Load the integer read syscall
	syscall  					#perform it
	sw 		$v0, input_int 		#store the input in the label
	jr 		$ra  				#Jump back to the programloop

#Determines the command being executed (e.g. Find, Insert, Delete, etc.)
#If command involves a specific number inputted by the user, stores that number in $a0
#Prints a string telling the user they made a mistake if they enter an invalid number
execcommand:
	li 		$t0, 60 				#Load 60 into $t0
	lw 		$a0, input_int 			#Load input_int into $a0
	beq 	$t0, $a0, endcode 		#If input_int was 60, jump to endcode
	li 		$t0, 50 				#Load 50 into $t0
	beq 	$t0, $a0, execprint  	#If input_int was 50, jump to execprint
	li 		$t0, 40 				#Load 40 into $t0
	beq 	$t0, $a0, execsize 		#If input_int was 40, jump to execsize
	li 		$t0, 10 				#Load 10 into $t0
	div 	$a0, $t0 				#Divide input_int by 10 to separate first and second digits
	mflo 	$t0 					#Load the quotient into $t0 so you can check which command to run
	mfhi 	$a0 					#move the remainder into the argument -- this is the number to deal with
	li 		$t2, 1 					#load 1 as immediate
	beq 	$t2, $t0, execinsert 	#If first digit of input was 1, perform insert
	li 		$t2, 2  				#Load 2 as immediate
	beq 	$t2, $t0, execdelete    #If second digit of input was 2, perform delete
	li 		$t2, 3  				#Load 3 as immediate
	beq 	$t2, $t0, printfind     #If first digit of input was 3, perform find
	li 		$v0, 4  				#Load the print string syscall number
	la 		$a0, mistake  			#Load the address of the string saying you made a mistake
	syscall 						#print that string

#Prints out the size of the int_list
#No arguments
execsize:
	la 		$a0, sizeof  			#Load the string that says "Size of list ="
	li 		$v0, 4  				#Load the print string syscall number
	syscall 						#print the string
	lw 		$a0, list_size 			#Load the size of the list in $a0
	li 		$v0, 1 					#Load the print int syscall number
	syscall 						#Print size 
	la 		$a0, newline 			#load the address of the newline string
	li 		$v0, 4 					#Load the string print syscall
	syscall 						#Perform the syscall
	j 		programloop 			#Go back to the loop of the program to start over

#Prints out the list in the console
#No arguments
execprint:
	la 		$t0, int_list 			#Load the address of the list
	lw 		$t1, list_size 			#Load the current size of the list
	li 		$t2, 4 					#Load 4 as an immediate
	mult 	$t1, $t2 				#Multiply the size of the list by 4 to get the offset of the last number + 4
	mflo 	$t1 					#Move result into $t1
	sub 	$t1, $t1, $t2 			#Subtract 4 from $t1 to get offset of last number
	li 		$t2, 0 					#Load 0 as an immediate in $t2 (overwrites $t2 = 4)
printloop: 							#loops through each index of the list and prints the int and a comma
	lw 		$a0, 0($t0)				#Load the number at int_list[i]
	addi 	$t0, 4   				#Move int_list address up to next int (int_list[i+1])
	addi 	$t2, 4 					#Track how far down you are to compare against max offset
	li 		$v0, 1 					#Load the print int syscall
	syscall 						#print int_list[i-1]
	bgt 	$t2, $t1, endprintloop 	#If you're past max offset address, you've finished printing. Go to endprintloop function
	la 		$a0, comma 				#print a comma if not your last one
	li 		$v0, 4 					#Load the string print syscall
	syscall 						#print the comma
	j 		printloop 				#do the loop again if you have to

#Prints a newline and jumps back to programloop
endprintloop:
	la 		$a0, newline 			#load the address of the newline string
	li 		$v0, 4 					#loads the string print syscall number
	syscall 						#performs the call
	j 		programloop  			#Goes back to the main program loop

# takes $a0, number between 1 and 9 to search for.  
# Outputs $v0, position of $a0 in int_list.
# If $v0 is not in int_list, outputs position
# to insert $a0 after to maintain sorted list. 
# Also outputs boolean $v1, true if $a0 was in list.
# Side effect -- Prints $v0 to console
printfind:
	#prepare arguments for helper function
	jal 	execfind   				#Searches for $a0, the number you're trying to search for
	move	$a0, $v0 				#Move the position to $a0 so you can print it
	li 		$v0, 1 					#Load int-print syscall number
	syscall 						#Perform the call
	la 		$a0, newline 			#Load the address of the newline string
	li 		$v0, 4 					#Load string print syscall number
	syscall 						#Perform the syscall
	j 		programloop 			#Go back to the main program loop

#The main find function. Used in insert, printfind, and delete. 
#Finds the position of the first instance of number stored in $a0 in int_list and stores in $v0
#If not in list, $v0 contains where to insert number to maintain sorted list
#$v1 is true if $a0 was in the list, false otherwise
execfind:
	subu 	$sp, $sp, 4 			#Set the stack pointer back
	sw 		$ra, 0($sp) 			#Store the return address on the stack so you can retrieve it later
	la 		$a1, int_list 			#Store the address of the int_list in $a1
	lw 		$t0, list_size 			#Store the current size of the list in $t0
	beqz 	$t0, listempty 			#Branch to the listempty procedure if list_size is 0 
	li 		$t1, 4 					#Load 4 as an immediate
	mult 	$t0, $t1 				#Calculate offset of last index + 4
	mflo 	$t0 					#Move from lo to $t0
	add 	$a2, $t0, $a1 		 	#Add offset to $a2 for upper bound for initial search call + 4
	sub 	$a2, $a2, 4 			#Subtrack 4 from $a2 to get last int_list index
	jal 	search 					#Perform the binary search with 0(int_list) as your lower bound and (list_size*4)-4(int_list) as your upper bound
	lw 		$ra, 0($sp) 			#Reload the return address stored on the stack
	addiu 	$sp, $sp, 4 			#Reset the stack pointer
	jr 		$ra 					#Jump back to return address

#If list is empty, insert $a0 in position 0 and $a0 was not found in list
listempty:
	li 		$v0, 0 					#Load $v0 as 0
	li 		$v1, 0 					#Load $v1 as 0
	jr 		$ra 					#Jump back to programloop

# Recursive binary search. 
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
	j 		notequal 			#Jump to the procedure that sets up next call if bounds aren't equal yet

#Procedure is called when upper bound < lower bound in search.
#Returns where you would insert $a0 to maintain sort
# Indicates that $a0 was not found in int_list
#a0 is what you're looking for, $a1 is lower bound
notfound:
	la 		$t1, int_list 		#Load the address of the int_list
	sub 	$t0, $a1, $t1 		#Store byte offset of lower bound address in $t0  
	li 		$t1, 4 				#Load 4 as an immediate
	div 	$t0, $t1 			#Divide byte offset by 4
	mflo 	$t0 				#Move into $t0
	add 	$v0, $t0, $zero 	#Store position in $v0
	li 		$v1, 0 				#Store 0 in $v1 ($a0 wasn't found)
	add 	$a0, $zero, $v0 	#Load position to insert in $a0
	jr 		$ra 				#Return to execfind


found:
	la 	 	$t2, int_list 		#Load the address of int_list
	sub 	$t0, $t0, $t2 		#store (middle address - beginning add. of int_list) in $t0
	li 		$t1, 4 				#Load the 4 immediate
	div 	$t0, $t1 			#calculate index of found
	mflo 	$v0 				#store here
	addi 	$v0, $v0, 1 		#Add one to the index you found $a0 at
	li 		$v1, 1 				#Load the 1 immediate in $v1 to show that you found $a0
	add 	$a0, $v0, $zero 	#Load position to insert in $a0
	jr		$ra  				#Return to execfind

notequal:
	blt 	$t1, $a0, midless	#if midpoint is less than what you're searching for, go to less than function
	bgt		$t1, $a0, midgreater #if midpoint is greater than what you're searching for, go to grtr than funct

#Moves the bounds down because the number you're looking for was smaller than the midpoint
midless:
	move 	$a1, $t0 			#move the midpoint to the lowerbound
	addi    $a1, $a1, 4 		#move up the midpoint by one address
	j 		search 				#Continue searching

#Moves the bounds up because the number you're looking for is larger than the midpoint
midgreater:
	move 	$a2, $t0 			#Set the lower bound to the mid point
	sub 	$a2, $a2, 4 		#Subtract 4 to remove overlap
	j 		search 				#Continue searching

#takes $a0 between 0 and 9.
#Inserts $a0 into int_list and maintains sort
execinsert:
	li 		$v0, 0 						#Load 0 immediate in $v0
	add 	$s5, $a0, $zero 			#Store $a0 in $s5 to be sure you don't overwrite in execfind
	jal 	execfind 					#Run execfind. Stores position to insert in $v0 and whether $a0 was in list in $v1
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
	li 		$t0, 4
	mult 	$s1, $t0
	mflo 	$t1
	add 	$t1, $s0, $t1
	sub 	$t1, $t1, $t0 #((4*list_size)-4)int_list addr
	mult 	$a1, $t0
	mflo 	$t2
	add 	$s0, $t2, $s0
	sub 	$s0, $s0, $t0
insert_repeated_loop:
	beq 	$s0, $t1, insert_at_end
	addi 	$s0, $s0, 4
	lw 		$t3, 0($s0)
	bne 	$t3, $a0, insert_repeat
	j 		insert_repeated_loop

insert_repeat:
	lw 		$t3, 0($s0)
	sw 		$a0, 0($s0)
	move	$a0, $t3
	j 		execinsert

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
	jal 	execfind
	beqz 	$v1, programloop
	la 		$s0, int_list
	la 		$s1, int_list
	lw 		$t0, list_size
	li 		$t1, 1
	beq 	$t0, $t1, onedelete
	li 		$t1, 4
	mult 	$t1, $t0
	mflo 	$t0
	add 	$s0, $s0, $t0
	sub 	$s0, $s0, $t1
	sub 	$s0, $s0, $t1 		#max address
	mult 	$v0, $t1
	mflo 	$t2
	add 	$s1, $s1, $t2
	sub 	$s1, $s1, $t1 		#starting address
deleteloop:
	beq 	$s1, $s0, deletefinal
	lw 		$t1, 4($s1)
	sw 		$t1, 0($s1)
	addi 	$s1, $s1, 4
	j 		deleteloop
deletefinal:
	lw 		$t1, 4($s1)
	sw 		$t1, 0($s1)
	sw 		$zero, 4($s1)
wrapup:
	lw 		$t1, list_size
	li 		$t2, 1
	sub 	$t1, $t1, $t2
	sw 		$t1, list_size
	j 		programloop

onedelete:
	sw 		$zero, ($s0)
	j 		wrapup