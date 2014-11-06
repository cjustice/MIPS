main:
		li			$a1, 1000000
		add 		$a0, $a1, $zero
		li			$t0, 1
		sub			$a0, $a0, 1
		jal			primetest
		move		$t3, $v0 #isPrime(tnum-1)
		sub			$a0, $a0, 1
		jal			primetest #isPrime(tnum-2)
		move		$t4, $v0
		li			$t0, 1
		sub			$a0, $a0, 1
		jal			primetest
		move		$t5, $v0
		jal			startcounter #g
		add	     	$a0, $v1, $zero
		li			$v0, 1
		syscall
		li			$v0, 10
		syscall

# tnum IS $a1
# totaltwins IS $v1 
startcounter:
		move		$s2, $ra    #save return address
		li			$v1, 0	#set totaltwins to 0
		j           twinprimeloop #begin twin prime counter

twinprimeloop:
		li			$t0, 5
		beq 		$a1, $t0, endcode
		li			$t0, 1
		sub			$a1, $a1, $t0  #curnum = tnum - 1
		add		    $t8, $t3, $zero 	#t8 if curnum is prime
		add 		$t3, $t4, $zero	#t3 if curnum-1 is prime
		add  		$t4, $t5, $zero	#t4 if curnum-2 is prime
		li			$t0, 3  	#t0 is 3
		sub  		$t6, $a1, $t0 #t6 is tnum-3
		add 		$a0, $t6, $zero 	#load up tnum-3 as an argument
		jal  		primetest
		add 		$t5, $v0, $zero	#t5 is isPrime(tnum-3)
		beq			$t8, $zero, twinprimeloop  #if the current number isn't prime, not a twin prime
		beq			$t4, $zero, twinprimeloop	#if current number - 2 isn't prime, continue
		addi 		$v1, $v1, 1 #increase totaltwins by 1
		j 			twinprimeloop

endcode:
		move		$ra, $s2		#set return address back to main
		addi 		$v1, $v1, 1
		jr			$ra

#----------     FUNCTION: primetest    ------------------------
#----------     ARGUMENTS: $a0 : the number to be tested ------
#----------     OUTPUT: $v0 : 1 if prime, 0 if not. -----------

primetest:
		slti		$t0, $a0, 3     #set $t0 to 1 if input less than 3 (0, 1, 2 not prime)
		bgtz		$t0, notprime	#if $t0 is true, exit program and not prime
		li		    $t0, 2 	        #load 2 into $t0
		div			$a0, $t0		#divide a0 by 2
		mfhi		$t1				#load the remainder into $t1
		beq			$t1, $zero, notprime #if the remainder is 0, not prime 
		addi		$t0, $zero, 3	#load 3 into $t0
		div 		$a0, $t0		#divide $a0 by 3
		mfhi		$t1				#load the remainder into $t1
		beq			$t1, $zero, notprime #if the remainder is 0, not prime
		addi		$t0, $zero, 5	#set temporary to five ( i = 5)
		move		$s1, $ra        #save return address so you can go to loop
		j         	loop

loop:
		mult		$t0, $t0        #square t0
		mflo		$t1				#move the square to $t1
		slt 		$t2, $a0, $t1   #set t2 to 1 if pnum is less than (i*i)
		bgtz		$t2, yesprime
		div         $a0, $t0        #divide input by i
		mfhi		$t2             #set t2 to remainder
		beq			$t2, $zero, notprime
		addi        $t2, $t0, 2
		div         $a0, $t2       #divide input by i+2
		mfhi		$t2
		beq         $t2, $zero, notprime
		addi        $t0, $t0, 6
		j           loop

notprime:
		add 		$v0, $zero, $zero
		jr			$ra #go back to main

yesprime:
		addi  		$v0, $zero, 1
		jr			$ra