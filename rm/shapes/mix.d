module rm.shapes.mix;

import std.math;
import std.array;
import std.algorithm;

import rm;
import geom;

class MixedShape : Shape
{
  Shape[] shapes;
  private
  {
    enum k = 3.0f;
  }

  this(Shape[] shapes, Material mat)
  {
    super(mat);
    this.shapes = shapes;
  }

  override float getDistance(Vec3 point)
  {
    assert(false, "Not implemented yet.");
  }
}
