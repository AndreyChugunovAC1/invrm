module rm.shapes.circle;

import geom;
import rm;

class Circle : Shape
{
  Vec3 center;
  float radius;

  this(Vec3 center, float radius, Material mat)
  {
    super(mat);
    this.center = center;
    this.radius = radius;
  }

  override float getDistance(Vec3 point) const
  {
    return (point - center).len() - radius;
  }
}
