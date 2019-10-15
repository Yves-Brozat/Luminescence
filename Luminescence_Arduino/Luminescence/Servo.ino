#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver( 0x40 );

//Angle position of servo
#define INIT_POS_SERVO 90
#define MIN_POS_SERVO 50
#define MAX_POS_SERVO 130
#define MIN_DIRECTION 10
#define MAX_DIRECTIONG -70 
#define MAX_DIRECTIOND 70 

//PWM conversion
#define MIN_SERVO  100 // La longueur d'impulsion 'minimale' (valeur du compteur, max 4096)
#define MAX_SERVO  360 // La longueur d'impulsion 'maximale' (valeur du compteur, max 4096)

#define PAS_SERVO 1 //angle en degree entre chaque mouvements. 
#define VIT_SWEEP 2 // nombre d'executions entre 2 inc de targetPos

//Luminosity sensors
#define VIT_CAPTEUR 10 // nombre d'executions entre deux relevés

//Variables relatives au servomoteur
int pos_servo = INIT_POS_SERVO; // 0..180
int targetPos = INIT_POS_SERVO;
int targetPos_tmp = INIT_POS_SERVO;
int timeServo = 0;
int timeSweep = 0;
int sgn = 1;


//Variables relatives aux capteurs de luminosité
int valSns[] = {0,0};
int valSnsCalib[] = {0, 0};
int luminosite = 0;
int angleLumiere = 0;
int timeCapteur = 0;
int min_luminosite = msg_cmn;

void setupServo(){
  pwm.begin();
  pwm.setPWMFreq(50);  // Les servo sont mis-à-jour à ~60 Hz
  calibrate(0);
  calibrate(1);
}

void updateServo(){
   switch(modeServo){
    case LIGHTREACTIVE :  followLight(); break;
    case REMOTE : followSerial(); break; 
   }  
}

void moveServo(){
  setTargetPos_tmp(targetPos);
  pos_servo = targetPos_tmp;
  pwm.setPWM(pinSrv, 0, map( pos_servo, MIN_POS_SERVO, MAX_POS_SERVO, MIN_SERVO, MAX_SERVO ));
  #ifdef DEBUGSERVO    
    Serial.print("pos_servo : ");
    Serial.print(pos_servo);
    Serial.println("");
  #endif
}

void setTargetPos_tmp(int targetPos){
  timeServo++; 
  if(timeServo > msg_vsm)
  {
    if(pos_servo <= targetPos - PAS_SERVO){ 
      targetPos_tmp = pos_servo + PAS_SERVO;
    }
    else if(pos_servo >= targetPos + PAS_SERVO){
      targetPos_tmp = pos_servo - PAS_SERVO;
    }
    else targetPos_tmp = targetPos;
    timeServo = 0; 
  }  
}

int getPosServo(){
  return pos_servo;
}

int getModeServo(){
  return modeServo;
}

void followLight(){
   timeCapteur++;
   if(timeCapteur > VIT_CAPTEUR){
     timeCapteur = 0;
     valSns[0] = analogRead(pinSns[0])-valSnsCalib[0];
     valSns[1] = analogRead(pinSns[1])-valSnsCalib[1];
     luminosite = valSns[1] + valSns[0];
     angleLumiere = valSns[1]- valSns[0];
     min_luminosite = valSnsCalib[0]+valSnsCalib[1]+msg_cmn;

     if (luminosite > min_luminosite){
      luminosite = constrain(luminosite, min_luminosite, msg_cmx);
      angleLumiere = constrain(angleLumiere, MAX_DIRECTIONG, MAX_DIRECTIOND);
      if (angleLumiere > -MIN_DIRECTION && angleLumiere < MIN_DIRECTION){
        targetPos = INIT_POS_SERVO;
      }
      else if (angleLumiere < -MIN_DIRECTION){
        targetPos = map(angleLumiere, -MIN_DIRECTION, MAX_DIRECTIONG, INIT_POS_SERVO, MIN_POS_SERVO);
      }
      else if (angleLumiere > MIN_DIRECTION){
        targetPos = map(angleLumiere, MIN_DIRECTION, MAX_DIRECTIOND, INIT_POS_SERVO, MAX_POS_SERVO);
      }
     }
     else {
      targetPos = INIT_POS_SERVO;
     }
   }
}

void calibrate(int i){          //i = 0 : Gauche, i = 1 : Droite
  valSnsCalib[i] = analogRead(pinSns[i]);
}

int getValSnsCalib(int i){      //i = 0 : Gauche, i = 1 : Droite
  return valSnsCalib[i];
}

int getValSns(int i){           //i = 0 : Gauche, i = 1 : Droite
  return valSns[i];
}

void followSerial(){
  targetPos = msg_agl;
}

void sweep(){
  timeSweep++;
  if (timeSweep > VIT_SWEEP){
    timeServo = 0;
    if(targetPos >= MAX_POS_SERVO || targetPos <= MIN_POS_SERVO){
      sgn *=-1;
    }
    targetPos += sgn*2;
  }

  #ifdef DEBUGSERVO    
    Serial.print("targetPos : ");
    Serial.print(targetPos);
    Serial.print("\t");
    Serial.print("sgn : ");
    Serial.print(sgn);
    Serial.print("\t");
  #endif

}
