import machine
import utime
import urandom
import mcp23017

#ADD mcp23017.py library to raspberry pico via thony Upload to /
#configure i2c pins
#ADD 1K PULL UPS to both ports or it won't work
sdaPIN=machine.Pin(20)
sclPIN=machine.Pin(21)
#configure i2c settings
i2c=machine.I2C(0,sda=sdaPIN, scl=sclPIN, freq=400000)
#create an object for using the chip
mcp = mcp23017.MCP23017(i2c,0x20)
utime.sleep_ms(1)

address_number = [3,2,1,0]
address_pin = []
clock = 28

# 0-7 Port A
# 8-15 Port B
for mcp_pin_number in range(0,15):
    print(mcp_pin_number)
    #mcp[mcp_pin_number].input()
    mcp[1].input(pull=1)

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
for mcp_pin_number in range(0,7):
    print(mcp_pin_number)
    print(mcp[mcp_pin_number].value())
    mcp_data = mcp_data + str(mcp[mcp_pin_number].value())

print ("address")
print (address)
print (hex(int(address,2)))
print ("{0:0>4X}".format(int(address, 2))) #use for address fields
print ("{0:0>2X}".format(int(address, 2))) #use for data fields

address_hexa="{0:0>4X}".format(int(address, 2))
print(address+" "+address_hexa)

print ("MCP")
print (mcp_data)
print (hex(int(mcp_data,2)))
print ("{0:0>4X}".format(int(mcp_data, 2))) #use for address fields
print ("{0:0>2X}".format(int(mcp_data, 2))) #use for data fields

mcp_data_hexa="{0:0>4X}".format(int(mcp_data, 2))
print(mcp_data+" "+mcp_data_hexa)