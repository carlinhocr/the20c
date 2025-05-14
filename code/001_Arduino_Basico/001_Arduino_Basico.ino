// with DUINO PROTOCOL ANALIZER
const char ADDR[] = {23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53}; //char is one byte from -127 to 127
const char DATA[] = {36,34,32,30,28,26,24,22};
const char EXP[] = {62,63,64,65,66,67,68,69,52,50,48,46,44,42,2,38}; // pin 2 is clock because you can attach interrupts

#define CLOCK 2

void setup() {
  for (int n=0;n<16;n++){
    pinMode(ADDR[n], INPUT);
  }
   for (int n=0;n<8;n++){
    pinMode(DATA[n], INPUT);
  }
  for (int n=0;n<16;n++){
    pinMode(EXP[n], INPUT);
  }
  pinMode(CLOCK, INPUT);
  // each time that on pin 2 (clock) 
  // I receive a HIGH on the rising edge r
  // run the onClock function
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING); 
  Serial.begin(115200);
}

void onClock (){
  char output[15];
  unsigned int address = 0;
  for (int n=0;n<16;n++){
    int bit = digitalRead(ADDR[n]) ? 1:0; //? ternary operator if TRUE then 1 else 0
    Serial.print(bit);
    address = (address << 1) + bit;
  }
  Serial.print("    ");
  unsigned int data = 0;
  for (int n=0;n<8;n++){
    int bit = digitalRead(DATA[n]) ? 1:0; //? ternary operator if TRUE then 1 else 0
    Serial.print(bit);
    data = (data << 1) + bit;
  }
  Serial.print("    ");
  unsigned int expansion = 0;
  for (int n=0;n<16;n++){
    int bit = digitalRead(EXP[n]) ? 1:0; //? ternary operator if TRUE then 1 else 0
    Serial.print(bit);
    expansion = (expansion << 1) + bit;
  }
  Serial.print("    ");
  sprintf(output," %04x %02x %04x",address,data,expansion);
  Serial.println(output);
}

void loop() {
}
