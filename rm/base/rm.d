module rm.base.rm;

import std.math : abs, pow;

import geom;
import rm.base.user;
import rm.base.scene;
import rm.shapes.shape;

class Rm
{
  User user;
  Scene scene;
  size_t width;
  size_t height;

  this(size_t width, size_t height, User user, Scene scene)
  {
    this.user = user;
    this.scene = scene;
    this.width = width;
    this.height = height;
  }

  import std.typecons : Nullable, nullable;

  /// dir must be normalized for optimization purposes
  Nullable!Vec3 moveToNextIntersection(Vec3 curPoint, Vec3 dir)
  {
    float d = void;

    for (;;)
    {
      d = scene.getDistance(curPoint);
      if (d > BIG_VALUE)
      {
        return Nullable!Vec3.init;
      }
      if (abs(d) < EPSILON)
      {
        return nullable(curPoint);
      }
      curPoint += dir * d;
    }
  }

  Vec3 traceRay(Vec3 start, Vec3 dir, int depth = 0)
  {
    if (depth >= 5) // TODO: magic number
    {
      return scene.fontColor;
    }

    dir.normMe();
    auto intersection = moveToNextIntersection(start, dir);

    if (intersection.isNull)
    {
      return scene.fontColor;
    }

    Vec3 curPoint = intersection.get;
    Shape sh = scene.getNearest(curPoint);
    Vec3 n = sh.getNorm(curPoint);

    Vec3 color = sh.mat.ka * scene.illa;
    foreach (light; scene.lights)
    {
      Vec3 toLighting = (light.pos - curPoint).norm();

      // TODO: smooth shadows
      bool isNotShadowed = moveToNextIntersection(curPoint + toLighting * SMALL_VALUE, toLighting).isNull;

      if (isNotShadowed)
      {
        Vec3 toUser = (user.pos - curPoint).norm();
        Vec3 reflected = 2 * n * n.dot(toLighting) - toLighting;

        color += (sh.mat.kd * toLighting.dot(n) * light.illd).clamp();
        color += (sh.mat.ks * pow(toUser.dot(reflected), sh.mat.alpha) * light.ills).clamp();
      }

      
    }
    return color.clamp();
  }

  Vec3 computeColor(size_t x, size_t y)
  {
    float xr = user.height * (x - cast(float) width / 2) / width;
    float yr = user.height * (cast(float) height / 2 - y) / width; // width here is needed
    Vec3 dir = user.dir * user.dist + user.right * xr + user.up * yr;

    return traceRay(user.pos + dir, dir);
  }
}
