module main;

import std.range;
import std.array;
import std.conv : to, ConvException;
import std.stdio;

import rm;
import geom;
import drawing;

void printUsage() => writeln("Usage: ./exe <width> <height>");

void main(string[] args)
{
  size_t width, height;

  if (args.length != 3)
  {
    printUsage();
    return;
  }

  try
  {
    width = to!size_t(args[1]);
    height = to!size_t(args[2]);
  }
  catch (ConvException e)
  {
    writeln("Can not convert all arguments to positive integer values.");
    printUsage();
  }

  auto frame = Buffer(width, height);
  auto mat = new immutable Material(
    Vec3(0.05, 0.06, 0.15),
    Vec3(0.05, 0.06, 0.15),
    Vec3(0.05, 0.06, 0.15),
    0.9
  );
  auto mat2 = new immutable Material(
    Vec3(0.04, 0.01, 0.01),
    Vec3(0.5, 0.1, 0.1),
    Vec3(0.5, 0.1, 0.1),
    0.9
  );
  auto mat3 = new immutable Material(
    Vec3(0.04, 0.08, 0.06),
    Vec3(0.1, 0.7, 0.1),
    Vec3(0.3, 0.8, 0.1),
    0.9
  );

  auto rm = new Rm(
    User(Vec3(0, 0, 0), Vec3(1, 0, 1), 1, 1),
    Scene([
      new Circle(Vec3(20, 0, 20), 2.5, mat),
      new Circle(Vec3(10, 0, 20), 2.5, mat),
      new Circle(Vec3(20, 0, 10), 2.5, mat),
      new Thor(Vec3(20, 5, 20), Vec3(0, 1, 0), 5, 1, mat2),
      new Thor(Vec3(20, -5, 20), Vec3(0, 1, 0), 10, 1, mat3),
      // new Thor(Vec3(30, 0, 0), Vec3(-1, 0, 0), 5, 1, mat2),
      // new Plane(0, Vec3(0, 1, 0), mat)
    ],
    [
      // new Light(Vec3(0), Vec3(1, 1, 1), Vec3(1, 1, 1)),
      new Light(Vec3(15, 20, 0), Vec3(1, 0.1, 0.1), Vec3(1, 0.1, 0.1)),
      new Light(Vec3(0, -10, 20), Vec3(0.5, 0.4, 0.8), Vec3(1, 0.6, 0.8))
    ],
    Vec3(0.03, 0.042, 0.08)));

  rm.setWidthHeight(width, height)
    .setRecLimit(3);

  import std.range : iota;
  import std.parallelism : parallel;

  foreach (y; parallel(iota(frame.height)))
  {
    foreach (x; parallel(iota(frame.width)))
    {
      frame[x, y] = Color.fromVec3(rm.computeColor(x, y));
    }
  }

  frame.dumpBufferToPPM("output.ppm");
}
