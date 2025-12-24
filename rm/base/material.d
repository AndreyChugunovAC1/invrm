module rm.base.material;

import geom;

class Material
{
  Vec3 ka;
  Vec3 kd;
  Vec3 ks;
  float alpha;

  this(Vec3 ka, Vec3 kd, Vec3 ks, float alpha = 1.0f)
  {
    this.ka = ka;
    this.kd = kd;
    this.ks = ks;
    this.alpha = alpha;
  }
}
