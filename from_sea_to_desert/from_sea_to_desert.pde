import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PImage sea;
PImage desert;

float D = 0.1;
float width_radius = 200;
float inner_radius = 100;
float gauss_0;

void setup() {
  size(1600, 900);
  sea = loadImage("sea.jpg");
  desert = loadImage("desert.jpg");
  sea.resize(1600, 900);
  desert.resize(1600, 900);
  gauss_0 = gauss(0);
  
  video = new Capture(this, 640/2, 360/2);
  opencv = new OpenCV(this, 640/2, 360/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
}

float gauss(float x) {
  return exp(-x*x/(2*D*D)) / (D*sqrt(2*PI));
}

void adjustImageTransparent(PImage img, float centerX, float centerY) {
  img.loadPixels();
  for (int x = 0; x < img.width; x++ ) {
    for (int y = 0; y < img.height; y++ ) {
      int loc = x + y*img.width;
      
      float r = red  (img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue (img.pixels[loc]);

      float distance = dist(x, y, centerX, centerY);
      float alpha;
      float out_radius = inner_radius + width_radius;
      if (distance < inner_radius) {
        alpha = 0;
      } else if (distance > out_radius) {
        alpha = 255;
      } else {
        distance = map(distance, inner_radius, out_radius, 0, 3*D);
        alpha = map(gauss(distance), gauss_0, 0, 0, 255);
      }
      color c = color(r, g, b, alpha);
      img.pixels[loc] = c;
    }
  }
  img.updatePixels();
}

void draw() {
  opencv.loadImage(video);
 
  Rectangle[] faces = opencv.detect();
  image(desert, 0, 0);
  if (faces.length > 0) {
    float x = faces[0].x + faces[0].width / 2.0;
    float y = faces[0].y + faces[0].height / 2.0;
    x = map(x, 320, 0, 0, 1600);
    y = map(y, 0, 180, 0, 900);
    println(x + ", " + y);
    adjustImageTransparent(sea, x, y);
  }
  image(sea, 0, 0);
}

void captureEvent(Capture c) {
  c.read();
}