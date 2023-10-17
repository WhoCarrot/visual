
#define M_PI 3.1415926535897932384626433832795

float ndot(vec2 a, vec2 b) { return a.x * b.x - a.y * b.y; }
float sdRhombus(in vec2 p, in vec2 b) {
  p = abs(p);
  float h = clamp(ndot(b - 2.0 * p, b) / dot(b, b), -1.0, 1.0);
  float d = length(p - 0.5 * b * vec2(1.0 - h, 1.0 + h));
  return d * sign(p.x * b.y + p.y * b.x - b.x * b.y);
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

float sdPentagon(in vec2 p, in float r) {
  const vec3 k = vec3(0.809016994, 0.587785252, 0.726542528);
  p.x = abs(p.x);
  p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
  p -= 2.0 * min(dot(vec2(k.x, k.y), p), 0.0) * vec2(k.x, k.y);
  p -= vec2(clamp(p.x, -r * k.z, r * k.z), r);
  return length(p) * sign(p.y);
}

float sdHexagon(in vec2 p, in float r) {
  const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
  p = abs(p);
  p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
  p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
  return length(p) * sign(p.y);
}

float sdHexagram(in vec2 p, in float r) {
  const vec4 k = vec4(-0.5, 0.86602540378, 0.57735026919, 1.73205080757);

  p = abs(p);
  p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
  p -= 2.0 * min(dot(k.yx, p), 0.0) * k.yx;
  p -= vec2(clamp(p.x, r * k.z, r * k.w), r);
  return length(p) * sign(p.y);
}

float sdOctogon(in vec2 p, in float r) {
  const vec3 k = vec3(-0.9238795325, 0.3826834323, 0.4142135623);
  p = abs(p);
  p -= 2.0 * min(dot(vec2(k.x, k.y), p), 0.0) * vec2(k.x, k.y);
  p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
  p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
  return length(p) * sign(p.y);
}

float dot2(in vec2 v) { return dot(v, v); }
float sdRoundedCross(in vec2 p, in float h) {
  float k = 0.5 * (h + 1.0 / h); // k should be const at modeling time
  p = abs(p);
  return (p.x < 1.0 && p.y < p.x * (k - h) + h)
             ? k - sqrt(dot2(p - vec2(1, k)))
             : sqrt(min(dot2(p - vec2(0, h)), dot2(p - vec2(1, 0))));
}

vec2 rotateUVmatrix(vec2 uv, vec2 pivot, float rotation) {
  mat2 rotation_matrix = mat2(vec2(sin(rotation), -cos(rotation)),
                              vec2(cos(rotation), sin(rotation)));
  uv -= pivot;
  uv = uv * rotation_matrix;
  uv += pivot;
  return uv;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);
  // uv *= sin(iTime * .25) * .2;
  // uv *= .0005;
  // uv *= .5;
  uv *= 1.5;
  // uv = rotateUVmatrix(uv, vec2(0.5), M_PI / 4.0);
  vec2 ra = 0.4 + 0.3 * cos(iTime + vec2(0.0, 1.57) + 0.0);
  // vec2 ra = cos(iTime + vec2(0.0, 8.));

  for (float i = 0.0; i < 4.; i++) {
    uv = fract(uv * 1.4) - 0.5;

    vec3 col = palette(length(uv0) + iTime * .8);

    // float d = sdRhombus(uv, ra * i * .3) * exp(-length(uv0)) + i;
    // ra += i * .01;

    float d = sdOctogon(uv, 1. + i * .5) * exp(-length(uv0)) + 1.;

    // sdHexagon(uv, 2.0) * sin(iTime*.1) +
    // sdHexagon(uv, 2.0) * sin(iTime*.33) * 2. -
    //  sdOctogon(uv, 0.1) * cos(iTime * .1))

    d = sin(d * 8. + iTime * .4) / 1.;
    // d = abs(d);
    d = pow(0.06 / d, 1.6);

    finalColor += col * d;
  }

  fragColor = vec4(finalColor, 1.0);
}