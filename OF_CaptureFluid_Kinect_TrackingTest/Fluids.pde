  
  private class MyFluidData implements DwFluid2D.FluidData{
   
    @Override
    // this is called during the fluid-simulation update step.
    public void update(DwFluid2D fluid) {
      
    /* float px, py, vx, vy, radius, vscale;
      boolean mouse_input = !cp5.isMouseOver() && mousePressed;
      if(mouse_input ){
        
        vscale = 15;
        px     = mouseX;
        py     = height-mouseY;
        vx     = 0//(mouseX - pmouseX) * +vscale;
        vy     = 0//(mouseY - pmouseY) * -vscale;
        
        if(mouseButton == LEFT){
          radius = 20;
          fluid.addVelocity(px, py, radius, vx, vy);
        }
        if(mouseButton == CENTER){
          radius = 50;
          fluid.addDensity (px, py, radius, 1.0f, 0.0f, 0.40f, 1f, 1);
        }
        if(mouseButton == RIGHT){
          radius = 15;
          fluid.addTemperature(px, py, radius, 15f);
        }
        
      }*/
      ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();
      float plx, ply, prx, pry, vx, vy, radius, vscale, temperature;
        for (int i = 0; i < skeletonArray.size(); i++) {
          KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
        //if the skeleton is being tracked compute the skleton joints
        if (skeleton.isTracked()) {
          KJoint[] joints = skeleton.getJoints();
          vscale = 15;
          plx = map(joints[KinectPV2.JointType_HandTipLeft].getX(), 0, kinect.getDepthImage().width, 0, width);
          ply = height - map(joints[KinectPV2.JointType_HandTipLeft].getY(), 0, kinect.getDepthImage().height, 0, height);
          prx = map(joints[KinectPV2.JointType_HandTipRight].getX(), 0, kinect.getDepthImage().width, 0, width);
          pry = height - map(joints[KinectPV2.JointType_HandTipRight].getY(), 0, kinect.getDepthImage().height, 0, height);
          //println(px);
          vx = random(-3.5, 3.5) * +vscale; // note the random(-5, 5) produces a number 
          vy = random(-3.5, 3.5) * -vscale;
          int right_handstate = joints[KinectPV2.JointType_HandRight].getState();
          int left_handstate = joints[KinectPV2.JointType_HandLeft].getState();
          if(left_handstate == KinectPV2.HandState_Open && right_handstate == KinectPV2.HandState_Open){
              //radius = 15;
              fluid.addDensity(plx, ply, 50, 1, 1, 1f, 1.0f);
              fluid.addDensity(prx, pry, 50, 1, 1, 1f, 1.0f);
          }else if(left_handstate == KinectPV2.HandState_Open && right_handstate == KinectPV2.HandState_Closed){
              fluid.addDensity (plx, ply, 50, 1, 1, 1f, 1.0f);
              fluid.addDensity (prx, pry, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
          }else if(left_handstate == KinectPV2.HandState_Open && right_handstate == KinectPV2.HandState_NotTracked){
              fluid.addDensity(plx, ply, 50, 1, 1, 1f, 1.0f);
          }else if(left_handstate == KinectPV2.HandState_Closed && right_handstate == KinectPV2.HandState_Open){
              fluid.addDensity (plx, ply, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
              fluid.addDensity(prx, pry, 50, 1, 1, 1f, 1.0f);
          }else if(left_handstate == KinectPV2.HandState_Closed && right_handstate == KinectPV2.HandState_Closed){
              fluid.addDensity (plx, ply, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
              fluid.addDensity (prx, pry, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
          }else if(left_handstate == KinectPV2.HandState_Closed && right_handstate == KinectPV2.HandState_NotTracked){
              fluid.addDensity (plx, ply, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
          }else if(left_handstate == KinectPV2.HandState_NotTracked && right_handstate == KinectPV2.HandState_Open){
              fluid.addDensity (plx, ply, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
          }else if(left_handstate == KinectPV2.HandState_NotTracked && right_handstate == KinectPV2.HandState_Closed){
              fluid.addDensity (prx, pry, 50, 1.0f, 0.0f, 0.40f, 1f, 1);
          }
          /*radius = 15;
          fluid.addDensity(plx, ply, radius, 1, 1, 1f, 1.0f);
          fluid.addDensity(prx, pry, radius, 1, 1, 1f, 1.0f);
          radius = 15;
          fluid.addVelocity(plx, ply, radius, vx, vy);
          fluid.addVelocity(prx, pry, radius, vx, vy);*/
       }
     }
//      px = view_w/2;
//      py = 50;
//      radius = 50;
//      fluid.addDensity (px, py, radius, 1.0f, 0.0f, 0.40f, 1f, 1);
//      fluid.addTemperature(px, py, radius, 5f);
  
      // use the text as input for density
      if(ADD_DENSITY_MODE == 0) addDensityTexture (fluid, opticalflow);
      if(ADD_DENSITY_MODE == 1) addDensityTexture_cam(fluid, opticalflow);
      
      addTemperatureTexture(fluid, opticalflow);
      addVelocityTexture(fluid, opticalflow);
      
    }
    
    // custom shader, to add density from a texture (PGraphics2D) to the fluid.
    public void addDensityTexture(DwFluid2D fluid, DwOpticalFlow opticalflow){
      context.begin();
      context.beginDraw(fluid.tex_density.dst);
      DwGLSLProgram shader = context.createShader("data/addDensity.frag");
      shader.begin();
      shader.uniform2f     ("wh"             , fluid.fluid_w, fluid.fluid_h);                                                                   
      shader.uniform1i     ("blend_mode"     , 6);    
      shader.uniform1f     ("multiplier"     , 3);    
      shader.uniform1f     ("mix_value"      , 0.1f);
      shader.uniformTexture("tex_opticalflow", opticalflow.frameCurr.velocity);
      shader.uniformTexture("tex_density_old", fluid.tex_density.src);
      shader.drawFullScreenQuad();
      shader.end();
      context.endDraw();
      context.end("app.addDensityTexture");
      fluid.tex_density.swap();
    }
    
 
    public void addDensityTexture_cam(DwFluid2D fluid, DwOpticalFlow opticalflow){
      int[] pg_tex_handle = new int[1];
      
      if( !pg_cam_a.getTexture().available() ) return;
      
      float mix = opticalflow.UPDATE_STEP > 1 ? 0.01f : 1.0f;
      
      context.begin();
      context.getGLTextureHandle(pg_cam_a, pg_tex_handle);
      context.beginDraw(fluid.tex_density.dst);
      DwGLSLProgram shader = context.createShader("data/addDensityCam.frag");
      shader.begin();
      shader.uniform2f     ("wh"        , fluid.fluid_w, fluid.fluid_h);                                                                   
      shader.uniform1i     ("blend_mode", 6);   
      shader.uniform1f     ("mix_value" , mix);     
      shader.uniform1f     ("multiplier", 1f);     
//      shader.uniformTexture("tex_ext"   , opticalflow.tex_frames.src);
      shader.uniformTexture("tex_ext"   , pg_tex_handle[0]);
      shader.uniformTexture("tex_src"   , fluid.tex_density.src);
      shader.drawFullScreenQuad();
      shader.end();
      context.endDraw();
      context.end("app.addDensityTexture");
      fluid.tex_density.swap();
    }
    
    
    
    // custom shader, to add temperature from a texture (PGraphics2D) to the fluid.
    public void addTemperatureTexture(DwFluid2D fluid, DwOpticalFlow opticalflow){
      context.begin();
      context.beginDraw(fluid.tex_temperature.dst);
      DwGLSLProgram shader = context.createShader("data/addTemperature.frag");
      shader.begin();
      shader.uniform2f     ("wh"        , fluid.fluid_w, fluid.fluid_h);                                                                   
      shader.uniform1i     ("blend_mode", 1);   
      shader.uniform1f     ("mix_value" , 0.1f);     
      shader.uniform1f     ("multiplier", 0.05f);     
      shader.uniformTexture("tex_ext"   , opticalflow.frameCurr.velocity);
      shader.uniformTexture("tex_src"   , fluid.tex_temperature.src);
      shader.drawFullScreenQuad();
      shader.end();
      context.endDraw();
      context.end("app.addTemperatureTexture");
      fluid.tex_temperature.swap();
    }
    
    // custom shader, to add density from a texture (PGraphics2D) to the fluid.
    public void addVelocityTexture(DwFluid2D fluid, DwOpticalFlow opticalflow){
      context.begin();
      context.beginDraw(fluid.tex_velocity.dst);
      DwGLSLProgram shader = context.createShader("data/addVelocity.frag");
      shader.begin();
      shader.uniform2f     ("wh"             , fluid.fluid_w, fluid.fluid_h);                                                                   
      shader.uniform1i     ("blend_mode"     , 2);    
      shader.uniform1f     ("multiplier"     , 1.0f);   
      shader.uniform1f     ("mix_value"      , 0.1f);
      shader.uniformTexture("tex_opticalflow", opticalflow.frameCurr.velocity);
      shader.uniformTexture("tex_velocity_old", fluid.tex_velocity.src);
      shader.drawFullScreenQuad();
      shader.end();
      context.endDraw();
      context.end("app.addDensityTexture");
      fluid.tex_velocity.swap();
    }
 
  }
  
