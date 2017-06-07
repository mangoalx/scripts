# Python program for checking though tesseract result, comparing numbers and telling out how many numbers are skipped
# By John Xu
#
#
#				History
# V0.1	First version, 2 continued numbers confirm the jump, can be fooled easily
#
# When jump followed by jump, it lost trace and can not update numNew, need better process
import sys
inputfile = sys.argv[1]

#Constant
MaxJump=4					# Maximum acceptable jump number, otherwise will be discarded, set to 4 to avoid 1->7 error
#Global variables
numStart=-1
numCurrent=-1
numNew=-1
numNew2=-1
totalSkip=0
def numContinued(number):
	global numNew, numCurrent
	if(numCurrent==-1):
		return False
	elif ((number-numCurrent) in [0,1]):
		numCurrent=number
		numNew=-1
		numNew2=-1
		return True
	else:
		return False
def numJumped(number):
	global numNew, numNew2, numCurrent, totalSkip, MaxJump, numStart
	
	if(numNew==-1):
		numNew=number
		return False
	elif ((number-numNew) in [0,1]):
		if(numCurrent!=-1): 		#first number recognized
			numDiff=numNew-numCurrent-1
			if((numDiff<0)or(numDiff>MaxJump)):
				print("Error -----------------------")
			print "Jumped %d at %d!" %(numDiff, numCurrent)
			totalSkip+=numDiff
		else:
			print "Start number: %d" %numNew
			numStart=numNew
		numCurrent=number
		numNew=-1
		numNew2=-1
		return True
	else:
		if(numNew2==-1):
			numNew2=number
		elif ((number-numNew2) in [0,1]):		#numNew2 is confirmed
			numDiff=numNew2-numCurrent-1
			if(0<(numNew-numCurrent)<numDiff):	#numNew is fit in the jump gap, so jump step should -1
				numDiff-=1
			if((numDiff<0)or(numDiff>MaxJump)):
				print("Error -----------------------")
			else:
				totalSkip+=numDiff
			print "Jumped %d at %d!" %(numDiff, numCurrent)
			numCurrent=number
			numNew=-1
			numNew2=-1
			return True
		else:
			numNew=numNew2						#refresh numNew for following comparison
			numNew2=number
		# continue work here
#		numDiff=number-numCurrent
#		if((numDiff>0)and(numDiff<(numNew-numCurrent))or(numNew<numCurrent)):
#			numNew=number
		return False

def process(number):
	global numCurrent,MaxJump
	if((number<numCurrent)or((numCurrent!=-1)and((number-numCurrent)>MaxJump))):
		print "invalid number %d" %number
		return
	print(number)
	if(not(numContinued(number))):
		if(numJumped(number)):
			print ">>>>>>"
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

