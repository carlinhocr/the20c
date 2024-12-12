import machine
import utime
import urandom

address_number = [3,2,1,0]
address_pin = []
clock = 28

for pin_number in address_number:
    print(pin_number)
    address_pin.append(machine.Pin(pin_number, machine.Pin.IN))

#read pin values

address = ""
for pin in address_pin:
    print(pin.value())
    address = address + str(pin.value())
print (address)
    
