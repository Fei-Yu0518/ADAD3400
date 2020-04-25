import processing.sound.*;
import KinectPV2.*;

KinectPV2 kinect;
SoundFile soundfile;
int cols;
int rows;
float[][] current;
float[][] previous;

float dampening = 0.99;

ArrayList<flower> list =new ArrayList<flower>();
PImage imgs[] = new PImage[5];
int time=millis();
int _max = 600; // max depth
int _min = 300; // min depth
int _x = 0;
int _y = 0;
int flag = 0;
int now_max = _min;


void setup() {
  size(800, 600, P3D);
  cols = width;
  rows = height;
  current = new float[cols][rows];
  previous = new float[cols][rows];
  for (int i=0; i<5; i++) {
    imgs[i] = loadImage(i+".png");
  }
  soundfile = new SoundFile(this, "ripple_sound.aiff");
  frameRate(60);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableSkeletonDepthMap(true); //added
  //kinect.enableInfraredImg(true);
  //kinect.enableInfraredLongExposureImg(true);
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

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      drawBody(joints);
    }
  }
  
  loadPixels();
  for (int i = 1; i < cols-1; i++) {
    for (int j = 1; j < rows-1; j++) {
      current[i][j] = (
        previous[i-1][j] + 
        previous[i+1][j] +
        previous[i][j-1] + 
        previous[i][j+1]) / 2 -
        current[i][j];
      current[i][j] = current[i][j] * dampening;
      int index = i + j * cols;
     pixels[index] = color(current[i][j]);
    }
  }
  updatePixels();

  float[][] temp = previous;
  previous = current;
  current = temp;

  for (int i=list.size()-1; i>=0; i--) {
    flower p =  list.get(i);
    p.update();
    p.show();
    if (p.tint<0) {
      list.remove(p);
    }
  }


//  if (millis()-time>2000 && now_max != _max && flag == 1) {
//    time=millis();
//    //previous[_x][_y] = 1000;
//    soundfile.play();
//    list.add(new flower(imgs[int(random(5))], _x, _y));
//    flag = 0;
//  }

//  int [] rawData = kinect.getRawDepthData();
//  //println(rawData.length);
//  now_max = _max;

//  for (int x = 0; x < 512; x++) {
//    for (int y = 0; y < 424; y ++) {
//      int offset = x + y * 512;
//      if (now_max >= rawData[offset] && rawData[offset] <= _max && rawData[offset] >= _min) {
//        _x = (int)map(x,0, 512, 0, width);
//        _y = (int)map(y,0, 424, 0, height);
//        now_max = rawData[offset];
//        flag = 1;
//      }
//    }
//  }
//  println(_x, _y, now_max);
}

//draw the body
void drawBody(KJoint[] joints) {
  //drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  //drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  //drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  //drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  //drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  //// Right Arm
  //drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  //drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  //drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  //drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  //drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  //drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  //drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  //drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  //drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  //drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  //drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  //// Left Leg
  //drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  //drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  //drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  ////Single joints
  //drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  //drawJoint(joints, KinectPV2.JointType_HandTipRight);
  //drawJoint(joints, KinectPV2.JointType_FootLeft);
  //drawJoint(joints, KinectPV2.JointType_FootRight);

  //drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  //drawJoint(joints, KinectPV2.JointType_ThumbRight);

  //drawJoint(joints, KinectPV2.JointType_Head);
}

//draw a bone from two joints
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width), map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height), joints[jointType1].getZ());
  _x = (int)map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width);
  _y = (int)map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height);//translate(map(joints[jointType1].getX(), 0, 320, 0, width), map(joints[jointType1].getY(), 0, 240, 0, height), joints[jointType1].getZ());
  //println(map(joints[jointType1].getX(), 0, kinect.getDepthImage().width, 0, width));
    
  previous[_x][_y] = 1000;
  list.add(new flower(imgs[int(random(5))], _x, _y));


  //fill(0, 255, 0);
  //ellipseMode(CENTER);
  //ellipse(0, 0, 100, 100);
  
  popMatrix();
  //line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}
