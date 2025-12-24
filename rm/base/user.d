module rm.base.user;

import geom;

struct User
{
  const
  {
    Vec3 pos;
    Vec3 dir;
    Vec3 up;
    Vec3 right;
  }

  float dist;
  float height;

  this(Vec3 pos, Vec3 dir, float dist, float height, Vec3 up = [0, 1, 0])
  {
    import std.stdio;
    this.pos = pos;
    this.dir = dir.norm;
    up = up.norm;
    this.right = dir.cross(up).norm;
    this.up = right.cross(dir).norm;
    this.dist = dist;
    this.height = height;
  }
}
