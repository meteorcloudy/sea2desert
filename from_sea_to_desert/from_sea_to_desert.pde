import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

Movie ocean;
PImage sea;
Movie desert;

float D = 0.1;
float GAUSS_0;
float RECOVER_SPEED = 255 / 20;

// video size
int VIDEO_WIDTH = 320;
int VIDEO_HEIGHT = 240;

int scl = 1;
float MAX_RADIUS = 100;
float GROW_SPEED = 2;
float INIT_RADIUS = 5;

// List of my Face objects (persistent)
ArrayList<Face> faceList;

// List of detected faces (every frame)
Rectangle[] faces;

// Number of faces detected over all time. Used to set IDs.
int faceCount = 0;

void setup() {
  size(1280, 720);
  ocean = new Movie(this, "ocean.mp4");
  ocean.loop();
  desert = new Movie(this, "desert.mp4");
  desert.loop();
  GAUSS_0 = gauss(0);
  
  video = new Capture(this, VIDEO_WIDTH, VIDEO_HEIGHT);
  opencv = new OpenCV(this, VIDEO_WIDTH, VIDEO_HEIGHT);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  faceList = new ArrayList<Face>();

  video.start();
}

float gauss(float x) {
  return exp(-x*x/(2*D*D)) / (D*sqrt(2*PI));
}

void adjustImageTransparent(PImage img) {
  img.loadPixels();
  for (int x = 0; x < img.width; x++ ) {
    for (int y = 0; y < img.height; y++ ) {
      int loc = x + y*img.width;
      
      float r = red  (img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue (img.pixels[loc]);
      float oldAlpha = alpha(img.pixels[loc]);
      float finalAlpha = constrain(oldAlpha + RECOVER_SPEED, 0, 255);
      
      for (Face face : faceList) {
        float distance = dist(x, y, face.centerX, face.centerY);
        float alpha;
        
        if (distance < face.inner_radius) {
          alpha = 0;
        } else if (distance > face.out_radius) {
          alpha = 255;
        } else {
          distance = map(distance, face.inner_radius, face.out_radius, 0, 3*D);
          alpha = map(gauss(distance), GAUSS_0, 0, 0, 255);
        }
        finalAlpha = min(alpha, finalAlpha);
      }
      
      color c = color(r, g, b, finalAlpha);
      img.pixels[loc] = c;
    }
  }
  img.updatePixels();
}

void draw() {
  scale(scl);
  opencv.loadImage(video);
  detectFaces();
  image(desert, 0, 0);
  sea = ocean.get();
  adjustImageTransparent(sea);
  image(sea, 0, 0);
}

void captureEvent(Capture c) {
  c.read();
  ocean.read();
  desert.read();
}