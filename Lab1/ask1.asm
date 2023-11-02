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
	

	li $t1, 32
	li $v0,1
	move $a0,$s0		#Prints number
	syscall
	
	li $v0,4
	la $a0,has_text
	syscall
	
loop:
	beq $s0,0, print
	srl $s0,$s0,1
	subi $t1, $t1, 1
	j loop
	
print:	

	li $v0,1
	move $a0, $t1		#Prints amount of leading zeroes
	syscall
	
	li $v0, 4
	la $a0, zer_text	
	syscall
	
	la $v0,10		#Exits Program
	syscall
