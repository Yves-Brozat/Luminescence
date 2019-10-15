/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */



import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;
import processing.opengl.PJOGL;


  // Fluid_CustomParticles show how to setup a completely customized particle
  // system that is interacting with the fluid simulation.
  // The particle data (positions) is stored in an OpenGL texture (GL_RGBA32F) 
  // and gets updated each frame using GLSL shaders.
  // No Data transfer (application <-> device), is required.
  //
  //
  // controls:
  //
  // LMB: add Particles + Velocity
  // MMB: add Particles
  // RMB: add Particles
  
  boolean medusesTrigged = false;
  boolean rainTrigged = false;
  int plantFlow = 0;
  int noiseFlow = 0;
  boolean fluid_reset = false;
  boolean display_particles = false;
  boolean display_seeds = false;
  boolean display_shape = true;  //1 display, 0 clear, 2 nothing
  boolean display_gui = false;
  boolean touchPressed1 = false;
  boolean touchPressed2 = false;
  float x1 = 0,y1 = 0,x2 = 0,y2 = 0, px1, py1, px2, py2;
  float r1 = 15, v1 = 15, r2 = 15, v2 = 15;
  int n1 = 300, n2 = 300;
  float volume = 0;
  
  private class MyFluidData implements DwFluid2D.FluidData{
    
    float x = 0, y = 0, vxx= 0, vyy = 0, r = 0 ;
    int t = 60, flow = 0;
    float px = 0, py = 0, vx= 0, vy= 0, radius= 0, vscale, temperature;

    public void planteSpawn(DwFluid2D fluid){
      float inc = 1;
      for(int i = 0; i<plante.N; i+=inc){
        //int j = i%(plante.N/16);
        //int j = int(random(plante.N))%55;
        if(random(100.0) >= 100-0.1*plantFlow && !fluid_reset){
          radius = random(25,75);
          vscale = 55-plantFlow;
          px     = plante.vertices.get(i).x-20; 
          py     = viewport_h-plante.vertices.get(i).y;
          vx     = 1 * +vscale;
          vy     = 1 *  vscale;
          temperature = 0.f;
          fluid.addDensity(px, py, radius, 0.2f, 0.3f, 0.5f, 1.0f);
          fluid.addTemperature(px, py, radius, temperature);
          fluid.addVelocity(px,py, radius, vx, 0);
          particles.spawn(fluid, px, py, radius, plantFlow);
        }
      }
    }

    public void touchSpawn2(DwFluid2D fluid){
      radius = r2;
      vscale = v2;
      px     = x2;
      py     = y2; 
      vx     = (x2 - px2) * +vscale;
      vy     = (y2 - py2) * +vscale;
      fluid.addDensity (px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f);
      fluid.addVelocity(px, py, radius, vx, vy);
      particles.spawn(fluid,px,py,radius, n2);
    }

    public void touchSpawn1(DwFluid2D fluid){
      radius = r1;
      vscale = v1;
      px     = x1;
      py     = y1;
      vx     = (x1 - px1) * +vscale;
      vy     = (y1 - py1) * +vscale;
      fluid.addDensity (px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f); 
      fluid.addVelocity(px, py, radius, vx, vy);
      particles.spawn(fluid, px, py, radius, n1);
    }

    public void mouseSpawn(DwFluid2D fluid){
      boolean mouse_input;
      if(GUI) mouse_input = !cp5.isMouseOver() && mousePressed;
      else mouse_input  = mousePressed;
      
      if(mouse_input && mouseButton == LEFT){
        radius = 15;
        vscale = 15;
        px     = mouseX;
        py     = displayHeight-mouseY;
        vx     = (mouseX - pmouseX) * +vscale;
        vy     = (mouseY - pmouseY) * -vscale;
        fluid.addDensity (px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f); 
        fluid.addVelocity(px, py, radius, vx, vy);
        particles.spawn(fluid, px, py, radius*2, 300);
      }
      if(mouse_input && mouseButton == CENTER){
        radius = 15;
        vscale = 15;
        px     = mouseX;
        py     = displayHeight-mouseY;
        temperature = 2f;
        fluid.addDensity(px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f);
        fluid.addTemperature(px, py, radius, temperature);
        particles.spawn(fluid, px, py, radius, 100);
      }
      if(mouse_input && mouseButton == RIGHT){
        radius = 50;
        vscale = 50;
        px     = mouseX;
        py     = displayHeight - mouseY; // invert
        vx     = (mouseX - pmouseX) * +vscale;
        vy     = (mouseY - pmouseY) * -vscale;
        fluid.addDensity (px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f);
        //fluid.addVelocity(px,py, radius,vx,vy);
        particles.spawn(fluid, px, py, radius, 300);
      }
    }

    float borderSize = 0.2*displayHeight;
    public void bigMeduseSpawn(DwFluid2D fluid){
      if(frameCount%t == 0){
        t = int(random(60,120));
        x = random(borderSize, displayWidth - borderSize);
        y = random(borderSize, displayHeight - borderSize);
        r = random(40,70);
        vxx = random(-200,200);
        vyy = random(-200,200);
        flow = int(random(1000,5000));
      } 
      fluid.addDensity (x, y, r, 0.25f, 0.0f, 0.1f, 1.0f);
      fluid.addVelocity(x, y, random(0.8)*r, vxx, vyy);
      particles.spawn(fluid, x, y, r, flow);

    }

    public void littleMeduseSpawn(DwFluid2D fluid){
      x = random(width);
      y = random(height);
      r = random(10,30);
      vxx = random(-1000,1000);
      vyy = random(-100,100);
      flow = int(random(500,1000));  
      fluid.addDensity (x, y, r, 0.25f, 0.0f, 0.1f, 1.0f);
      fluid.addVelocity(x, y, 0.5*r, vxx, vyy);
      particles.spawn(fluid, x, y, r, flow);
    }

    public void noisySpawn(DwFluid2D fluid){
      for (int i = 0; i<5; i++){
        if(!fluid_reset){
          px = noise(100*i+0.0005*frameCount)*width;
          py = noise(1000*i + 0.001*frameCount)*height;
          radius = noise(500*i + 0.0005*frameCount)*20*(i+1);
          vscale = 15;
          vx = vscale*sin(frameCount/radius);
          vy = vscale*cos(frameCount/radius);
          fluid.addDensity(px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f);
          fluid.addTemperature(px, py, radius, 0.5*(i-2));
          fluid.addVelocity(px,py, 0.8*radius,vx,vy);
          particles.spawn(fluid, px, py, radius, round((i+1)*0.3*noiseFlow));
        }
      }
    }

    // update() is called during the fluid-simulation update step.
    @Override
    public void update(DwFluid2D fluid) { 
      planteSpawn(fluid);
      mouseSpawn(fluid);
      if (medusesTrigged) bigMeduseSpawn(fluid);
      if (rainTrigged) littleMeduseSpawn(fluid);
      noisySpawn(fluid);
      if(touchPressed1) touchSpawn1(fluid);
      if(touchPressed2) touchSpawn2(fluid);
      fluid.addVelocity(0.5*displayWidth,0.5*displayHeight, 0.5*displayWidth,0.1*panAngle*random(-1,1), panAngle);
   }
    
  }
  
  
  int viewport_w = 1280;
  int viewport_h = 720;
  int viewport_x = 0;
  int viewport_y = 0;
  
  int gui_w = 200;
  int gui_x = 20;
  int gui_y = 20;
  
  int fluidgrid_scale = 3;
  boolean newSpawn = true;
  
  DwFluid2D fluid;

  SVGImport plante;
  float x_svg, y_svg,scl_svg;

  // custom particle system
  MyParticleSystem particles;
  
  // some state variables for the GUI/display
  boolean START_FULLSCREEN           = true;
  boolean ROTATING3D                 = false;
  boolean SERIAL                     = false;
  boolean OSC                        = true;
  boolean GUI                        = true;
  boolean AUDIO                      = false;
  int     BACKGROUND_COLOR           = 0;
  boolean UPDATE_FLUID               = true;
  boolean DISPLAY_FLUID_TEXTURES     = false;
  boolean DISPLAY_FLUID_VECTORS      = false;
  int     DISPLAY_fluid_texture_mode = 0;
  boolean DISPLAY_PARTICLES          = false;
  
  float panAngle = 0;  //angle panoramique quand rotating3D est activé

    // render targets
  PGraphics2D pg_fluid;
  PGraphics2D pg_obstacles;
  
  public void settings() {
    if(START_FULLSCREEN){
      viewport_w = displayWidth;
      viewport_h = displayHeight;
      viewport_x = 0;
      viewport_y = 0;
      if (ROTATING3D)  fullScreen(P3D);
      else fullScreen(P2D);
    } 
    else {
      viewport_w = (int) min(viewport_w, displayWidth  * 1.0f);
      viewport_h = (int) min(viewport_h, displayHeight * 1.0f);
      if (ROTATING3D) size(viewport_w, viewport_h, P3D);
      else size(viewport_w, viewport_h, P2D);
    }
    smooth(4);
    PJOGL.profile = 3;
  }
  

  
  public void setup() {
    surface.setLocation(viewport_x, viewport_y);
    
    // main library context
    DwPixelFlow context = new DwPixelFlow(this);
    context.print();
    context.printGL();
    
    // fluid simulation
    fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);
  
    // set some simulation parameters
    fluid.param.dissipation_density     = 0.999f;
    fluid.param.dissipation_velocity    = 0.99f;
    fluid.param.dissipation_temperature = 0.10f;
    fluid.param.vorticity               = 0.001f;
    fluid.param.apply_buoyancy          = true;
    fluid.param.timestep                = 0.05f;
    
    PShape planteShape = loadShape("SVG/fougere_v2.svg").getChild(0);
    //plante = new SVGImport(planteShape, 1.15*viewport_h/1080, 0.05*viewport_w, -0.17*viewport_h); //pour SVG/Contour2.svg
    x_svg = 0.17*displayWidth;
    y_svg = 0.13*displayHeight;
    scl_svg = 0.26*displayHeight/1080;
    plante = new SVGImport(planteShape, scl_svg, x_svg , y_svg);
    println("Nombre de vertices du SVG : " +plante.N);
    println("xLast : " + plante.vertices.get(plante.N-1).x + "   yLast : " + plante.vertices.get(plante.N-1).y);

    if (GUI)    createGUI();    
    if (SERIAL) setupSerial();
    if (OSC) setupOsc();
    if (AUDIO) setupAudio();

    // interface for adding data to the fluid simulation
    MyFluidData cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);
   
    // pgraphics for fluid
    pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_fluid.smooth(4);
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();     

    // pgraphics for obstacles
    pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_obstacles.smooth(4);
    pg_obstacles.beginDraw();
    pg_obstacles.clear();   
    //Plante
    plante.drawShape(pg_obstacles); 
    pg_obstacles.endDraw();
    //Sol
    pg_obstacles.rect(0, 0, 1, pg_obstacles.height);

    fluid.addObstacles(pg_obstacles);
    
    // custom particle object
    particles = new MyParticleSystem(context, 1000 * 1000);

    
    background(0);
    frameRate(60);
  }
  



  public void draw() {    
    
    background(0);
    
    // update simulation
    if(UPDATE_FLUID){
       if(display_shape) {
        pg_obstacles.beginDraw();
        pg_obstacles.clear();
        plante.drawShape(pg_obstacles);
        pg_obstacles.rect(0, 0, 1, pg_obstacles.height);
        pg_obstacles.endDraw();
        //display_shape = 2;
      }
      else{ 
        pg_obstacles.beginDraw();
        pg_obstacles.clear();
        pg_obstacles.endDraw();
        //display_shape = 2;
      }
      fluid.addObstacles(pg_obstacles);
      fluid.update();
      particles.update(fluid);

    }

    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    
    //Herbes dansantes
    if (display_seeds){
      for(int y = 0; y<pg_fluid.height-25; y+=int(0.01*pg_fluid.height)){
        float n = noise(0.1*y);
        float y0 = y + (2*n-1)*0.05*pg_fluid.height;
        pg_fluid.beginShape();
        pg_fluid.noFill();
        pg_fluid.curveVertex(0,y0);
        if (AUDIO){
          for(int i = 0; i < fond.bufferSize() - noise(y)*512; i+=n*256){
            float ii = 1.0-1.0*i/fond.bufferSize();
            pg_fluid.stroke(#74B1FA,70*ii);
            pg_fluid.strokeWeight(3.0*ii);
            pg_fluid.curveVertex(1.0*i*noise(2.0*y), 
              y0                                                        //Position
              + 0.05*pg_fluid.height*(noise(0.001*i))                   //Forme
              + 0.00002*i*pg_fluid.height*sin(ii+y+0.0001*i*frameCount) //Oscillation
              + 0.1*i*fond.left.get(i)                                  //Vibration avec le son
              + 0.3*i*(noise(10*y)-0.5)                                 //Pente
            );
          }
        }
        else{
          float l = 512*2;
          for(int i = 0; i < l - noise(y)*512; i+=n*256){
            float ii = 1.0-1.0*i/l;
            pg_fluid.stroke(#74B1FA,70*ii);
            pg_fluid.strokeWeight(3.0*ii);
            pg_fluid.curveVertex(1.0*i*noise(2.0*y), 
              y0                                                        //Position
              + 0.05*pg_fluid.height*(noise(0.001*i))                   //Forme
              + 0.00002*i*pg_fluid.height*(sin(ii+y+(0.0001*i)*frameCount)+volume*sin(0.0001*(noise(10*y)-0.5)*frameCount)) //Oscillation
              + 0.3*i*(noise(10*y)-0.5)                                 //Pente
            );
          }
        }
      pg_fluid.endShape();
      }
    }
    
    pg_fluid.endDraw();
    
    
    //render fluid stuff
    if(DISPLAY_FLUID_TEXTURES)
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);      // render: density (0), temperature (1), pressure (2), velocity (3)
    if(DISPLAY_FLUID_VECTORS)      
      fluid.renderFluidVectors(pg_fluid, 10);      // render: velocity vector field    
    if(display_particles)
      particles.render(pg_fluid, BACKGROUND_COLOR);      // render: particles; 0 ... points, 1 ...sprite texture, 2 ... dynamic points

    
    // display
    pushMatrix();
    if(ROTATING3D){
      //background(0,10);
      translate(0,0.5*height, 0);
      rotateX(
        (panAngle)*0.5);
      translate(0,-0.5*height, 0);
    }
    image(pg_fluid    , 0, 0);
    //if(display_shape == 1) 
    image(pg_obstacles, 0, 0);
    popMatrix();

    if(AUDIO){
      playAudio();
    }
    
    if(display_gui){
      // display number of particles as text
      String txt_num_particles = String.format("Particles  %,d", particles.ALIVE_PARTICLES);
      fill(0, 0, 0, 220);
      noStroke();
      rect(10, height-10, 160, -30);
      fill(255,128,0);
      text(txt_num_particles, 20, height-20);
    }
    // info
    cp5.setVisible(display_gui);
    String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
    surface.setTitle(txt_fps);
  }
  



  
  public void fluid_resizeUp(){
    fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
  }
  public void fluid_resizeDown(){
    fluid.resize(width, height, ++fluidgrid_scale);
  }
  public void fluid_reset(){
    fluid.reset();
    particles.reset();
   }
  public void fluid_togglePause(){
    UPDATE_FLUID = !UPDATE_FLUID;
  }
  public void fluid_displayMode(int val){
    DISPLAY_fluid_texture_mode = val;
    DISPLAY_FLUID_TEXTURES = DISPLAY_fluid_texture_mode != -1;
  }
  public void fluid_displayVelocityVectors(int val){
    DISPLAY_FLUID_VECTORS = val != -1;
  }

  public void fluid_displayParticles(int val){
    DISPLAY_PARTICLES = val != -1;
  }

  public void keyPressed(){
     if (key == CODED) {
      if (keyCode == LEFT) {
        medusesTrigged = true;
      } else if (keyCode == RIGHT) {
        rainTrigged = true;
      } 
    }
  }

  public void keyReleased(){
    if(key == 'p') fluid_togglePause(); // pause / unpause simulation
    if(key == '+') fluid_resizeUp();    // increase fluid-grid resolution
    if(key == '-') fluid_resizeDown();  // decrease fluid-grid resolution
    if(key == 'r') fluid_reset();       // restart simulation
    
    if(key == '1') DISPLAY_fluid_texture_mode = 0; // density
    if(key == '2') DISPLAY_fluid_texture_mode = 1; // temperature
    if(key == '3') DISPLAY_fluid_texture_mode = 2; // pressure
    if(key == '4') DISPLAY_fluid_texture_mode = 3; // velocity
    
    if(key == 'q') DISPLAY_FLUID_TEXTURES = !DISPLAY_FLUID_TEXTURES;
    if(key == 'w') DISPLAY_FLUID_VECTORS  = !DISPLAY_FLUID_VECTORS;
    
    if(key == '*') {
      GUI = !GUI;
      display_gui = !display_gui;
    }
    
    if(key == 'a') panAngle += 10;
    if(key == 'z') panAngle -= 10;
    if(key == ' ') display_particles = !display_particles;
    if(key == 'x') display_seeds = !display_seeds;
    if(key == 'c') display_shape = !display_shape;
    if(key == '0') plante.visible = !plante.visible;
    if(AUDIO) keyReleasedAudio();

    if (key == CODED) {
      if (keyCode == LEFT) {
        medusesTrigged = false;
      } else if (keyCode == RIGHT) {
        rainTrigged = false;
      } 
    }
  }
 
  
  
  ControlP5 cp5;
  
  public void createGUI(){
    cp5 = new ControlP5(this);
    
    int sx, sy, px, py, oy;
    
    sx = 100; sy = 14; oy = (int)(sy*1.5f);
    

    ////////////////////////////////////////////////////////////////////////////
    // GUI - FLUID
    ////////////////////////////////////////////////////////////////////////////
    Group group_fluid = cp5.addGroup("fluid");
    {
      group_fluid.setHeight(20).setSize(gui_w, 300)
      .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
      group_fluid.getCaptionLabel().align(CENTER, CENTER);
      
      px = 10; py = 15;
      
      cp5.addButton("reset").setGroup(group_fluid).plugTo(this, "fluid_reset"     ).setSize(80, 18).setPosition(px    , py);
      cp5.addButton("+"    ).setGroup(group_fluid).plugTo(this, "fluid_resizeUp"  ).setSize(39, 18).setPosition(px+=82, py);
      cp5.addButton("-"    ).setGroup(group_fluid).plugTo(this, "fluid_resizeDown").setSize(39, 18).setPosition(px+=41, py);
      
      px = 10;
     
      cp5.addSlider("velocity").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=(int)(oy*1.5f))
          .setRange(0, 1).setValue(fluid.param.dissipation_velocity).plugTo(fluid.param, "dissipation_velocity");
      
      cp5.addSlider("density").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
          .setRange(0, 1).setValue(fluid.param.dissipation_density).plugTo(fluid.param, "dissipation_density");
      
      cp5.addSlider("temperature").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
          .setRange(0, 1).setValue(fluid.param.dissipation_temperature).plugTo(fluid.param, "dissipation_temperature");
      
      cp5.addSlider("vorticity").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
          .setRange(0, 1).setValue(fluid.param.vorticity).plugTo(fluid.param, "vorticity");
          
      cp5.addSlider("iterations").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
          .setRange(0, 80).setValue(fluid.param.num_jacobi_projection).plugTo(fluid.param, "num_jacobi_projection");
            
      cp5.addSlider("timestep").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
          .setRange(0, 1).setValue(fluid.param.timestep).plugTo(fluid.param, "timestep");
          
      cp5.addSlider("gridscale").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py+=oy)
          .setRange(0, 50).setValue(fluid.param.gridscale).plugTo(fluid.param, "gridscale");
      
      RadioButton rb_setFluid_DisplayMode = cp5.addRadio("fluid_displayMode").setGroup(group_fluid).setSize(80,18).setPosition(px, py+=(int)(oy*1.5f))
          .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(2)
          .addItem("Density"    ,0)
          .addItem("Temperature",1)
          .addItem("Pressure"   ,2)
          .addItem("Velocity"   ,3)
          .activate(DISPLAY_fluid_texture_mode);
      for(Toggle toggle : rb_setFluid_DisplayMode.getItems()) toggle.getCaptionLabel().alignX(CENTER);
      
      cp5.addRadio("fluid_displayVelocityVectors").setGroup(group_fluid).setSize(18,18).setPosition(px, py+=(int)(oy*2.5f))
          .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(1)
          .addItem("Velocity Vectors", 0)
          .activate(DISPLAY_FLUID_VECTORS ? 0 : 2);
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // GUI - DISPLAY
    ////////////////////////////////////////////////////////////////////////////
    Group group_display = cp5.addGroup("display");
    {
      group_display.setHeight(20).setSize(gui_w, 50)
      .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
      group_display.getCaptionLabel().align(CENTER, CENTER);
      
      px = 10; py = 15;
      
      cp5.addSlider("BACKGROUND").setGroup(group_display).setSize(sx,sy).setPosition(px, py)
          .setRange(0, 255).setValue(BACKGROUND_COLOR).plugTo(this, "BACKGROUND_COLOR");
      
      cp5.addRadio("fluid_displayParticles").setGroup(group_display).setSize(18,18).setPosition(px, py+=(int)(oy*1.5f))
          .setSpacingColumn(2).setSpacingRow(2).setItemsPerRow(1)
          .addItem("display particles", 0)
          .activate(DISPLAY_PARTICLES ? 0 : 2);
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // GUI - ACCORDION
    ////////////////////////////////////////////////////////////////////////////
    cp5.addAccordion("acc").setPosition(gui_x, gui_y).setWidth(gui_w).setSize(gui_w, height)
      .setCollapseMode(Accordion.MULTI)
      .addItem(group_fluid)
      .addItem(group_display)
      .open(4);
  }
