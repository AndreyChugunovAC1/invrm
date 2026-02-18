module geom.random;

import std.random;
import std.math;

T genNormal(T = float)(T expected, T deviation, ref Random rnd)
{
  auto u1 = uniform!"(]"(0.0, 1.0, rnd);
  auto u2 = uniform!"[)"(0.0, 2.0 * PI, rnd);

  return expected + deviation * sqrt(-2.0 * log(u1)) * cos(u2);
}
