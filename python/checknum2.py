# Python program for checking though tesseract result, comparing numbers and telling out how many numbers are skipped
# By John Xu
#
#
#				History
# V0.1	First version, 2 continued numbers confirm the jump, can be fooled easily
# V0.2  Use separate module to check jumps, to confirm jump the continued number needed can be set to 3 or even higher
#		Also 4 lists are used to track 4 different possible value group, to find out which one is real
#
#
# When jump followed by jump, it lost trace and can not update numNew, need better process
import sys
inputfile = sys.argv[1]
import pdb					# For debug

#Constant
MaxJump=10					# Maximum acceptable jump number, otherwise will be discarded, set to 4 to avoid 1->7 error
#Global variables
numStart=-1
numCurrent=-1
totalSkip=0

#import checkJump
#------------------------------------------------------------------------------------------------------------------
# New check jump module

#Static variables
dataForCheck=[]
dataSeq0=[]
dataSeq1=[]
dataSeq2=[]
dataSeq3=[]
#Global variables

jumpNo=0
#Constants
confirmNo=3												# How many number continued will be confirmed as jumped to here
def checkContinue(number1,number2):
	if((number2-number1) in [0,1]):
		return True
	else:
		return False
def clearJumpLists():
	dataForCheck[:]=[]
	dataSeq0[:]=[]
	dataSeq1[:]=[]
	dataSeq2[:]=[]
	dataSeq3[:]=[]

# Check if the number is continuous to the last element of the list
# If yes (or the list is empty), add the number to the list and return True
# Otherwise return False
def checkJumpList(alist,number):				

	length=len(alist)									# Get the last element index
	if(length > 0):										# Not empty, then check the last element
		if(not checkContinue(alist[length-1],number)):	# Check if the new number continues with the last one in this list
			return False
	alist.append(number)								# Yes, or empty list, then add new number to this list
	return True

def numJumped(number):
	global dataForCheck, dataSeq0, dataSeq1, dataSeq2, dataSeq3
	global jumpNo,numStart								# These global variables will be modified in this block, must be specified
	dataForCheck.append(number)							# add to the check data list
	
	for alist in [dataSeq0, dataSeq1, dataSeq2, dataSeq3]:
		if(checkJumpList(alist,number)):				# If the number is accepted by this list, then check if confirmNo is reached
			length=len(alist)
			if(length>=confirmNo):						# The list size is greater than confirmNo, then the jump is confirmed
														# then set jumpNo and return true
				pdb.set_trace()
				if(numCurrent==-1):
					numStart=alist[0]
					jumpNo=0
				else:
					jumpNo=alist[0] - numCurrent -1
					index=dataForCheck.index(alist[0])		# Get the index of the first element in dataForCheck list
					for i in range(0,index):
						if(numCurrent<dataForCheck[i]<number):
							jumpNo-=1						# Check if data before our first confirmed number is also less than it
														# if it is true then jumpStep should be decreased by 1. 
				clearJumpLists()						# In case the jump is comfirmed, now clear all lists
				return True
			else:
				return False

# If program reaches here, means a new non-continued number appeared. I will clear 2 smallest lists, and move the 2 un-empty lists
# to seq0 and seq1.
# It is not likely to happen, so I just clear the last list temperarily
	dataSeq3[:]=[]
	checkJumpList(dataSeq3,number)
	return False
#====================================================================================================================================
def numContinued(number):
	global numNew, numCurrent
	if(numCurrent==-1):
		return False
	elif ((number-numCurrent) in [0,1]):
		numCurrent=number
		clearJumpLists()					#clear jump lists
		return True
	else:
		return False

def process(number):
	global numCurrent,totalSkip
	if((number<numCurrent)or((numCurrent!=-1)and((number-numCurrent)>MaxJump))):
		print "invalid number %d" %number
		return
	print(number)
	if(not(numContinued(number))):
		if(numJumped(number)):
			if(numCurrent==-1):
				print "Start at %d" %numStart
			else:
				print "Jumped %d at %d." %(jumpNo,numCurrent)
				totalSkip+=jumpNo		
			print ">>>>>>"
			numCurrent=number	
	else:
		print "------"

# Variables for main func
emptyLine=0
fileLine=0
otherLine=0

with open(inputfile,'r') as infile:
	for line in infile:
		line=line.strip()	#remove space & newline etc.
		if(len(line)==0):
			#empty line
			emptyLine+=1
			continue
		if(len(line)>6 and line[6]=="."): 
			line=line[:6]		#Takes only first 6 charactors if next one is a '.'
		if(line.isdigit()):
			#pure number
			number=int(line)
			process(number)
			continue
		if(line.startswith("frame")):
			#image file
			fileLine+=1
			continue
		else:
			otherLine+=1
print "Start number: %d, Last number: %d" %(numStart, numCurrent)
numTotal= numCurrent-numStart+1				
print "Total skipped: %d, total number: %d, skip percentage: %f%%" % (totalSkip, numTotal, 100.0*totalSkip/numTotal)
print "emptylines: %d   filelines: %d   otherLine: %d" % (emptyLine, fileLine, otherLine)


