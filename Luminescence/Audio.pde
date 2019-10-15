import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer fond;
AudioPlayer passagereL;
AudioPlayer passagereR;
AudioPlayer passagere3;

//REGLAGE
//Gain
float main = 0;
float proche = 3;
float loin = -3;

//VARIABLE
float pan = 0;

void setupAudio(){
  minim = new Minim(this);
  fond = minim.loadFile("Piste-de-fond.mp3");
  passagereL = minim.loadFile("Piste-passagere-1.mp3");
  passagereR = minim.loadFile("Piste-passagere-2.mp3");
  passagere3 = minim.loadFile("Piste-passagere-3.mp3");
 
  fond.setGain(main);
  //fond.loop();
  //fond.skip(180000);
  passagereL.setGain(-80);
  passagereL.loop();
  passagereR.setGain(-80);
  passagereR.loop();
  passagere3.setGain(-80);
  passagere3.loop();
}

void playAudio(){
  //passagere3.setGain(map(abs(panAngle),0,HALF_PI, -80,3));
  
  fond.setPan(pan/2);
  passagereL.setPan(pan);
  passagereR.setPan(-pan);
  
  fond.setGain(main);   
  if(panAngle < 0){
    passagereL.shiftGain(passagereL.getGain(),proche,500);
    passagereR.shiftGain(passagereR.getGain(),-loin,500);
  }
  else if(panAngle > 0){
    passagereL.shiftGain(passagereL.getGain(),-loin,500);
    passagereR.shiftGain(passagereR.getGain(),proche,500);
  }
  else{
    passagereL.shiftGain(passagereL.getGain(),-80,5000);
    passagereR.shiftGain(passagereR.getGain(),-80,5000);
  }
  //if(panAngle != 0) passagere3.shiftGain(passagere3.getGain(),6,500);
  //else passagere3.shiftGain(passagere3.getGain(), -80, 5000);
  //passagere3.setPan(panAngle/HALF_PI);
 // println(panAngle+ "\t Volume P3 : " + passagere3.getGain() + "\t Pan P3 : " + passagere3.getPan());
  if(fond.isPlaying()){
    //println("Position : " + fond.position() + " ms \t Volume : " + getMax());
  }
}

float getMax(){
  float max = 0;
  for(int i =0; i<fond.bufferSize(); i++){
    max = max(max, fond.left.get(i));
  }
  return max;
}

void keyReleasedAudio(){
  if (key == ' '){
    if(fond.isPlaying()){
      fond.pause();
      println(fond.position());
    } 
    else {
      fond.rewind();
      fond.loop();
      passagereL.skip(fond.position());
      passagereR.skip(fond.position());
      passagere3.skip(fond.position());
    }
  }
  if(key == '0'){
     if(fond.isMuted()) fond.unmute();
     else fond.mute();
  }
  
}

//addListener ( )
//bufferSize ( )
//cue ( )
//getBalance ( )
//getFormat ( )
//getGain ( )
//getMetaData ( )
//getPan ( )
//getVolume ( )
//isLooping ( )
//isMuted ( )
//isPlaying ( )
//length ( )
//loop ( )
//loopCount ( )
//mute ( )
//pause ( )
//play ( )
//position ( )
//removeListener ( )
//rewind ( )
//sampleRate ( )
//setBalance ( )
//setGain ( )
//setLoopPoints ( )
//setPan ( )
//setVolume ( )
//shiftBalance ( )
//shiftGain ( )
//shiftPan ( )
//shiftVolume ( )
//skip ( )
//type ( )
//unmute ( )
