precision mediump float;

varying vec2 pos;

void main() {
    vec4 c1 = vec4(.5, .1, .9, 1.);
    vec4 c2 = vec4(.1, .8, .7, 1.);
    vec4 c = mix(c1, c2, pos.x);

    gl_FragColor = c;
}