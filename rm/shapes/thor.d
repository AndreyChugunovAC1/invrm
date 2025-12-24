module rm.shapes.thor;

import geom;
import rm;

class Thor : Shape
{
  Vec3 pos, n;
  float rBig, rSmall;

  this(Vec3 pos, Vec3 n, float rBig, float rSmall, Material mat)
  {
    super(mat);
    this.pos = pos;
    this.n = n;
    this.rBig = rBig;
    this.rSmall = rSmall;
  }

  override float getDistance(Vec3 point)
  {
    Vec3 a = point - pos;
    Vec3 b = n.cross(a.cross(n));

    if (b.len2() <= Vec3.min_square_length)
    {
      import std.math : sqrt;
      return sqrt(a.len2() + rBig ^^ 2) - rSmall;
    }

    return (pos + b.norm() * rBig - point).len() - rSmall;
  }

  override Vec3 getNorm(Vec3 point)
  {
    Vec3 a = point - pos;
    Vec3 b = n.cross(a.cross(n));

    // assuming point is on surface - no corner cases:
    Vec3 c = pos + b.norm() * rBig;
    return (point - c).norm();
  }
}
