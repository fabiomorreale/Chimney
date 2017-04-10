class Source {

  // Location and size
  float x;
  float y;
  float r;
  float distance;
  Gain g;
  Glide gainValue;
  SamplePlayer sp; 
  String sourceFile;
  color c;
  boolean playing;
  boolean atom;
  int nexto;

  Source (int nextInt, String filename, color kol, boolean _atom) {
    r = 50;
    c = kol;
    playing = false;
    atom = _atom;
    nexto = nextInt;

    sourceFile = sketchPath("data/audio/") + filename;   

    try {  
      sp = new SamplePlayer(ac, new Sample(sourceFile));
      sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      sp.setKillOnEnd(false);
    }
    catch(Exception e)
    {
      println("Exception while attempting to load sample!");
      e.printStackTrace();
      exit();
    }

    gainValue = new Glide(ac, 0.0, 20); 
    g = new Gain(ac, 1, gainValue);

    g.addInput(sp); //nullpointer
    sp.setToLoopStart();

    ac.out.addInput(g);
    ac.start();
    if (!atom) {
      sp.start();
    }
  }

  boolean contains(float mx, float my) {
    if (dist(mx, my, x, y) < r) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    float transp = map(distance, 0, r/2, 220, 0);
    fill(c, 15);
    noStroke();
    if (!atom) {
      fill(c, 10);
      for (int i=1; i<=innerCircles; i++) {
        ellipse(x, y, r*i/innerCircles, r*i/innerCircles);
      }
    } else {
      fill(c, 50);
      ellipse(x, y, r, r);
    }
    
    fill(c,200);
    textAlign(CENTER);
    textSize(12);
    text(nexto, x,y+3);
    textAlign(LEFT);
    strokeWeight(0.5);
    stroke(c, 100);
    noFill();
    ellipse(x, y, r, r);

  }

  void volume(float posX, float posY) {
    distance = sqrt(pow((posX-x), 2)+pow((posY-y), 2));
    float vol;

    if (!atom) {
      if (distance>(r/2)) {
        vol = 0;
      } else {
        if (!playing) {
          sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
          sp.setToLoopStart();
          sp.setToLoopStart();
          sp.start();
          playing = true;
        }
        vol = -(distance/(r/2))+1;
      }
      gainValue.setValue(vol);
    } else {
      if (distance>(r/2)) {
        if (playing) {
          sp.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
          //sp.setToEnd();  // uncomment if you want sound to stop as the fly leave the circle
          playing = false;
        }
      } else {  // if the flys lays inside the atomic circle
        if (!playing) {
          gainValue.setValue(0.5);
          sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
          sp.setToLoopStart();
          sp.setToLoopStart();
          sp.start();
          playing = true;
        }
      }
    }
  }

  void setX(float x_) {
    this.x = x_;
  }

  void setY(float y_) {
    this.y = y_;
  }

  void setR(float x_, float y_) {
    float diff = 2*sqrt(pow(this.x-x_, 2)+pow(this.y-y_, 2));
    this.r = diff;
  }

  void setR(float r_) {
    this.r = 0;
  }

  void setRSize(float r_) {
    this.r = r_;
  }

  float getX() {
    return this.x;
  }

  float getY() {
    return this.y;
  }

  float getR() {
    return this.r;
  }

  void stop() {
    sp.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
    sp.setToEnd();
  }
}