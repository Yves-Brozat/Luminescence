//#define DEBUG
//#define DEBUGSF
//#define DEBUGSERIAL
//#define DEBUGSERVO

//Pins definition
const byte pinPot[] = {A0,A1};
const byte pinSns[] = {A2,A7};
const byte pinSrv = 0;

//mode pour le déplacement du servo
#define LIGHTREACTIVE 0
#define REMOTE 1
int modeServo = REMOTE; // 0 si réactif à la lumiere, 1 si controlé via Serial

void setup() {
  Serial.begin(115200);
  Serial.setTimeout(5);
  setupServo();
  setupSF();
}

void loop() {
  updateServo();
  moveServo();
   
  sendSerial();
  receiveSerial();
   
  loopSF();

  #ifdef DEBUG
    Serial.print("    CG: ");
    Serial.print(analogRead(pinSns[0]));
    Serial.print("    CD: ");
    Serial.print(analogRead(pinSns[1]));
    //Serial.print("    CD-CG: ");
    //Serial.print(angleLumiere);
    //Serial.print("    CD+CG: ");
    //Serial.print(luminosite);
    Serial.println("");
  #endif
}
