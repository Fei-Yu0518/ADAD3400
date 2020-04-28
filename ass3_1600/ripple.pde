class ripple{
float x ;
float y ;
float tint;
float tintsetp=10;
int size=0;
  ripple(float x,float y){
      this.x = x;
      this.y = y;
    }

 void show(){
      pushMatrix();
      translate(x, y);
      tint(255, tint);
      size+=5;
      size =constrain(size ,0,200);  
      ellipse(0, 0, size, size);
      stroke(220,50);
      noFill();
      popMatrix();
    }
    
  void update(){
      tint+=tintsetp;
      if(tint>255){
      tintsetp = -20;
      }
    }
}
