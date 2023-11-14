# MACROS
.macro print_str (%str)

	.data
	myLabel: .asciiz %str
	.text
	li $v0, 4
	la $a0, myLabel
	syscall

.end_macro

.data
	input: .space 101
	inputSize: .word 100

.text
.globl main

main:
	li $v0, 8
   	la $a0, input
	lw $a1, inputSize
	syscall
	
	jal rmEnter
	
	move $s0,$v0	#Index of last character
	addi $s0,$s0,-1
	
	la $a0, input
	move $a1, $s0

	jal is_symmetric
	move $s1, $v0

	print_str("String ")
	la $a0,input
	li $v0, 4
	syscall

	beqz $s1,notsym
	print_str(" is symmetric.\n")

	j end
	notsym:
		print_str(" is not symmetric.\n")
		

	end:
		li $v0, 10
		syscall

rmEnter:
	li $t3, 0	#'\0'
	li $v0,-1	#Returns index of last character 0 if empty

	loop:
		addi $v0,$v0,1	
		lb $t0, ($a0)	#Loads current char

		beq $t0, 10, foundIt	#If it found '\n' changes it to '\0'

		add $a0, $a0, 1
		j loop
	
	foundIt:
		sb $t3, ($a0)
		jr $ra

is_symmetric:
	# $a0 = input, $a1 = last character index
	blez $a1,issym	#Base case: last unchecked character index is either 0 or less, we have 1 character left at most
	
	lb $t0, ($a0)	#First unchecked character
	move $t1, $a0	#Temp stores the start of the unchecked string
	add $t1, $t1, $a1	#Gets to the index of the last unchecked character
	lb $t2, ($t1)	#Last unchecked character

	bne $t0,$t2,isnotsym	#Mirrored characters differ 

	addi $sp, $sp, -4	#Make space in stack
	sw $ra, ($sp)	#Store previous return address in stack

	addi $a0, $a0, 1	#Get to the rest unchecked string address
	addi $a1, $a1, -2	#We have checked 2 characters so we remove 2

	jal is_symmetric	#Recursive call of the function

	lw $ra, ($sp)	#Load the previous return address from the stack
	addi $sp, $sp, 4	#Reset the stack pointer

	jr $ra	

	isnotsym:
		li $v0,0
		jr $ra
	issym:
		li $v0,1
		jr $ra