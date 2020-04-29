import processing.sound.*;
import KinectPV2.*;

KinectPV2 kinect;

float dampening = 0.99;

ArrayList<flower> flower_list =new ArrayList<flower>();
ArrayList<ripple> ripple_list = new ArrayList<ripple>();
PImage imgs[] = new PImage[5];
int _x = 0;
int _y = 0;


void setup() {
  fullScreen(P2D);
  for (int i=0; i<5; i++) {
    imgs[i] = loadImage(i+".png");
  }
  frameRate(20);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableSkeletonDepthMap(true); 

  kinect.init();
}


void draw() {
  background(0);
   ////get the skeletons as an Arraylist of KSkeletons
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonDepthMap();

  //individual joints
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    //if the skeleton is being tracked compute the skleton joints
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      drawBody(joints);
    }else{
      background(0);
    }
  }
  

  for (int i=flower_list.size()-1; i>=0; i--) {
    flower p =  flower_list.get(i);
    p.update();
    p.show();
    if (p.tint<0) {
      flower_list.remove(p);
    }
  }
  for (int j=ripple_list.size()-1; j>=0; j--) {
    ripple r =  ripple_list.get(j);
    r.update();
    r.show();
    if (r.tint<0) {
      ripple_list.remove(r);
    }
  }
}


//draw the body
void drawBody(KJoint[] joints) {
  int right_handstate = joints[KinectPV2.JointType_HandRight].getState();
  int left_handstate = joints[KinectPV2.JointType_HandLeft].getState();
  if(right_handstate == KinectPV2.HandState_NotTracked && left_handstate == KinectPV2.HandState_NotTracked){
    background(0);
  }else if(right_handstate == KinectPV2.HandState_NotTracked && left_handstate != KinectPV2.HandState_NotTracked){
    drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  }else if(left_handstate == KinectPV2.HandState_NotTracked && right_handstate != KinectPV2.HandState_NotTracked){
    drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  }else{
    drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
    drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  }
  
}

//draw a bone from two joints
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  //translate(map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width), map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height));
  _x = (int)map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width);
  _y = (int)map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height);//translate(map(joints[jointType1].getX(), 0, 320, 0, width), map(joints[jointType1].getY(), 0, 240, 0, height), joints[jointType1].getZ());
  //println(map(joints[jointType1].getX(), 0, kinect.getDepthImage().width, 0, width));
    
  flower_list.add(new flower(imgs[int(random(5))], _x, _y));
  ripple_list.add(new ripple( _x, _y));

  popMatrix();
}
