#include <Wire.h>
#include <PWM.h> 

//Base frequency and trimmer Ranges  
#define MIN_FREQUENCY 0
#define MAX_FREQUENCY 100
#define MIN_FREQUENCY_OFFSET -5.0
#define MAX_FREQUENCY_OFFSET 5.0
#define MIN_BRIGHTNESS 0          // allows light to be off to reveal the full oscillating effect
#define MAX_BRIGHTNESS 70.0       // too high and flickering will occur

const byte LED_stripBlack = 10;        // pin for LED strip control
const byte LED_stripWhite = 9;        // pin for LED strip control
const byte EMagnet = 3;           // pin for Electromagnet control
const byte ButtonSW = 6;          // pin for mode selection button

boolean led_on = true;
boolean serial_on = true;
boolean pot_on = false;
boolean mode_changed = true;

byte mode = 1; //toggle it by button SW
//mode 1 = normal slow motion mode controlled by serial
//mode 2 = normal slow motion mode controlled by 2 pots 
//mode 3 = completely off

byte buttonState = 0;             // current state of the button
byte lastButtonState = 0;         // previous state of the button

float frequency_offset = msg_fql;
float duty_eMagnet = 15.0;          // 15; be carefull not to overheat the magnet with too high duty cycle. Better adjust force through magnet position
float frequency_eMagnet = msg_fqm;  
float duty_ledBlack = msg_lub;  
float duty_ledWhite = msg_luw;  
float frequency_led = frequency_eMagnet + frequency_offset; 

int lastBrightnessValueBlack = 0;
int lastBrightnessValueWhite = 0;

void setupSF()
{
  pinMode(ButtonSW, INPUT_PULLUP); // Mode button
    
  //initialize all timers except for 0, to save time keeping functions
  InitTimersSafe(); 

  //sets the frequency for the specified pin
  bool success = SetPinFrequencySafe(LED_stripBlack, frequency_led);
  bool success1 = SetPinFrequencySafe(LED_stripWhite, frequency_led);
  bool success2 = SetPinFrequencySafe(EMagnet, frequency_eMagnet);
}

void loopSF()
{     
  if (mode_changed == true)
  {
    if (mode == 1)  //normal slow motion mode (power on)
    {   
      serial_on = true;
      eMagnet_on();    
      led_on = true;
      pot_on = false;
    }
    if (mode == 2)  //normal slow motion mode (power on)
    {   
      serial_on = false;
      eMagnet_on();    
      led_on = true;
      pot_on = true;
      duty_ledBlack = MAX_BRIGHTNESS;
      duty_ledWhite = MAX_BRIGHTNESS;
    }
    else if (mode == 3)  // distorted reality mode
    {
      serial_on = false;
      eMagnet_off();
      led_on = false;
      pot_on = false;
    }
    
    mode_changed = false; 
  }
  
  if (serial_on == true){
    frequency_eMagnet = msg_fqm;
    frequency_offset = msg_fql;
    frequency_led = frequency_eMagnet + msg_fql;
    if(act_lum == 1)  {
      led_on = true; 
      duty_ledBlack = msg_lub;
      duty_ledWhite = msg_luw;
    }
    else if (act_lum == 0) {
      led_on = false;
    }
    //act_lum = 2;
    if(act_mot == 1){
      eMagnet_on(); 
    }
    else if (act_mot == 0){
      eMagnet_off();
    }
    act_mot = 2;
  }

  if (pot_on == true){
    frequency_eMagnet = -(MAX_FREQUENCY - MIN_FREQUENCY)*float(analogRead(A0))/1023L+MAX_FREQUENCY;
    frequency_offset = -(MAX_FREQUENCY_OFFSET-MIN_FREQUENCY_OFFSET)/1023L*analogRead(A1)+MAX_FREQUENCY_OFFSET; //Speed: 0.1 .. 5 Hz
    frequency_led = frequency_eMagnet + frequency_offset;  
  }
  if (led_on == true)
  {
    SetPinFrequencySafe(EMagnet, frequency_eMagnet);   
    SetPinFrequencySafe(LED_stripBlack, frequency_led);
    SetPinFrequencySafe(LED_stripWhite, frequency_led);

    //-------------Black LED-------------
    if (lastBrightnessValueBlack < round(duty_ledBlack*255/100))  //previously dimmer - gradually bright it
    {
      for (int i=lastBrightnessValueBlack; i<round(duty_ledBlack*255/100); i++)
      {
        pwmWrite(LED_stripBlack, i);
        delay(10);
      }
    } 
    else if (lastBrightnessValueBlack > round(duty_ledBlack*255/100)) //previously brighter - gradually dim it
    {
      for (int i=lastBrightnessValueBlack; i>round(duty_ledBlack*255/100); i--)
      {
        pwmWrite(LED_stripBlack, i);
        delay(10);      
      }
    }
    else  //no change in brightness
      pwmWrite(LED_stripBlack, round(duty_ledBlack*255/100));   

    lastBrightnessValueBlack = round(duty_ledBlack*255/100);

    //-------------White LED-----------------
    if (lastBrightnessValueWhite < round(duty_ledWhite*255/100))  //previously dimmer - gradually bright it
    {
      for (int i=lastBrightnessValueWhite; i<round(duty_ledWhite*255/100); i++)
      {
        pwmWrite(LED_stripWhite, i);
        delay(10);
      }
    } 
    else if (lastBrightnessValueWhite > round(duty_ledWhite*255/100)) //previously brighter - gradually dim it
    {
      for (int i=lastBrightnessValueWhite; i>round(duty_ledWhite*255/100); i--)
      {
        pwmWrite(LED_stripWhite, i);
        delay(10);      
      }
    }
    else  //no change in brightness
      pwmWrite(LED_stripWhite, round(duty_ledWhite*255/100));   

    lastBrightnessValueWhite = round(duty_ledWhite*255/100);
  }
  else  //led_on = false;
  {
    //-----gradually dim off black
    for (int i=round(duty_ledBlack*255/100); i>0; i--)
    {
      pwmWrite(LED_stripBlack, i);
      delay(30);
    }
      
    duty_ledBlack = 0;      
    pwmWrite(LED_stripBlack, 0);
    lastBrightnessValueBlack = 0;

    //-----gradually dim off White
    for (int i=round(duty_ledWhite*255/100); i>0; i--)
    {
      pwmWrite(LED_stripWhite, i);
      delay(30);
    }
      
    duty_ledWhite = 0;      
    pwmWrite(LED_stripWhite, 0);
    lastBrightnessValueWhite = 0;
  }
#ifdef DEBUGSF
    //Heatbeat on-board LED
    //digitalWrite(LED, HIGH); // LED on
    //delay(300);
    //digitalWrite(LED, LOW); // LED off
    //delay(300); 
    //digitalWrite(LED, HIGH); // LED on
    //delay(200);
    //digitalWrite(LED, LOW); // LED off
    //delay(1200); 
    
    //serial print current parameters
    Serial.print("Frequency Offset: "); 
    Serial.print(frequency_offset);
    Serial.print("  Force: ");
    Serial.print(duty_eMagnet);
    Serial.print("  Freq Mag: ");
    Serial.print(frequency_eMagnet);
    Serial.print("  Freq LED: ");
    Serial.print(frequency_led);
    Serial.print("  Brightness: ");
    Serial.println(duty_ledBlack);
  #endif

    
  // read the button SW
  buttonState = digitalRead(ButtonSW);

  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) 
  {
    // if the state has changed, increment the counter
    if (buttonState == LOW) 
    {    
      mode++;

      if (mode > 3)
        mode = 1; //rotary menu
      
      mode_changed = true ;      
    }

    // delay a little bit for button debouncing
    delay(50);
  }

  lastButtonState = buttonState;
}



//**********************************************************************************************************************************************************
void eMagnet_on() 
{
  pwmWrite(EMagnet, round(duty_eMagnet*255/100));
}



//**********************************************************************************************************************************************************
void eMagnet_off() 
{
  pwmWrite(EMagnet, 0);  
}
