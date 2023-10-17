#define NUM_LAYERS 10.

mat2 rotate(float a) {
  float s = sin(a), c = cos(a);
  return mat2(c, -s, s, c);
}

vec3 palette(float t) {
  vec3 v[4] = vec3[](vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5),
                     vec3(1.0, 1.0, 1.0), vec3(4.735, 4.005, 4.540));

  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.263, 0.416, 0.557);

  return v[0] + v[1] * cos(6.28318 * (v[2] * t + v[3]));
}

float random(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float star(vec2 uv, float flare) {
  float d = length(uv);
  float m = .03 / d;

  float rays = max(0., 1. - abs(uv.x * uv.y * 1000.));
  m += rays * flare;

  uv *= rotate(3.1415 / 4.);

  rays = max(0., 1. - abs(uv.x * uv.y * 1000.));
  m += rays * .3 * flare;

  m *= smoothstep(1., .05, d);

  return m;
}

vec3 starLayer(vec2 uv) {

  vec3 col = vec3(0);

  vec2 gv = fract(uv) - 0.5;
  vec2 id = floor(uv);

  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 offset = vec2(x, y);

      float n = random(id + offset);
      float size = fract(n * 563.32);

      float s = star(gv - offset - vec2(n, fract(n * 23.)) + .5,
                     smoothstep(.9, 1., size));

      s *= sin(iTime * 3. + n * 6.2831) * .5 + 1.;

      col += s * size * palette(fract(n * 123.432) * iTime * .5) *
             vec3(1., .2, 1.);
    }
  }

  return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;
  float t = iTime * .04;

  uv *= rotate(t);
  vec3 col = vec3(0.);

  for (float i = 0.; i <= 1.; i += 1. / NUM_LAYERS) {
    float depth = fract(i + t);
    float scale = mix(20., .5, depth);

    float fade = depth * smoothstep(1., .9, depth);

    col += starLayer(uv * scale + i * 2342.123) * fade;
  }

  fragColor = vec4(col, 1.0);
}