import machine
import utime
import urandom
import mcp23017

#configure i2c pins
sdaPIN=machine.Pin(20)
sdlPIN=machine.Pin(21)
#configure i2c settings
i2c=machine.I2C(0,sda=sdaPIN, scl=sclPIN, freq=400000)
#create an object for using the chip
mcp = mcp23017.MCP23017(i2c,0x20)


address_number = [3,2,1,0]
address_pin = []
clock = 28

for mcp_pin_number in range(0,15):
    mcp[mcp_pin_number].input()

for pin_number in address_number:
    print(pin_number)
    address_pin.append(machine.Pin(pin_number, machine.Pin.IN))

#read pin values

address = ""
for pin in address_pin:
    print(pin.value())
    address = address + str(pin.value())
mcp_data = ""
print("mcp")
for mcp_pin_number in range(8,15):
    print(mcp[mcp_pin_number].value())
    mcp_data = mcp_data + int(mcp[mcp_pin_number].value())
    
print (address)
print (hex(int(address,2)))
print ("{0:0>4X}".format(int(address, 2))) #use for address fields
print ("{0:0>2X}".format(int(address, 2))) #use for data fields

address_hexa="{0:0>4X}".format(int(address, 2))
print(address+" "+address_hexa)