import KinectPV2.*;

KinectPV2 kinect;

float dampening = 0.99;
int _max = 1000; // max depth
int _min = 500; // min depth
int _x = 0;
int _y = 0;
int now_max = _min;
void setup() {
  size(800, 600, P3D);
  frameRate(60);
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableInfraredImg(true);
  kinect.enableInfraredLongExposureImg(true);
  kinect.init();
}


void draw() {
  background(0);

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
      }
    }
  }
  
  ellipse(_x, _y, 10, 10);
}
