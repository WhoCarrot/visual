import ddf.minim.analysis.*;
import ddf.minim.*;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import peasy.*;

Minim       minim;
AudioPlayer jingle;
FFT         fft;
PeasyCam    cam;

boolean fill = true;

int scl;
int cols = 16;
int rows = 32;
int fftSize = 8192/2;
float multiplier = 1;
String songname = "../../data/theme47.mp3";
float skip = -1;
float maxwidth = 256;
float[][] terrain;
float maxheight;
float cMod = 0.0;
float desiredcMod = 0.0;

float fillFramerate = 24;
float noFillFramerate = fillFramerate;

float backgroundHue = 0.0;
float backgroundBrightness = 0.0;
float backgroundSaturation = 0;
float backgroundChangePercentage = 50;
float backgroundChangeMin = 0;
float backgroundChangeMax = 100;
float backgroundIntensityDecay = 1;
float dropheightpercentage = 190;

float lowHeightTicker = 0;
float lowHeightTime = 30;
float lowHeightThreshold = 10;

float alphaDecay = .5;
float alphaMin = -270;
float alphaMax = 360;
float alphaCurrent = alphaMin;

float zEnableMin = -0.33;
float zEnableMax = 1;
// float zEnable = -1;
// float zEnable = -.33;
// float zEnable = .33;
float zEnable = -0.20000497;

float zEnableSpeed = 0;
boolean playing = true;

// PostFX fx;
PostFXSupervisor supervisor;
Pass[] fillPasses;
Pass[] noFillPasses;

void setup () {
  // maxwidth = width / 2;
  // cam = new PeasyCam(this, 100);
  // cam.setMinimumDistance(50);
  // cam.setMaximumDistance(500);

  minim = new Minim(this);
  setMaximumHeight(songname);
  jingle = minim.loadFile(songname, fftSize);
  jingle.play();
  fft = new FFT( jingle.bufferSize(), jingle.sampleRate() );
  // fx = new PostFX(this);
  supervisor = new PostFXSupervisor(this);
  fillPasses = new Pass[] {
    // new SobelPass(this),his),
    // new ChromaticAberrationPass(this),
    // new ChromaticAberrationPass(this),
    // new SobelPass(this),
    // new PixelatePass(this, 1000f),
    // new SobelPass(this),
    // new PixelatePass(this, 300f),
    // new SobelPass(this),
    // // new SobelPass(this),
    // new PixelatePass(this, 100f),
    // new SobelPass(this),
    // new PixelatePass(this, 400f),
    // // new SobelPass(this),
    new ChromaticAberrationPass(this),
    new ChromaticAberrationPass(this),
    // new ChromaticAberrationPass(this),
    // new ChromaticAberrationPass(this),
    new PixelatePass(this, 100f),
    new PixelatePass(this, 150f),
    new PixelatePass(this, 200f),
    new SobelPass(this),
    new PixelatePass(this, 200f),
    // new BrightPass(this, 0.2f),
    // new SobelPass(this),
    new BloomPass(this, 0.2, 20, 100),
    // new PixelatePass(this, 800f),
    // new SobelPass(this),
    // new BloomPass(this, 0.2, 20, 5),
    // new SobelPass(this),
    // new BloomPass(this, 0.3, 100, 240),
    // new SobelPass(this),
    // new ChromaticAberrationPass(this),
    // new BloomPass(this, 0.2, 20, 40),
    // new SaturationVibrancePass(this),
    // new SobelPass(this),
    // new SobelPass(this),
    // new SobelPass(this),
    // new ChromaticAberrationPass(this),
    // new BloomPass(this, 0.2, 20, 40),
    // new SaturationVibrancePass(this),
    new VignettePass(this, .8, .3),
  };

  // noFillPasses = new Pass[] {
  //   new SobelPass(this),
  //   new BrightPass(this, 0.7f),
  //   // new PixelatePass(this, 400f),
  //   new ChromaticAberrationPass(this),
  //   // new SobelPass(this),
  //   // new SobelPass(this),
  //   // new SobelPass(this),
  //   // new ChromaticAberrationPass(this),
  //   // new BloomPass(this, 0.2, 20, 40),
  //   // new SaturationVibrancePass(this),
  //   new VignettePass(this, .8, .3),
  // };

  // noFillPasses = fillPasses;

  // noFillPasses = new Pass[] {
  //   new PixelatePass(this, 400f),
  //   new ChromaticAberrationPass(this),
  //   new BloomPass(this, 0.4, 40, 40),
  //   // new BloomPass(this, 0.1, 300, 300),
  //   new VignettePass(this, 0.8, 0.3),
  // };
// 
  // size(720, 1280, P3D);
  fullScreen(P3D);
  // size(1080, 1350, P3D);
  
  // surface.setLocation(100, 100);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  colorMode(HSB, 360, 360, 360, 360);
  smooth();
  frameRate(fillFramerate);
  noStroke();

  scl = width / cols / 2;
  
  terrain = new float[cols][rows];

  println(fft.specSize());

  // jingle.cue(40000);
}

void setFill(boolean fillValue) {
  if (fillValue == fill) return;

  if (fillValue) {
    println("fill");
    println(jingle.position());
    fill = true;
    frameRate(fillFramerate);
  } else {
    backgroundBrightness = 360;
    fill = false;
    println("nofill");
    println(jingle.position());
    // println(heightpercentage);
    frameRate(noFillFramerate);
  }
}

// boolean hardcodedDrop = false;
void draw () {
  if (!playing) return;

  // if (jingle.position() >= 132350 && !hardcodedDrop) {
  //   setFill(false);
  //   hardcodedDrop = true;
  // }

  noStroke();
  setTitle();

  // background(color(360, 360, 0, .0001));
  background(backgroundHue, backgroundSaturation, backgroundBrightness, .01);
  fft.forward(jingle.mix);

  float maxfromband = 0;
  // Loop through the entire band
  for(int i = 0; i < fft.specSize(); i++)
  {
    // todo scale cols to specsize
    if (i >= cols) {
      break;
    }
    
    for (int row = rows-1; row > 0; row--) {
      terrain[i][row] = terrain[i][row-1];
    }
      
    terrain[i][0] = fft.getBand(i) * multiplier;
    if (terrain[i][0] > maxfromband) {
      maxfromband = terrain[i][0];
    }
  }
  
  
  // translate(width/2, height/2, map(jingle.position(), 0, jingle.length(), -1000, -500));
  translate(width/2, height/2, -5000);
  rotateX(PI/2);
  // rotateY(PI/2);
  scale(.75);
  
  float heightpercentage = maxfromband * 100 / maxheight;
  float c = map(heightpercentage, 0, 100, 0, 40);
  //float xPow = map(jingle.position(), 0, jingle.length(), 6, 10);
  //float xPow = map(jingle.position(), 0, jingle.length(), -2, 10);
  float xPow = 2;
  float yPow = 2;

  // frameRate(map(heightpercentage, 0, 100, 60, 144));
  
  // Change color when nothing is happening
  if (heightpercentage < lowHeightThreshold) {
    lowHeightTicker++;
    if (lowHeightTicker > lowHeightTime && !fill) {
      setFill(true);
    }
    desiredcMod = map(jingle.position(), 0 , jingle.length(), 0, 360);
  } else {
    lowHeightTicker = 0;
  }
  
  if (heightpercentage > dropheightpercentage) {
    if (fill) {
      setFill(false);
    }
  }
  
  if (cMod != desiredcMod) {
    if (cMod > desiredcMod) {
      cMod -= 0.1;
    } else {
      cMod += 0.1;
    }
  }
  
  strip(c+cMod, 360-cMod, .4, .1, -1, xPow, yPow, heightpercentage);
  strip(c+cMod, 360-cMod, -.4, .1, -1, xPow, yPow, heightpercentage);
  strip(c+cMod, 360-cMod, .4, .1, .1, xPow, yPow, heightpercentage);
  strip(c+cMod, 360-cMod, -.4, .1, .1, xPow, yPow, heightpercentage);

  if (heightpercentage > backgroundChangePercentage) {
    backgroundHue = c+cMod;
    if (map(heightpercentage, backgroundChangePercentage, 100, backgroundChangeMin, backgroundChangeMax) > backgroundBrightness) {
      backgroundBrightness = map(heightpercentage, backgroundChangePercentage, 100, backgroundChangeMin, backgroundChangeMax);
    }
  } else if (backgroundBrightness > 0) {
    backgroundBrightness -= map(backgroundBrightness, 0, 360, backgroundIntensityDecay, backgroundIntensityDecay*2);
  }

  // if (fill) {
  //   zEnable += zEnableSpeed;
  // } else {
  //   zEnable -= zEnableSpeed;
  // }
  // zEnable = min(max(zEnable, zEnableMin), zEnableMax);

  supervisor.render();
  for (Pass pass : fill ? fillPasses : noFillPasses) {
    supervisor.pass(pass);
  }
  supervisor.compose();

  // saveFrame("exports/image" + frameCount + ".jpg");
}

void strip(float colorMin, float colorMax, float xMod, float yMod, float zMod, float xPow, float yPow, float heightpercentage) {
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      float h = terrain[x][y];
      //float c = map(h, 0, maxheight, colorMin, colorMax);
      float c = map(h, 0, maxheight, 0, 360);
      // float sw = map(heightpercentage, 0, 100, -maxwidth/8, maxwidth)-pow(y,2);
      float sw = map(heightpercentage, 0, 100, -maxwidth/8, maxwidth)+y;
      if (sw < 1) sw = 1;
      strokeWeight(sw);
      if (fill) {



        float alphaValue = map(y, 0, rows, alphaMax, alphaMin) / 2 + map(heightpercentage, 0, 100, alphaMin, alphaMax) / 2;
        if (alphaValue > alphaCurrent) {
          alphaCurrent = alphaValue;
        } else {
          alphaCurrent -= alphaDecay;
        }
        alphaCurrent = max(min(alphaCurrent, alphaMax, 360), alphaMin, 0);

        fill(color(c, 360, 360, alphaCurrent));
        // noFill();
        stroke(color(c, 360, 360, alphaCurrent));
      } else {
        // fill(c, 360, map(heightpercentage, 0, 100, 0, 360));
        stroke(c, 360, 360);
        noFill();
      }


      float ySine = sin(map(x, 0, cols, 0, HALF_PI));
      float xSine = tan(map(y, 0, rows-1, 0, HALF_PI));

      
      vertex(x*scl*xMod*xSine, y*yMod-x*ySine*scl+scl, zMod*terrain[x][y]+zMod*pow(y,yPow)*pow(x,xPow)*zEnable);
      vertex(x*scl*xMod*xSine, (y+1)*yMod-x*ySine*scl+scl, zMod*terrain[x][y+1]+zMod*pow(y,yPow)*pow(x,xPow)*zEnable);
      // vertex(x*scl*xMod*xSine, y*yMod-x*ySine*scl+scl, zMod*terrain[x][y]*zEnable);
      // vertex(x*scl*xMod*xSine, (y+1)*yMod-x*ySine*scl+scl, zMod*terrain[x][y+1]*zEnable);

      // if (fill) {
      // } else {
      //   vertex(x*scl*xMod*xSine, y*yMod-x*ySine*scl, zMod*terrain[x][y]/*+zMod*pow(y,yPow)*pow(x,xPow)*/);
      //   vertex(x*scl*xMod*xSine, (y+1)*yMod-x*ySine*scl, zMod*terrain[x][y+1]/*+zMod*pow(y,yPow)*pow(x,xPow)*/);
      // }
    }
    endShape();
  }
}


String prepad(int num, int amount) {
  String unpadded = "" + num;
  String zeroes = new String(new char[amount]).replace("\0", "0");
  return zeroes.substring(unpadded.length()) + unpadded;
}

void setTitle() {
  float position = map(jingle.position(), 0, jingle.length(), 0, 100);
  String[] songParts = songname.split("/");
  String songTitle = songParts[songParts.length - 1];
  surface.setTitle("song: " + songTitle + " | progress: " + prepad(round(position), 3) + "/100% | fps: " + prepad(round(frameRate), 3));
}

void setMaximumHeight(String name) {
  AudioSample jingle = minim.loadSample(name, fftSize);
  
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  float[] fftSamples = new float[fftSize];
  FFT fft = new FFT( fftSize, jingle.sampleRate());
  
  int totalChunks = (leftChannel.length / fftSize) + 1;
  for(int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx)
  {
    int chunkStartIndex = chunkIdx * fftSize;
    int chunkSize = min( leftChannel.length - chunkStartIndex, fftSize );
    System.arraycopy( leftChannel, chunkStartIndex, fftSamples, 0, chunkSize);    
    if ( chunkSize < fftSize )
    {
      java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 );
    }
    fft.forward( fftSamples );
    
    float[] heights = new float[fftSize/2];
    for(int i = 0; i < fftSize/2; ++i)
    {
      heights[i] = fft.getBand(i);
      
      if (fft.getBand(i) * multiplier > maxheight)
        maxheight = fft.getBand(i) * multiplier;
    }
  }
  jingle.close();
}


void keyPressed() {
  if (key == 'f' || key == 'F') {
    setFill(!fill);
  } else if (key == ' ') {
    if (playing) { 
      jingle.pause();
    } else {
      jingle.play();
    }
    playing = !playing;
  } else if (key == CODED) {
    if (keyCode == RIGHT) {
      jingle.cue(jingle.position() + 10000);
    } else if (keyCode == LEFT) {
      jingle.cue(jingle.position() - 10000);
    }
  }
}

void mouseWheel(MouseEvent event) {
  float scrollAmount = event.getCount();
  zEnable += scrollAmount / 10;
  println(zEnable);
}