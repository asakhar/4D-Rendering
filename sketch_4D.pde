Cube cube;
mat rotation;
mat rotation3D;
mat projection;
vec offset;

int mousePX;
int mousePY;

float wAngle = 0.;
float zAngle = 0.;
float xAngle = 0.;
float yAngle = 0.;

import java.util.HashMap;
HashMap<Character, Boolean> pressedKeys;

void setup() {  
  size(800, 800, P3D);
  cube = new Cube(4, 50.);
  projection = new mat(4, 
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0
  );
  offset = new vec(width/2, height/2, 0);
  pressedKeys = new HashMap<Character, Boolean>();
  pressedKeys.put('w', false);
  pressedKeys.put('z', false);
}

void mousePressed() {
  mousePX = mouseX;
  mousePY = mouseY;
}

void mouseDragged() {
  xAngle -= (float(mouseY-mousePY))/100.;
  yAngle -= (float(mouseX-mousePX))/100.;
  mousePX = mouseX;
  mousePY = mouseY;
}

void mouseWheel(MouseEvent e) {
  var prev = offset.z();
  offset.set(2, prev + 10*(float)e.getCount());
  if(offset.z() <= 0) {
    offset.set(2, 0.1);
  }
  print(offset.z());
}

void draw() {
  background(255);
  
  translate(offset.x(), offset.y(), offset.z());
  
  rotation = new mat(4, 
    cos(wAngle), 0          ,          0, -sin(wAngle),
    0          , 1          ,          0,            0,
    0          , 0          ,          1,            0,
    sin(wAngle), 0          ,          0, cos(wAngle) 
  );
  
  rotation3D = new mat(3, 
    cos(zAngle), -sin(zAngle), 0,
    sin(zAngle),  cos(zAngle), 0,
    0, 0, 1
  );
  
  rotation3D = rotation3D.mul(new mat(3, 
    cos(yAngle), 0, -sin(yAngle),
    0, 1, 0,
    sin(yAngle), 0, cos(yAngle)
  ));
  
  rotation3D = rotation3D.mul(new mat(3, 
    1, 0, 0,
    0, cos(xAngle), -sin(xAngle),
    0, sin(xAngle), cos(xAngle)
  ));

  //// ########### SLOW adds vertex rendering
  //for(var point : cube.vert) {
  //  point = rotation.mul(point);
  //  point = projection.copy().div((150.-point.w())/100.).mul(point);
  //  pushMatrix();
  //  translate(point.x(), point.y(), point.z());
  //  sphere(5);
  //  popMatrix();
  //}
  //// ########### SLOW
  
  for(var edge : cube.edges) {
    var pointA = rotation.mul(edge.or);
    var pointB = rotation.mul(edge.di);
    
    pointA = projection.copy().div((150.-pointA.w())/100.).mul(pointA);
    pointB = projection.copy().div((150.-pointB.w())/100.).mul(pointB);
    
    pointA = rotation3D.mul(pointA);
    pointB = rotation3D.mul(pointB);
    
    strokeWeight(5/((120.-.5*(pointA.z()+pointB.z()))/100.));
    line(pointA.x(), pointA.y(), pointA.z(), pointB.x(), pointB.y(), pointB.z());
  }
  if(pressedKeys.get('w'))
    wAngle += 0.01;
  if(pressedKeys.get('z'))
    zAngle += 0.01;
}

void keyPressed() {
  if(pressedKeys.containsKey(key))
    pressedKeys.replace(key, true);
}

void keyReleased() {
  if(pressedKeys.containsKey(key))
    pressedKeys.replace(key, false);
}
