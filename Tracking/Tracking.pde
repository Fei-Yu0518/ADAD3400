import org.openkinect.processing.*;
KinectTracker tracker;
void setup() {
  size(640, 520);

  tracker = new KinectTracker(this);
}

void draw() {
  background(255);

  tracker.track();
  // Show the image
  tracker.display();

  PVector v1 = tracker.getPos();
  fill(50, 100, 250, 200);
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);

  PVector v2 = tracker.getLerpedPos();
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " , 10, 500);
}
