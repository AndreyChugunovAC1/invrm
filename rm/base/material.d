module rm.base.material;

import geom;

class Material
{
  Vec3 ka; // ambient
  Vec3 kd; // diffuse
  Vec3 ks; // spectral
  float alpha; // gamma correction?
  float rflk; // reflection koef
  // float rfrk; // refraction koef

  this(Vec3 ka, Vec3 kd, Vec3 ks, float rflk = 0.0f, float alpha = 1.0f) pure
  {
    this.ka = ka;
    this.kd = kd;
    this.ks = ks;
    this.rflk = rflk;
    this.alpha = alpha;
  }
}
