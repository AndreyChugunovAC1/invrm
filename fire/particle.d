module fire.particle;

import std.random;
import std.math;

import geom;
import rm;

class Particle
{
  private
  {
    enum alpha = 1.0f;
    enum beta = 1.0f;
    enum timeToDistance = (1.2f / 0.6f - 1.0f)  * 9.81f;
    enum maxDistance = 2.0f;
    enum radiusCoef = 1.0f / 7.0f;

    Random rnd;
  }

  Material mat;
  Sphere sphere;
  float curTime;

  this()
  {
    mat = new Material(
      Vec3(0.05, 0.01, 0.01),
      Vec3(0.5, 0.1, 0.1),
      Vec3(0.5, 0.1, 0.1)
    );
    sphere = new Sphere(Vec3(0.0), 1.0, mat);
    rnd = Random(unpredictableSeed);
    this.reset();
  }

  void update(float dt)
  {
    // assuming F_a = const
    if (sphere.center.len() >= maxDistance)
    {
      reset();
    }

    // += alpha * W(t)
    float deviation = sqrt(0.1 * dt);
    sphere.center += alpha * Vec3(
      genNormal(0.0F, deviation, rnd),
      genNormal(0.0F, deviation, rnd),
      genNormal(0.0F, deviation, rnd)
    );

    // += beta * A(t)
    curTime += dt;
    sphere.center += beta * Vec3(
      0,
      timeToDistance * curTime * dt,
      0
    );

    sphere.radius = getRadius();
    import std.algorithm.comparison;
    float a = clamp((maxDistance - sphere.center[1]) / maxDistance, 0.0, 1.0);
    sphere.mat.ka = (1 - a) * Vec3(0.05, 0.025, 0.0) + a * Vec3(0.05, 0.01, 0.01);
    sphere.mat.kd = (1 - a) * Vec3(0.5, 0.25, 0.0) + a * Vec3(0.5, 0.1, 0.1);
    sphere.mat.ks = (1 - a) * Vec3(0.5, 0.25, 0.0) + a * Vec3(0.5, 0.1, 0.1);
  }

  void reset() pure
  {
    float r = sqrt(uniform01(rnd));
    float theta = uniform!"[)"(0.0, 2.0 * PI, rnd);

    sphere.center = Vec3(r * cos(theta), 0.0, r * sin(theta));
    sphere.radius = getRadius();
    curTime = 0.0f;
  }

  private float getRadius() pure => radiusCoef * (maxDistance - sphere.center[1]) / maxDistance;
}
