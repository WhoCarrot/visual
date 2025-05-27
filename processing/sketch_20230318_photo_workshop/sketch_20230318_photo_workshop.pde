import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

PostFXSupervisor supervisor;
Pass[] passes;


String photos[] = new String[] {
    "01.jpg",
    "02.png",
    "03.png",
    "04 (1).jpg",
    "05.jpg",
    "06.jpg",
    "07.jpg",
    "08.png",
    "09.png",
    "10.jpeg"
};
PImage backgroundPhoto;
PImage photo;

boolean toggle = true;
int value;

void setup() {



    // colorMode(HSB, 255);
    size(2560 / 2, 1440, P2D);
    surface.setLocation(2560 / 2, 0);
    // imageMode(CENTER);


    supervisor = new PostFXSupervisor(this);
    passes = new Pass[] {
        // new PixelatePass(this, 400),
        // new SobelPass(this),
        new ChromaticAberrationPass(this),
        // new BloomPass(this, 0.2, 120, 40),

    };

    backgroundPhoto = loadImage(photos[2]);
    backgroundPhoto.resize(min(width, height), 0);

    photo = loadImage(photos[3]);
    photo.resize(round(min(width, height) / 3), 0);


    // imageMode(CENTER);

    // photo2.resize(200, 0);


    // saveFrame("output/image.png");
}

void draw() {
    // translate(0, 0, 0);
    background(200);
    // blendMode(BLEND);
    // fill(60);

    // image(photo1, photo1.width / 2, photo1.height / 2);
    // tint(255, 255);
    // image(photo1, width / 2 - photo1.width / 2, height / 2 - photo1.height / 2);
    // if (frameCount % 255 == 0) {
    //     toggle = !toggle;
    // }

    // value = toggle ? frameCount % 255 : 255 - frameCount % 255;
    value = frameCount;

    // tint(value, 255);
    tint(255, 255);
    image(backgroundPhoto, 0, 0);

    // tint(255, 100);
    // pushMatrix();

    PImage newPhoto = makeTransparent(photo, 150);
    // rotate(frameCount / 100);
    // rotate(value);
    blend(
        newPhoto,
        0, 0, newPhoto.width, newPhoto.height,
        0, 0, backgroundPhoto.width, backgroundPhoto.height,
        DARKEST
    );
    // popMatrix();
    // tint(255, 150);
    // image(newPhoto, width / 2 - newPhoto.width / 2, height / 2 - newPhoto.height / 2);
    
    // pushMatrix();
    // translate(0, 0);
    // rotate(value / 100);
    // image(newPhoto, width / 2, height / 2, width, height);
    // popMatrix();


    supervisor.render();
    for (Pass pass : passes) {
        supervisor.pass(pass);
    }
    supervisor.compose();
}

PImage makeTransparent(PImage image, int threshold) {
    // image.loadPixels();
    PImage newImage = createImage(image.width, image.height, ARGB);
    for (int x = 0; x < image.width; x++) {
        for (int y = 0; y < image.width; y++) {
            color c = image.get(x, y);
            if (brightness(c) >= threshold) {
                newImage.set(x, y, color(255, 255, 255, 0));
            } else {
                int sens = 30;
                float xmod = map(x, 0, image.width, 0, sens);
                float ymod = map(y, 0, image.height, 0, sens);
                float valuemod = map(value, 0, 255, 0, sens);
                float rNoise = map(noise(sens * 0 + xmod + valuemod, sens * 0 + ymod + valuemod), 0, 1, 0, 255);
                float gNoise = map(noise(sens * 1 + xmod + valuemod, sens * 1 + ymod + valuemod), 0, 1, 0, 255);
                float bNoise = map(noise(sens * 2 + xmod + valuemod, sens * 2 + ymod + valuemod), 0, 1, 0, 255);
                float r = red(c) + rNoise % 255;
                float g = green(c) + gNoise % 255;
                float b = blue(c) + bNoise % 255;
                float d = dist(image.width / 2, image.height / 2, x, y);
                float a = map(d, 0, dist(image.width / 2, image.height / 2, 0, 0), 255, -255);
                color newColor = color(r, g, b, a);
                newImage.set(x, y, newColor);
            }
        }
    }
    return newImage;




    // final color colors[] = image.pixels;
    // for (int i = 0; i < colors.length; i++) {
    //     final color c = colors[i];
    //     if (brightness(c) >= threshold) {
    //         println(alpha(c));

    //         colors[i] = color(0, 0, 0, 0);
    //         println(alpha(c));
    //         println(" ");
    //     }
    // }
    // // image.updatePixels();
    // return image;
}