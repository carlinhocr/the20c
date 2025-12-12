const char PA[] = {7,6,5,4,3,2,1,0}; //char is one byte from -127 to 127

#include <Servo.h>


Servo myServo;

void setup() {
  Serial.println("Hola");
  // put your setup code here, to run once:
  for (int n=0;n<8;n++){
    pinMode(PA[n], INPUT);
  }
  myServo.attach(13);
  Serial.begin(9600);
}

void testMotor() {
  for (int i=0;i<181;i=i+15){
    i;
    Serial.println(i);
    myServo.write(i);
    delay (2000) ;
  }
}

void senseDirection() {
  unsigned int portA = 0;
  for (int n=0;n<8;n++){
    int pinA = digitalRead(PA[n]) ? 1:0; //? ternary operator if TRUE then 1 else 0
    Serial.print(pinA);
    portA = (portA << 1) + pinA;
  };
  if (portA == 3) {
    myServo.write(180);
  } else if (portA == 2){
    myServo.write(90);
  }  else {
    myServo.write(0);  
  };
}

void loop() {
  // put your main code here, to run repeatedly:
  //testMotor();
  senseDirection();

}
