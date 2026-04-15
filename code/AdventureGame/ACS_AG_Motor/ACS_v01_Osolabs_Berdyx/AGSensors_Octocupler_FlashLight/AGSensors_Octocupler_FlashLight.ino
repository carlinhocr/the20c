// We define the heartbeat of the Adventure Game
// We also define how to run a relay

#define SYNC  2 //sync is PB6
#define PB0  8
#define PB1  9
#define PB2  10
#define OUT1  11
#define OUT2  12
#define OUT3 13

int beatDelay = 50;
int beatOnOFF=1; //off by default for a relay
int relayDelay = 1000;

void beatOn()
{
//0 is using the relay to turn on
  digitalWrite(OUT2, 0);
}

void beatOff()
{
//1 is using the relay to turn off
  digitalWrite(OUT2, 1);
}

void flashlightOn()
{
//0 is using the relay to turn on
  digitalWrite(OUT3, 0);
}

void flashlightOff()
{
//1 is using the relay to turn off
  digitalWrite(OUT3, 1);
}

void waterOn()
{
//0 is using the mosfet to turn on
  digitalWrite(OUT1, 1);
}

void waterOff()
{
//1 is using the mosfet to turn off
  digitalWrite(OUT1, 0);
}

void onSync()
{
  Serial.print("Entra onSync: ");
  int bit0 = digitalRead(PB0) ? 1:0; //? ternary operator if TRUE then 1 else 0
  int bit1 = digitalRead(PB1) ? 1:0; //? ternary operator if TRUE then 1 else 0
  int bit2 = digitalRead(PB2) ? 1:0; //? ternary operator if TRUE then 1 else 0
  Serial.print(bit2);
  Serial.print(bit1);
  Serial.println(bit0);
  if (bit0 == 0){
    Serial.println("Activating HeartBeat Relay");
    beatOn();  
  }
  else {
    Serial.println("Turning Off HeartBeat Relay");
    beatOff();
  };
  if (bit1 == 1){
    Serial.println("Activating Water Relay");
    waterOn();  
  }
  else {
    Serial.println("Turning Off Water Relay");
    waterOff();
  };
  if (bit2 == 0){
    Serial.println("Activating Flashlight Relay");
    beatOn();  
  }
  else {
    Serial.println("Turning Off Flashlight Relay");
    beatOff();
  };
}
 
void setup()
{
  pinMode(SYNC, INPUT_PULLUP);
  pinMode(PB0, INPUT_PULLUP);
  pinMode(PB1, INPUT_PULLUP);
  pinMode(PB2, INPUT_PULLUP);
  pinMode(OUT1, OUTPUT);
  pinMode(OUT2, OUTPUT);
  pinMode(OUT3, OUTPUT);
  digitalWrite(OUT1, 0);
  digitalWrite(OUT2, 1); //turn off relay
  digitalWrite(OUT3, 1); //turn off relay
  // each time that on pin 2 (SYNC) i receive a HIGH on the rising edge run the onSync function
  attachInterrupt(digitalPinToInterrupt(SYNC), onSync, FALLING); 
  Serial.begin(115200);
  Serial.println("Arranca Arduino OCTOCUPLER");
}

void loop() {
  delay(1000);
  int bit0 = digitalRead(PB0) ? 1:0; //? ternary operator if TRUE then 1 else 0
  int bit1 = digitalRead(PB1) ? 1:0; //? ternary operator if TRUE then 1 else 0
  int bit2 = digitalRead(PB2) ? 1:0; //? ternary operator if TRUE then 1 else 0
  Serial.print(bit2);
  Serial.print(bit1);
  Serial.println(bit0);
   if (bit0 == 0){
    Serial.println("Activating HeartBeat Relay");
    beatOn();  
  }
  else {
    Serial.println("Turning Off HeartBeat Relay");
    beatOff();
  };
  if (bit1 == 0){
    Serial.println("Activating Water Relay");
    waterOn();  
  }
  else {
    Serial.println("Turning Off Water Relay");
    waterOff();
  };
  if (bit2 == 0){
    Serial.println("Activating Flashlight Relay");
    flashlightOn();  
  }
  else {
    Serial.println("Turning Off Flashlight Relay");
    flashlightOff();
  };
}

