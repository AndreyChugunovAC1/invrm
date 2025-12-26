module rm.base.light;

import geom;

class Light
{
  Vec3 pos;
  Vec3 illd;
  Vec3 ills;

  this(Vec3 pos, Vec3 illd, Vec3 ills)
  {
    this.pos = pos;
    this.illd = illd;
    this.ills = ills;
  }
}
