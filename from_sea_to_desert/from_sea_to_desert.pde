import processing.video.*;
import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

Kinect kinect;
import java.awt.*;

Movie ocean;
PImage sea;
Movie desert;

float D = 0.1;
float GAUSS_0;
float RECOVER_SPEED = 255 / 20;

int scl = 1;
float MAX_RADIUS = 100;
float GROW_SPEED = 2;
float INIT_RADIUS = 5;

ArrayList<Person> personList;
float [][] alpha;

void setup() {
  size(1280, 720);
  ocean = new Movie(this, "ocean.mp4");
  ocean.loop();
  desert = new Movie(this, "desert.mp4");
  desert.loop();
  GAUSS_0 = gauss(0);
  alpha = new float[width][height];
  for (int x = 0; x < width; x++)
    for (int y = 0; y < height; y++)
      alpha[x][y] = 255;
  kinect = new Kinect(this);
  personList = new ArrayList<Person>();
}

float gauss(float x) {
  return exp(-x*x/(2*D*D)) / (D*sqrt(2*PI));
}

void adjustImageTransparent(PImage img) {
  img.loadPixels();
  synchronized(personList) {
    for (int x = 0; x < img.width; x++ ) {
      for (int y = 0; y < img.height; y++ ) {
        int loc = x + y*img.width;
        
        float r = red  (img.pixels[loc]);
        float g = green(img.pixels[loc]);
        float b = blue (img.pixels[loc]);
        float oldAlpha = alpha[x][y];
        float finalAlpha = constrain(oldAlpha + RECOVER_SPEED, 0, 255);
        
        for (Person person : personList) {
          float distance = dist(person.px, person.py, x, y);
          float alpha;
          
          if (distance < person.inner_radius) {
            alpha = 0;
          } else if (distance > person.out_radius) {
            alpha = 255;
          } else {
            distance = map(distance, person.inner_radius, person.out_radius, 0, 3*D);
            alpha = map(gauss(distance), GAUSS_0, 0, 0, 255);
          }
          finalAlpha = min(alpha, finalAlpha);
        }
        
        alpha[x][y] = finalAlpha;
        color c = color(r, g, b, finalAlpha);
        img.pixels[loc] = c;
      }
    }
  }
  img.updatePixels();
}

void draw() {
  scale(scl);
  image(desert, 0, 0);
  sea = ocean.get();
  adjustImageTransparent(sea);
  image(sea, 0, 0);
  synchronized(personList) {
    for (int i=personList.size()-1; i>=0; i--) {
      personList.get(i).grow();
    }
  }
}

void movieEvent(Movie m) {
  m.read();
}

void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(personList) {
    personList.add(new Person(_s));
  }
}

void disappearEvent(SkeletonData _s)
{
  synchronized(personList) {
    for (int i=personList.size()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == personList.get(i).id) 
      {
        personList.remove(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(personList) {
    for (int i=personList.size()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == personList.get(i).id) 
      {
        personList.get(i).update(_a);
        break;
      }
    }
  }
}