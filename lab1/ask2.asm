.data
giveN1: .asciiz "Please give N1:\n"
giveN2: .asciiz "Please give N2:\n"

result1: .asciiz "The max final union of ranges is ["
result2: .asciiz "].\n"

.text
.globl main

main:
	li $t2,0		#Starts min at -1
	li $t3,0		#Starts max at -1

loop:
	li $v0,4
	la $a0,giveN1
	syscall
	
	li $v0,5
	syscall			#Takes N1
	move $t0,$v0
	bltz $t0,end
		
	li $v0,4
	la $a0,giveN2
	syscall	
	
	li $v0,5
	syscall			#Takes N2
	move $t1,$v0
	bltz $t1,end
	
	ble $t0,$t2,lessMin	#N1 less than minimum N until now
	
	ble $t0,$t3,moreMax	#N1 between minimum and maximum Ns

checkDiff:	
	sub $t4,$t1,$t0		#Calculates the range distance
	sub $t5,$t3,$t2		#Calculates max range distance
	bgt $t4,$t5,bothMore	#Found bigger range that is outside of old range
	
	j loop
	
lessMin:
	bge $t1,$t3,bothMore	#N1 less than minimum and N2 greater than maximum
	bge $t1,$t2,leftLess	#N1 less than minium and N2 between minumum and maximum
	j checkDiff
moreMax:
	bgt $t1,$t3,rightMore	#N1 between minimum and maximum and N2 greater than maximum
	j checkDiff
rightMore:
	move $t3,$t1		#Updates max
	j loop
leftLess:
	move $t2,$t0		#Updates min
	j loop
bothMore:
	move $t2,$t0		#Updates both min and max
	move $t3,$t1
	j loop

end:
	blez $t3,exit
	li $v0, 4
	la $a0,result1		
	syscall
	
	li $v0,1
	move $a0,$t2		#Prints min
	syscall
	
	li $v0,11
	li $a0,','
	syscall
	
	li $v0,1
	move $a0,$t3		#Prints max
	syscall
	
	li $v0,4
	la $a0,result2
	syscall
		
exit:
	la $v0,10		#Exits Program
	syscall
