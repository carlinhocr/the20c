// We define the heartbeat of the Adventure Game

#define SYNC  2 ;sync is PB6
#define PB0  8
#define PB1  9
#define OUT3  10

int beatDelay = 50;

void beat()
{
  digitalWrite(OUT3, 1);
  delay (beatDelay);
  digitalWrite(OUT3, 0);
  delay (beatDelay+50);
}

void onSync()
{
  int bit0 = digitalRead(PB0) ? 1:0; //? ternary operator if TRUE then 1 else 0
  int bit1 = digitalRead(PB1) ? 1:0; //? ternary operator if TRUE then 1 else 0
  if (bit1 == 0 and bit0 == 0){
    beatDelay = 1000;
  }
  else if (bit1 == 0 and bit0 == 1){
    beatDelay = 800;
  }
  else if (bit1 == 1 and bit0 == 0){
    beatDelay = 400;
  }
    else if (bit1 == 1 and bit0 == 1){
    beatDelay = 200;
  }
}
 
void setup()
{
  pinMode(SYNC, INPUT);
  pinMode(PB0, INPUT);
  pinMode(PB1, INPUT);
  pinMode(OUT3, OUTPUT);

  // each time that on pin 2 (SYNC) i receive a HIGH on the rising edge run the onSync function
  attachInterrupt(digitalPinToInterrupt(SYNC), onSync, RISING); 
  Serial.begin(115200);
}

void loop() {
  beat();
  beat();
;
}

