// We define the heartbeat of the Adventure Game
// We also define how to run a relay
// we add a water sensor to see how much water is the cave
// we manage a led with 8x8 in 4 for rows using ic2


#include <LedControl.h>


// #define SYNC  2 //sync is PB6
// #define PB0  8
// #define PB1  9
// #define PB2  10
// #define OUT1  11
// #define OUT2  12

#define CLK 10
#define CS 11
#define DataIn 12

int beatDelay = 50;
int relayDelay = 1000;
int waterPin = A0; // Sensor connected to Analog Pin 0
int waterValue = 0;


// pin 12 data in
LedControl lc =LedControl(12,10,11,4);

void iCSetup()
{
  // power on max 72XX
  lc.shutdown(0,false);
  // lc.shutdown(1,false);
  // lc.shutdown(2,false);
  // lc.shutdown(3,false);
  
  //set brightnes to medium
  lc.setIntensity(0, 8);

  //clear the display
  lc.clearDisplay(0);
};

void ledWriteLine()
{
  lc.setLed(0, 3, 3, true); 
  lc.setLed(0, 3, 4, true);
  lc.setLed(0, 4, 3, true);
  lc.setLed(0, 4, 4, true);
  // delay(500); // Delay for better readability
  // byte linea[2]={B00000000,B11111111};
  // lc.setRow(1,0, B11111111);
  // delay(500); // Delay for better readability  
  // lc.setRow(1,0, B00000000);
  // delay(500); // Delay for better readability  
};

// void readWaterSensor() 
// {
//   waterValue = analogRead(waterPin); // Read the analog value
//   Serial.print("Water level: ");
//   Serial.println(waterValue); // Print value to Serial Monitor
//   delay(500); // Delay for better readability
// }

// void beat()
// {
//   digitalWrite(OUT2, 1);
//   delay (beatDelay);
//   digitalWrite(OUT2, 0);
//   delay (beatDelay+50);
// }

// void relayOn()
// {
//   digitalWrite(OUT1, 1);
// }

// void relayOff()
// {
//   digitalWrite(OUT1, 0);
// }

// void onSync()
// {
//   Serial.print("Entra onSync: ");
//   int bit0 = digitalRead(PB0) ? 1:0; //? ternary operator if TRUE then 1 else 0
//   int bit1 = digitalRead(PB1) ? 1:0; //? ternary operator if TRUE then 1 else 0
//   int bit2 = digitalRead(PB2) ? 1:0; //? ternary operator if TRUE then 1 else 0
//   Serial.print(bit2);
//   Serial.print(bit1);
//   Serial.println(bit0);
//   if (bit2 == 1){
//     Serial.println("Activating Relay");
//     relayOn();
//   }
//   else {
//     Serial.println("Turning Off Relay");
//     relayOff();
//   }
//   if (bit1 == 0 and bit0 == 0){
//     beatDelay = 1000;
//   }
//   else if (bit1 == 0 and bit0 == 1){
//     beatDelay = 800;
//   }
//   else if (bit1 == 1 and bit0 == 0){
//     beatDelay = 400;
//   }
//     else if (bit1 == 1 and bit0 == 1){
//     beatDelay = 200;
//   }
// }
 
void waterCopete(int rowsWave)
{
  lc.clearDisplay(0);
  for (int i = 0; i <= rowsWave; i++){
    lc.setRow(0, i, B11111111);
  };
  lc.setRow(0, rowsWave+1, B01010101);
  delay(1000); // Delay for better readability 
  lc.setRow(0, rowsWave+1, B10101010);
  delay(1000); // Delay for better readability 
}

void heartBeatLED(){
  byte heartBig[8]={                  
                    B00000000,
                    B00011000,
                    B00111100,
                    B01111110,
                    B11111111,
                    B11111111,
                    B01100110,
                    B00000000
  };
  byte heartSmall[8]={
                    B00000000,
                    B00000000,
                    B00011000,
                    B00111100,
                    B01111110,           
                    B01111110,           
                    B00100100,
                    B00000000
  };
  for (int i = 0; i < 8; i++){
    lc.setRow(3, i,heartBig[i]);
  };
  delay(1000); // Delay for better readability 
  for (int i = 0; i < 8; i++){
    lc.setRow(3, i,heartSmall[i]);
  };
  delay(1000); // Delay for better readability
  lc.clearDisplay(0);
}

void setup()
{
  // pinMode(SYNC, INPUT);
  // pinMode(PB0, INPUT);
  // pinMode(PB1, INPUT);
  //iCSetup();
  // pinMode(PB2, INPUT);
  // pinMode(OUT1, OUTPUT);
  // pinMode(OUT2, OUTPUT);

  // each time that on pin 2 (SYNC) i receive a HIGH on the rising edge run the onSync function
  //attachInterrupt(digitalPinToInterrupt(SYNC), onSync, RISING); 

  // power on max 72XX
  lc.shutdown(0,false);
  lc.shutdown(1,false);
  lc.shutdown(2,false);
  lc.shutdown(3,false);
  
  //set brightnes to medium
  lc.setIntensity(0, 8);
  lc.setIntensity(1, 8);
  lc.setIntensity(2, 8);
  lc.setIntensity(3, 8);
  //clear the display
  lc.clearDisplay(0);
  lc.clearDisplay(1);
  lc.clearDisplay(2);
  lc.clearDisplay(3);

  Serial.begin(115200);
  Serial.println("Arranca Arduino");
}

void loop() {
  // test heart beat
  //beat();
  //beat();
  // test water sensor
  //readWaterSensor();
  //turn on line of led
  //ledWriteLine();
  // lc.setRow(0, 0, B11111111);
  // lc.setRow(1, 0, B11111111);
  // lc.setRow(2, 0, B11111111);
  // lc.setRow(3, 0, B11111111);  
  // delay(1000); // Delay for better readability 
  // lc.setRow(0, 0, B00000000);
  // lc.setRow(1, 0, B00000000);
  // lc.setRow(2, 0, B00000000);
  // lc.setRow(3, 0, B00000000);  
  // delay(1000); // Delay for better readability 
  waterCopete(0);
  waterCopete(1);
  waterCopete(2);
  waterCopete(3);
  waterCopete(4);
  waterCopete(5);
  waterCopete(6);  
  heartBeatLED();
  heartBeatLED();
}

