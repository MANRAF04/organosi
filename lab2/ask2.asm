.data
giveN1: .asciiz "Please give N1:\n"
giveN2: .asciiz "Please give N2:\n"

result1: .asciiz "The max final union of ranges is ["
result2: .asciiz "].\n"

.text
.globl main

main:
	li $s0, -1	#min
	li $s1, -1 	#max
	j loop

loop:
	li $v0,4
	la $a0,giveN1  		#prints message to take N1
	syscall
	
	li $v0,5
	syscall			#Takes N1
	move $t0,$v0
	bltz $t0,print
		
	li $v0,4
	la $a0,giveN2		#prints message to take N2
	syscall	
	
	li $v0,5
	syscall			#Takes N2
	move $t1,$v0
	bltz $t1,print
	
	bgt $t0, $s0, check_kpN2
	blt $t0, $s1, kp_N1
		
	j no_or_full_epi


check_kpN2:
	blt $t0, $s1, kp_N1
	j no_or_full_epi

kp_N1:
	bgt $t0, $s0, kp_N2
	move $s0, $t0
	j kp_N2

kp_N2:
	bgt $s1, $t1, loop
	move $s1, $t1
	j loop

no_or_full_epi:
	sub $t2, $s1, $s0
	sub $t3 $t1, $t0
	
	bgt $t2,$t3, loop
	move $s0, $t0
	move $s1, $t1
	j loop

print:
	
	bltz $s0, end
	bltz $s1, end
	
	li $v0, 4
	la $a0,result1		#Print max range
	syscall
	
	li $v0,1
	move $a0,$s0
	syscall
	
	li $v0,11
	li $a0,','
	syscall
	
	li $v0,1
	move $a0,$s1
	syscall
	
	li $v0,4
	la $a0,result2
	syscall
		
end:	
	la $v0,10		#Exits Program
	syscall