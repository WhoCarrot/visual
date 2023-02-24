import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioPlayer jingle;
FFT         fft;

boolean fill = true;

int scl;
int cols = 16;
int rows = 32;
int multiplier = 2;
int fftSize = 1024;
String songname = "../../data/theme4.mp3";
float skip = -1;
float angle = 0;
float maxwidth = 64;
float[][] terrain;
float maxheight;
float cMod = 0.0;
float desiredcMod = 0.0;

float backgroundHue = 0.0;
float backgroundBrightness = 0.0;
float backgroundSaturation = 0;
float backgroundChangePercentage = 50;
float backgroundChangeMin = 0;
float backgroundChangeMax = 100;
float backgroundIntensityDecay = 2;
float dropheightpercentage = 98.3;

float lowHeightTicker = 0;
float lowHeightTime = 60;


void preload () {
}

void setup () {
  // size(1920, 1080, P3D);
  fullScreen(P3D, 2);
  strokeJoin(ROUND);
  strokeCap(ROUND);
  colorMode(HSB, 360);
  smooth();
  frameRate(144);
  noStroke();
  
  minim = new Minim(this);
  setMaximumHeight(songname);
  jingle = minim.loadFile(songname, fftSize);
  jingle.play();
  fft = new FFT( jingle.bufferSize(), jingle.sampleRate() );

  scl = width / cols;
  
  terrain = new float[cols][rows];
  
  // initRecording();
}

void draw () {
  // while (getCurrentTime() < getSoundTime() + frameDuration * frameOffset) {
    // println(frameRate);

    
    

  background(backgroundHue, backgroundSaturation, backgroundBrightness);
  
  stroke(255, 0, 0);
  float position;
  if (skip != -1) {
    position = skip;
    jingle.cue(floor(map(skip, 0, width, 0, jingle.length())));
    skip = -1;
  } else {
    position = map(jingle.position(), 0, jingle.length(), 0, width);
  }
  line(position, height, position, height-25);
  noStroke();
  
  fft.forward( jingle.right );
  
  float maxfromband = 0;
  // Loop through the entire band
  for(int i = 0; i < fft.specSize() / 2; i++)
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
  
  //translate(width/2, height/2, map(jingle.position(), 0, jingle.length(), -1000, -500));
  translate(width/2, height/2, map(jingle.position(), 0, jingle.length(), -1000, -500));
  rotateX(PI/2);
  //rotateZ(map(jingle.position(), 0, jingle.length(), 0, PI*10));
  
  float heightpercentage = maxfromband * 100 / maxheight;
  float c = map(heightpercentage, 0, 100, 0, 40);
  //float xPow = map(jingle.position(), 0, jingle.length(), 6, 10);
  //float xPow = map(jingle.position(), 0, jingle.length(), -2, 10);
  float xPow = 0;
  float yPow = 2;
  
  // Change color when nothing is happening
  if (heightpercentage < 5) {
    lowHeightTicker++;
    if (lowHeightTicker > lowHeightTime) {
      println("fill");
      fill = true;
    }
    desiredcMod = map(jingle.position(), 0 , jingle.length(), 0, 360);
  } else {
    lowHeightTicker = 0;
  }
  
  if (heightpercentage > dropheightpercentage) {
    if (fill) {
      backgroundBrightness = 360;
      fill = false;
      println("nofill");
      println(heightpercentage);
    }
  }
  
  if (cMod != desiredcMod) {
    if (cMod > desiredcMod) {
      cMod -= 0.1;
    } else {
      cMod += 0.1;
    }
  }
  
  strip(c+cMod, 360-cMod, 1, 1, 1, xPow, yPow, heightpercentage);
  strip(c+cMod, 360-cMod, -1, 1, 1, xPow, yPow, heightpercentage);
  strip(c+cMod, 360-cMod, 1, 1, -1, xPow, yPow, heightpercentage);
  strip(c+cMod, 360-cMod, -1, 1, -1, xPow, yPow, heightpercentage);
  
  //strip(c+cMod, 360-cMod, 1, -1, 1, xPow, yPow, heightpercentage);
  //strip(c+cMod, 360-cMod, -1, -1, 1, xPow, yPow, heightpercentage);
  //strip(c+cMod, 360-cMod, 1, -1, -1, xPow, yPow, heightpercentage);
  //strip(c+cMod, 360-cMod, -1, -1, -1, xPow, yPow, heightpercentage);
  
  if (heightpercentage > backgroundChangePercentage) {
    backgroundHue = c+cMod;
    if (map(heightpercentage, backgroundChangePercentage, 100, backgroundChangeMin, backgroundChangeMax) > backgroundBrightness) {
      backgroundBrightness = map(heightpercentage, backgroundChangePercentage, 100, backgroundChangeMin, backgroundChangeMax);
    }
  } else if (backgroundBrightness > 0) {
    backgroundBrightness -= map(backgroundBrightness, 0, 360, backgroundIntensityDecay, backgroundIntensityDecay*2);
  }
  
  // recordFrame();
  // }
}

void strip(float colorMin, float colorMax, float xMod, float yMod, float zMod, float xPow, float yPow, float heightpercentage) {
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      float h = terrain[x][y];
      //float c = map(h, 0, maxheight, colorMin, colorMax);
      float c = map(h, 0, maxheight, 0, 360);
      stroke(c, 360, 360);
      float strokeWeight = map(heightpercentage, 0, 100, -maxwidth/8, maxwidth)-pow(y,2);
      if (strokeWeight < 1)
        strokeWeight = 1;
      strokeWeight(strokeWeight);
      if (fill) {
        fill(c, 360, 360);
      } else {
        noFill();
      }
      float ySine = sin(map(x, 0, cols, 0, HALF_PI));
      float xSine = tan(map(y, 0, rows-1, 0, HALF_PI));
      vertex(x*scl*xMod*xSine, y*yMod-x*ySine*scl, zMod*terrain[x][y]/*+zMod*pow(y,yPow)*pow(x,xPow)*/);
      vertex(x*scl*xMod*xSine, (y+1)*yMod-x*ySine*scl, zMod*terrain[x][y+1]/*+zMod*pow(y,yPow)*pow(x,xPow)*/);
    }
    endShape();
  }
}

void setMaximumHeight(String name) {
  AudioSample jingle = minim.loadSample(name, fftSize);
  
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  //int fftSize = fftsize;
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
