.data 

	.align 2
	array_size: .word 4
	array_base: 
		   .word 5
		   .word 5
		   .word 4
		   .word 10
		  output: .asciiz "arrayChange= "

.text 
.globl main
#--------------------------------------------------------------------------------------------
# @param[in]	$a0	Address of array
# @param[in]	$a1	Size of array
# @param[out]	$s2	array change	
#--------------------------------------------------------------------------------------------
main: 
	la $a0,array_base	# address array -> $a0
	lw $a1, array_size	# size array -> $a1
	
	addi $t0,$zero,-1	# index array -> $t0
	addi $s2,$zero,0	#result -> $s2, initialization value = 0
	loop: 
		addi $t0,$t0,1	# i=i+1
		sll $t2,$t0,2	# $t2=$t0 *4 = 4*i
		add $t2,$a0,$t2 # address of array[i] -> $t2
		lw $s0,0($t2)	# $s0=value of array[i]
		
		addi $t1,$t0,1	# $t1=i+1
		sll $t3,$t1,2 	# $t3=4*t1 = 4(i+1)
		add $t3,$a0,$t3 # address of array[i+1] -> $t3
		lw $s1,0($t3)	# $s1=value of array[i+1]
		
		beq $t1,$a1,continue	#if $t5=$a1 = size_array -> branch continue
	
		blt $s0,$s1,loop# if array[i] < array[i+1] -> branch loop

		addi $s0,$s0,1	#  $s0=$s0+1
		sw $s0,0($t3)	# array[i+1]=array[i] +1
		sub $t4,$s0,$s1 # $t4 = $s0-$s1 = array[i] +1 - array[i+1]
		add $s2 ,$s2,$t4# result = result + the minimal number of moves array[i]<array[i+1]
		
		addi $t5,$t0,2  # $t5 = $t0+2= i + 2
		beq $t5,$a1,continue	#if $t5=$a1 = size_array -> branch continue
		j loop		#else j loop
		
	
#--------------------------------------------------------------------------------------------
# @brief 		Print result
# @param[in]	$a0	Address of array
# @param[in]	$s2	Array change to print
# @param[out]	Print message output + result array change
#--------------------------------------------------------------------------------------------
	continue: 
		addi $v0,$zero,56
		move $a1,$s2
		la $a0, output
		syscall 
#--------------------------------------------------------------------------------------------
# @brief Exit
#--------------------------------------------------------------------------------------------
		addi $v0,$zero,10 #exit
		syscall
		
	
