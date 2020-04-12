int time = 0;
void setup(){
  background(0);
  size(800,600);
  frameRate(60);
}

void draw(){
  time++;
  if(time > 120){
    time = 0;
    ellipse(mouseX,mouseY,10,10);
  }
  
}
