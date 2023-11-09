# MACROS
.macro print_int (%x)
li $v0, 1
add $a0, $zero, %x
syscall
.end_macro

.macro READ_INT
li $v0, 5
syscall
.end_macro

.macro print_str (%str)
.data
myLabel: .asciiz %str
	.text
	li $v0, 4
	la $a0, myLabel
	syscall
.end_macro


.data
array:
	.byte 0x70,0x8C,0xF3,0x82,0x1B,0x9D,0x52,0x3C,0x46
	
.text
.globl main


main:
	print_str("Enter pointer:\n")
	READ_INT
	move $s0, $v0
	
	print_str("Enter offset:\n")
	READ_INT
	move $s1, $v0
	
	print_str("Enter nbits:\n")
	READ_INT
	move $s2, $v0
	
    la $s3, array       
    add $s3,$s3,$s0     # Load the beggining array element

	move $a0,$s3
	move $a1,$s1        # Prepare the arguments for the function call
	move $a2,$s2        

    jal bits_read

    move $t0,$v0
    li $t1,1            
    sll $t1,$t1,31      # create a 32-bit mask with "1" only in the beginning
    printBin:
    	beqz $t1,end    # if mask == 0 we reached the end
    	and $t2,$t0,$t1 # perform and with the mask that focuses on the current bit
    	srl $t1,$t1,1   # move the "1" to the next bit
    	beqz $t2,printZero  # if the and is full of zeros the bit is "0"
    	print_int(1)        # else bit is "1"
    	j printBin
    	printZero:
    	print_int(0)
    	
    	j printBin
end:
	li $v0, 10      # Exit program
	syscall

bits_read:
    # $a0 = starting array element, $a1 = offset, $a2 = nbits
    li $t9, 0   #$t9 = counter of bits checked
    li $v0, 0   #$v0 = result
    loop:
        lb		$t1, ($a0)   # $t1 = $a0
        li		$t0, 128    # our mask $t0 = 1000 0000
        srlv	$t0, $t0, $a1   # shift mask offset times
        and		$t3, $t1, $t0   # $t3 = $t1 and $t0
        addi	$a1,$a1,1       # increase offset by one 
        bnez    $t3, changeRes  # if $t3 != 0 then we need to update our bits result with the new 1 bit
    rest:
        addi    $t9,$t9,1       # add counter by one
        bge	    $t9,$a2,exit    # if counter == nbits we have finished
        bgtz	$t0, loop       # if mask == 0 we need to refresh it to 1000 0000
        addi	$t9,$t9,-1      # counter should not be increased in case we are at the step of switching elements
        
        li	    $a1,0          # next element should be read from the MSB 
        addi 	$a0,$a0,1      # icrease $a0 to the next array element
        blt     $t9,$a2,loop   # return to loop if $t9 is less than nbits
    exit:
        jr      $ra
    changeRes:
        sub $t7,$a2,$t9
        addi $t7,$t7,-1
        li $t6,1
        sllv $t6,$t6,$t7       # set the new bit to its proper location,(nbits - counter - 1) from the right
        or $v0,$v0,$t6         # perform or to add the new bit to the result in the correct position
        j rest
