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
  kinect.enableInfraredImg(true);
  kinect.enableInfraredLongExposureImg(true);
  kinect.init();
}


void draw() {
  background(0);

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


  if (millis()-time>2000 && now_max != _max && flag == 1) {
    time=millis();
    previous[_x][_y] = 1000;
    soundfile.play();
    list.add(new flower(imgs[int(random(5))], _x, _y));
    flag = 0;
  }

  int [] rawData = kinect.getRawDepthData();
  //println(rawData.length);
  now_max = _max;

  for (int x = 0; x < 512; x++) {
    for (int y = 0; y < 424; y ++) {
      int offset = x + y * 512;
      if (now_max >= rawData[offset] && rawData[offset] <= _max && rawData[offset] >= _min) {
        _x = (int)map(x,0, 512, 0, width);
        _y = (int)map(y,0, 424, 0, height);
        now_max = rawData[offset];
        flag = 1;
      }
    }
  }
  println(_x, _y, now_max);
}
