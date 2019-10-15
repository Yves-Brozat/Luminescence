import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress remote;

void setupOsc() {
  oscP5 = new OscP5(this, 9000);
  remote = new NetAddress("127.0.0.1",13000);
  sendFloat(remote, "/Remote/Pan", 0.5); 
  sendFloat(remote, "/Remote/Main", 1.0);
  sendFloat(remote, "/Remote/Proche", 0.75);
  sendFloat(remote, "/Remote/Loin", 0.25);
  sendInt(remote, "/isPlaying", 0);
  sendInt(remote, "/stop", 0);

  float x = x_svg/viewport_w;
  float y = y_svg/viewport_h;
  sendFloat(remote, "/mappingX", x);
  sendFloat(remote, "/mappingY", y);
  sendFloat(remote, "/mappingScale", scl_svg);
}


void sendFloat(NetAddress ipAddr, String msgAddr, float f) {
  OscMessage msgOut = new OscMessage(msgAddr);
  msgOut.add(f);
  oscP5.send(msgOut, ipAddr); 
}

void sendInt(NetAddress ipAddr, String msgAddr, int i) {
  OscMessage msgOut = new OscMessage(msgAddr);
  msgOut.add(i);
  oscP5.send(msgOut, ipAddr); 
}

void oscEvent(OscMessage msg) {
  
  String addr = msg.addrPattern();
  print(" addrpattern: " + addr + "    ");
  String typetag = msg.typetag();
  println("\t typetag: " + typetag);
  
  float val1 = 0, val2 = 0, val3 = 0;
  if(typetag.equals("fff")){ 
    val1  = msg.get(0).floatValue();
    val2  = msg.get(1).floatValue();
    val3  = msg.get(2).floatValue();
  }
  if(typetag.equals("ff")){ 
    val1  = msg.get(0).floatValue();
    val2  = msg.get(1).floatValue();
  }
  if(typetag.equals("f")){ 
    val1  = msg.get(0).floatValue();
  }  
  
  switch(addr){
    
    case "/medusesTrigged" : medusesTrigged = (msg.get(0).intValue() > 0.5);  break;
    case "/rainTrigged" : rainTrigged = (msg.get(0).intValue() > 0.5);  break;
    case "/plantFlow" :  plantFlow = msg.get(0).intValue(); break;
    case "/noiseFlow" :  noiseFlow = msg.get(0).intValue(); break;

    case "/resetFluid" :
    fluid_reset();
    fluid_reset = msg.get(0).intValue() > 0.5;
    break;

    case "/displayVideo" :
    boolean on = msg.get(0).intValue() > 0.5;
    display_particles = on;
    display_seeds = on;
    println("ON/OFF : " + on);
    break;

    case "/panVideo" :
    panAngle = map(val1,50,130, -20, 20);  //Video
    break;

    case "/display_particles" : display_particles = msg.get(0).intValue() > 0.5;  break;
    case "/display_seeds" : display_seeds = msg.get(0).intValue() > 0.5;  break;
    case "/display_shape" : display_shape = msg.get(0).intValue() > 0.5;  break;  
    case "/shapeVisible" : plante.visible = msg.get(0).intValue() > 0.5;  break;  

    case "/dessin/1x":
    px1 = x1;
    x1 = val1*displayWidth;
    break;

    case "/dessin/2x":
    px2 = x2;
    x2 = val1*displayWidth;
    break;

    case "/dessin/1y":
    py1 = y1;
    y1 = displayHeight - val1*displayHeight;
    break;

    case "/dessin/2y":
    py2 = y2;
    y2 = displayHeight - val1*displayHeight;
    break;

    case "/rightHandX" : 
    px2 = x2;
    x2 = val1*width;
    break;

    case "/rightHandY" : 
    py2 = y2;
    y2 = val1*height;
    break;

    case "/kinect" : touchPressed2 = msg.get(0).intValue()>0.5;  break;

    case "/dessin/1/z": touchPressed1 = msg.get(0).intValue()>0.5;  break;
    case "/dessin/2/z": touchPressed2 = msg.get(0).intValue()>0.5;  break;
    case "/dessin/1/r": r1 = val1;  break;
    case "/dessin/2/r": r2 = val1;  break;
    case "/dessin/1/v": v1 = val1;  break;
    case "/dessin/2/v": v2 = val1;  break;
    case "/dessin/1/n": n1 = msg.get(0).intValue();  break;
    case "/dessin/2/n": n2 = msg.get(0).intValue();  break;

    case "/param/dissipation_density" : fluid.param.dissipation_density     = val1; break;
    case "/param/dissipation_velocity" : fluid.param.dissipation_velocity     = val1; break;
    case "/param/dissipation_temperature" : fluid.param.dissipation_temperature =   val1; break;
    case "/param/vorticity" : fluid.param.vorticity =   val1; break;
    case "/param/timestep" : fluid.param.timestep =   val1; break;

    case "/mappingX" : 
    x_svg = val1*viewport_w; 
    plante.displace(x_svg, y_svg); 
    //plante.drawShape(pg_obstacles);  
    //fluid.addObstacles(pg_obstacles);
    break;
    case "/mappingY" : 
    y_svg = val1*viewport_h; 
    plante.displace(x_svg, y_svg);  
    //plante.drawShape(pg_obstacles);  
    //fluid.addObstacles(pg_obstacles);   
    break;
    case "/mappingScale" : 
    scl_svg = val1; 
    plante.resize(scl_svg); 
    //plante.drawShape(pg_obstacles);  
    //fluid.addObstacles(pg_obstacles);
    break;

    case "/enveloppe" : 
    volume = val1;
    break;
  }
}
