module fire.fire;

import rm;
import geom;
import std.random;
import std.algorithm;
import std.array;

final class Fire
{
  Scene scene;
  static maxHeight = 1.5f;

  private
  {
    FireParticle[] particles;
    Random rnd;
  }

  struct FireParticle
  {
    Sphere sphere;
    // stochastic params:
  }

  private
  {
    Vec3 rndVec01() pure
    {
      return Vec3((2 * uniform01(rnd) - 1) / 2.0, uniform01(rnd) / 2.0, (2 * uniform01(rnd) - 1) / 2.0);
      // return Vec3(0);
    }

    float radiusFromPos(ref Vec3 pos) => (maxHeight - pos[1]) * 0.1;
  }

  this()
  {
    auto mat = new immutable Material(
      Vec3(0.05, 0.01, 0.01),
      Vec3(0.5, 0.1, 0.1),
      Vec3(0.5, 0.1, 0.1),
      0.0
    );

    rnd = Random(100);

    Light[] lights = [new Light(Vec3(10, 0, 0), Vec3(1, 1, 1), Vec3(1, 1, 1))];
    this.particles = new FireParticle[10];

    foreach (ref particle; particles)
    {
      auto cen = rndVec01();
      particle.sphere = new Sphere(cen, radiusFromPos(cen), mat);
    }

    scene = new Scene(particles.map!(p => cast(Shape) p.sphere).array, lights);
  }

  void updateParticles(ulong dt, Vec3 baseDirection = Vec3(0))
  {
    foreach (_; 0 .. dt)
    {
      foreach (ref particle; particles)
      {
        Vec3 delta = baseDirection;
        switch (uniform(0, 6, rnd))
        {
        case 0:
          delta += Vec3(1, 0, 0);
          break;
        case 1:
          delta += Vec3(-1, 0, 0);
          break;
        case 2:
          delta += Vec3(0, 0, 1);
          break;
        case 3:
          delta += Vec3(0, 0, -1);
          break;
        case 4:
          delta += Vec3(0, 3.0, 0);
          break;
        case 5:
          delta += Vec3(0, -0.2, 0);
          break;
        default:
          assert(0);
        }
        particle.sphere.center += delta * 0.001;
        if (particle.sphere.center.len2() >= maxHeight * maxHeight)
        {
          particle.sphere.center = rndVec01();
        }
        particle.sphere.radius = radiusFromPos(particle.sphere.center);
      }
    }
  }
}
