class Particle {
    color c;
    int r;
    float maxSpeed = 3;
    PVector position;
    PVector velocity;
    PVector acceleration;

    public Particle(x, y, c) {
        this.c = c;
        this.position = new PVector(x, y);
    }

    public void Update() {
        this.velocity.add(this.acceleration);
        this.acceleration.mult(0);
        this.velocity.limit(this.maxSpeed);
        this.position.add(this.velocity);
    }

    public void CalculateForce(Particle other, float gravity) {
        int distance = this.position.dist(other.position);
    }
}