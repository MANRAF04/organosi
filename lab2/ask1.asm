# MACROS
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
li $t4,0    # $t4 = index for read the array's elements

loop:
	bge $t4,%size,end   # if $t4 >= size we reached the end
	READ_INT
	move $t3,$v0
	sw $t3,0(%arr)      # store the int to the array's index position
	addi %arr,%arr,4    # go to the next int spot
	addi $t4,$t4,1      # add index by one
	j loop 
end:
.end_macro

.macro PRINT_INT_ARR (%arr,%size)
li $t4,0    # $t4 = index for read the array's element
loop:
	bge $t4,%size,end   # if $t4 >= size we reached the end
	lw  $a0,0(%arr)     # prepare the int element on the index position to be printed
	addi %arr,%arr,4    # go to the next int spot
	addi $t4,$t4,1      # add index by one
	li $v0,1
	syscall             #print the int with and change line
	PRINT_STR("\n")
	j loop 
end:
	PRINT_STR("END OF ARRAY\n")
.end_macro

# A Macro to put a new element to the output array
.macro ADD_TO_OUT(%lessnum,%lessarr,%lesscount)
# lessnum = element int, lessarr = element's array, lesscount = elements' index
meth:
	sw %lessnum,($t0)       # store the element to the output array
	addi $t0,$t0,4          # go to the next int spot of the merged array
	addi %lesscount,%lesscount,1    # add index by one
	addi %lessarr,%lessarr,4    # go to the next int spot of the elements' array
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
	la $s0,in1                  # store in1 array from the user to $s0
	READ_INT_ARR($s0,$s1)
	la $s0,in1

	PRINT_STR("\tArray 2\nEnter in2 size:")
  	READ_INT
	move $s3,$v0
	la $s2,in2                  ## store in1 array from the user to $s0
	READ_INT_ARR($s2,$s3)  
  	la $s2,in2

	la $a0,in1	    
	move $a1,$s1	      # Prepare arguments for the merge function call
	la $a2,in2	    
	move $a3,$s3	

	la $s4,out          # store the output array's pointer in $s4
	add $s5,$s1,$s3     # store the output array's size in $s5
	
	addi $sp,$sp,-4     # make room for the array pointer in the stack
	sw $s4,($sp)        # store the output array pointer to the stack
	
	jal merge

	addi $sp,$sp,4      # release the used room in the stacked
  	PRINT_STR("\tOut Array\n")
  	PRINT_INT_ARR($s4,$s5)  	    # print the output array
  	
exit:
	li $v0, 10      # exit program
	syscall

merge:
# $a0 = in1, $a1 = size1, $a2 = in2 $a3 = size2, stack1 = output array pointer 

	lw $t0,($sp) # $t0 = Out arr
	li $t1,0	# counter1 for in1
	li $t2,0	# counter2 for in2
	
	loop:
		beq $t1,$a1,rest2   #if counter1 == size2, then put the rest in2 elements to the merged array 			
		beq $t2,$a3,rest1   #if counter2 == size, then put the rest in1 elements to the merged array
		lw $t3,($a0)        # $t3 = in1[0]
		lw $t4,($a2)        # $t4 = in2[0]
		
		beq $t3,$t4,both            # if in1[i] == in2[i], then put both elements to merged array
		bgt $t3,$t4,oneBigger       # if in1[i] > in2[i], then go to oneBigger branch
		ADD_TO_OUT($t3,$a0,$t1)     # if in1[i] < in2[i], add in1[i] to the merged array
		j loop
	oneBigger:
		ADD_TO_OUT($t4,$a2,$t2)     # add in2[i] to the merged array
		j loop
	both:
		ADD_TO_OUT($t3,$a0,$t1)     # add in1[i] to the merged array
		ADD_TO_OUT($t4,$a2,$t2)     # add in2[i] to the merged array
		j loop
	rest1:
		beq $t1,$a1,end     # if counter1 == size1, go to the end
		lw $t3,($a0)        # load the current element of in1 to $t3
		ADD_TO_OUT($t3,$a0,$t1)     # add the element to the merged array
		j rest1     # repeat until you reached the end of in1
	rest2:
		beq $t2,$a3,end     # if counter2 == size2, go to the end
		lw $t4,($a2)        # load the current element of in2 to $t4
		ADD_TO_OUT($t4,$a2,$t2)     # add the element to the merged array
		j rest2     # repeat until you reached the end of in2

	end:
		jr $ra
