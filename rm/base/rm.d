module rm.base.rm;

import std.math : abs;

import drawing; // TODO: extra dependency
import geom;
import rm.base.user;
import rm.base.scene;
import rm.shapes.shape;

class Rm
{
  User user;
  Scene scene;

  static immutable float EPSILON = 1.0e-4f;
  static immutable float BIG_EPSILON = 1.0e-2f;
  static immutable float LIMIT = 1.0e+9f;

  this(User user, Scene scene)
  {
    this.user = user;
    this.scene = scene;
  }

  private
  {
    void computeColor(size_t x, size_t y, ref Buffer buffer)
    {
      float xr = user.height * (x - cast(float) buffer.width / 2) / buffer.width;
      float yr = user.height * (cast(float) buffer.height / 2 - y) / buffer.width; // width here is needed
      Vec3 dir = user.dir * user.dist + user.right * xr + user.up * yr;
      Vec3 curPoint = user.pos + dir;
      float d = void;

      dir.normMe();
      do
      {
        d = scene.getDistance(curPoint);
        curPoint += dir * d;
      }
      while (abs(d) > EPSILON && d < LIMIT);

      if (d > LIMIT)
      {
        buffer[x, y] = scene.fontColor;
      }
      else
      {
        Shape sh = scene.getNearest(curPoint);
        Vec3 n = Vec3(
          sh.getDistance(curPoint + Vec3(BIG_EPSILON, 0, 0)) - sh.getDistance(curPoint + Vec3(-BIG_EPSILON, 0, 0)),
          sh.getDistance(curPoint + Vec3(0, BIG_EPSILON, 0)) - sh.getDistance(curPoint + Vec3(0, -BIG_EPSILON, 0)),
          sh.getDistance(curPoint + Vec3(0, 0, BIG_EPSILON)) - sh.getDistance(curPoint + Vec3(0, 0, -BIG_EPSILON)),
        );
        n.normMe();

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
        buffer[x, y] = Color.fromVec3(color);
      }
    }
  }

  void fillBuffer(ref Buffer buffer)
  {
    foreach (y; 0 .. buffer.height)
    {
      foreach (x; 0 .. buffer.width)
      {
        computeColor(x, y, buffer);
      }
    }
  }
}
