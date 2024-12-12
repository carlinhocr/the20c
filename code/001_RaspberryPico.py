import machine
import utime
import urandom

address = [3,2,1,0]
clock = 28

for pin in address:
    pinMode(pin,INPUT)

#read pin values
    
for pin in address:
    print(digitalRead(pin))
    
