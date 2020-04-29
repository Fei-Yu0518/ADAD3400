class flower{

float x ;
float y ;
float rot = 0;
PImage flower;
float tint;
float tintsetp=10;
int size=0;
    flower(PImage flower,float x,float y){
      this.x = x;
      this.y = y;
      this.flower = flower;
      this.flower.resize(160,90);
    }
    
    void show(){
      pushMatrix();
      translate(x, y);
      rotate(rot);
      tint(255, tint);
      size+=4;
      size =constrain(size ,0,600);  
      image(flower, -size/2, -size/2, size, size); 
      popMatrix();

    }
    
    void update(){
      rot = rot + 1.0;
      tint+=tintsetp;
      if(tint>255){
      tintsetp = -20;
      }
    }


}
