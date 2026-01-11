module main;

import std.range;
import std.array;
import std.conv : to, ConvException;
import std.stdio;
import std.range : iota;
import std.parallelism : parallel;

import rm;
import geom;
import drawing;
import fire.fire;

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
  auto fire = new Fire();
  auto rm = new Rm(User(Vec3(10, 0, 0), Vec3(-1, 0, 0), 1, 0.5), fire.scene);
  rm.setWidthHeight(width, height)
    .setRecLimit(2);

  foreach (y; parallel(iota(frame.height)))
  {
    foreach (x; parallel(iota(frame.width)))
    {
      frame[x, y] = Color.fromVec3(rm.computeColor(x, y));
    }
  }

  frame.dumpBufferToPPM("output.ppm");
}
