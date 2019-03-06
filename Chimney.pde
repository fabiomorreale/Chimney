import beads.*;
//
AudioContext ac;
PImage bg;

ArrayList<Source> sources;

PFont font;
float time = 0.0;
float increment = 0.001;
float staticChangeX = random(10);
float staticChangeY = random(10);
int randomPopulation = 1;
boolean flag = false;
boolean circle = false;
boolean menu = false;
boolean freeze = false;
boolean atomic = false;
int directionClock = 0;
int move = -1;
int pointer = 0;
int threshold = 15;
int thresholdC = 5;
int thresholdDelete = 50;
int tailSize = 100;
float[][] tail;
int numBackgrounds;
String[] files;
String[] filesMp3, filesAiff, filesAif, filesWav;
String next;
int nextInt;
int filePointer;
color[] colors;
float x, y, radius, _radiusnoise;
int mp3num, aiffnum, aifnum, wavnum;
float angle = 0;
float xInc = -200;
int numeroFile;
float timeFromRefresh;
boolean doNotAdd = false;
boolean addPointer = false;
int timeDragged;
int innerCircles = 5;


public void setup() {
  fullScreen(2);
  background(0);
  cursor(CROSS);
  java.io.File imgFolder = new java.io.File(sketchPath("data/imgs"));
  java.io.FilenameFilter jpgFilter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".jpg");
    }
  };
  numBackgrounds = imgFolder.list(jpgFilter).length;
  smooth(); 
  frameRate(25);
  font = loadFont("Source16.vlw");
  textSize(10);
  numeroFile = 0;
  fetchSource();
  ac = new AudioContext();  // create new audiocontext
  sources = new ArrayList<Source>();  // create an array made of all the different sources
  _radiusnoise = random(10);  // radius of the fly
  filePointer = 0; 
  noiseDetail(8, 0.4);
  tail = new float[2][tailSize];
  noiseSeed(0);
  for (int i=0; i<tailSize; i++) {
    tail[0][i]=0;
    tail[1][i]=0;
  }
  fetchSource();
}

void draw() {
  if ((millis() < 1100)&&(millis()>1000)) {
    freeze = true;
  }

  background(0);

  _radiusnoise += 0.001;  // variate the radius of the fly

  if (!freeze) {
    x = noise(time, staticChangeX)*width*2-width/3;  // change the x position of the fly
    y = noise(staticChangeY, time)*height*2-height/3;  // change the y position of the fly
    while (x>width) {
      staticChangeX += 0.001;
      x = noise(time, staticChangeX)*width*2-width/3;
    }
    while (x<0) {
      staticChangeX += 0.001;
      x = noise(time, staticChangeX)*width*2-width/3;
    }
    while (y>height) {
      staticChangeY += 0.001;
      y = noise(staticChangeY, time)*height*2-height/3;
    }
    while (y<0) {
      staticChangeY += 0.001;
      y = noise(staticChangeY, time)*height*2-height/3;
    }
    time += increment;  // determines the actual change
  }

  for (int i = 0; i < sources.size (); i++) {  // display and play each source
    Source source = sources.get(i);
    source.volume(x, y);
    source.display();
  }

  // update tail and display fly
  tail[0][tailSize-1]= x;
  tail[1][tailSize-1] = y;
  for (int i=0; i<tailSize-1; i++) {
    tail[0][i]=tail[0][i+1];
    tail[1][i]=tail[1][i+1];
    stroke(255);
    strokeWeight(map(i,0,tailSize,0.1,radius));
    line(tail[0][i], tail[1][i], tail[0][i+1], tail[1][i+1]);
    strokeWeight(1);
  }
  fill(0, 0, 0);
  stroke(255);
  noiseDetail(2, 0.4);
  radius = noise(_radiusnoise*10)*15+5;
  ellipse(x, y, radius-3, radius-3);
  noiseDetail(8, 0.4);
  noStroke();
  
  // display menu
  displayMenu();
  fill(200);

  if (directionClock==1) {
    angle += 0.4;
    if (angle>PI) {
      angle=PI;
    }
  } else if (directionClock==-1) {
    angle -= 0.4;
    if (angle<0) {
      angle=0;
    }
  } else {
    angle=0;
  }

  pushMatrix();
  translate(10, 10);
  translate(sqrt(3)*20/4, 10);
  noStroke();
  fill(200, 200);
  rotate(angle);
  translate(-sqrt(3)*20/4, -10);
  triangle(0, 0, sqrt(3)*20/2, 10, 0, 20);
  popMatrix();

  // display atomic status
  fill(200, 200);
  textFont(font, 16);
  stroke(0);
  if (atomic) {
    text("ATOMIC", 40, 26);
  }
}

void mousePressed() {
  for (int i = 0; i < sources.size (); i++) {
    Source source = sources.get(i);
    float cosi = mouseX-source.getX();
    float sini = mouseY-source.getY();
    float check = (pow(cosi, 2)+pow(sini, 2))/source.getR();

    if ((sqrt(pow((cosi), 2))<threshold)&&(sqrt(pow((sini), 2))<threshold)) {  // radius reshaping
      // set new center
      source.setX(mouseX);
      source.setY(mouseY);
      move = i;
      circle = false;
      // double click delete
      if (mouseEvent.getClickCount()==2) {
        Source source2 = sources.get(move);
        source2.stop();
        sources.remove(move);
        pointer--;
      }
    } else if (abs(check-source.getR()/4)<thresholdC) {  // center moving
      move = i;
      circle = true;
    }
  }

  if (menu&&(mouseX<200)) {
    float tmp = (mouseY-46)/16;
    int tmpint = floor(tmp);
    if ((tmpint<files.length)&&(tmpint>=0)) {
      filePointer= tmpint;
      next = files[filePointer];
      nextInt = filePointer;
    }
  }
}

void mouseDragged() {
  if (move==-1) {  // the newborn circle is growing
    if (!doNotAdd) {
      addSource();
      doNotAdd = true;
      addPointer = true;
    }
    Source sourceP = sources.get(pointer);
    sourceP.setR(mouseX, mouseY);
    sourceP.display();
    timeDragged = millis();
  } else {  // moving existing circle
    Source sourceM = sources.get(move);
    if (circle == false) {
      sourceM.setX(mouseX);
      sourceM.setY(mouseY);
    } else {  // reshaping existing circle while keeping the center fixed
      sourceM.setR(mouseX, mouseY);
    }
    sourceM.display();
  }
}

void mouseReleased() {
  if (move==-1) {
    if ((mouseX>200)||!menu||(millis()-timeDragged<100)) {
      if (addPointer) {
        pointer++; 
        addPointer = false;
      }
      doNotAdd = false;
    }
  } else {
    move=-1;
  }
}

void addSource() {
  sources.add(new Source(nextInt, next, colors[filePointer], atomic)); // next cointains string with the name of the file
  Source source = sources.get(pointer);
  source.setX(mouseX);
  source.setY(mouseY);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode==RIGHT) {
      if (menu==false) {
        menu = true;
        directionClock = 1;
      }
    } else if (keyCode==LEFT) {
      if (menu==true) {
        menu=false;
        directionClock = -1;
      }
    } else if (keyCode==DOWN) {
      if (filePointer<files.length-1) {
        filePointer++;
        next = files[filePointer];
        nextInt = filePointer;
      }
    } else if (keyCode==UP) {
      if (filePointer>0) {
        filePointer--;
        next = files[filePointer];
        nextInt = filePointer;
      }
    }
  }
  if (keyCode==ENTER) {  // Win and Unix
    atomic = !atomic;
  }
  if (keyCode==RETURN) { // OSx
    atomic = !atomic;
  }
  if (key == 'r') {
    randomize();
  }
  if (key == 'c') {
    clearAll();
  }
  if (key == ' ') {
    freeze = !freeze;
  }
  if (key==27) {
    key=0;
  }
}

public void fetchSource() {
  java.io.File folder = new java.io.File(sketchPath("data/audio"));
  java.io.FilenameFilter mp3Filter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".mp3");
    }
  };
  java.io.FilenameFilter aiffFilter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".aiff");
    }
  };
  java.io.FilenameFilter aifFilter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".aif");
    }
  };
  java.io.FilenameFilter wavFilter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".wav");
    }
  };
  filesMp3 = folder.list(mp3Filter);
  filesAiff = folder.list(aiffFilter);
  filesAif = folder.list(aifFilter);
  filesWav = folder.list(wavFilter);
  mp3num = filesMp3.length;
  aiffnum = filesAiff.length;
  aifnum = filesAif.length;
  wavnum = filesWav.length;
  if ((mp3num+aiffnum+aifnum+wavnum)!=numeroFile) {
    startSource();
    numeroFile = mp3num+aiffnum+aifnum+wavnum;
  }
  timeFromRefresh = millis();
}

void startSource() {
  files = new String[mp3num+aiffnum+aifnum+wavnum];

  for (int i=0; i<mp3num; i++) {
    files[i] = filesMp3[i];
  };
  for (int i=mp3num; i<aiffnum+mp3num; i++) {
    files[i] = filesAiff[i-mp3num];
  };
  for (int i=mp3num+aiffnum; i<aiffnum+mp3num+aifnum; i++) {
    files[i] = filesAif[i-mp3num-aiffnum];
  };
  for (int i=mp3num+aiffnum+aifnum; i<aiffnum+mp3num+aifnum+wavnum; i++) {
    files[i] = filesWav[i-mp3num-aiffnum-aifnum];
  };

  next = files[0];
  nextInt = 0;
  colors = new color[files.length];
  for (int i=0; i<files.length; i++) {
    float total = random(255,510);

    color colorTmp = color(random(100)+155,random(100)+155,random(100)+155);
    colors[i] = colorTmp;
  }
}

void displayText() {
  for (int i=0; i<files.length; i++) {
    fill(colors[i]);
    if (next==files[i]) { 
      textFont(font, 16);
    } else {
      textFont(font, 14);
    }
    text(i+"  "+files[i].toUpperCase(), 5, 55+i*16);
  }
}

void displayMenu() {
  if (!menu) {
    if (xInc>=-200) {
      xInc -= 30;
      if (xInc<-200)xInc=-200;
    }
  } else {
    if (xInc<=0) {
      xInc += 30;
      if (xInc>0)xInc=0;
    }
  }

  pushMatrix();
  translate(xInc, 0);
  fill(40, 150);
  rect(0, 0, 200, height);
  displayText();
  popMatrix();
}

void randomize() {
  for (int i=0; i<randomPopulation; i++) {
    int tmpN = floor(random(files.length));
    sources.add(new Source(tmpN, files[tmpN], colors[tmpN], atomic));
    Source source = sources.get(pointer);
    source.setX(random(width));
    source.setY(random(height));
    source.setRSize(100+random(500));
    pointer++;
  }
}

void clearAll() {
  int tmp = sources.size();
  for (int i=0; i<tmp; i++) {
    Source source = sources.get(0);
    source.stop();
    sources.remove(0);
  }
  pointer = 0;
}
