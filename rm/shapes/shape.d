module rm.shapes.shape;

import std.typecons : Tuple;

import geom;
import rm.base.material;

abstract class Shape
{
  const(Material) mat;

  this(const(Material) mat)
  {
    this.mat = mat;
  }

  abstract float getDistance(Vec3 point);

  /// Returns best normalized normal to shape in given point
  /// may assume, that point is on the surface
  Vec3 getNorm(Vec3 point)
  {
    Vec3 n = Vec3(
      getDistance(point + Vec3(SMALL_VALUE, 0, 0)) - getDistance(point + Vec3(-SMALL_VALUE, 0, 0)),
      getDistance(point + Vec3(0, SMALL_VALUE, 0)) - getDistance(point + Vec3(0, -SMALL_VALUE, 0)),
      getDistance(point + Vec3(0, 0, SMALL_VALUE)) - getDistance(point + Vec3(0, 0, -SMALL_VALUE)),
    );
    return n.norm();
  }
}
