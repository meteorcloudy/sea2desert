
int IN_UNIT = 1;
int OUT_UNIT = 5;

class Person {
  
  SkeletonData skeleton;
  
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
    update(data);
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
    skeleton.copy(data);
  }
  
  double getMin() {
    res = 1000000000.0;
    // Body
    getDist(Kinect.NUI_SKELETON_POSITION_HEAD, 
            Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
            Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
            Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
            Kinect.NUI_SKELETON_POSITION_SPINE);
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
            Kinect.NUI_SKELETON_POSITION_SPINE);
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_SPINE);
    getDist(Kinect.NUI_SKELETON_POSITION_SPINE, 
            Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
    getDist(Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
            Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
    getDist(Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
            Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
    getDist(Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
            Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  
    // Left Arm
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
            Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
    getDist(Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
            Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
    getDist(Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
            Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
  
    // Right Arm
    getDist(Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
    getDist(Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
    getDist(Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
  
    // Left Leg
    getDist(Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
            Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
    getDist(Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
            Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
    getDist(Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
            Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);
  
    // Right Leg
    getDist(Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
    getDist(Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
    getDist(Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
            Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
    return res;
  }
  
  void getDist(int _j1, int _j2) {
    if (skeleton.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
      skeleton.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      res = Math.min(res, PointToSegDist(px, py, skeleton.skeletonPositions[_j1].x*width, 
      skeleton.skeletonPositions[_j1].y*height, 
      skeleton.skeletonPositions[_j2].x*width, 
      skeleton.skeletonPositions[_j2].y*height));
    }
  }
  
  double PointToSegDist(double x, double y, double x1, double y1, double x2, double y2){
    double cross = (x2 - x1) * (x - x1) + (y2 - y1) * (y - y1);
    if (cross <= 0) return Math.sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1));
  
    double d2 = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
    if (cross >= d2) return Math.sqrt((x - x2) * (x - x2) + (y - y2) * (y - y2));
     
    double r = cross / d2;
    double px = x1 + (x2 - x1) * r;
    double py = y1 + (y2 - y1) * r;
    return Math.sqrt((x - px) * (x - px) + (py - y1) * (py - y1));
  }
  
  float dist(float x, float y) {
    px = x; py = y;
    return (float) getMin();
  }
}