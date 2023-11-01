.data
num_text: .asciiz "Number "
has_text: .asciiz " has "
zer_text: .asciiz " leading zeroes\n"

.text
.globl main
main:
	li $v0, 5
	syscall			#Takes integer number from user
	move $s0,$v0

	li $v0,4
	la $a0,num_text
	syscall
	
	li $v0,1
	move $a0,$s0		#Prints number
	syscall
	
	bltz $s0,alwZero	#We know that the msb of negative numbers is 1 so there are no leading zeroes
	
	#clz $t1,$s0
	li $t1,32
	
countZeroes:
	beqz $s0,rest
	srl $s0,$s0,1
	addi $t1,$t1,-1
	j countZeroes
	
rest:
	li $v0,4
	la $a0,has_text
	syscall
	
	li $v0,1
	move $a0, $t1		#Prints amount of leading zeroes
	syscall
	
	li $v0, 4
	la $a0, zer_text	
	syscall
	
	la $v0,10		#Exits Program
	syscall

alwZero:
	li $t1,0
	j rest