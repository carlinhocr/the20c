const char PA[] = {9,8,7,6,5,4,3,2}; //char is one byte from -127 to 127

#include <Servo.h>


Servo myServo, myServo1, myServo2, myServo3, myServo4;

void setup() {
  Serial.println("Hola");
  // put your setup code here, to run once:
  for (int n=0;n<8;n++){
    pinMode(PA[n], INPUT);
  }
  myServo1.attach(13);
  myServo2.attach(12);
  myServo3.attach(11);
  myServo4.attach(10);  
  Serial.begin(9600);
}

void testMotor() {
  for (int i=0;i<181;i=i+15){
    i;
    Serial.println(i);
    myServo1.write(i);
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
  //checkTwoMotors(portA);
  checkFourMotors(portA);
  delay(1000);
}

void checkOneMotor(unsigned int port) {  
  if (port == 3) {
    myServo1.write(180);
  } else if (port == 2){
    myServo1.write(90);
  }  else {
    myServo1.write(0);  
  };
}

void checkTwoMotors(unsigned int port) {  
  if (port == 3) {
    myServo1.write(180);
  } else if (port == 2){
    myServo1.write(90);
  } else if (port == 1){
    myServo1.write(0);  
  } else if (port == 6){
    myServo2.write(180);   
  } else if (port == 5){
    myServo2.write(90); 
  } else if (port == 4){
    myServo2.write(0);     
  };
}

void checkFourMotors(unsigned int port) {  
  if (port == 3) {
    myServo1.write(180);
  } else if (port == 2){
    myServo1.write(90);
  } else if (port == 1){
    myServo1.write(0);  
  } else if (port == 6){
    myServo2.write(180);   
  } else if (port == 5){
    myServo2.write(90); 
  } else if (port == 4){
    myServo2.write(0);   
  } else  if (port == 9) {
    myServo3.write(180);
  } else if (port == 8){
    myServo3.write(90);
  } else if (port == 7){
    myServo3.write(0);  
  } else if (port == 12){
    myServo4.write(180);   
  } else if (port == 11){
    myServo4.write(90); 
  } else if (port == 10){
    myServo4.write(0);    
  };
}


void loop() {
  // put your main code here, to run repeatedly:
  //testMotor();
  senseDirection();

}
