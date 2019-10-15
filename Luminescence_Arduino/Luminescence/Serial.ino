int timeSerialOut = 0;
float msg_lub = 10.0;  //Intensité des leds black (0,20)
float msg_luw = 10.0;  //Intensité des leds white (0,20)
float msg_fqm = 52.5; //Frequence du moteur en Hz (0,100)
float msg_fql = -2.5; //Offset leds/moteur en Hz (-5,5)
int msg_agl = 90; //Angle servomoteur (0,180)
int msg_vsm = 100; // nombre d'executions entre deux incrémentations/mouvements
int msg_cmn = 100; // Minimum de luminosité captée (= lumière émise par l'écran)
int msg_cmx = 300; //Maximum de luminosité captée

int act_lum = 0;  //On/Off led
int act_mot = 0;  //On/Off moteur

#define VIT_SENDER 1

void receiveSerial(){
  if(Serial.available()){
    String str = ""; 
    while (Serial.available()){
      str += String(Serial.readString());
      //delay(10);
    }

    String prefix = str.substring(0,3);
    String value = str.substring(3);

    #ifdef DEBUGSERIAL    
    Serial.print("Message recu : " + str + "\t");
    Serial.println("Prefix : " + prefix + "\t Value : " + value);
    #endif
    
    if(prefix == "lub"){
      msg_lub = value.toFloat();
      #ifdef DEBUGSERIAL
      Serial.print("Lumiere noire : ");
      Serial.print(msg_lub);
      Serial.println("");
      #endif
    }
    if(prefix == "luw"){
      msg_luw = value.toFloat();
      #ifdef DEBUGSERIAL
      Serial.print("Lumiere blanche : ");
      Serial.print(msg_luw);
      Serial.println("");
      #endif
    }
    if(prefix == "fqm"){
      msg_fqm = value.toFloat();
      #ifdef DEBUGSERIAL
      Serial.print("Frequence moteur : ");
      Serial.print(msg_fqm);
      Serial.println(" Hz");
      #endif
    }
    if(prefix == "fql"){
      msg_fql = value.toFloat();
      #ifdef DEBUGSERIAL
      Serial.print("Frequence Lumiere : ");
      Serial.print(msg_fql);
      Serial.println(" Hz");
      #endif
    }
    if(prefix == "agl"){
      msg_agl = value.toInt();
      #ifdef DEBUGSERIAL
      Serial.print("Angle Servo : ");
      Serial.print(msg_agl);
      Serial.println(" [0, 180]");
      #endif
    }
    if(prefix == "rmt"){
      int i = value.toInt();
      modeServo = i;
      #ifdef DEBUGSERIAL
      Serial.print("Mode servo");
      Serial.print(modeServo);
      Serial.println("   (1 = REMOTE, 0 = LIGHTREACTIVE)");
      #endif
    }
    if(prefix == "clb"){
      int i = value.toInt();
      calibrate(i);
      #ifdef DEBUGSERIAL
      Serial.print("Capteur calibré : ");
      Serial.print(i);
      Serial.println("   (0 = GAUCHE, 1 = DROIT)");
      Serial.print("valSnsCalib = ");
      Serial.print(getValSnsCalib(i));
      Serial.println("   [0..1024]"); 
      #endif
    }
    if(prefix == "mod"){
      int i = value.toInt();
      act_mot = i;
      act_lum = i;
      #ifdef DEBUGSERIAL
      Serial.print("Moteur : ");
      Serial.print(act_mot);
      Serial.print(  "Lumiere : ");
      Serial.print(act_lum);
      Serial.println("   (1 = ON, 0 = OFF)");
      #endif
    }
    if(prefix == "mot"){
      act_mot = value.toInt();
      #ifdef DEBUGSERIAL
      Serial.print("Moteur : ");
      Serial.print(act_mot);
      Serial.println("   (1 = ON, 0 = OFF)");
      #endif
    }
    if(prefix == "led"){
      act_lum = value.toInt();
      #ifdef DEBUGSERIAL
      Serial.print("Leds : ");
      Serial.print(act_lum);
      Serial.println("   (1 = ON, 0 = OFF)");
      #endif
    }
    if(prefix == "vsm"){
      msg_vsm = value.toInt();
      #ifdef DEBUGSERIAL
      Serial.print("Vitesse Servo : ");
      Serial.print(msg_vsm);
      Serial.println(" [50, 300]");
      #endif
    }

    if(prefix == "cmn"){
      msg_cmn = value.toInt();
      #ifdef DEBUGSERIAL
      Serial.print("Luminosité ambiante (écran) : ");
      Serial.println(msg_cmn);
      #endif
    }

    if(prefix == "cmx"){
      msg_cmx = value.toInt();
      #ifdef DEBUGSERIAL
      Serial.print("Max luminosité captée : ");
      Serial.print(msg_cmx);
      Serial.println(" [50, 300]");
      #endif
    }
  }
}

void sendSerial(){
 if(timeSerialOut > VIT_SENDER){
    if(modeServo == LIGHTREACTIVE){
      Serial.print("ServoPosition");
      Serial.print(" ");
      Serial.println(getPosServo());

      Serial.print("CapteurGauche");
      Serial.print(" ");
      Serial.println(getValSns(0));

      Serial.print("CapteurDroit");
      Serial.print(" ");
      Serial.println(getValSns(1));

      delay(1);
    }
  timeSerialOut = 0;
 }
 timeSerialOut++;
}
