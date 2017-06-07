from checknum2.py import numCurrent
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
#	global list dataForCheck, dataSeq0, dataSeq1, dataSeq2, dataSeq3
	dataForCheck.append(number)							# add to the check data list
	
	for alist in [dataSeq0, dataSeq1, dataSeq2, dataSeq3]:
		if(checkJumpList(alist,number)):				# If the number is accepted by this list, then check if confirmNo is reached
			length=len(alist)
			if(length>=confirmNo):						# The list size is greater than confirmNo, then the jump is confirmed
														# then set jumpNo and return true
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

