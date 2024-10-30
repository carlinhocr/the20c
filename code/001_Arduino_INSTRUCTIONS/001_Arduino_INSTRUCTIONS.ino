
// with ARDUINO CONNECTOR
const char ADDR[] = {23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53}; //char is one byte from -127 to 127
const char DATA[] = {36,34,32,30,28,26,24,22};

// with regular cables
// const char ADDR[] = {22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52}; //char is one byte from -127 to 127
// const char DATA[] = {39,41,43,45,47,49,51,53};


#define CLOCK 2
#define READ_WRITE 3
#define SYNC 4
//#define CS1 4 cia only
//#define CS2 5 cia only
#define CSRAM 6


void setup() {
  for (int n=0;n<16;n++){
    pinMode(ADDR[n], INPUT);
  }
   for (int n=0;n<8;n++){
    pinMode(DATA[n], INPUT);
  }
  pinMode(CLOCK, INPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(SYNC, INPUT);
//  pinMode(CS1, INPUT);
//  pinMode(CS2, INPUT);
// pinMode(CSRAM, INPUT);
  // each time that on pin 2 (clock) i receive a HIGH on the rising edge run the onClock function
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING); 
  Serial.begin(115200);
}

void onClock (){
//  int CS1_VALUE = digitalRead(CS1) ? 1:0;
//  int CS2_VALUE = digitalRead(CS2) ? 1:0;
//  int CSRAM_VALUE = digitalRead(CSRAM) ? 1:0;
//  Serial.print(CS1_VALUE);
//  Serial.print(CS2_VALUE);
char SYNC_VALUE = digitalRead(SYNC) ? 'S':'n';
  Serial.print("    ");
//  Serial.print(CSRAM_VALUE);
  Serial.print(" ");
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
  char *instruction=sync_string(SYNC_VALUE,data);
  sprintf(output, " %04x  %04c %01c %02x %01c",address,digitalRead(READ_WRITE)?'r':'W',SYNC_VALUE,data,' ');
  Serial.print(output);
  Serial.println(instruction);

}

char *sync_string(char SYNC_VALUE,unsigned int data) {
  if (SYNC_VALUE == 'S'){
    switch (data){
      case 0x00:
      return "BRK";
      case 0x0a:
      return "ASL A";
      case 0x20:
      return "JSR abs";
      case 0x4c:
      return "JMP abs";
      case 0x58:
      return "CLI impl";
      case 0x78:
      return "SEI impl";
      case 0x85:
      return "STA zpg";
      case 0x8d:
      return "STA abs";
      case 0x91:
      return "STA ind,Y";
      case 0x9a:
      return "TXS impl";
      case 0xe8:
      return "INX";
      case 0xad:
      return "LDA abs";
      case 0xa0:
      return "LDY #";
      case 0xa1:
      return "LDA X,ind";
      case 0xa2:
      return "LDX #";
      case 0xa5:
      return "LDA zpg";
      case 0xa9:
      return "LDA #";
      case 0xb1:
      return "LDA ind,Y";
      case 0xb5:
      return "LDA zpg,X";
      case 0xb9:
      return "LDA abs,Y";
      case 0xbd:
      return "LDA abs,X";
      case 0xc0:
      return "CPY #";
      case 0xc8:
      return "INY impl";
      case 0xc9:
      return "CMP #";
      case 0xd0:
      return "BNE rel";
      case 0xf0:
      return "BEQ rel";
      default:
      return "UNKNOWN";
    };
    }
  else{
    return  "   " ;
  }
} 

void loop() {
}
