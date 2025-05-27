import ddf.minim.analysis.*;
import ddf.minim.*;

AudioManager audioManager;

int songIndex = 42;
int fps = 144;

void setup() {
    AudioPlayer audioPlayer = new Minim(this).loadFile("../../data/theme" + songIndex + ".mp3");
    
    // Setup audio playing & analysis
    // println(this.getClass().getSimpleName());
    audioManager = new AudioManager(audioPlayer);
    
    // Setup sketch
    size(500, 250);
    strokeJoin(ROUND);
    strokeCap(ROUND);
    colorMode(HSB, audioManager.getAvgSize(),100,100);
    smooth();
    frameRate(fps);
}

void draw() {
    background(0);
    stroke(255);
    
    final int weight = width / avgSize;
    final float maxHeight = height * maxViewportUsage;
    final float xOffset = weight / 2 + (width - avgSize * weight) / 2;
    
    // if (resetBoundsAtEachStep) {
    //     minVal = 0.0;
    //     maxVal = 0.0;
    //     firstMinDone = false;
// }
    
    AudioFrame audioFrame = audioManager.getAudioFrame(frameRate);
    
    //Calculate the total range of smoothed spectrum; this will be used to scale all values to range 0...1
    println(audioFrame.maxValue);
    final float range = audioFrame.maxValue - audioFrame.minValue;
    final float scaleFactor = range + 0.00001; // avoid div. by zero
    
    for (int i = 0; i < avgSize; i++) {
        stroke(i,100,100);
        strokeWeight(weight);
        
        // Y-coord of display line; fftSmooth is scaled to range 0...1; this is then multiplied by maxHeight
        // to make it within display port range
        float fftSmoothDisplay = maxHeight * ((audioFrame.fftSmooth[i] - minVal) / scaleFactor);
        // Artificially impose a minimum of zero (this is mathematically bogus, but whatever)
        fftSmoothDisplay = max(0.0, fftSmoothDisplay);
        
        // X-coord of display line
        float x = xOffset + i * weight;
        
        line(x, height, x, height - fftSmoothDisplay);
    }
    text("smoothing: " + (int)(smoothing * 100) + "\n",10,10);
// }
    // println(frequencies.length);
}

// void keyPressed() {
//     if (key == ' ') {
//         if (audioPlayer.isPlaying()) {
//             audioPlayer.pause();
//         } else {
//             audioPlayer.play();
//         }
//     }
// }

// float[] getFrequencies() {
//     fft.forward(audioPlayer.mix);
//     float[] frequencies = new float[fft.specSize()];

//     for (int i = 0; i < fft.specSize(); i++) {
//         frequencies[i] = fft.getBand(i);
//     }

//     return frequencies;
// }





// float[] calculateAWeightingDBForFFTAverages(FFT fft) {
//     float[] result = new float[fft.avgSize()];
//     for (int i = 0; i < result.length; i++) {
//         result[i]= calculateAWeightingDBAtFrequency(fft.getAverageCenterFrequency(i));
//     }
//     return result;    
// }

// float calculateAWeightingDBAtFrequency(float frequency) {
//     return linterp(aWeightFrequency, aWeightDecibels, frequency);    
// }

// float dB(float x) {
//     if (x == 0) return 0;
//     else return 10 * (float)Math.log10(x);
// }

// float linterp(float[] x, float[] y, float xx) {
//     assert(x.length > 1);
//     assert(x.length == y.length);

//     float result = 0.0;
//     boolean found = false;

//     if (x[0] > xx) {
//         result = y[0];
//         found = true;
//     }

//     if (!found) {
//         for (int i = 1; i < x.length; i++) {
//             if (x[i] > xx) {
//                 result = y[i - 1] + ((xx - x[i - 1]) / (x[i] - x[i - 1])) * (y[i] - y[i - 1]);
//                 found = true;
//                 break;
//             }
//         }
//     }

//     if (!found) {
//         result = y[y.length - 1];
//     }

//     return result;     
// }


