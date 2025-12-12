const char PA[] = {9,8,7,6,5,4,3,2}; //char is one byte from -127 to 127

#include <Servo.h>


Servo myServo, myServoTwo;

void setup() {
  Serial.println("Hola");
  // put your setup code here, to run once:
  for (int n=0;n<8;n++){
    pinMode(PA[n], INPUT);
  }
  myServo.attach(13);
  myServoTwo.attach(9);
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
  //checkOneMotor(portA);
  checkTwoMotors(portA);
  delay(1000);
}

void checkOneMotor(unsigned int port) {  
  if (port == 3) {
    myServo.write(180);
  } else if (port == 2){
    myServo.write(90);
  }  else {
    myServo.write(0);  
  };
}

void checkTwoMotors(unsigned int port) {  
  if (port == 3) {
    myServo.write(180);
  } else if (port == 2){
    myServo.write(90);
  } else if (port == 1){
    myServo.write(0);  
  } else if (port == 6){
    myServoTwo.write(180);   
  } else if (port == 5){
    myServoTwo.write(90); 
  } else if (port == 4){
    myServoTwo.write(0);     
  };
}

void loop() {
  // put your main code here, to run repeatedly:
  //testMotor();
  senseDirection();

}
