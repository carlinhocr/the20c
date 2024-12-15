import machine
import utime
import urandom
import mcp23017

#ADD mcp23017.py library to raspberry pico via thony Upload to /
#configure i2c pins
#ADD 1K PULL UPS to both ports or it won't work
sdaPIN=machine.Pin(26)
sclPIN=machine.Pin(27)
#configure i2c settings
i2c=machine.I2C(1,sda=sdaPIN, scl=sclPIN, freq=400000)
#create an object for using the chip
mcp = mcp23017.MCP23017(i2c,0x20)
mcp1 = mcp23017.MCP23017(i2c,0x21)
mcp2 = mcp23017.MCP23017(i2c,0x22)


utime.sleep_ms(1)

address_number = [3,2,1,0]
address_pin = []
clock = 28

# 0-7 Port A
# 8-15 Port B
for mcp_pin_number in range(0,15):
    print(mcp_pin_number)
    #mcp[mcp_pin_number].input()
    mcp[mcp_pin_number].input(pull=1)

mcp1.porta.mode = 0xff #direction 0 output 1 Input
mcp1.portb.mode = 0xff #direction 0 output 1 Input
mcp2.porta.mode = 0xff #direction 0 output 1 Input
mcp2.portb.mode = 0xff #direction 0 output 1 Input

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
for mcp_pin_number in range(7,-1,-1):
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
print(hex(mcp.porta.gpio))
print(str("{0:0>4X}".format(mcp.porta.gpio, 2)))

print("MCP 1 PORT A")
print(hex(mcp1.porta.gpio))
mcp1_hexa = str("{0:0>4X}".format(mcp1.porta.gpio, 2))
print(mcp1_hexa)
print(bin(mcp1.porta.gpio))
mcp1_bin=str("{0:0>4b}".format(mcp1.porta.gpio, 2))
print(mcp1_bin)
print(mcp1_bin + " " +mcp1_hexa)
print("MCP 1 PORT B & A")
print(str("{0:0>4X}".format(mcp1.gpio, 4)))
mcp1_full_hexa = str("{0:0>4X}".format(mcp1.gpio, 4))
mcp1_full_bin = str("{0:0>4b}".format(mcp1.gpio, 4))
print (mcp1_full_bin + "   " + mcp1_full_hexa)

print("MCP 2 PORT B & A")
print(str("{0:0>4X}".format(mcp2.gpio, 4)))
mcp2_full_hexa = str("{0:0>4X}".format(mcp2.gpio, 4))
mcp2_full_bin = str("{0:0>4b}".format(mcp2.gpio, 4))
print (mcp2_full_bin + "   " + mcp2_full_hexa)