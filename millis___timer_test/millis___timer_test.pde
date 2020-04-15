int time = millis();
void setup(){
  background(0);
  size(800, 600);
}

void draw(){
  if(millis()-time>2000){
  time=millis();
  ellipse(mouseX,mouseY,10,10);
  }
}
