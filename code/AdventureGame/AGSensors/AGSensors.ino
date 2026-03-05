// We define the heartbeat of the Adventure Game
// We also define how to run a relay

#define SYNC  2 //sync is PB7
#define PB0  8
#define PB1  9
#define PB2  10
#define OUT1  11
#define OUT2  12

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

void relayOn()
{
  digitalWrite(OUT1, 1);
}

void relayOff()
{
  digitalWrite(OUT1, 0);
}

void onSync()
{
  Serial.print("Entra onSync: ");
  int bit0 = digitalRead(PB0) ? 1:0; //? ternary operator if TRUE then 1 else 0
  //int bit1 = digitalRead(PB1) ? 1:0; //? ternary operator if TRUE then 1 else 0
  //int bit2 = digitalRead(PB2) ? 1:0; //? ternary operator if TRUE then 1 else 0
  //Serial.print(bit2);
  //Serial.print(bit1);
  Serial.println(bit0);
  if (bit0 == 1){
    Serial.println("Activating HeartBeat Relay");
    beatOn();  
  }
  else {
    Serial.println("Turning Off HeartBeat Relay");
    beatOff();
  };
}
  // if (bit2 == 1){
  //   Serial.println("Activating Relay");
  //   relayOn();
  // }
  // else {
  //   Serial.println("Turning Off Relay");
  //   relayOff();
  // }
  // if (bit1 == 0 and bit0 == 0){
  //   beatDelay = 1000;
  // }
  // else if (bit1 == 0 and bit0 == 1){
  //   beatDelay = 800;
  // }
  // else if (bit1 == 1 and bit0 == 0){
  //   beatDelay = 400;
  // }
  //   else if (bit1 == 1 and bit0 == 1){
  //   beatDelay = 200;
  // }
//}
 
void setup()
{
  pinMode(SYNC, INPUT);
  pinMode(PB0, INPUT);
  // pinMode(PB1, INPUT);
  // pinMode(PB2, INPUT);
  pinMode(OUT1, OUTPUT);
  pinMode(OUT2, OUTPUT);

  // each time that on pin 2 (SYNC) i receive a HIGH on the rising edge run the onSync function
  // attachInterrupt(digitalPinToInterrupt(SYNC), onSync, RISING); 
  Serial.begin(115200);
  Serial.println("Arranca Arduino");
}

void loop() {
  delay(1000);
}

