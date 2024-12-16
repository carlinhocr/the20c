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
mcp0 = mcp23017.MCP23017(i2c,0x20)
mcp1 = mcp23017.MCP23017(i2c,0x21)
mcp2 = mcp23017.MCP23017(i2c,0x22)

utime.sleep_ms(1)

# 0-7 Port A
# 8-15 Port B
for mcp_pin_number in range(0,15):
    mcp0[mcp_pin_number].input(pull=1)
    mcp1[mcp_pin_number].input(pull=1)
    mcp2[mcp_pin_number].input(pull=1)

#mcp0.porta.mode = 0xff #direction 0=output 1=Input
#mcp0.portb.mode = 0xff #direction 0=output 1=Input
#mcp2.porta.mode = 0xff #direction 0=output 1=Input
#mcp2.portb.mode = 0xff #direction 0=output 1=Input
#mcp1.porta.mode = 0xff #direction 0=output 1=Input
#mcp1.portb.mode = 0xff #direction 0=output 1=Input
#mcp2.porta.mode = 0xff #direction 0=output 1=Input
#mcp2.portb.mode = 0xff #direction 0=output 1=Input
mcp_pin_instruction = 15 #mcp1 pin instruction for SYN  FLAG
pinClock = 16

intPin = machine.Pin(16,machine.Pin.IN,machine.Pin.PULL_DOWN)

def onClockCallback(pin):
    print("Clock now")
    print("MCP 0 PORT B & A")
    print(str("{0:0>4X}".format(mcp0.gpio, 4)))
    mcp0_full_hexa = str("{0:0>4X}".format(mcp0.gpio, 4))
    mcp0_full_bin = str("{0:0>4b}".format(mcp0.gpio, 4))
    print (mcp0_full_bin + "   " + mcp0_full_hexa)
    
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
    mcp1_porta_bin = str("{0:0>2b}".format(mcp1.porta, 2))
    mcp1_porta_hexa = str("{0:0>2X}".format(mcp1.porta, 2))
    if mcp1[mcp_pin_instruction].value() == 1:
        mcp_instruction = "Aca hay instrucción"
    else:
        mcp_instruction = "DATA"
    print("ADDDRESS BINARY  DATA BINARY  ADDRESS HEXA DATA HEXA  INSTRUCTION")
    print(mcp0_full_bin + " " + mcp1_porta_bin + " " + mcp2_full_hexa  + " " + mcp1_porta_hexa + " " + mcp_instruction)
        
intPin.irq(trigger=machine.Pin.IRQ_RISING, handler=onClockCallback)     
    
#read pin values
while True:
    utime.sleep_ms(1)
    

