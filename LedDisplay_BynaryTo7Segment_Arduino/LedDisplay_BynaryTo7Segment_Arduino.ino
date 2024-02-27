byte BUS[] = {2,3,4,5};
byte LCD[] = {6,7,8,9,10,11,12};
byte BarValue[4];

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
  // // zero
  // bool found0 = true;
  // for (int i=0;i<4;i++){
  //   if (BarValue[i] != b_0[i]){
  //     found0 = false;   
  //   }
  // };
  // if (found0 == true){
  //   for (int n=0;n<7;n++){
  //     digitalWrite(LCD[n],d_0[n]);
  //     };
  // }
  // // one
  // bool found1 = true;
  // for (int i=0;i<4;i++){
  //   if (BarValue[i] != b_1[i]){
  //     found1 = false;   
  //   }
  // };
  // if (found1 == true){
  //   for (int n=0;n<7;n++){
  //     digitalWrite(LCD[n],d_1[n]);
  //     };
  // }
  // two
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
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_0[n]);
//   };
//   delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_1[n]);
//   };
//   delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_2[n]);
//   };
//   delay (500);
//   delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_3[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_4[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_5[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_6[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_7[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_8[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_9[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_a[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_b[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_c[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_d[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_e[n]);
//   };
//     delay (500);
//   for (int n=0;n<7;n++){
//     digitalWrite(LCD[n],d_f[n]);
//   };
//     delay (500);
// }


