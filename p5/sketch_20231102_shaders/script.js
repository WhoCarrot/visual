let exampleShader;

function preload() {
    exampleShader = loadShader('example.vert', 'example.frag');
}

function setup() {
    createCanvas(windowWidth, windowHeight, WEBGL);

    shader(exampleShader);
}

function draw() {
    // background(20);
    clear();

    ellipse(0, 0, width, height, 160);
}

function windowResized() {
    resizeCanvas(windowWidth, windowHeight, true);
}
