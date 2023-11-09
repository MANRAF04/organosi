.macro READ_INT
li $v0, 5
syscall
.end_macro

.macro PRINT_STR(%s)
.data
str: .asciiz %s
	.text
	li $v0,4
	la $a0,str
	syscall
.end_macro

.macro READ_INT_ARR (%arr,%size)
li $t4,0

loop:
	bge $t4,%size,end
	READ_INT
	move $t3,$v0
	sw $t3,0(%arr) 
	addi %arr,%arr,4
	addi $t4,$t4,1
	j loop 
end:
.end_macro

.macro PRINT_INT_ARR (%arr,%size)
li $t4,0
loop:
	bge $t4,%size,end
	lw  $a0,0(%arr) 
	addi %arr,%arr,4
	addi $t4,$t4,1
	li $v0,1
	syscall
	PRINT_STR("\n")
	j loop 
end:
	PRINT_STR("END OF ARRAY\n")
.end_macro

.macro ADD_TO_OUT(%lessnum,%lessarr,%lesscount)
meth:
	sw %lessnum,($t0)
	addi $t0,$t0,4
	addi %lesscount,%lesscount,1
	addi %lessarr,%lessarr,4
.end_macro

.data
prompt: .asciiz "Enter an integer: "
.align 2
in1: .space 1000
.align 2
in2: .space 1000
.align 2
out: .space 2000


.text
main:
  	
  	PRINT_STR("\tArray 1\nEnter in1 size:")
  	
  	READ_INT
	move $s1,$v0
	la $s0,in1
	READ_INT_ARR($s0,$s1)
	la $s0,in1
	#PRINT_STR("\tArray 1\n")
	#PRINT_INT_ARR($s0,$s1)

	PRINT_STR("\tArray 2\nEnter in2 size:")
  	READ_INT
	move $s3,$v0
	la $s2,in2
	READ_INT_ARR($s2,$s3)  
  	la $s2,in2
  	#PRINT_STR("\tArray 2\n")
  	#PRINT_INT_ARR($s2,$s3)  	
	la $a0,in1	#In1
	move $a1,$s1	#Size1
	la $a2,in2	#In2
	move $a3,$s3	#Size2
	
	la $s4,out
	add $s5,$s1,$s3
	
	addi $sp,$sp,-4
	sw $s4,($sp)
	
	jal merge

	addi $sp,$sp,4
  	PRINT_STR("\tOut Array\n")
  	PRINT_INT_ARR($s4,$s5)  	
  	
exit:
	li $v0, 10
	syscall

merge:
	lw $t0,($sp)	#Out arr
	li $t1,0	#Counter for in1
	li $t2,0	#Counter for in2
	
	loop:
		beq $t1,$a1,rest2
				
		beq $t2,$a3,rest1
		lw $t3,($a0)
		lw $t4,($a2)
		
		beq $t3,$t4,both
		bgt $t3,$t4,oneBigger
		ADD_TO_OUT($t3,$a0,$t1)
		j loop
	oneBigger:
		ADD_TO_OUT($t4,$a2,$t2)
		j loop
	both:
		ADD_TO_OUT($t3,$a0,$t1)
		ADD_TO_OUT($t4,$a2,$t2)
		j loop
	rest1:
		beq $t1,$a1,end
		lw $t3,($a0)
		ADD_TO_OUT($t3,$a0,$t1)
		j rest1
	rest2:
		beq $t2,$a3,end
		lw $t4,($a2)
		ADD_TO_OUT($t4,$a2,$t2)
		j rest2

	end:
		jr $ra
