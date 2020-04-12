import processing.sound.*;
SoundFile soundfile;
int cols;
int rows;
float[][] current;
float[][] previous;

float dampening = 0.99;

ArrayList<flower> list =new ArrayList<flower>();
PImage imgs[] = new PImage[5];
int time=0;
void setup() {
  size(800, 600);
  cols = width;
  rows = height;
  current = new float[cols][rows];
  previous = new float[cols][rows];
  for(int i=0;i<5;i++){
    imgs[i] = loadImage(i+".png");
  }
 soundfile = new SoundFile(this, "ripple_sound.aiff");
 frameRate(60);
}

//void mousePressed() {

//}

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
  
  for(int i=list.size()-1;i>=0;i--){
   flower p =  list.get(i);
   p.update();
   p.show();
   if(p.tint<0){
    list.remove(p);
   }
  }
  time++;
  if(time>120){
  time=0;
    previous[mouseX][mouseY] = 1000;
  soundfile.play();
  list.add(new flower(imgs[int(random(5))],mouseX,mouseY));
  }
  
}
