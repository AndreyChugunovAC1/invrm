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
  auto mat = new Material(
    Vec3(0.01, 0.01, 0.05),
    Vec3(0.1, 0.1, 0.5),
    Vec3(0.1, 0.1, 0.5)
  );
  auto mat2 = new Material(
    Vec3(0.04, 0.01, 0.01),
    Vec3(0.5, 0.1, 0.1),
    Vec3(0.5, 0.1, 0.1)
  );
  auto rm = new Rm(
    frame.width, frame.height,
    User(Vec3(0, 0, 0), Vec3(1, 0, 1), 1, 1),
    Scene([
      new Circle(Vec3(20, 5, 20), 2.5, mat),
      new Thor(Vec3(20, 5, 20), Vec3(3, 3, -1), 5, 1, mat2),
      // new Thor(Vec3(30, 0, 0), Vec3(-1, 0, 0), 5, 1, mat2),
      // new Plane(0, Vec3(0, 1, 0), mat)
    ],
    [
      // new Light(Vec3(0), Vec3(1, 1, 1), Vec3(1, 1, 1)),
      new Light(Vec3(0, 20, 0), Vec3(1, 0.1, 0.1), Vec3(1, 0.1, 0.1))
    ]));

  foreach (y; 0 .. frame.height)
  {
    foreach (x; 0 .. frame.width)
    {
      frame[x, y] = Color.fromVec3(rm.computeColor(x, y));
    }
  }

  frame.dumpBufferToPPM("output.ppm");
}
