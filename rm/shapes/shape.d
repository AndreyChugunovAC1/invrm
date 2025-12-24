module rm.shapes.shape;

import std.typecons : Tuple;

import geom;
import rm.base.material;

abstract class Shape
{
  Material mat;

  this(Material mat)
  {
    this.mat = mat;
  }

  abstract float getDistance(Vec3 point);
}
