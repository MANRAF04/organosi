.data
in1: .word -5, 0, 2, 11
in2: .word -2, 0, 1, 13, 15
size1: .word 4
size2: .word 5

.text
.globl main
main:
    la		$a1, in1		# 
    la		$a2, in2		# 
    
    lw		$a3, size1		#
    lw		$a0, size2		#
    add     $t1, $a0, $a3
    sll		$t1, $t1, 2			# $ = $t1 << 0
    
    sub		$sp, $sp, $t1		# $sp = $sp + $t1
    
    jal		merge				# jump to merge and save position to $ra
    

merge:
    lw		$t1, $a3		# size1
    lw		$t2, $a0		# size2
    la      $t3, $a1
    la      $t4, $a2
    la      $t5, $s8


exit:
    li		$v0, 10		# $v0 = 10
    syscall
    