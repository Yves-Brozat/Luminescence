import processing.serial.*;


Serial serial;  // Create a list of objects from Serial class
int msg_lum = 200;         // a list to hold data from the serial ports
int msg_pan = 90;
void setupSerial()  {
  serial = new Serial(this, serial.list()[0], 9600);
}


void serialEvent(Serial thisPort) {
  while(thisPort.available()>0){
    int inByte = thisPort.read();
    //println(inByte);
    if(inByte <= 180){
      msg_pan = inByte;
      float pan = float(msg_pan);
      panAngle = radians(pan-90);  
      print("   PAN :" + msg_pan);
    }
    else if(inByte >= 200){
      msg_lum = inByte;
      float lum = float(msg_lum);
      fluid.param.timestep = map(lum, 200, 255, 0.025f, 0.1f);
      print("   TIMESTEP :" + fluid.param.timestep);
    }
    println("");
  }
  
  //println("msg_pan:"+msg_pan + "   msg_lum :"+msg_lum);
}

/*
The following Wiring/Arduino code runs on both microcontrollers that
were used to send data to this sketch:

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
}

void loop() {
  // read analog input, divide by 4 to make the range 0-255:
  int analogValue = analogRead(0)/4; 
  Serial.write(analogValue);
  // pause for 10 milliseconds:
  delay(10);                 
}


*/
