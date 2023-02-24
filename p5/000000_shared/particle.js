class Particle {
    constructor(
        p5,
        x,
        y,
        r,
        c,
        { maxVelocity = 3, maxAcceleration = 0.05 } = {}
    ) {
        this.p5 = p5;
        this.position = this.p5.createVector(x, y);
        this.velocity = this.p5.createVector(0, 0);
        this.acceleration = this.p5.createVector(0, 0);
        this.r = r;
        this.c = c;
        this.maxVelocity = maxVelocity;
        this.maxAcceleration = maxAcceleration;
    }

    seek(target) {
        const desired = p5.Vector.sub(target, this.position);
        desired.normalize();
        desired.mult(this.maxVelocity);
        const steer = p5.Vector.sub(desired, this.velocity);
        steer.limit(this.maxAcceleration);
        return steer;
    }

    applyForce(force) {
        this.acceleration.add(force);
        this.acceleration.limit(this.maxAcceleration);
    }

    update() {
        this.velocity.add(this.acceleration);
        this.velocity.limit(this.maxVelocity);
        this.acceleration.mult(0);
        this.position.add(this.velocity);
    }

    draw() {
        this.p5.push();
        this.p5.strokeWeight(this.r);
        this.p5.stroke(this.c);
        this.p5.noFill();
        this.p5.ellipse(this.position.x, this.position.y, this.r, this.r);
        this.p5.pop();
    }
}
