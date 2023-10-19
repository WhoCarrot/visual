import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

ParticleSystem ps;

PostFXSupervisor postFXSupervisor;
Pass[] postFXPasses;

void setup() {
    size(640, 360, P3D);
    ps = new ParticleSystem(0, new PVector(width / 2, height / 2));
    
    
    postFXSupervisor = new PostFXSupervisor(this);
    postFXPasses = new Pass[] {
        // new SobelPass(this),
        new ChromaticAberrationPass(this),
            new BloomPass(this, 0.2, 20, 120),
            // new PixelatePass(this, 100f),
            // new BrightPass(this, 0.3f),
            new VignettePass(this,.8,.3),
        };
}

void draw() {
    background(0);
    
    //Calculate a "wind" force based on mouse horizontal position
    float dx = map(mouseX, 0, width, -0.2, 0.2);
    float dy = map(mouseY, 0, height, -0.2, 0.2);
    PVector wind = new PVector(dx, dy);
    ps.applyForce(wind);
    ps.run();
    for (int i = 0; i < 2; i++) {
        ps.addParticle();
    }
    
    postFXSupervisor.render();
    for (Pass pass : postFXPasses) {
        postFXSupervisor.pass(pass);
    }
    postFXSupervisor.compose();
}
