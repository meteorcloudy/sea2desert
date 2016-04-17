/**
 * Which Face Is Which
 * Daniel Shiffman
 * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
 *
 * Modified by Jordi Tost (call the constructor specifying an ID)
 * @updated: 01/10/2014
 */

int SURVIVE_TIME = 25;

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
    println(radius);
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
    timer = SURVIVE_TIME;
    centerX = r.x + r.width / 2.0;
    centerY = r.y + r.height / 2.0;
    centerX = map(centerX, VIDEO_WIDTH, 0, 0, width/scl);
    centerY = map(centerY, 0, VIDEO_HEIGHT, 0, height/scl);
    inner_radius = radius * 1 / scl;
    out_radius = radius * 3 / scl;
    available = false;
  }

  // Count me down, I am gone
  void countDown() {
    timer--;
  }

  // I am deed, delete me
  boolean dead() {
    if (timer < 0) return true;
    return false;
  }
}