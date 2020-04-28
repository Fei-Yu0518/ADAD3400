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
int _x = 0;
int _y = 0;




void setup() {
  fullScreen(P2D);
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

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      drawBody(joints);
    }else{
      background(0);
    }
  }
  
  loadPixels();
  for (int i = 1; i < cols-10; i++) {
    for (int j = 1; j < rows-10; j++) {
      current[i][j] = ( previous[i-1][j] + previous[i+1][j] + previous[i][j-1] + previous[i][j+1] ) / 2 - current[i][j];
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
}


//draw the body
void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
}

//draw a bone from two joints
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  //translate(map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width), map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height));
  _x = (int)map(joints[jointType2].getX(), 0, kinect.getDepthImage().width, 0, width);
  _y = (int)map(joints[jointType2].getY(), 0, kinect.getDepthImage().height, 0, height);//translate(map(joints[jointType1].getX(), 0, 320, 0, width), map(joints[jointType1].getY(), 0, 240, 0, height), joints[jointType1].getZ());
  //println(map(joints[jointType1].getX(), 0, kinect.getDepthImage().width, 0, width));
    
  previous[_x][_y] = 1;
  list.add(new flower(imgs[int(random(5))], _x, _y));

  popMatrix();
}
