module rm.base.rm;

import std.math : abs, pow;
import std.typecons : Nullable, nullable;

import geom;
import rm.base.user;
import rm.base.scene;
import rm.shapes.shape;

class Rm
{
  private
  {
    User user;
    Scene scene;
    size_t width = 100;
    size_t height = 100;
    uint recLimit = 3;
  }

  this(User user, Scene scene)
  {
    this.user = user;
    this.scene = scene;
  }

  Rm setRecLimit(uint limit)
  {
    recLimit = limit;
    return this;
  }

  Rm setWidthHeight(size_t width, size_t height)
  {
    this.width = width;
    this.height = height;
    return this;
  }

  /// dir must be normalized before the function call
  /// for optimization purposes
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

  /// dir must be normalized before the function call
  /// for optimization purposes
  Vec3 traceRay(Vec3 start, Vec3 dir, uint depth = 0)
  {
    if (depth >= recLimit)
    {
      return scene.fontColor;
    }

    auto intersection = moveToNextIntersection(start, dir);

    if (intersection.isNull)
    {
      return scene.fontColor;
    }

    Vec3 curPoint = intersection.get;
    Shape sh = scene.getNearest(curPoint);
    Vec3 n = sh.getNorm(curPoint);

    // no lights color:
    Vec3 color = sh.mat.ka * scene.illa;

    // lights:
    Vec3 toUser = (user.pos - curPoint).norm();

    foreach (light; scene.lights)
    {
      Vec3 toLighting = (light.pos - curPoint).norm();

      // TODO: smooth shadows
      bool isNotShadowed = moveToNextIntersection(curPoint + toLighting * SMALL_VALUE, toLighting)
        .isNull;

      if (isNotShadowed)
      {
        Vec3 reflected = 2 * n * n.dot(toLighting) - toLighting; // automatically normalized

        color += (sh.mat.kd * toLighting.dot(n) * light.illd).clamp();
        color += (sh.mat.ks * pow(toUser.dot(reflected), sh.mat.alpha) * light.ills).clamp();
      }
    }

    // reflection:
    if (sh.mat.rflk == 0.0f)
    {
      Vec3 reflected = 2 * n * n.dot(toUser) - toUser; // automatically normalized
      color += sh.mat.rflk * traceRay(curPoint + SMALL_VALUE * reflected, reflected, depth + 1);
    }

    return color.clamp();
  }

  Vec3 computeColor(size_t x, size_t y)
  {
    float xr = user.height * (x - cast(float) width / 2) / width;
    float yr = user.height * (cast(float) height / 2 - y) / width; // width here is needed
    Vec3 dir = user.dir * user.dist + user.right * xr + user.up * yr;

    return traceRay(user.pos + dir, dir.norm());
  }
}
