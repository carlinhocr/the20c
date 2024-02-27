byte BUS[] = {2,3,4,5};
byte LCD[] = {6,7,8,9,10,11,12};
byte BarValue[4];

byte pinLed1 =A0;
byte pinLed2 =A1;

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
  pinMode (pinLed1,OUTPUT);
  pinMode (pinLed2,OUTPUT);
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

  for (int n=0;n<4;n++){
    BarValue[n] = digitalRead(BUS[n]) ? 1:0;
  };
  digitalWrite(pinLed1,LOW);
  digitalWrite(pinLed2,HIGH);
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
  digitalWrite(pinLed1,HIGH);
  digitalWrite(pinLed2,LOW);
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
