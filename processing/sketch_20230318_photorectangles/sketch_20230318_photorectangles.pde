import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import java.util.*;

Stack<Float> mouseDistances = new Stack<Float>();
PVector previousMousePosition;

PostFXSupervisor supervisor;
Pass[] passes;

PImage[] photos;


PImage photo;
PImage photo2;

int minSize = 8;
int maxSize = 900;
int minAmount = 1;
int maxAmount = 3000;
int minAlpha = 50;
int maxAlpha = 10;
int fc = 0;

void setup() {
    photos = new PImage[] {
        // loadImage("1.png"),
        // loadImage("2.png"),
        // loadImage("3.png"),
        // loadImage("4.png"),
        // loadImage("5.png"),
        // loadImage("harv.png"),
        // loadImage("01.jpg"),
        loadImage("mondriaan.jpg"),
        loadImage("mondriaan2.jpg"),
    };
    for (PImage p : photos) {
        p.resize(900, 0);
    }



    // photo = loadImage("1.jpg");
    // photo.resize(900, 0);
    // photo2 = loadImage("2.jpg");
    // photo2.resize(900, 0);

    // frameRate(30);

    supervisor = new PostFXSupervisor(this);
    passes = new Pass[] {
        // new PixelatePass(this, 200f),
        // new SobelPass(this),
        // new InvertPass(this), 
        // new BrightPass(this, 0.8f),
        // new InvertPass(this),
        // new SobelPass(this),
        // new VignettePass(this, 0.8, 0.3),
        // new InvertPass(this),
        // new SobelPass(this),
        // new SobelPass(this),
        // new BloomPass(this, 0.4, 160, 40),
        // new BrightnessContrastPass(this),
        // new BlurPass(this),
        // new ToonPass(this),
        // new SobelPass(this),
    };

    size(900, 900, P2D);
    // fullScreen(P3D);
}

boolean toggle = true;
int current = 0;
void draw() {

    if (previousMousePosition == null) {
        previousMousePosition = new PVector(mouseX, mouseY);
    }

    mouseDistances.push(previousMousePosition.dist(new PVector(mouseX, mouseY)));
    if (mouseDistances.size() > 5) mouseDistances.remove(0);
    previousMousePosition = new PVector(mouseX, mouseY);

    float sum = 0;
    for (Float f : mouseDistances) {
        sum += f;
    }
    float avg = sum / mouseDistances.size();

    float smoothstep = map(frameCount % 1000, 0, 1000, 0, 1);
    if (smoothstep == 0) {
        toggle = !toggle;
        current++;

        println(current % photos.length);
        println((current + 1) % photos.length);
        println();
    }



    int s = 0;
    // if (smoothstep <= .2) s = minSize;
    if (smoothstep <= .5) s = round(map(smoothstep, .2, .5, minSize, maxSize));
    // else if (smoothstep >= .8) s = maxSize;
    else if (smoothstep >= .5) s = round(map(smoothstep, .5, .8, maxSize, minSize));
    s = min(max(s, minSize), maxSize);

    int amount = 0;
    if (smoothstep <= .5) amount = round(map(smoothstep, .2, .5, maxAmount, minAmount));
    else if (smoothstep >= .5) amount = round(map(smoothstep, .5, .8, minAmount, maxAmount));
    amount = min(max(amount, minAmount), maxAmount);

    int a = 0;
    if (smoothstep <= .5) a = round(map(smoothstep, 0, .5, maxAlpha, minAlpha));
    else if (smoothstep >= .5) a = round(map(smoothstep, .5, 1, minAlpha, maxAlpha));
    a = min(max(a, minAlpha), maxAlpha);

    for (int q = 0; q < amount; q++) {
        // int s = round(map(avg, 0, max(width, height), minSize, maxSize));
        // int s = round(minSize + random(maxSize - minSize));


        // int s = round(map(toggle ? smoothstep, 0, 1, minSize, maxSize));
        int xoff = round(map(random(1), 0, 1, -s, s));
        int yoff = round(map(random(1), 0, 1, -s, s));
        // int x = mouseX + xoff;
        // int y = mouseY + yoff;

        int x = round(s / 2 + random(width - s));
        int y = round(s / 2 + random(height - s));

        PImage photo1 = photos[current % photos.length];
        PImage photo2 = photos[(current + 1) % photos.length];

        PImage randomPhoto = random(1) >= smoothstep ? photo1 : photo2;

        // float r = 0;
        // float g = 0;
        // float b = 0;
        // int count = 0;
        // for (int i = x; i < x + s; i++) {
        //     for (int j = y; j < y + s; j++) {
        //         color c = randomPhoto.get(i, j);
        //         r += (255 - red(c) + map(noise(100 + frameCount / 10), 0, 1, 0, 100)) % 255;
        //         g += (255 - green(c) + map(noise(200 + frameCount / 10), 0, 1, 0, 100)) % 255;
        //         b += (255 - blue(c) + map(noise(300 + frameCount / 10), 0, 1, 0, 100)) % 255;
        //         count++;
        //     }
        // }
        // noStroke();
        // fill(color(r / count, g / count, b / count, 25));





        // float r = (255 - red(randomPhoto.get(x, y)) - map(noise(100 + frameCount / 100, x / 10, y / 10), 0, 1, 0, 255)) % 255;
        // float g = (255 - green(randomPhoto.get(x, y)) - map(noise(200 + frameCount / 100, x / 10, y / 10), 0, 1, 0, 255)) % 255;
        // float b = (255 - blue(randomPhoto.get(x, y)) - map(noise(300 + frameCount / 100, x / 10, y / 10), 0, 1, 0, 255)) % 255;
        float r = (50 + red(randomPhoto.get(x, y)) - map(noise(100 + fc / maxAmount + x / 10, 100 + fc / 100 + y / 10), 0, 1, 0, 255)) % 255;
        float g = (50 + green(randomPhoto.get(x, y)) - map(noise(200 + fc / maxAmount + x / 10, 200 + fc / 100 + y / 10), 0, 1, 0, 255)) % 255;
        float b = (50 + blue(randomPhoto.get(x, y)) - map(noise(300 + fc / maxAmount + x / 10, 300 + fc / 100 + y / 10), 0, 1, 0, 255)) % 255;
        noStroke();
        fill(color(r, g, b, a));


        // rect(x, y, s, s);
        circle(x, y, s);
        
        fc++;
    }







    




    // for (int q = 0; q < 100; q++) {
    //     float sizeMultiplier = max(map(frameCount, 0, min(width, height), 1, 0), 0);
    //     int w = round(map(random(1), 0, 1, minSize, minSize + maxSize * sizeMultiplier));
    //     int h = round(map(random(1), 0, 1, minSize, minSize + maxSize * sizeMultiplier));
    //     int x = round(random(width - w));
    //     int y = round(random(height - h));

    //     float r = 0;
    //     float g = 0;
    //     float b = 0;
    //     int count = 0;
    //     for (int i = x; i < x + w; i++) {
    //         for (int j = y; j < y + h; j++) {
    //             color c = photo.get(i, j);
    //             r += red(c);
    //             g += green(c);
    //             b += blue(c);
    //             count++;
    //         }
    //     }
    //     noStroke();
    //     fill(color(r / count, g / count, b / count));

    //     rect(x, y, w, h);
    // }

    
    supervisor.render();
    for (Pass pass : passes) {
        supervisor.pass(pass);
    }
    supervisor.compose();
}