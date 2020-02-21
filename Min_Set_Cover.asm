#####################################
#	OÐUZHAN ÞENTÜRK             #
#		                    #
#	osenturk@gtu.edu.tr         #
#####################################
.data  
	fileName: .asciiz "input.txt"      # filename for input
	string: .space 1024		   # to store set and subset
	star: .asciiz "*"		   # to replace subset
	minus:.asciiz "-"		   # to replace set
	tab : .asciiz "     "		   # to print more smoothly
	promt: .asciiz "\n---MIN-SET-COVER---\n"
# Register Table
# $s7 = address of set
# $s6 = address of star character
# $s1 = address of minus character
# $s5 = address of first subset
# $s2 = address of subset which max intersect
.text
# Open file for reading
	li   $v0, 13          	# system call for open file
	la   $a0, fileName    	# input file name
	li   $a1, 0           
	syscall              	# open a file 
	move $t0, $v0       	# save the file descriptor  
# Reading from file 
	li   $v0, 14        	# system call for reading from file
	move $a0, $t0       	# file descriptor 
	la   $a1, string    	# address which to read
	li   $a2, 1024      	# string size    
	syscall             	# read from file
# This registers to be used later
	la $s7, string      	# load address of set to register
	la $s6, star	   	# load address of star to register
	la $s1, minus	   	# load address of minus to register
	move $t7, $s7  	    	# iterator		
# Printing File Content
	li  $v0, 4          	# system Call for PRINT STRING
	la  $a0, string     	# address which to print
	syscall             
# Printing "\n---MIN-SET-COVER---\n"
	li  $v0, 4          	# system Call for PRINT STRING
	la  $a0, promt      	# address which to print
	syscall             
# Loop for save first subset address this address used to be find the least number of sets that can cover set		
loop:
	lb $t1, 0($t7) 		# load character
	beq $t1, '\n', exit	# if character equal to \n , set is finished
	addi $t7, $t7, 1	# iterator ++
	j loop
# Save first subset adress
exit:
	addi $t7, $t7, 1
	move $s5, $t7 	     
# Find max intersect subset
control: 
	move $t5, $s5 	 	# adress of subset which max intersect
	move $t7, $s5 	 	# iterator to traverse subsets
	move $s4, $zero  	# variable max store count of character which max intersect
	
for2:
	move $s3, $zero		# variable count store count of character which intersect for every subset
	
for4:
	move $t6, $s7  		# Address of set, you can check register table at the begining of program	
		
for3:
	lb $t1, 0($t7)		# character of subset
	lb $t2, 0($t6) 		# character of set
	beq $t1, '\0', check	# check end of string
	beq $t1, '\n', check	# check end of subset
	beq $t2, '\n', check2	# check end of set
	beq $t2, $t1, if	# if character of subset equal to character of set
	addi $t6, $t6, 1	# address of set ++
	j for3
check: 
	blt $s4, $s3, label	# if max < count go to label
	beq $t1, '\0', exit3	# check end of string	
	addi $t7, $t7, 1	# address of subset ++
	move $t5, $t7
	j for2
		
if:
	addi $s3, $s3, 1 	# count++
	addi $t7, $t7, 1	# address of subset ++
	j for4

label:  
	move $s4, $s3 		# max = count
	move $s2, $t5 		# save address of subset which max intersect 
	beq $t1, '\0', exit3	# check end of string
	addi $t7, $t7, 1	# address of subset ++
	move $t5, $t7
	j for2
	
check2:
	addi $t7, $t7, 1	# address of subset ++
	j for4

exit3:
	li  $v0, 4         	# system Call for PRINT STRING
	la  $a0, tab     	# address which to print
	syscall    
	beq $s4, $zero, exit2	# if max = 0 terminate program this means subsets covers set
	lb $t3, 0($s6) 	    	# "*" character for replacement string
	lb $t4, 0($s1) 	    	# "-" character for replacement string
	move $t7, $s2		# address of subset which max intersect
hop4:	
# Print subset which max intersect
	lb $t1, 0($t7)		# character of subset which max intersect
	beq $t1, '\n', hop5	# check end of subset
	beq $t1, '\0', hop5	# check end of subset
	jal print
	addi $t7, $t7, 1	# address of subset which max intersect ++
	j hop4
# Replace string 	
hop5:
	move $t7, $s2		# address of subset which max intersect
hop:	
	move $t6, $s7		# address of set
	
hop2:
	lb $t1, 0($t7)		# character of subset which max intersect
	lb $t2, 0($t6) 		# character of set
	beq $t1, '\n', control	# check end of subset
	beq $t1, '\0', control	# check end of subset
	beq $t2, '\n', hop3	# check end of set
	beq $t1, $t2, replace	# if character of subset which max instersect equal to character of set
	addi $t6, $t6, 1	# address of set ++
	j hop2
	
replace:
	sb $t3, 0($t7)		# Replace * character you can look .data segment
	sb $t4, 0($t6)		# Replace - character you can look .data segment
	addi $t7, $t7, 1	# address of subset which max intersect ++
	j hop
	
hop3:
	addi $t7, $t7, 1	# address of subset which max intersect ++
	j hop
	
print:	
# print character
	move $a0, $t1
	li $v0, 11 
	syscall
	jr $ra
	
exit2:
# Close file
 	li   $v0, 16       
  	move $a0, $t0     
  	syscall    
# End of Program
	li $v0, 10     	    # Finish the Program
	syscall
