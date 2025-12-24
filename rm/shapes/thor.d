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
    Vec3 b = n.cross(a.cross(n)).norm(); // TODO corner case with cross

    return ((pos + b * rBig) - point).len() - rSmall;
  }
}
