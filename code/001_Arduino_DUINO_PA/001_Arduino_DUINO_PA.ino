// with DUINO PROTOCOL ANALYZER
const char ADDR[] = {23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53}; //char is one byte from -127 to 127
const char DATA[] = {36,34,32,30,28,26,24,22};
const char EXP[] = {62,63,64,65,66,67,68,69,52,50,48,46,44,42,2,38}; // pin 2 is clock because you can attach interrupts

#define RESET 38 //E0
#define CLOCK 2 //E1 40
#define READ_WRITE 42 //E2
#define SYNC 68 //E9

void setup() {
  for (int n=0;n<16;n++){
    pinMode(ADDR[n], INPUT);
    pinMode(EXP[n], INPUT);
  };
   for (int n=0;n<8;n++){
    pinMode(DATA[n], INPUT);
  };
  pinMode(CLOCK, INPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(SYNC, INPUT);
  pinMode(RESET, INPUT);
  // each time that on pin 2 (clock) i receive a HIGH on the rising edge run the onClock function
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING); 
  Serial.begin(115200);
}

void onClock (){
  char SYNC_VALUE = digitalRead(SYNC) ? 'S':'n';
  char RESET_VALUE = digitalRead(RESET) ? 'n':'R';
  char READ_WRITE_VALUE = digitalRead(READ_WRITE)?'r':'W';
  char output[40];
  unsigned int address = 0;
  for (int n=0;n<16;n++){
    int bit = digitalRead(ADDR[n]) ? 1:0; //? ternary operator if TRUE then 1 else 0
    Serial.print(bit);
    address = (address << 1) + bit;
  };
  Serial.print("    ");
  unsigned int data = 0;
  for (int n=0;n<8;n++){
    int bit = digitalRead(DATA[n]) ? 1:0; //? ternary operator if TRUE then 1 else 0
    Serial.print(bit);
    data = (data << 1) + bit;
  };
  char *instruction=sync_string(SYNC_VALUE,RESET_VALUE,data);
  char *chip=find_chip(address);
  sprintf(output, " %04x %01c %01c %02x %s %s",address,READ_WRITE_VALUE,SYNC_VALUE,data,chip,instruction);
  Serial.println(output);
}


char *sync_string(char SYNC_VALUE,char RESET_VALUE,unsigned int data) {
  if (RESET_VALUE == 'R'){
    return "RESET";
  };
  if (SYNC_VALUE == 'S'){
    switch (data){
      case 0x00:
      return "BRK";
      case 0x01:
      return "ORA X,ind";
//----------------------------CASE INSTRUCTIONS       
      case 0x02:
      return "INVALID";
      case 0x03:
      return "INVALID";
      case 0x04:
      return "INVALID";
      case 0x05:
      return "ORA zpg";
      case 0x06:
      return "ASL zpg";
      case 0x07:
      return "INVALID";
      case 0x08:
      return "PHP impl";
      case 0x09:
      return "ORA #";
      case 0x0a:
      return "ASL A";
      case 0x0b:
      return "INVALID";
      case 0x0c:
      return "INVALID";
      case 0x0d:
      return "ORA abs";
      case 0x0e:
      return "ASL abs";
      case 0x0f:
      return "INVALID";
      case 0x20:
      return "JSR abs";
//----------------------------OPCODES COMPLETE FROM HERE
      case 0x40:
      return "RTI impl";  
      case 0x41:
      return "EOR X,ind"; 
      case 0x42:
      return "INVALID";
      case 0x43:
      return "INVALID";
      case 0x44:
      return "INVALID";
      case 0x45:
      return "EOR zpg";   
      case 0x46:
      return "LSR zpg";
      case 0x47:
      return "INVALID";
      case 0x48:
      return "PHA impl";
      case 0x49:
      return "EOR #"; 
      case 0x4a:
      return "LSR A"; 
      case 0x4b:
      return "INVALID";
      case 0x4c:
      return "JMP abs";
      case 0x4d:
      return "EOR abs"; 
      case 0x4e:
      return "LSR abs";
      case 0x4f:
      return "INVALID";
      case 0x50:
      return "BVC rel";
      case 0x51:
      return "EOR ind,Y";
      case 0x52:
      return "INVALID";
      case 0x53:
      return "INVALID";
      case 0x54:
      return "INVALID";
      case 0x55:
      return "EOR zpg,X";
      case 0x56:
      return "LSR zpg,X";
      case 0x57:
      return "INVALID";
      case 0x58:
      return "CLI impl";
      case 0x59:
      return "EOR zpg,Y";
      case 0x5a:
      return "INVALID";
      case 0x5b:
      return "INVALID";
      case 0x5c:
      return "INVALID";
      case 0x5d:
      return "EOR abs,X"; 
      case 0x5e:
      return "LSR abs,X";
      case 0x5f:
      return "INVALID";
      case 0x60:
      return "RTS impl";
      case 0x61:
      return "ADC X,ind";
      case 0x62:
      return "INVALID";
      case 0x63:
      return "INVALID";
      case 0x64:
      return "INVALID";
      case 0x65:
      return "ADC zpg";
      case 0x66:
      return "ROR zpg";
      case 0x67:
      return "INVALID";
      case 0x68:
      return "PLA impl";
      case 0x69:
      return "ADC #";
      case 0x6a:
      return "ROR A";
      case 0x6b:
      return "INVALID";
      case 0x6c:
      return "JMP ind";
      case 0x6d:
      return "ADC abs";
      case 0x6e:
      return "ROR abs";
      case 0x6f:
      return "INVALID";
//----------------------------OPCODES COMPLETE UNTIL HERE
      case 0x78:
      return "SEI impl";
      case 0x80:
      return "INVALID";
      case 0x81:
      return "STA X,ind";
      case 0x82:
      return "INVALID";
      case 0x83:
      return "INVALID";
      case 0x84:
      return "STY zpg";
      case 0x85:
      return "STA zpg";
      case 0x86:
      return "STX zpg";
      case 0x87:
      return "INVALID";
      case 0x88:
      return "DEY impl";
      case 0x89:
      return "INVALID";
      case 0x8a:
      return "TXA impl";
      case 0x8b:
      return "INVALID";
      case 0x8c:
      return "STY abs";
      case 0x8d:
      return "STA abs";
      case 0x8e:
      return "STX abs";      
      case 0x8f:
      return "INVALID";
      case 0x90:
      return "BCC rel";
      case 0x91:
      return "STA ind,Y";
      case 0x9a:
      return "TXS impl";
      case 0xa0:
      return "LDY #";
      case 0xa1:
      return "LDA X,ind";
      case 0xa2:
      return "LDX #";
      case 0xa3:
      return "INVALID";
      case 0xa4:
      return "LDY zpg";
      case 0xa5:
      return "LDA zpg";
      case 0xa6:
      return "LDX zpg";      
      case 0xa7:
      return "INVALID";
      case 0xa8:
      return "TAY impl";
      case 0xa9:
      return "LDA #";
      case 0xaa:
      return "TAX impl";
      case 0xab:
      return "INVALID";
      case 0xac:
      return "LDY abs";
      case 0xad:
      return "LDA abs";
      case 0xae:
      return "LDX abs";
      case 0xaf:
      return "INVALID";
      case 0xb0:
      return "BCS Rel";
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
      case 0xca:
      return "DEX impl";
      case 0xd0:
      return "BNE rel";
      case 0xe0:
      return "CPX #";
      case 0xe8:
      return "INX";
      case 0xea:
      return "NOP";
      case 0xee:
      return "INC abs";
      case 0xf0:
      return "BEQ rel";
      case 0xf8:
      return "SED impl";
      case 0xfa:
      return "BEQ rel";
//----------------------------DEFAULT CASE      
      default:
      return "UNKNOWN";
    };
    }
  else{
    return  "   " ;
  }
} 

char *find_chip(unsigned int prefix_address) {
  if (prefix_address >= 32768){ //8000 hex
    return "ROM  ";
   } else if (prefix_address >= 256 and prefix_address < 512){ //$0000 y $4000
    return "STACK";   
  } else if (prefix_address >= 0 and prefix_address < 16386){ //$0000 y $4000
    return "RAM  ";
 } else if (prefix_address >= 24576 and prefix_address < 28672){ //$6000 $7000
    return "VIA1 ";
 }  else if (prefix_address >= 28672 and prefix_address < 32768){//$7000 $8000
    return "VIA2 ";
 } else {
    return "UNKWO";
 };
}

void loop() {
}
