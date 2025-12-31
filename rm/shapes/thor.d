module rm.shapes.thor;

import geom;
import rm;

class Thor : Shape
{
  Vec3 center, n;
  float rBig, rSmall;

  this(Vec3 center, Vec3 n, float rBig, float rSmall, const(Material) mat)
  {
    super(mat);
    this.center = center;
    this.n = n;
    this.rBig = rBig;
    this.rSmall = rSmall;
  }

  override float getDistance(Vec3 point)
  {
    Vec3 a = point - center;
    Vec3 b = n.cross(a.cross(n));

    if (b.isZero)
    {
      import std.math : sqrt;
      return sqrt(a.len2() + rBig ^^ 2) - rSmall;
    }

    return (center + b.norm() * rBig - point).len() - rSmall;
  }

  override Vec3 getNorm(Vec3 point)
  {
    Vec3 a = point - center;
    Vec3 b = n.cross(a.cross(n));

    // assuming point is on surface - no corner cases:
    Vec3 c = center + b.norm() * rBig;
    return (point - c).norm();
  }
}
