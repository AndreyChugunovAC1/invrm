module rm.shapes.plane;

import geom;
import rm;

class Plane : Shape
{
  Vec3 n;
  float coordOnN;

  this(Vec3 pos, Vec3 n, const(Material) mat)
  {
    super(mat);
    this.n = n.norm();
    this.coordOnN = this.n.dot(pos);
  }

  /// coordOnN is an absolute value, i.e.
  /// point "norm(n) * coordOnN" is on plane,
  /// but "n * coordOnN" might be not
  this(float coordOnN, Vec3 n, Material mat)
  {
    super(mat);
    this.n = n.norm();
    this.coordOnN = coordOnN;
  }

  override float getDistance(Vec3 point)
  {
    return point.dot(n) - coordOnN;
  }

  override Vec3 getNorm(Vec3 _)
  {
    return n;
  }
}
