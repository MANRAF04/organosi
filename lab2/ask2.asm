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
    add $s3,$s3,$s0

	move $a0,$s3
	move $a1,$s1
	move $a2,$s2

    jal bits_read

    move $t0,$v0
    li $t1,1
    sll $t1,$t1,31
    printBin:
    	beqz $t1,end
    	and $t2,$t0,$t1
    	srl $t1,$t1,1
    	beqz $t2,printZero
    	print_int(1)
    	j printBin
    	printZero:
    	print_int(0)
    	
    	j printBin
end:
	li $v0, 10
	syscall

bits_read:
    li $t9, 0   #counter
    li $v0, 0   #result
    loop:
        lb		$t1, ($a0)
        li		$t0, 128
        srlv		$t0, $t0, $a1
        and		$t3, $t1, $t0
        addi		$a1,$a1,1
        bnez    $t3, changeRes
        rest:
        addi    $t9,$t9,1
        bge	$t9,$a2,exit
        bgtz	$t0, loop
        addi	$t9,$t9,-1
        
        li	$a1,0
        addi 	$a0,$a0,1
        blt     $t9,$a2,loop
        exit:
        jr      $ra
    changeRes:
        sub $t7,$a2,$t9
        addi $t7,$t7,-1
        li $t6,1
        sllv $t6,$t6,$t7
        or $v0,$v0,$t6
        j rest
