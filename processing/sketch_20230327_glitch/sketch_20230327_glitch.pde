
import java.util.*;

PImage image;

void setup() {
    // PImage image = loadImage("input.png");
    byte bytes[] = loadBytes("input.png");

    for (int i = 167; i < bytes.length; i++) {
        if (random(1) > .0001) continue;

        byte randomBytes[] = new byte[1];
        new Random().nextBytes(randomBytes);
        bytes[i] = randomBytes[0];
    }

    saveBytes("data/output.png", bytes);

    image = loadImage("output.png");

    size(1024, 1024, P2D);
}

void draw() {



    image(image, 0, 0);
}