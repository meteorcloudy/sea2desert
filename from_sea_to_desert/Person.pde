
int IN_UNIT = 1;
int OUT_UNIT = 5;

class Person {
  
  // Assign a number to each face
  int id;
  
  // The radius of the transparent circle
  float radius;
  float inner_radius;
  float out_radius;
  float px, py;
  double res;
  
  // Make me
  Person(SkeletonData data) {
    radius = INIT_RADIUS;
    id = data.dwTrackingID;
    px = py = -1000000;
    update(data);
  }
  
  Person() {
    radius = INIT_RADIUS;
    id = -1;
    px = 0;
    py = 360;
  }
  
  // The radius is growing
  void grow() {
    radius += GROW_SPEED;
    if (radius > MAX_RADIUS) {
      radius = MAX_RADIUS;
    }
    inner_radius = radius * IN_UNIT / scl;
    out_radius = radius * OUT_UNIT / scl;
  }

  // Give me a new location / size
  // Oooh, it would be nice to lerp here!
  void update(SkeletonData data) {
    int pos = Kinect.NUI_SKELETON_POSITION_HEAD; 
    if (data.skeletonPositionTrackingState[pos] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      px = data.skeletonPositions[pos].x * width;
      py = data.skeletonPositions[pos].y * height;
    }
  }
}