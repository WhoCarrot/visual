new p5((p5) => {
    const particles = [];

    p5.setup = () => {
        p5.createCanvas(p5.windowWidth, p5.windowHeight);

        particles.push(
            new Particle(
                p5,
                p5.windowWidth / 2,
                p5.windowHeight / 2,
                3,
                p5.color(255, 0, 0)
            )
        );
    };

    p5.draw = () => {
        p5.background(20);

        for (const particle of particles) {
            particle.applyForce(
                particle.seek(p5.createVector(p5.mouseX, p5.mouseY))
            );
            particle.update();
            particle.draw();
        }
    };

    p5.windowResized = () => {
        p5.resizeCanvas(p5.windowWidth, p5.windowHeight, true);
    };
});
