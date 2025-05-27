class Particle {
    PVector loc;
    PVector vel;
    PVector acc;
    float lifespan;
    
    Particle(PVector l) {
        acc = new PVector(0, 0);
        float vx = randomGaussian() * 0.3;
        float vy = randomGaussian() * 0.3;
        vel = new PVector(vx, vy);
        loc = l.copy();
        lifespan = map(random(1), 0, 1, 25, 300);
    }
    
    void run() {
        update();
        render();
    }
    
    //Methodto apply a force vector to the Particle object
    //Note we are ignoring "mass" here
    void applyForce(PVector f) {
        acc.add(f);
    }  
    
    //Method to update position
    void update() {
        vel.add(acc);
        loc.add(vel);
        lifespan -= 2.5;
        acc.mult(0);// clear Acceleration
    }
    
    //Method to display
    void render() {
        fill(255);
        stroke(255);
        point(loc.x, loc.y);
        // tint(255, lifespan);
        // image(img, loc.x, loc.y);
        // Drawing a circle instead
        // fill(255,lifespan);
        // noStroke();
        // ellipse(loc.x,loc.y,img.width,img.height);
    }
    
    // Is the particle still useful?
    boolean isDead() {
        if (lifespan <= 0.0) {
            return true;
        } else {
            return false;
        }
    }
}