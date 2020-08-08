/**
 * 
 * PixelFlow | Copyright (C) 2016 Thomas Diewald - http://thomasdiewald.com
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */

import KinectPV2.KJoint;
import KinectPV2.*;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.imageprocessing.DwOpticalFlow;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;
//import processing.video.Capture;

  int cam_w = 1920;
  int cam_h = 1080;
  
  int view_w = 1920;
  int view_h = (int)(view_w * cam_h/(float)cam_w);
  
  int gui_w = 200;
  int gui_x = 1720;
  int gui_y = 0;
  
  int jointType1;
  int jointType2;
  
  int fluidgrid_scale = 1;
  
  
  // main library context
  DwPixelFlow context;
  
  // collection of imageprocessing filters
  DwFilter filter;
  
  // fluid solver
  DwFluid2D fluid;
  
  MyFluidData cb_fluid_data;
  
  // optical flow
  DwOpticalFlow opticalflow;
  
  // buffer for the capture-image
  PGraphics2D pg_cam_a, pg_cam_b; 

  // offscreen render-target for fluid
  PGraphics2D pg_fluid;
  
  // camera capture (video library)
  KinectPV2 kinect;
  
  
  // some state variables for the GUI/display
  int     BACKGROUND_COLOR = 0;
  boolean DISPLAY_SOURCE   = true;
  boolean APPLY_GRAYSCALE  = true;
  boolean APPLY_BILATERAL  = true;
  int     VELOCITY_LINES   = 6;
  
  boolean UPDATE_FLUID            = true;
  boolean DISPLAY_FLUID_TEXTURES  = true;
  boolean DISPLAY_FLUID_VECTORS   = !true;
  boolean DISPLAY_PARTICLES       = !true;
  
  int     DISPLAY_fluid_texture_mode = 0;
  
  int     ADD_DENSITY_MODE = 1;
  
  
  public void settings() {
    size(view_w + gui_w, view_h, P2D);
    smooth(4);
  }

  public void setup() {
    
    // main library context
    context = new DwPixelFlow(this);
    context.print();
    context.printGL();
    
    filter = new DwFilter(context);
    
    // fluid object
    fluid = new DwFluid2D(context, view_w, view_h, fluidgrid_scale);
    
    // some fluid parameters
    fluid.param.dissipation_density     = 0.90f;
    fluid.param.dissipation_velocity    = 0.80f;
    fluid.param.dissipation_temperature = 0.70f;
    fluid.param.vorticity               = 0.30f;

    // calback for adding fluid data
    cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);
    
    // optical flow object
    opticalflow = new DwOpticalFlow(context, cam_w, cam_h);
    
    // optical flow parameters    
    opticalflow.param.display_mode = 1;

    // webcam capture
    kinect = new KinectPV2(this);

    kinect.enableDepthImg(true);
    kinect.enableSkeletonDepthMap(true);

    kinect.enableSkeletonColorMap(true);
    kinect.enableColorImg(true);

    kinect.init();
    // render buffers
    pg_cam_a = (PGraphics2D) createGraphics(cam_w, cam_h, P2D);
    pg_cam_a.noSmooth();
    pg_cam_a.beginDraw();
    pg_cam_a.background(0);
    pg_cam_a.endDraw();
    
    pg_cam_b = (PGraphics2D) createGraphics(cam_w, cam_h, P2D);
    pg_cam_b.noSmooth();
    
    pg_fluid = (PGraphics2D) createGraphics(view_w, view_h, P2D);
    pg_fluid.smooth(4);

  
    createGUI();
    
    background(0);
    frameRate(60);
  }
  

  

  public void draw() {
    
    //if( cam.available() ){
      //cam.read();
      
      // render to offscreenbuffer
      
     
      pg_cam_b.beginDraw();
      pg_cam_b.background(0);
      pg_cam_b.image(kinect.getColorImage(), 0, 0);
      pg_cam_b.endDraw();
      swapCamBuffer(); // "pg_cam_a" has the image now
      
      if(APPLY_BILATERAL){
        filter.bilateral.apply(pg_cam_a, pg_cam_b, 5, 0.10f, 4);
        swapCamBuffer();
      }
      
      // update Optical Flow
      opticalflow.update(pg_cam_a);
      
      if(APPLY_GRAYSCALE){
        // make the capture image grayscale (for better contrast)
        filter.luminance.apply(pg_cam_a, pg_cam_b); swapCamBuffer(); 
      }
    //}
    
     ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual joints
     for (int i = 0; i < skeletonArray.size(); i++) {
        KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
        //if the skeleton is being tracked compute the skleton joints
        if (skeleton.isTracked()) {
          KJoint[] joints = skeleton.getJoints();

          color col  = skeleton.getIndexColor();
          fill(col);
          stroke(col);
          println("IT IS TRACKED");
          drawBody(joints);
          //drawHandState(joints[KinectPV2.JointType_HandRight]);
          //drawHandState(joints[KinectPV2.JointType_HandLeft]);
        }
      }
      
    if(UPDATE_FLUID){
      fluid.update();
    }
    

    // render everything
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    if(DISPLAY_SOURCE && ADD_DENSITY_MODE == 0){
      pg_fluid.image(pg_cam_a, 0, 0, view_w, view_h);
    }
    pg_fluid.endDraw();
    
    // add fluid stuff to rendering
    if(DISPLAY_FLUID_TEXTURES){
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    if(DISPLAY_FLUID_VECTORS){
      fluid.renderFluidVectors(pg_fluid, 10);
    }
    
    // add optical flow stuff to rendering
    if(opticalflow.param.display_mode == 2){
      opticalflow.renderVelocityShading(pg_fluid);
    }
    opticalflow.renderVelocityStreams(pg_fluid, VELOCITY_LINES);


    // display result
    background(0);
    image(pg_fluid, 0, 0);
    
    // info
    String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", cam_w, cam_h, opticalflow.UPDATE_STEP, frameRate);
    surface.setTitle(txt_fps);
  }
  
  
  void swapCamBuffer(){
    PGraphics2D tmp = pg_cam_a;
    pg_cam_a = pg_cam_b;
    pg_cam_b = tmp;
  }
  
  
  
  void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
}
   public int rightHandState(KJoint[] joints){
    int right_handstate = joints[KinectPV2.JointType_HandRight].getState();
    return right_handstate;
   }
   
   public int leftHandState(KJoint[] joints){
    int left_handstate = joints[KinectPV2.JointType_HandLeft].getState();
    return left_handstate;
   }

  //draw a bone from two joints
  void drawBone(KJoint[] joints, int jointType1, int jointType2) {
    pushMatrix();
    translate(map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width), map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height), joints[jointType2].getZ());
    //translate(map(joints[jointType1].getX(), 0, 320, 0, width), map(joints[jointType1].getY(), 0, 240, 0, height), joints[jointType1].getZ());
    //println(map(joints[jointType1].getX(), 0, kinect.getDepthImage().width, 0, width));
    fill(0);
    ellipse(0, 0, 100, 100);
    println("ELIPSE ELIPSE ELIPSE");
    
    popMatrix();
    //line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
  }

  //draw a ellipse depending on the hand state
  void drawHandState(KJoint joint) {
    noStroke();
    handState(joint.getState());
    pushMatrix();
    translate(joint.getX(), joint.getY(), joint.getZ());
    //ellipse(0, 0, 70, 70);
    popMatrix();
  }

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */

//Depending on the hand state change the color
  void handState(int handState) {
    switch(handState) {
    case KinectPV2.HandState_Open:
      fill(0, 255, 0);
      break;
    case KinectPV2.HandState_Closed:
      fill(255, 0, 0);
      break;
    case KinectPV2.HandState_Lasso:
      fill(0, 0, 255);
      break;
    case KinectPV2.HandState_NotTracked:
      fill(100, 100, 100);
      break;
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  public void fluid_resizeUp(){
    fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
  }
  public void fluid_resizeDown(){
    fluid.resize(width, height, ++fluidgrid_scale);
  }
  public void fluid_reset(){
    fluid.reset();
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
  public void opticalFlow_setDisplayMode(int val){
    opticalflow.param.display_mode = val;
  }
  public void activeFilters(float[] val){
    APPLY_GRAYSCALE = (val[0] > 0);
    APPLY_BILATERAL = (val[1] > 0);
  }
  public void setOptionsGeneral(float[] val){
    DISPLAY_SOURCE = (val[0] > 0);
  }
  
  public void setAddDensityMode(int val){
    ADD_DENSITY_MODE = val;
  }
 
  
  public void mouseReleased(){
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
    if(key == 'e') DISPLAY_PARTICLES      = !DISPLAY_PARTICLES;
  }
  


  

  

  //
  // This Demo-App combines Optical Flow (based on Webcam capture frames)
  // and Fluid simulation.
  // The resulting velocity vectors of the Optical Flow are used to change the
  // velocity of the fluid. The Capture Frames are the source for the Fluid_density.
  // 

  
  
  
  
  


  
