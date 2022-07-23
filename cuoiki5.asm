.data
infix: 	 .space 100
postfix: .space 100
stack:	 .space 100
prompt_infix: .asciiz  "Nhap vao bieu thuc: \nNote: Toang hang thuoc doan [0,99], toan tu bao gom +,-,*,/ "
message_infix: .asciiz "Bieu thuc da nhap: "
message_postfix: .asciiz "Bieu thuc hau to: "
message_result: .asciiz "\nKet qua bieu thuc: "
.align 2 
array_base: .word 4
.text
#______________________________________________________________
#@Tom tat: Nhap va in ra bieu thuc vua nhap

main:
	li $v0, 54
 	la $a0, prompt_infix
	la $a1, infix		
	la $a2, 256
	syscall  
 
	la $a0, message_infix
	li $v0, 4
	syscall
	
	la $a0, infix
	li $v0, 4
	syscall
#_________________________________________________________________
#@Tom tat:	Gan gia tri cua cac toan tu vao thanh ghi
#@Tham so ra	$s4	: +
#@Tham so ra	$s5	: -
#@Tham so ra	$s6	: *
#@Tham so ra	$s7	: /
#_________________________________________________________________
	addi $s4,$zero,'+'	#Luu toan tu + vao thanh ghi $s4
	addi $s5,$zero,'-'	#Luu toan tu - vao thanh ghi $s5
	addi $s6,$zero,'*'	#Luu toan tu * vao thanh ghi $s6
	addi $s7,$zero,'/'	#luu toan tu / vao thanh ghi $s7
	addi $k0,$zero,' '	#Luu dau cach vao thanh ghi $k0
#_________________________________________________________________	
	la $s0,infix	#$s0 chua dia chi chuoi infix
	la $s1,postfix	#$s1 chua dia chi chuoi postfix
	la $s2,stack	#$s2 chua dia chi chuoi stack
	
	addi $t0,$zero,-1	# chi so cua chuoi infix
	addi $t1,$zero,-1	# chi so cua chuoi postfix
	addi $t2,$zero,-1	# chi so cua chuoi stack
loop: 
	addi $t0,$t0,1		#chi so chuoi infix +1
	add $t3,$s0,$t0		# $t3 = infix[chi so]
	lb $t4,0($t3)
	
	beq $t4,$s4,operator	# +
	beq $t4,$s5,operator	# -
	beq $t4,$s6,operator	# *
	beq $t4,$s7,operator	# /
	beq $t4,10, endloop	# \n

	#day vao postfix 
	addi $t1,$t1,1
	add $t5,$t1,$s1
	sb $t4 , 0($t5)
	
	lb $a0,1($t3)		#$a0 = infix[chiso+1]
			
	jal check_number
	beq $v0, 1,loop
	jal add_space
	j loop

operator: 	
	beq $t2,-1,push_to_stack	#neu stack rong thi day vao stack
	#neu stack khac rong, lay ra tung phan tu trong stack de so sanh muc do uu tien
	add $t7,$s2,$t2		
	lb $t8 , 0($t7)
	beq $t8 ,$s4,t2	# + -> nhay den t2
	beq $t8,$s5,t2	# - -> nhay den t2
	li $a1,2	# khac + - : muc do uu tien = 2
	j check_t1
	
t2: 	li $a1,1	# gan muc do uu tien =1
	
check_t1:	
	beq $t4,$s4,t1		# + -> nhay den t1
	beq $t4,$s5,t1		# - -> nhay den t1
	li $a0,2		# khac + - -> muc do uu tien =2
	j compare_t1_t2
t1: 
	li $a0,1

compare_t1_t2:
ble $a0,$a1,ge_precedence	#muc do uu tien toan tu dang xet <= muc do uu tien toan tu dau cua stack -> jump 
	
push_to_stack:
	addi $t2,$t2,1	
	add $t6,$s2,$t2
	sb $t4,0($t6)
	jal add_space
	j loop
#-----------------------------------------------------------------
#Tom
#-----------------------------------------------------------------
ge_precedence:
		
	addi $t1,$t1,1	#chi so postfix +1
	add $t5,$s1,$t1	#dia chi can day vao postfix
	sb $t8 , 0($t5)	# day top stack -> postfix 
	jal add_space	
	addi $t2,$t2-1
	j operator
#-----------------------------------------------------------------
endloop: 
pop_all_stack:
	beq $t2,-1,print_postfix # neu chi so dau stack = -1 -> stack rong -> in postfix
	add $t7,$s2,$t2		#$t7 chua dia chi phan tu cau stack
	lb $k1,0($t7)		#$k1 chua gia tri tai dia chi $t7
	addi $t1,$t1,1		#tang chi so postfix
	add $t3,$s1,$t1		#$t3 chua dia chi cuoi chuoi postfix
	sb $k1,0($t3)		#day dau vao postfix
	jal add_space		#them dau ' '
	addi $t2,$t2,-1		# giam chi so stack
	j pop_all_stack
print_postfix:
		la $a0, message_postfix
		li $v0, 4
		syscall
		
		li $v0,4
		la $a0,postfix
		syscall
#-----------------------------------------------------------------
#@Tinh gia tri bieu thuc
#@Dau vao  @s0 : postfix
#@Dau vao: $s1	:array_base
#-----------------------------------------------------------------
	la $s0,postfix		#Luu dia chi co so cua chuoi postfix ->$s0
	la $s1,array_base	#Luu dia chi co so cua mang chua toan hang -> $s1
	addi $t0,$zero,-1	#Chi so khoi tao i = -1 -> $t0
	addi $t1,$zero,-1
loop_postfix:
	addi $t0,$t0,1		#i=i+1
	add $t2,$s0,$t0		#dia chi cua ki tu dang xet
	lb $t3,0($t2)		#lay gia tri cua ki tu dang xet -> $t2
	
	beq $t3,$s4,operator_add	#gia tri trong thanh ghi $t3 = +
	beq $t3,$s5,operator_sub	#gia tri trong thanh ghi $t3 = -
	beq $t3,$s6,operator_mul	#gia tri trong thanh ghi $t3 = *
	beq $t3,$s7,operator_div	#gia tri trong thanh ghi $t3 = /
	beq $t3,' ',loop_postfix	#gia tri trong thanh ghi $t3 = ' ' 
	beq $t3,$zero,end_loop_postfix	##gia tri trong thanh ghi $t3 = '/0' -> end loop
	
	lb $a0,1($t2)
	jal check_number	#check ki tu sau co phai la chu so hay khong
	beq $v0,1,get_value_2	# Neu la so thi nhay toi ham get_value_2 -> lay gia tri cua so co 2 chu so

	add,$t3,$t3,-48		#Neu ki tu tiep khong phai chu so, lay gia tri cua so co 1 chu so	
	addi $t1,$t1,1
	sll $t4,$t1,2
	add $t4,$t4,$s1
	sw $t3 ,0($t4)
	j loop_postfix	
#----------------------------------------------------------------
#@Tom tat  Lay gia tri cua so co 2 chua so
#@Dau vao  $t3 : chu so hang chuc
#@Dau vao  $a0 : chu so hang don vi
#@ Ra: Day gia tri vao array_base
#---------------------------------------------------------------
get_value_2: 
		addi $t3,$t3,-48
		addi $a0,$a0,-48
		mul $t3,$t3,10
		add $t4,$t3,$a0
		
		addi $t1,$t1,1
		sll $t5,$t1,2
		add $t5,$t5,$s1
		sw $t4 ,0($t5)
		addi $t0,$t0,1
		
		j loop_postfix
#-------------------------------------------------------------------
#@Tom tat: 	Luu so co chi so i -> $t5 , i-1 ->$t7
#@operator_add : $t7+$t5 -> $t8 -> day vao dau array
#operator_sub  : $t7-$t5 -> $t8 -> day vao dau array
#operator_mul  : $$t7*$t5 -> $t8 -> day vao dau array
#operator_div  : $t7/$t5 -> $t8 -> day vao dau array
#------------------------------------------------------------------	
operator_add:
	sll $t5,$t1,2
	add $t5,$s1,$t5
	lw $t5,0($t5)
	
	addi $t1,$t1,-1
	sll $t6,$t1,2
	add $t6,$s1,$t6
	lw $t7,0($t6)
	
	add $t8,$t5,$t7
	sw $t8,0($t6)
	j loop_postfix
operator_sub:
	sll $t5,$t1,2
	add $t5,$s1,$t5
	lw $t5,0($t5)
	
	addi $t1,$t1,-1
	sll $t6,$t1,2
	add $t6,$s1,$t6
	lw $t7,0($t6)
	
	sub $t8,$t7,$t5
	sw $t8,0($t6)
	j loop_postfix
operator_mul:
	sll $t5,$t1,2
	add $t5,$s1,$t5
	lw $t5,0($t5)
	
	addi $t1,$t1,-1
	sll $t6,$t1,2
	add $t6,$s1,$t6
	lw $t7,0($t6)
	
	mul $t8,$t7,$t5
	sw $t8,0($t6)
	j loop_postfix
operator_div:
	sll $t5,$t1,2
	add $t5,$s1,$t5
	lw $t5,0($t5)
	
	addi $t1,$t1,-1
	sll $t6,$t1,2
	add $t6,$s1,$t6
	lw $t7,0($t6)
	
	div $t8,$t7,$t5
	sw $t8,0($t6)
	j loop_postfix
#-----------------------------------------------------------------
#@ in ra man hinh ket qua bieu thuc
#-----------------------------------------------------------------
end_loop_postfix:
	lw $s2,0($s1)
	li $v0,4
	la $a0,message_result
	syscall
	
	li $v0,1
	move $a0,$s2
	syscall
	
		
#-----------------------------------------------------------------

Exit:	li $v0,10
	syscall		
#---------------------------------------------------------------
#brief them dau cach	
add_space:
	addi $t1,$t1,1
	add $t5,$s1,$t1
	sb $k0,0($t5)
	jr $ra
#-----------------------------------------------------------------
# @tom tat 	kiem tra ki tu dang xet co phai so hay khong
# @Tham so dau vao: $a0 : ki tu dang xet
# @Tham so dau ra:  $v0 : 1 = dung; 0 = sai
#-----------------------------------------------------------------
check_number:        
	li $t8, '0'
	li $t9, '9'
	
	beq $t8, $a0, check_number_true
	beq $t9, $a0, check_number_true
	
	slt $v0, $t8, $a0
	beqz $v0, check_number_false
	
	slt $v0, $a0, $t9
	beqz $v0, check_number_false	
	
	check_number_true:
	li $v0, 1
	jr $ra
	check_number_false:	
	li $v0, 0	
	jr $ra 
#-------------------------------------------------------------------















