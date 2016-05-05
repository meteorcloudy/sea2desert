/**
 * Which Face Is Which
 * Daniel Shiffman
 * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
 *
 * Modified by Jordi Tost (call the constructor specifying an ID)
 * @updated: 01/10/2014
 */

int SURVIVE_TIME = 25;
int IN_UNIT = 1;
int OUT_UNIT = 5;

class Face {
  
  // A Rectangle
  Rectangle r;
  
  // Am I available to be matched?
  boolean available;
  
  // Should I be deleted?
  boolean delete;
  
  // How long should I live if I have disappeared?
  int timer;
  
  // Assign a number to each face
  int id;
  
  // The radius of the transparent circle
  float radius;
  float centerX;
  float centerY;
  float inner_radius;
  float out_radius;
  
  // Make me
  Face(int newID, int x, int y, int w, int h) {
    radius = INIT_RADIUS;
    delete = false;
    id = newID;
    update(new Rectangle(x,y,w,h));
  }
  
  // The radius is growing
  void grow() {
    if (available) return;
    radius += GROW_SPEED;
    //println(radius);
    if (radius > MAX_RADIUS) {
      radius = MAX_RADIUS;
    }
  }

  // Show me
  void display() {
    fill(0,0,255,timer);
    stroke(0,0,255);
    rect(r.x,r.y,r.width, r.height);
    //rect(r.x*scl,r.y*scl,r.width*scl, r.height*scl);
    fill(255,timer*2);
    text(""+id,r.x+10,r.y+30);
    //text(""+id,r.x*scl+10,r.y*scl+30);
    //text(""+id,r.x*scl+10,r.y*scl+30);
  }

  // Give me a new location / size
  // Oooh, it would be nice to lerp here!
  void update(Rectangle newR) {
    r = (Rectangle) newR.clone();
    timer = round(SURVIVE_TIME * radius / MAX_RADIUS);
    centerX = r.x + r.width / 2.0;
    centerY = r.y + r.height / 2.0;
    centerX = map(centerX, VIDEO_WIDTH, 0, 0, width/scl);
    centerY = map(centerY, 0, VIDEO_HEIGHT, 0, height/scl);
    inner_radius = radius * IN_UNIT / scl;
    out_radius = radius * OUT_UNIT / scl;
    available = false;
  }

  // Count me down, I am gone
  void countDown() {
    if (timer != 0) {
      radius = max(0, radius / timer * (timer-1));
      inner_radius = radius * IN_UNIT / scl;
      out_radius = radius * OUT_UNIT / scl;
    }
    timer--;
  }

  // I am deed, delete me
  boolean dead() {
    if (timer < 0) return true;
    return false;
  }
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