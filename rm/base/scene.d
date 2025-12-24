module rm.base.scene;

import std.algorithm : map, fold, min;

import geom;
import rm.shapes.shape;
import rm.base.lighting;

struct Scene
{
  Shape[] shapes;
  Light[] lights;
  Vec3 fontColor;
  Vec3 illa;

  this(Shape[] shapes, Light[] lights, Vec3 fontColor = Vec3.zero, Vec3 illa = Vec3(1))
  {
    this.shapes = shapes;
    this.lights = lights;
    this.fontColor = fontColor;
    this.illa = illa;
  }

  float getDistance(Vec3 point)
  {
    return shapes
      .map!(s => s.getDistance(point))
      .fold!min;
  }

  Shape getNearest(Vec3 point)
  {
    float mind = float.max;
    Shape cur = null;

    foreach (sh; shapes)
    {
      float dist = sh.getDistance(point);

      if (dist < mind) {
        mind = dist;
        cur = sh;
      }
    }
    return cur;
  }
}
