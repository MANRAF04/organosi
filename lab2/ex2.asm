.macro print_int (%x)
li $v0, 1
add $a0, $zero, %x
syscall

# Print a newline character.
li $v0, 11
li $a0, '\n'
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
	
	lb $t0, 0($s3)
	print_array($s3, $s2)
	
	

end:
	li $v0, 10
	syscall