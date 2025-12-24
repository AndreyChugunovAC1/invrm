module main;

import std.range;
import std.array;

import rm;
import geom;
import drawing;

void main(string[] args)
{
  auto frame = Buffer(500, 500);
  auto mat = new Material(
    Vec3(0.01, 0.01, 0.05),
    Vec3(0.1, 0.1, 0.5),
    Vec3(0.1, 0.1, 0.5)
  );
  auto rm = new Rm(
    User(Vec3(0, 0, 0), Vec3(1, 0, 1), 1, 1),
    Scene(
      [
        new Circle(Vec3(30, 5, 30), 2.5, mat),
        new Thor(Vec3(30, 5, 30), Vec3(3, 3, -1), 5, 1, mat)
      ],
      [
        new Light(Vec3(0), Vec3(1, 1, 1), Vec3(1, 1, 1)),
        new Light(Vec3(0, 10, 0), Vec3(1, 0.1, 0.1), Vec3(1, 0.1, 0.1))
      ]));
  rm.fillBuffer(frame);
  dumpBuffer("output.ppm", frame);
}
