.data
newline: .asciiz "\n"
prompt:  .asciiz "\n Calculate the number of twin primes less than or equal to: "        #input prompt
numberof: .asciiz "\n The number of twin primes is: "

.text
main:
		li			$v0, 4						#Prepare syscall for integer input
		la 			$a0, prompt					#load the prompt "enter integer:"
		syscall									#perform the syscall
		li 			$v0, 5  					#prep integer read syscall
		syscall									#perform int read syscall.
		nop  									#no op
		add 		$a1, $v0, $zero				#store input in a1
		addi 		$a1, $a1, 1 				#increase a1 by one to capture primes equal to arg (arg += 1)
		li			$v0, 0  					#clear v0 for safety
		add 		$a0, $a1, $zero				#copy $a1 argument into $a0 for initial primetesting ($a0 = arg + 1)
		li			$t0, 1      			 	#load t0 with 1 so you can subtract from a0
		sub			$a0, $a0, $t0  				#subtract 1 from a0 ($a0 = arg + 1 -1 = arg)
		jal			primetest  					#jump to primetest and test isPrime(arg)
		move		$t3, $v0 					#save isPrime(arg) in t3
		sub			$a0, $a0, 1   				#$a0 = $a0 - 1 = arg - 1
		jal			primetest 					#isPrime(arg - 1)
		move		$t4, $v0                    #save isPrime(arg - 1) in t4
		sub			$a0, $a0, 1                 #subtract again from a0 (arg - 2)
		jal			primetest   				#isPrime(arg - 2)
		move		$t5, $v0                    #save isPrime(arg - 2) in t5
		jal			startcounter                #calculate the number of twinprimes by launching startcounter
		li			$v0, 4   					#string print syscall prep
 		la 			$a0, numberof	   			#load the string called numberof
 		syscall	  							 	#print "\n The number of twin primes is: "
		add	     	$a0, $v1, $zero 			#load the function result in a0 
		li			$v0, 1  					#prep the int print syscall
		syscall                                 #print the number of twinprimes
		addi 		$v0, $zero, 4       		#print string syscall
		la 			$a0, newline  				#prep the new line string
		syscall 							    #print the new line
		jal			startfirstgreater           #begin the bonus function (first twin prime pair > 1000000)
		add 		$a0, $v0, $zero 			#load first of greater twin
		li 			$v0, 1   					#prep to print it
		syscall                                 #perform print syscall
		addi 		$v0, $zero, 4       		#print string syscall
		la 			$a0, newline                #load newline string
		syscall                      			#print it
		add  		$a0, $v1, $zero 			#load second of greater twin
		li 			$v0, 1 						#prep to print newline
		syscall 							 	#print newline
		li 			$v0, 10 					#prep exit syscall
		syscall 								#exit program

#tnum is $a1
#first of pair is $v0
#second of pair is $v1
startfirstgreater:
		move		$s7, $ra  					#save return address in s7 for later return
		li 			$v0, 0 						#clear v0
		li 			$v1, 0 						#clear v1
		li 			$a1, 1000000 				#you want to calculate the twinprimes > 1000000
		j  			greaterloop 				#begin the loop

greaterloop:
		add 		$a0, $zero, $a1 			#load tnum as a0
		jal			primetest					#test if tnum is prime
		add 		$s2, $zero, $v0				#save isPrime(tnum) in s2
		addi 		$a0, $a1, 2     			#add two to tnum
		jal			primetest 					#test if tnum+2 is prime
		add 		$s3, $zero, $v0 			#save isPrime(tnum+2) in s3
		addi 		$a1, $a1, 1 				#increment a1
		beq 		$s2, $zero, greaterloop 	#if isPrime(tnum) is false, run again
		beq 		$s3, $zero, greaterloop 	#if isPrime(tnum+2) is false, run again
		addi 		$v1, $a1, 1 				#v1 gets second of greater than if both are prime
		li 			$t0, 1  					#t0 gets 1
		sub 		$v0, $a1, $t0				#v0 gets first of greater than (a1 was already incremented, so roll back)
		add 		$ra, $s7, $zero 			#bring return address back
		jr 			$ra 						#jump back to main

# tnum IS $a1
# totaltwins IS $v1 
startcounter:
		addiu 		$sp, $sp, -4				#allocate one word on the stack
		sw 			$ra, ($sp)					#save ra on the stack
		#move		$s2, $ra   					#save return address
		li			$v1, 0						#set totaltwins to 0
		j           twinprimeloop 				#begin twin prime counter

twinprimeloop:
		li			$t0, 5                      #load 5 in $t0
		beq 		$a1, $t0, endcode           #branch to endcode if argument equals 5
		li			$t0, 1 						#load 1 as an immediate
		sub			$a1, $a1, $t0  				#curnum = tnum - 1
		add		    $t8, $t3, $zero 			#t8 if curnum is prime
		add 		$t3, $t4, $zero				#t3 if curnum-1 is prime
		add  		$t4, $t5, $zero				#t4 if curnum-2 is prime
		li			$t0, 3  					#t0 is 3
		sub  		$t6, $a1, $t0 				#t6 is tnum-3
		add 		$a0, $t6, $zero 			#load up tnum-3 as an argument
		jal  		primetest 					#jump to primetest and test tnum-3
		add 		$t5, $v0, $zero				#t5 is isPrime(tnum-3)
		beq			$t8, $zero, twinprimeloop   #if the current number isn't prime, not a twin prime
		beq			$t4, $zero, twinprimeloop	#if current number - 2 isn't prime, continue
		addi 		$v1, $v1, 1 				#increase totaltwins by 1
		j 			twinprimeloop 				#repeat loop with new arguments in registers

endcode:
		lw			$ra, ($sp)  				#load $ra back from the stack
		addiu 		$sp, $sp, 4					#restore the stack
		addi 		$v1, $v1, 1
		jr			$ra

#----------     FUNCTION: primetest    ------------------------
#----------     ARGUMENTS: $a0 : the number to be tested ------
#----------     OUTPUT: $v0 : 1 if prime, 0 if not. -----------

primetest:
		slti		$t0, $a0, 3     			#set $t0 to 1 if input less than 3 (0, 1, 2 not prime)
		bgtz		$t0, notprime				#if $t0 is true, exit program and not prime
		li		    $t0, 2 	        			#load 2 into $t0
		div			$a0, $t0					#divide a0 by 2
		mfhi		$t1							#load the remainder into $t1
		beq			$t1, $zero, notprime 		#if the remainder is 0, not prime 
		addi		$t0, $zero, 3				#load 3 into $t0
		div 		$a0, $t0					#divide $a0 by 3
		mfhi		$t1							#load the remainder into $t1
		beq			$t1, $zero, notprime 		#if the remainder is 0, not prime
		addi		$t0, $zero, 5				#set temporary to five ( i = 5)
		move		$s1, $ra        			#save return address so you can go to loop
		j         	loop  						#do it again

loop:
		mult		$t0, $t0        			#square t0
		mflo		$t1							#move the square to $t1
		slt 		$t2, $a0, $t1   			#set t2 to 1 if pnum is less than (i*i) (pnum is prime)
		bgtz		$t2, yesprime 				#launch yesprime code to show pnum is prime
		div         $a0, $t0        			#divide pnum by i
		mfhi		$t2             			#set t2 to (pnum % i)
		beq			$t2, $zero, notprime 		#if there's a remainder, argument is not prime so launch notprime code
		addi        $t2, $t0, 2                 #add 2 to i
		div         $a0, $t2       				#divide input by i+2
		mfhi		$t2 						#move the remainder of (pnum/i+2) to $t2
		beq         $t2, $zero, notprime  		#if THAT is 0 then it's not prime
		addi        $t0, $t0, 6 				#otherwise i = i+6
		j           loop 						#loop again with new i

notprime:
		add 		$v0, $zero, $zero  			#set return value ($v0) as 0 to say the arg was not prime
		jr			$ra 						#go back to return address

yesprime:
		addi  		$v0, $zero, 1 				#set return value ($v0) as 1 to say the arg WAS prime
		jr			$ra  						#go back to return address