.text
.globl main            		# label "main" must be global

main:

label: add $t1, $t0, $a0  
       sw $t1, 5($t3)     
       lw $s2, 5($t3),    
       slt $t1, $t0, $s3  
       addi $s0, $s0, 1   
       beq $t1, $at, label
