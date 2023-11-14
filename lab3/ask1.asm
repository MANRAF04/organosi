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
    	
	#li $v0, 4
    	#la $a0, input
    	#syscall
    	
    	li $v0,11
    	la $t0, input
    	add $t0,$t0,$s0
    	#lb $a0,($t0)
    	#syscall
    	
    	jal is_symmetric

is_symmetric:
	# $a0 = input, $a1 = input_size
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a1, 4($sp)
	sw $a0, 0($sp)

end:
	li $v0, 10
	syscall

rmEnter:
	li $t3, 0
	li $v0,-1
	loop:
		addi $v0,$v0,1
		lb $t0, ($a0)
		beq $t0, 10, foundIt
		add $a0, $a0, 1
		j loop
	
	foundIt:
		sb $t3, ($a0)
		jr $ra