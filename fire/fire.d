module fire.fire;

import rm;
import geom;
import std.random;
import std.algorithm;
import std.array;
import fire.particle;

final class Fire
{
  Scene scene;
  static maxHeight = 1.5f;

  private
  {
    enum particleCount = 300;
    Particle[] particles;
  }

  this()
  {
    Light[] lights = [
      new Light(Vec3(10, 0, 0), Vec3(0.6), Vec3(0.5)),
      new Light(Vec3(-10, 0, 0), Vec3(0.6), Vec3(0.5)),
      new Light(Vec3(0, 0, 10), Vec3(0.6), Vec3(0.5)),
      new Light(Vec3(0, 0, -10), Vec3(0.6), Vec3(0.5))
    ];
    this.particles = new Particle[300];
    foreach (ref particle; particles)
    {
      particle = new Particle();
    }
    import std.range;

    scene = new Scene(particles.map!(p => cast(Shape) p.sphere).array, lights);
  }

  void updateParticles(float dt)
  {
    foreach (ref particle; particles)
    {
      particle.update(dt);
    }
  }
}
