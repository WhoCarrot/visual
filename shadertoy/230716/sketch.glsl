void mainImage(out vec4 f, in vec2 p) {
  float n = 0.;
  vec2 c = vec2(-.745, .186) + 3. * (p.xy / iResolution.y - .5) *
                                   pow(.01, 1. + cos(.2 * iGlobalTime)),
       z = c * n;

  for (int i = 0; i < 128; i++) {
    z = vec2(z.x * z.x - z.y * z.y, 2. * z.x * z.y) + c;

    if (dot(z, z) > 1e4)
      break;

    n++;
  }

  f = .5 + .5 * cos(vec4(3, 4, 11, 0) + .05 * (n - log2(log2(dot(z, z)))));
}