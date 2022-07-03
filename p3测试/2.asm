lw $5,0($s2)#input
lw $t1,0($s1)#output
beq $5,$6,cnt
sw $5,0($s1)
sw $5,4($s1)
j stop
cnt:lw $t7,4($s1)#++
addiu $t7,$7,1
sw $t7,4($s1)
stop:ori $t3,$0,1000
sw $t3,4($s0)#CTRL
ori $t4,$0,9
sw $t4,0($s0)#PRESET
eret
