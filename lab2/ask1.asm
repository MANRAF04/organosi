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
    	la $a0, prompt
    	li $v0, 4
    	syscall
  	
  	READ_INT
	move $s1,$v0
	la $s0,in1
	READ_INT_ARR($s0,$s1)
	la $s0,in1
	PRINT_STR("\tArray 1\n")
	PRINT_INT_ARR($s0,$s1)

  	READ_INT
	move $s3,$v0
	la $s2,in2
	READ_INT_ARR($s2,$s3)  
  	la $s2,in2
  	PRINT_STR("\tArray 2\n")
  	PRINT_INT_ARR($s2,$s3)  	
  	
exit:
	li $v0, 10
	syscall
