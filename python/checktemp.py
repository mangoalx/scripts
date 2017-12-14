#!/usr/bin/env python

# Python program for checking through tesseract result, comparing numbers and counting out how many numbers are skipped
# By John Xu
#
#
#				History
# V0.1	First version, 2 continued numbers confirm the jump, can be fooled easily
# V0.2  To check jumps, for confirming a jump the continued number needed can be set to 3 or even higher
#		Also 4 lists are used to track 4 different possible value group, to find out which one is real
# V0.21 - to strip whitespace, '.', '-' from the ocr result
# V0.3  - Allow big jump, and wrap back jump
#		- Print bigjump if jumpno >=3, djump if jumpno =2
# V0.4
#		- Print the first start number so we can check if it is continuous with prev/next out files
#		- Process all .num file in the folder to get one sum up result
#		- Add options, so we can control the way how result is generated
#		* Add options to specify MaxJump, loopBackNo, confirmNo etc. to better control the process
#		- Print >'s according to the steps of jump, so visually illustrate how big it jumped
#
# When jump followed by jump, it lost trace and can not update numNew, need better process

#from __future__ import print_function		# for using python 3.x print function so be able to change the ending \n
											# not compatible with 2.x print, using sys.stdout.write instead

import sys
import glob					# For filename match
import pdb					# For debug
import argparse				# command line option and arguments

							# parse the command line options and arguments
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")
parser.add_argument("inputfile",help="specify the input file(s), ex. *.num", nargs='*',action="store", default="*.num")
args = parser.parse_args()


#Constant
#MaxJump=10					# Maximum acceptable jump number, otherwise will be discarded, set to 4 to avoid 1->7 error  
MaxJump=100					# Temporarily set to 100 for camera bug (may jump 18 after a chopy), whim could stuck then jump 50
loopBackNo=30			# If new number is less than loopBackNumber, the video restarted from begining, the jump does not count

#Global variables
numStart=-1
numFirstStart=-1		# To keep the very first start number of this number file
numCurrent=-1
totalSkip=0
numTotal=0
newStart=-1				# used to tell process() where is the new start point after a confirmed jump
#import checkJump
#------------------------------------------------------------------------------------------------------------------
# New check jump module

#Constants
confirmNo=3				# How many number continued will be confirmed as jumped to here
maxNoTracked=4			# How many different value we will track when checking a jump
jumpString=["Jumped","Djumped","BigJumped"]
#Static variables
dataForCheck=[]
dataSeq=[]
#dataSeq1=[]
#dataSeq2=[]
#dataSeq3=[]


#Global variables
jumpNo=0

def checkContinue(number1,number2):
	if((number2-number1) in [0,1]):
		return True
	else:
		return False
def clearJumpLists():
	dataForCheck[:]=[]
	dataSeq[:]=[]
#	dataSeq1[:]=[]
#	dataSeq2[:]=[]
#	dataSeq3[:]=[]

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
	global dataForCheck, dataSeq
	global jumpNo, numStart, newStart						# These global variables will be modified in this block, must be specified
	dataCounted=[]
	dataForCheck.append(number)							# add to the check data list
	
	for i in range(0,len(dataSeq)):
		if(checkJumpList(dataSeq[i],number)):			# If the number is accepted by this list, then check if confirmNo is reached
			length=len(dataSeq[i])
#			if(length==1):								# ==1, so it starts a new list, sort the lists
				
			if(length>=confirmNo):						# The list size is greater than confirmNo, then the jump is confirmed
														# then set jumpNo and return true
#				pdb.set_trace()
				newStart=dataSeq[i][0]					# After jump the new start number
				if(numCurrent==-1):						# If numCurrent is -1, means this number should be treat as the start number
					numStart=dataSeq[i][0]
					jumpNo=0
				else:
					jumpNo=dataSeq[i][0] - numCurrent -1
					ind=dataForCheck.index(dataSeq[i][0])		# Get the index of the first element in dataForCheck list
					for i in range(0,ind):
						if(numCurrent<dataForCheck[i]<number):	# Check if data before our first confirmed number is also less than it
							if not dataForCheck[i] in dataCounted:	# Already counted this value?
								dataCounted.append(dataForCheck[i])	# No: then add it to counted list
								jumpNo-=1							# 
														# if it is true then jumpStep should be decreased by 1. 
				clearJumpLists()						# In case the jump is comfirmed, now clear all lists
				return True
			else:
				return False
	length=len(dataSeq)									# If number is not continous to any of the data lists, add it to a new list
	if(length>=maxNoTracked):							# Already exceeded the max allowed tracking data?
		del(dataSeq[0])									# Then delete the first list
		length=len(dataSeq)
	while length>0:									# No, so append the data as a new list
		i=length-1									# Search to find where to insert the new list
		if number>=dataSeq[i][0]:					# number >= the first value of current list, then we find insert position
			break
		length-=1									
	dataSeq.insert(length,[number])					# If list is empty, length will be 0, so inserting at index 0
	
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
	global numCurrent,totalSkip,numStart,numTotal,numFirstStart
	if((loopBackNo<number<numCurrent)or((numCurrent!=-1)and((number-numCurrent)>MaxJump))):
		if args.verbose:
			print "invalid number %d" %number
		return
	if args.verbose:
		print(number)
	if(not(numContinued(number))):
		if(numJumped(number)):
			if(numCurrent==-1):
				print "Start at %d" %(numStart)
				numFirstStart=numStart									# Save the very first start number
			else:
				if((number<loopBackNo)and(numCurrent>loopBackNo)):		#Is it a loop back confirmed?
					print "Looped back after %d." %(numCurrent)
					numTotal+= numCurrent-numStart+1
					numStart=newStart
				else:
					ind=jumpNo-1										#to print Djump for 2 steps and Bigjump for 3 or more steps
#					for i in xrange(0,ind): print('>', end='')			# to avoid output a newline, using 3.x print
					for i in xrange(0,jumpNo): sys.stdout.write('>')	#output 1 '>' for each jump step. 
					sys.stdout.write(' ')
					length=len(jumpString)-1
					ind = 0 if ind < 0 else length if ind > length else ind
					print "%s %d at %d." %(jumpString[ind],jumpNo,numCurrent)
					totalSkip+=jumpNo		
#			print ">>>>>>"
			numCurrent=number	
	else:
		if args.verbose:
			print "------"

# Variables for main func
#emptyLine=0
ocrNumber=0
fileLine=0
otherLine=0

#if(len(sys.argv)>1):
#	inputfile = sys.argv[1]			#if filename is specified, use glob to search all matched files
#else:
#	inputfile='*.num'				#if filename is not specified, default is all .num file

inputfile=args.inputfile			#Got from argparse

#print inputfile				#debug
if ('*' in inputfile) or ('?' in inputfile):	# wildcar in filename, so need glob it
	inputfile=sorted(glob.glob(inputfile))
#for f in sorted(glob.glob(inputfile)):
for f in inputfile:
	print "Processing input file %s" %(f)
	with open(f,'r') as infile:
		for line in infile:
#			if(line.startswith("frame"):
			if(line.startswith("frame") or line.startswith("./frame")):		# Replaced ls with find command, so file name got extra ./
				#image file, all ocr-result start with the image filename
				fileLine+=1
				if("===" in line):						# frame-000010.jpg ===002097
					line = line.split("===",1)[1]		#strip out ocr result
				else:
					continue							# === not found, then no ocr result behind the filename
			line=line.strip()	#remove space & newline etc.
			if(len(line)==0):
				#empty line
				#emptyLine+=1
				continue

# Sometimes extra charaters may appear at the head or the tail. So trying to remove it (1 or whitespace at head, point etc. at the tail)
#		if(len(line)>6):
#			if(line[0] != "0"):		#First char is not 0 then remove it, could be a space or 1
#				line=line[1:]
#			elif(line[6] in "1- .,:!'`)"): 
									#Removing trailing 1 may cause errors
#			elif(line[6] in " .,:!'`"):		 
#				line=line[:6]		#Takes only first 6 charactors if next one is a '.' or something likewise
#		line=line.replace("o","0")	#Temporary measure to correct o->0 problem

			# When using digits whitelist, space/period/dash could appear in the result, so remove them all
			line=line.replace(" ","").replace(".","").replace("-","")
			if(line.isdigit()):
				#pure number
				ocrNumber+=1
				number=int(line)
				process(number)
				continue
			else:
				otherLine+=1
				print "other line #####"
				print(line)
print "Start number: %d, Last number: %d" %(numFirstStart, numCurrent)
numTotal+= numCurrent-numStart+1
print "Total skipped: %d, total number: %d, skip percentage: %f%%" % (totalSkip, numTotal, 100.0*totalSkip/numTotal)
print "ocrNumbers: %d   filelines: %d   otherLines: %d" % (ocrNumber, fileLine, otherLine)


