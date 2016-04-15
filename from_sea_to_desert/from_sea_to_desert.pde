

PImage sea;
PImage desert;

void setup() {
  size(1600, 900);
  sea = loadImage("sea.jpg");
  desert = loadImage("desert.jpg");
  sea.resize(1600, 900);
  desert.resize(1600, 900);
  image(desert, 0, 0);
  image(sea, 0, 0);
}

void draw() {

}