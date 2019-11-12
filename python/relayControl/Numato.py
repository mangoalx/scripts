#-------------------------------------------------------------------------------
# Name:        Numato USB relay python control library
# Purpose:
#
# Author:      John Xu
#
# Created:     04/05/2018
# Licence:     Public Domain
#
# Version: 	0.1
#			- Base class for Numato relay
#			- Found that when using writeall command, should not append "\n\r", only '\r' works
#
#			* 
#			* implement gpio and adc command
#			* relay number check (parameter inspection)
#			* id & version command
#			* better status information output
#-------------------------------------------------------------------------------




#import crcmodbus, serial
#import struct, time
#from array import array
import serial,sys

#------------------------------------------------------------------
# constants
#------------------------------------------------------------------
NumRelay=4 				# total 4 realys, max relay no. 3

CmdVer="ver "
CmdIdGet="id get"
CmdIdSet="id set "
CmdRelayOn="relay on "
CmdRelayOff="relay off "
CmdRelayRead="relay read "
CmdRelayReadAll="relay readall"
CmdRelayWriteAll="relay writeall "


'''
class OperatingPoint:
    def __init__(self, voltage=0, current=0):
        self.voltage = voltage
        self.current = current
    def getCurrent(self):
        return self.current
    def getVoltage(self):
        return self.voltage
    def setVoltage(self,voltage):
        self.voltage = voltage
    def setCurrent(self, current):
        self.current = current
'''

class USBrelay:

	def __init__(self, serial_port="/dev/ttyACM0", serial_baud=19200):
		self.commPort = serial.Serial(serial_port, serial_baud, timeout=1)
		print("USB relay initialized")


#--------------------------------------------------------
#	Send out a command and, if there is, return the response
#--------------------------------------------------------		
	def sendCmd(self,command="ver"):
#		print(command)
		#Clear the input buffer to avoid garbage info
		if sys.version_info[0] > 2:					#version check, to be compatible to version 3 & version 2
			self.commPort.reset_input_buffer()
		else:
			self.commPort.flushInput()
		self.commPort.write(command + "\r")
		self.commPort.readline()					#read back the echoed command line
#		print(self.commPort.readline())				#for debug
		ch=self.commPort.read(1)					#read the first charactor of next line
		if(ch == '\r'):
			ch=self.commPort.read(1)				#first ch read is 0xd of previous new line
		if(len(ch) == 0 ) or (ch == '>'):
			return None
		else:
			return ch+self.commPort.readline()		#read the rest of the line and return it with the first char

#--------------------------------------------------------
#	Check version
#--------------------------------------------------------		
	def version(self):
		print(self.sendCmd(CmdVer))
		
#--------------------------------------------------------
#	get ID
#--------------------------------------------------------		
	def idGet(self):
		print(self.sendCmd(CmdIdGet))
		
#--------------------------------------------------------
#	set ID
#--------------------------------------------------------		
	def idSet(self,idnum):
		self.sendCmd(CmdIdSet + idnum)

#--------------------------------------------------------
#	Turn on a relay
#--------------------------------------------------------		
	def relayOn(self,num):
		self.sendCmd(CmdRelayOn + str(num))
		
#--------------------------------------------------------
#	Turn off a relay
#--------------------------------------------------------		
	def relayOff(self,num):
		self.sendCmd(CmdRelayOff + str(num))
		
#--------------------------------------------------------
#	Read status of a relay
#--------------------------------------------------------		
	def relayRead(self,num):
		print(self.sendCmd(CmdRelayRead + str(num)))
		
#--------------------------------------------------------
#	Read status of all relays
#--------------------------------------------------------		
	def relayReadAll(self):
		print(self.sendCmd(CmdRelayReadAll))
		
#--------------------------------------------------------
#	Write to all relays
#--------------------------------------------------------		
	def relayWriteAll(self,data):
		self.sendCmd(CmdRelayWriteAll + "{:02x}".format(data))
#--------------------------------------------------------
#	Raw command
#--------------------------------------------------------		
	def rawCommand(self,data):
		info = self.sendCmd(data)
		if(info is not None):
			print(info)

		
'''        self.slaveAddress = chr(slave_address)
        self.registerWriteDelay = reg_write_delay

    def addCRC(self, pack):
        crc = crcmodbus.INITIAL_MODBUS
        for ch in pack:
            crc = crcmodbus.calcByte( ch, crc)
        crc1 = crc & 0xFF
        crc2 = crc >> 8
        comWithCRC = pack + chr(crc1) + chr(crc2)
        return comWithCRC

    def writeRegister(self, startAddress, data):
        packet = self.slaveAddress
        adr1 = startAddress >> 8
        adr2 = startAddress & 0xFF
        noOfBytes = len(data)
        noOfReg = len(data)/2
        packet += ''.join(chr(x) for x in [0x10, adr1, adr2, 0x00, noOfReg, noOfBytes])
        packet += data
        packetWithCRC = self.addCRC(packet)
        self.commPort.write(packetWithCRC)
        time.sleep(self.registerWriteDelay)

    def readRegister(self, startAddress, noOfBytes):
        packet = self.slaveAddress
        adr_H = startAddress >> 8
        adr_L = startAddress & 0xFF
        noOfBytes_H = noOfBytes >> 8
        noOfBytes_L = noOfBytes & 0xFF
        packet += ''.join(chr(x) for x in [0x03, adr_H, adr_L, noOfBytes_H, noOfBytes_L])
        self.commPort.flushInput()
        packetWithCRC = self.addCRC(packet)
        self.commPort.write(packetWithCRC)
        ret = self.commPort.read(3)
        numberOfBytes = ord(ret[2]) + 2
        return self.commPort.read(numberOfBytes)

    def getOperatingPoint(self):
        ret = self.readRegister(0x0B00, 4)
        floatStr = ret[0:4]
        voltage = struct.unpack('f', floatStr[::-1])
        floatStr = ret[4:8]
        current = struct.unpack('f', floatStr[::-1])
        return OperatingPoint(voltage[0],current[0])

    def setCCurrent(self, current=0):
        valueAsStr = struct.pack('f', current)
        data = valueAsStr[::-1]
        self.writeRegister(0x0A01,data)
        command = ''.join(chr(x) for x in [0x00, 0x01])
        self.writeRegister(0x0A00, command)

    def setCPower(self, power=0):
        valueAsStr = struct.pack('f', power)
        data = valueAsStr[::-1]
        self.writeRegister(0x0A05,data)
        command = ''.join(chr(x) for x in [0x00, 0x03])
        self.writeRegister(0x0A00, command)

    def setCVoltage(self, voltage=0):
        valueAsStr = struct.pack('f', voltage)
        data = valueAsStr[::-1]
        self.writeRegister(0x0A03,data)
        command = ''.join(chr(x) for x in [0x00, 0x02])
        self.writeRegister(0x0A00, command)

    def setInputOn(self):
        command = ''.join(chr(x) for x in [0x00, 42])
        self.writeRegister(0x0A00,command)

    def setInputOff(self):
        command = ''.join(chr(x) for x in [0x00, 43])
        self.writeRegister(0x0A00,command)

'''
