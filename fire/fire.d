module fire.fire;

import rm;
import geom;
import std.random;
import std.algorithm;
import std.array;

final class Fire
{
  Scene scene;

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

  this()
  {
    auto mat = new immutable Material(
      Vec3(0.04, 0.01, 0.01),
      Vec3(0.5, 0.1, 0.1),
      Vec3(0.5, 0.1, 0.1),
      0.0
    );

    rnd = Random(100); // unpredictableSeed()
    Vec3 rndVec01()
    {
      return Vec3(uniform01(rnd), uniform01(rnd), uniform01(rnd));
    }

    Light[] lights = [new Light(Vec3(10, 0, 0), Vec3(1, 1, 1), Vec3(1, 1, 1))];
    this.particles = new FireParticle[100];

    foreach (ref particle; particles)
    {
      particle.sphere = new Sphere(rndVec01(), uniform(0.01, 0.1), mat);
    }

    scene = new Scene(particles.map!(p => cast(Shape)p.sphere).array, lights);
  }

  void updateParticles(ulong dt)
  {

  }
}
