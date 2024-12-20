import machine
import utime
import urandom
import mcp23017
import pico_i2c_lcd

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
    mcp2[mcp_pin_number].input()


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

#mcp2.pin(mcp_pin_instruction,mode=1,interrupt_enable=1,default_value=0)

mcp2.portb.default_value= 0x00
mcp2.portb.interrupt_enable = 0x80
mcp2.portb.interrupt_configuration=0xFF
mcp2.portb.io_control=0b10100110
mcp2.portb.gpint=0xff
mcp2.portb.interrupt_compare_default =0x00

def onClockCallbackMCP():
    print("MCP IRQ")
intPin = machine.Pin(16,machine.Pin.IN,machine.Pin.PULL_DOWN)

def lcdTest(devNumber):
    i2c.writeto(devNumber,'\x7c')
    i2c.writeto(devNumber,'\x2d')
    i2c.writeto(devNumber,"Testing 123")
    

def onClockCallback(pin):
    flagged = mcp2.portb.interrupt_flag
    captured = mcp2.portb.interrupt_captured
    pin_value=mcp2[15].value()
    if pin_value == 1: #rising value of pin interrupt
        print(pin_value,flagged,captured)
        mcp0_full_hexa = str("{0:0>4X}".format(mcp0.gpio, 2))
        mcp0_full_bin = str("{0:0>4b}".format(mcp0.gpio, 2))
        mcp1_full_hexa = str("{0:0>4X}".format(mcp1.gpio, 4))
        mcp1_full_bin = str("{0:0>4b}".format(mcp1.gpio, 4))
        mcp2_full_hexa = str("{0:0>4X}".format(mcp2.gpio, 4))
        mcp2_full_bin = str("{0:0>4b}".format(mcp2.gpio, 4))
        mcp1_porta_bin = str("{0:0>2b}".format(mcp1.porta.gpio, 2))
        mcp1_porta_hexa = str("{0:0>2X}".format(mcp1.porta.gpio, 2))
        if mcp1[mcp_pin_instruction].value() == 1:
            instruction_text = str(whichInstruction(mcp1.porta.gpio))
            mcp_instruction = "INSTRUCTION:  "+instruction_text
        else:
            mcp_instruction = "DATA"
        print(mcp0_full_bin + "  " + mcp1_porta_bin + "  " + mcp0_full_hexa  + "  " + mcp1_porta_hexa + "     " + mcp_instruction)
        
def whichInstruction(code):
      if code == 0x00:
          return "BRK"
      elif code == 0x01:
          return "ORA X,ind"
      elif code == 0x02:
          return "INVALID"
      elif code == 0x03:
          return "INVALID"
      elif code == 0x04:
          return "INVALID"
      elif code == 0x05:
          return "ORA zpg"
      elif code == 0x06:
          return "ASL zpg"
      elif code == 0x07:
          return "INVALID"
      elif code == 0x08:
          return "PHP impl"
      elif code == 0x09:
          return "ORA #"
      elif code == 0x0a:
          return "ASL A"
      elif code == 0x0b:
          return "INVALID"
      elif code == 0x0c:
          return "INVALID"
      elif code == 0x0d:
          return "ORA abs"
      elif code == 0x0e:
          return "ASL abs"
      elif code == 0x0f:
          return "INVALID"
      elif code == 0x20:
          return "JSR abs"
      elif code == 0x40:
          return "RTI impl"  
      elif code == 0x41:
          return "EOR X,ind" 
      elif code == 0x42:
          return "INVALID"
      elif code == 0x43:
          return "INVALID"
      elif code == 0x44:
          return "INVALID"
      elif code == 0x45:
          return "EOR zpg"   
      elif code == 0x46:
          return "LSR zpg"
      elif code == 0x47:
          return "INVALID"
      elif code == 0x48:
          return "PHA impl"
      elif code == 0x49:
          return "EOR #" 
      elif code == 0x4a:
          return "LSR A" 
      elif code == 0x4b:
          return "INVALID"
      elif code == 0x4c:
          return "JMP abs"
      elif code == 0x4d:
          return "EOR abs" 
      elif code == 0x4e:
          return "LSR abs"
      elif code == 0x4f:
          return "INVALID"
      elif code == 0x50:
          return "BVC rel"
      elif code == 0x51:
          return "EOR ind,Y"
      elif code == 0x55:
          return "EOR zpg,X"
      elif code == 0x56:
          return "LSR zpg,X"
      elif code == 0x58:
          return "CLI impl"
      elif code == 0x59:
          return "EOR zpg,Y"
      elif code == 0x5d:
          return "EOR abs,X" 
      elif code == 0x5e:
          return "LSR abs,X"
      elif code == 0x60:
          return "SEI impl"
      elif code == 0x78:
          return "SEI impl"
      elif code == 0x85:
          return "STA zpg"
      elif code == 0x8d:
          return "STA abs"
      elif code == 0x91:
          return "STA ind,Y"
      elif code == 0x9a:
          return "TXS impl"
      elif code == 0xe8:
          return "INX"
      elif code == 0xa0:
          return "LDY #"
      elif code == 0xa1:
          return "LDA X,ind"
      elif code == 0xa2:
          return "LDX #"
      elif code == 0xa5:
          return "LDA zpg"
      elif code == 0xa8:
          return "TAY impl"
      elif code == 0xa9:
          return "LDA #"
      elif code == 0xaa:
          return "TAX impl"
      elif code == 0xad:
          return "LDA abs"
      elif code == 0xb1:
          return "LDA ind,Y"
      elif code == 0xb5:
          return "LDA zpg,X"
      elif code == 0xb9:
          return "LDA abs,Y"
      elif code == 0xbd:
          return "LDA abs,X"
      elif code == 0xc0:
          return "CPY #"
      elif code == 0xc8:
          return "INY impl"
      elif code == 0xc9:
          return "CMP #"
      elif code == 0xca:
          return "DEX impl"
      elif code == 0xd0:
          return "BNE rel"
      elif code == 0xe0:
          return "CPX #"
      elif code == 0xea:
          return "NOP"
      elif code == 0xf0:
          return "BEQ rel"
      elif code == 0xf8:
          return "SED impl"
      elif code == 0xfa:
          return "BEQ rel"
      else:
          return "UNKNOWN"
   
    
    
intPin.irq(trigger=machine.Pin.IRQ_FALLING, handler=onClockCallback)
lcdTest(39)
print("ADDDRESS  BINARY  DATA BIN  ADDR  DATA   INSTRUCTION")    
#read pin values
while True:
    utime.sleep_ms(1)
    


