class Particle {
    constructor(
        x,
        y,
        r,
        color,
        { minSpeed = 0, maxSpeed = 1, maxForce = 0.05 } = {}
    ) {
        this.position = new THREE.Vector2(x, y);
        this.velocity = new THREE.Vector2(0, 0);
        this.acceleration = new THREE.Vector2(0, 0);
        this.minSpeed = minSpeed;
        this.maxSpeed = maxSpeed;
        this.maxForce = maxForce;
        this.r = r;
        this.color = color;

        const geometry = new THREE.CircleGeometry(r, 32);
        const material = new THREE.MeshBasicMaterial({ color });
        this.mesh = new THREE.Mesh(geometry, material);
    }

    follow(position) {
        const steer = this.seek(position);
        this.acceleration = steer;
    }

    update() {
        this.velocity.add(this.acceleration);
        this.acceleration.multiplyScalar(0);
        this.velocity.clampScalar(this.minSpeed, this.maxSpeed);
        this.position.add(this.velocity);

        this.mesh.position.x = this.position.x;
        this.mesh.position.y = this.position.y;
    }

    seek(target) {
        const desired = new THREE.Vector2();
        desired.subVectors(target, this.position);
        desired.normalize();
        desired.multiplyScalar(this.maxSpeed);
        const steer = desired.sub(this.velocity);
        steer.clampScalar(0, this.maxForce);
        return steer;
    }

    display() {}
}
