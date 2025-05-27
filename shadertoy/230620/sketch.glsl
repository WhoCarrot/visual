
#define M_PI 3.1415926535897932384626433832795

vec3 palette(float t) {
  //[[0.426 0.335 0.062] [0.733 0.296 0.481] [0.517 1.175 0.041]
  //[5.378 3.117 2.848]]

  vec3 v[4] = vec3[](vec3(0.426, 0.335, 0.062), vec3(0.733, 0.296, 0.481),
                     vec3(0.517, 1.175, 0.041), vec3(5.378, 3.117, 2.848));

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

float sdOctogon(in vec2 p, in float r) {
  const vec3 k = vec3(-0.9238795325, 0.3826834323, 0.4142135623);
  p = abs(p);
  p -= 2.0 * min(dot(vec2(k.x, k.y), p), 0.0) * vec2(k.x, k.y);
  p -= 2.0 * min(dot(vec2(-k.x, k.y), p), 0.0) * vec2(-k.x, k.y);
  p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
  return length(p) * sign(p.y);
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

  for (float i = 0.0; i < 16.; i++) {
    vec3 col = palette(length(uv) + i * .1);

    uv = fract(uv * 1.05) - 0.5;
    float d = length(uv) * exp(-length(uv0)) + i * .2;
    d = sin(d * 4. + iTime * .2) / 4.;
    d = abs(d);
    d = pow(0.0004 / d, 1.2);

    // finalColor += col * d;
    finalColor += col * d;
  }
  // uv *= 2.;

  // // uv = rotateUVmatrix(uv, vec2(0.5), M_PI/4.0);

  // for (float i = 0.0; i < 4.0; i++) {

  //   // uv = fract(uv * 1.1) - 0.5;

  //   vec3 col = palette(length(uv0) + i * .8 + iTime * .8);

  //   float d = (smoothstep(.1, .2, sdPentagon(uv, 1.) * sin(iTime)) +
  //              (smoothstep(.1, .2, sdOctogon(uv, 1.) * cos(iTime))) *
  //                  exp(-length(uv0)));

  //   d = sin(d * 8. + iTime) / 8.;
  //   d = abs(d);
  //   d = pow(0.02 / d, 2.);

  //   finalColor += col * d;
  // }

  fragColor = vec4(finalColor, 1.0);
}