import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PImage sea;
PImage desert;

float D = 0.1;
float gauss_0;
float recover_speed = 255 / 20;

// video size
int VIDEO_WIDTH = 320;
int VIDEO_HEIGHT = 180;

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
  size(1600, 900);
  sea = loadImage("sea.jpg");
  desert = loadImage("desert.jpg");
  sea.resize(width / scl, height / scl);
  desert.resize(width / scl, height / scl);
  gauss_0 = gauss(0);
  
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
      float finalAlpha = constrain(oldAlpha + recover_speed, 0, 255);
      
      for (Face face : faceList) {
        float distance = dist(x, y, face.centerX, face.centerY);
        float alpha;
        
        if (distance < face.inner_radius) {
          alpha = 0;
        } else if (distance > face.out_radius) {
          alpha = 255;
        } else {
          distance = map(distance, face.inner_radius, face.out_radius, 0, 3*D);
          alpha = map(gauss(distance), gauss_0, 0, 0, 255);
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
  adjustImageTransparent(sea);
  image(sea, 0, 0);
}

void detectFaces() {
  
  // Faces detected in this frame
  faces = opencv.detect();
  
  // Check if the detected faces already exist are new or some has disappeared. 
  
  // SCENARIO 1 
  // faceList is empty
  if (faceList.isEmpty()) {
    //println("s 1");
    // Just make a Face object for every face Rectangle
    for (int i = 0; i < faces.length; i++) {
      println("+++ New face detected with ID: " + faceCount);
      faceList.add(new Face(faceCount, faces[i].x,faces[i].y,faces[i].width,faces[i].height));
      faceCount++;
    }
  
  // SCENARIO 2 
  // We have fewer Face objects than face Rectangles found from OPENCV
  } else if (faceList.size() <= faces.length) {
    //println("s 2");
    boolean[] used = new boolean[faces.length];
    // Match existing Face objects with a Rectangle
    for (Face f : faceList) {
       // Find faces[index] that is closest to face f
       // set used[index] to true so that it can't be used twice
       float record = 50000;
       int index = -1;
       for (int i = 0; i < faces.length; i++) {
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && !used[i]) {
           record = d;
           index = i;
         } 
       }
       // Update Face object location
       used[index] = true;
       f.update(faces[index]);
    }
    // Add any unused faces
    for (int i = 0; i < faces.length; i++) {
      if (!used[i]) {
        println("+++ New face detected with ID: " + faceCount);
        faceList.add(new Face(faceCount, faces[i].x,faces[i].y,faces[i].width,faces[i].height));
        faceCount++;
      }
    }
  
  // SCENARIO 3 
  // We have more Face objects than face Rectangles found
  } else {
    // All Face objects start out as available
    //println("s 3");
    for (Face f : faceList) {
      f.available = true;
    } 
    // Match Rectangle with a Face object
    for (int i = 0; i < faces.length; i++) {
      // Find face object closest to faces[i] Rectangle
      // set available to false
       float record = 50000;
       int index = -1;
       for (int j = 0; j < faceList.size(); j++) {
         Face f = faceList.get(j);
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && f.available) {
           record = d;
           index = j;
         } 
       }
       // Update Face object location
       Face f = faceList.get(index);
       f.available = false;
       f.update(faces[i]);
    } 
    // Start to kill any left over Face objects
    for (Face f : faceList) {
      if (f.available) {
        f.countDown();
        if (f.dead()) {
          f.delete = true;
        } 
      }
    } 
  }
  
  // Delete any that should be deleted
  for (int i = faceList.size()-1; i >= 0; i--) {
    Face f = faceList.get(i);
    if (f.delete) {
      faceList.remove(i);
    } else {
      f.grow();
    }
  }
}

void captureEvent(Capture c) {
  c.read();
}