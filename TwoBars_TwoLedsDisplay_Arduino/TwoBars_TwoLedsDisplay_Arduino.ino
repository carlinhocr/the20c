byte BUS[] = {2,3,4,5};
byte LCD[] = {11,12,A5,A4,A3,A2,A1};
byte BarValue[4];

byte groundLed1 =A0;
byte groundLed2 =13;

const char b_0[] ={0,0,0,0};
const char b_1[] ={0,0,0,1};
const char b_2[] ={0,0,1,0};
const char b_3[] ={0,0,1,1};
const char b_4[] ={0,1,0,0};
const char b_5[] ={0,1,0,1};
const char b_6[] ={0,1,1,0};
const char b_7[] ={0,1,1,1};
const char b_8[] ={1,0,0,0};
const char b_9[] ={1,0,0,1};
const char b_a[] ={1,0,1,0};
const char b_b[] ={1,0,1,1};
const char b_c[] ={1,1,0,0};
const char b_d[] ={1,1,0,1};
const char b_e[] ={1,1,1,0};
const char b_f[] ={1,1,1,1};

const char d_0[] ={1,1,1,1,1,1,0};
const char d_1[] ={0,1,1,0,0,0,0};
const char d_2[] ={1,1,0,1,1,0,1};
const char d_3[] ={1,1,1,1,0,0,1};
const char d_4[] ={0,1,1,0,0,1,1};
const char d_5[] ={1,0,1,1,0,1,1};
const char d_6[] ={1,0,1,1,1,1,1};
const char d_7[] ={1,1,1,0,0,0,0};
const char d_8[] ={1,1,1,1,1,1,1};
const char d_9[] ={1,1,1,0,0,1,1};
const char d_a[] ={1,1,1,0,1,1,1};
const char d_b[] ={0,0,1,1,1,1,1};
const char d_c[] ={1,0,0,1,1,1,0};
const char d_d[] ={0,1,1,1,1,0,1};
const char d_e[] ={1,0,0,1,1,1,1};
const char d_f[] ={1,0,0,0,1,1,1};

void setup() {
  pinMode (groundLed1,OUTPUT);
  pinMode (groundLed2,OUTPUT);
  for (int n=0;n<4;n++){
    pinMode(BUS[n], INPUT);
  };
   for (int n=0;n<7;n++){
    pinMode(LCD[n], OUTPUT);
  }
  // each time that on pin 2 (clock) i receive a HIGH on the rising edge run the onClock function
  Serial.begin(115200);
}

void loop() {
  // reade the bus
  testAllNumberDual7Segment();
  for (int n=0;n<4;n++){
    BarValue[n] = digitalRead(BUS[n]) ? 1:0;
  };
  digitalWrite(groundLed1,LOW);
  digitalWrite(groundLed2,HIGH);
  light7segment(BarValue,d_0,b_0);
  light7segment(BarValue,d_1,b_1);
  light7segment(BarValue,d_2,b_2);
  light7segment(BarValue,d_3,b_3);
  light7segment(BarValue,d_4,b_4);
  light7segment(BarValue,d_5,b_5);
  light7segment(BarValue,d_6,b_6);
  light7segment(BarValue,d_7,b_7);
  light7segment(BarValue,d_8,b_8);
  light7segment(BarValue,d_9,b_9);
  light7segment(BarValue,d_a,b_a);
  light7segment(BarValue,d_b,b_b);
  light7segment(BarValue,d_c,b_c);
  light7segment(BarValue,d_d,b_d);
  light7segment(BarValue,d_e,b_e);
  light7segment(BarValue,d_f,b_f);
  delay(5000);
  digitalWrite(groundLed1,HIGH);
  digitalWrite(groundLed2,LOW);
  delay(5000);
}

void testNumber(char d_x[7]){
    for (int n=0;n<7;n++){
      digitalWrite(LCD[n],d_x[n]);
    };
}

void testNumberDual7Segment(char d_x[7]){
  digitalWrite(groundLed1,LOW);
  digitalWrite(groundLed2,HIGH);
  for (int n=0;n<7;n++){
    digitalWrite(LCD[n],d_x[n]);
  };
  delay(2500);
  digitalWrite(groundLed1,HIGH);
  digitalWrite(groundLed2,LOW);
  for (int n=0;n<7;n++){
    digitalWrite(LCD[n],d_x[n]);
  };
  delay(2500);
}

void testAllNumberDual7Segment(){
  testNumberDual7Segment(d_0);
  testNumberDual7Segment(d_1);
  testNumberDual7Segment(d_2);
  testNumberDual7Segment(d_3);
  testNumberDual7Segment(d_4);
  testNumberDual7Segment(d_5);
  testNumberDual7Segment(d_6);
  testNumberDual7Segment(d_7);
  testNumberDual7Segment(d_8);
  testNumberDual7Segment(d_9);
  testNumberDual7Segment(d_a);
  testNumberDual7Segment(d_b);
  testNumberDual7Segment(d_c);
  testNumberDual7Segment(d_d);
  testNumberDual7Segment(d_e);
  testNumberDual7Segment(d_f);
}

void testAllNumbers(){
  testNumber(d_0);
    delay(5000);
  testNumber(d_1);
    delay(5000);
  testNumber(d_2);
    delay(5000);
  testNumber(d_3);
    delay(5000);
  testNumber(d_4);
    delay(5000);
  testNumber(d_5);
    delay(5000);
  testNumber(d_6);
    delay(5000);
  testNumber(d_7);
    delay(5000);
  testNumber(d_8);
    delay(5000);
  testNumber(d_9);
    delay(5000);
  testNumber(d_a);
    delay(5000);
  testNumber(d_b);
    delay(5000);
  testNumber(d_c);
    delay(5000);
  testNumber(d_d);
    delay(5000);
  testNumber(d_e);
    delay(5000);
  testNumber(d_f);
    delay(5000);
}


void light7segment(char readValue[4], char d_x[7],char b_x[4]){
    bool found = true;
    for (int i=0;i<4;i++){
      if (readValue[i] != b_x[i]){
        found = false;   
      }
    };
    if (found == true){
      for (int n=0;n<7;n++){
        digitalWrite(LCD[n],d_x[n]);
      };
    }
}
