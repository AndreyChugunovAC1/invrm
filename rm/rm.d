module rm.rm;

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
  in
  {
    assert(abs(dir.len2 - 1.0f) < EPSILON);
  }
  body
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

    version (none)
    {
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
    }

    // reflection:
    if (sh.mat.rflk != 0.0f) // here it means explicit zero
    {
      Vec3 reflected = 2 * n * n.dot(toUser) - toUser; // automatically normalized
      color += sh.mat.rflk * traceRay(curPoint + SMALL_VALUE * reflected, reflected, depth + 1);
    }

    return color.clamp();
  }

  private
  {
    Vec3 computeColorInner(float x, float y)
    {
      float xr = user.height * (x - cast(float) width / 2) / width;
      float yr = user.height * (cast(float) height / 2 - y) / width; // yes, width
      Vec3 dir = user.dir * user.dist + user.right * xr + user.up * yr;

      return traceRay(user.pos + dir, dir.norm());
    }
  }

  Vec3 computeColor(size_t xScreen, size_t yScreen)
  {
    float x = xScreen;
    float y = yScreen;

    //dfmt off
    // regular grid with 4 points per scren pixel:
    return 0.25 * (
      computeColorInner(x + 0.25f, y + 0.25f) +
      computeColorInner(x + 0.25f, y + 0.75f) +
      computeColorInner(x + 0.75f, y + 0.25f) +
      computeColorInner(x + 0.75f, y + 0.75f)
    );
    //dfmt on
  }
}

Scene defaultScene()
{
  import rm;

  auto mat = new immutable Material(
    Vec3(0.05, 0.06, 0.15),
    Vec3(0.05, 0.06, 0.15),
    Vec3(0.05, 0.06, 0.15),
    0.9
  );
  auto mat2 = new immutable Material(
    Vec3(0.04, 0.01, 0.01),
    Vec3(0.5, 0.1, 0.1),
    Vec3(0.5, 0.1, 0.1),
    0.9
  );
  auto mat3 = new immutable Material(
    Vec3(0.04, 0.08, 0.06),
    Vec3(0.1, 0.7, 0.1),
    Vec3(0.3, 0.8, 0.1),
    0.9
  );

  //dfmt off
  return new Scene(
    [
      new Sphere(Vec3(20, 0, 20), 2.5, mat),
      new Sphere(Vec3(10, 0, 20), 2.5, mat),
      new Sphere(Vec3(20, 0, 10), 2.5, mat),
      new Thor(Vec3(20, 5, 20), Vec3(0, 1, 0), 5, 1, mat2),
      new Thor(Vec3(20, -5, 20), Vec3(0, 1, 0), 10, 1, mat3),
    ],
    [
      new Light(Vec3(15, 20, 0), Vec3(1, 0.1, 0.1), Vec3(1, 0.1, 0.1)),
      new Light(Vec3(0, -10, 20), Vec3(0.5, 0.4, 0.8), Vec3(1, 0.6, 0.8))
    ],
    Vec3(0.03, 0.042, 0.08));
  //dfmt on
}
