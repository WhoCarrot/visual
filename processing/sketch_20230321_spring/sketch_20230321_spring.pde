
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

// Constants
int FRAME_COUNT = 65;          // Amount of frames in data directory
float COOLDOWN = 150;           // Time between frames in milliseconds

// Variables
PostFXSupervisor supervisor;
Pass[] passes;
PImage[] frames = new PImage[FRAME_COUNT];
int startTime;

void setup() {
    for (int i = 0; i < FRAME_COUNT; i++) {
        frames[i] = loadImage("output" + (i + 1) + ".png");
    }

    startTime = millis();
    
    supervisor = new PostFXSupervisor(this);
    passes = new Pass[] {
        // new BloomPass(this, .4, 20, 40),
        // new ChromaticAberrationPass(this),
        // new SobelPass(this),
        // new VignettePass(this, .8, .3),
    };

    size(1440, 810, P2D);
    colorMode(HSB, 100, 100, 100, 100);
    background(0);
}

int lastIndex = -1;
void draw() {
    translate(width / 4, height / 4);

    background(0);

    int currentIndex = floor((millis() - startTime) / COOLDOWN % 60);
    PImage currentImage = frames[currentIndex];

    if (currentIndex > lastIndex) {
        // background(0);
    }
    
    // for (int k = 0; k < 10; k++) {
        for (int x = 0; x < currentImage.width; x++) {
            for (int y = 0; y < currentImage.height; y++) {
                int i = y * currentImage.width + x;
                float b = brightness(currentImage.pixels[i]);
                if (b < 60) continue;
                // if (random(1) > .05) continue;

                // float h = (hue(currentImage.pixels[i]) + round(map(noise(x * .01, y * .01, millis() * .05), 0, 1, 0, 360))) % 360;
                // float n = noise(x * .01, y * .01, millis() * .00025);
                // float n = noise(x * .005, y * .005, b * .005 + millis() * .00025);
                float s = saturation(currentImage.pixels[i]);
                float h = hue(currentImage.pixels[i]);
                float n = noise(s + millis() * .00025, b + millis() * .00025, h + millis() * 0.00025);
                h = (hue(currentImage.pixels[i]) + map(n, .4, .7, 0, 100)) % 100;
                // float h = ;
                // float h = hue(currentImage.pixels[i]);

                // int hue = round(map(noise(x*.01, y*.01, millis()*.5), .3, .7, 0, 360));
                // float w = map(random(1), 0, 1, 3, 8);
                float w = 2;
                float a = map(random(1), 0, 1, 100, 100);




                strokeWeight(w);
                stroke(color(h, s, b, a));
                point(x, y);
            }
        }
    // }

    lastIndex = currentIndex;

    supervisor.render();
    for (Pass pass : passes) {
        supervisor.pass(pass);
    }
    supervisor.compose();

    // image(currentImage, 0, 0);
}