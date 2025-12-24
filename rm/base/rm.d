module rm.base.rm;

import std.math : abs;

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

  enum epsilon = 1.0e-4f;
  enum limit = 1.0e+9f;

  this(size_t width, size_t height, User user, Scene scene)
  {
    this.user = user;
    this.scene = scene;
    this.width = width;
    this.height = height;
  }

  Vec3 computeColor(size_t x, size_t y)
  {
    float xr = user.height * (x - cast(float) width / 2) / width;
    float yr = user.height * (cast(float) height / 2 - y) / width; // width here is needed
    Vec3 dir = user.dir * user.dist + user.right * xr + user.up * yr;
    Vec3 curPoint = user.pos + dir;
    float d = void;

    dir.normMe();
    do
    {
      d = scene.getDistance(curPoint);
      curPoint += dir * d;
    }
    while (abs(d) > epsilon && d < limit);

    if (d > limit)
    {
      return scene.fontColor;
    }
    else
    {
      Shape sh = scene.getNearest(curPoint);
      Vec3 n = sh.getNorm(curPoint);

      Vec3 color = sh.mat.ka * scene.illa;
      foreach (light; scene.lights)
      {
        Vec3 toLighting = (light.pos - curPoint).norm();
        Vec3 toUser = (user.pos - curPoint).norm();
        Vec3 reflected = 2 * n * n.dot(toLighting) - toLighting;

        import std.math;

        color += (sh.mat.kd * toLighting.dot(n) * light.illd).clamp();
        color += (sh.mat.ks * pow(toUser.dot(reflected), sh.mat.alpha) * light.ills).clamp();
      }
      return color;
    }
  }
}
