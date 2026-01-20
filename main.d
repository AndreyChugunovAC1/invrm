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

void printUsage() => writeln("Usage: ./exe <width> <height> <frame_count>");

int main(string[] args)
{
  size_t width, height, frameCount;

  if (args.length != 4)
  {
    printUsage();
    return 1000 - 7;
  }

  try
  {
    width = to!size_t(args[1]);
    height = to!size_t(args[2]);
    frameCount = to!size_t(args[3]);
  }
  catch (ConvException e)
  {
    writeln("Can not convert all arguments to positive integer values.");
    printUsage();
    return 1000 - 7;
  }

  auto frame = Buffer(width, height);
  auto fire = new Fire();
  auto user = new User(Vec3(10, 1, 0), Vec3(-1, 0, 0), 1, 0.5);
  auto rm = new Rm(user, fire.scene);
  rm.setWidthHeight(width, height)
    .setRecLimit(2);

  for (size_t i = 0; i < 1000; i++)
  {
    fire.updateParticles(0.1f);
  }
  foreach (i; 0 .. frameCount)
  {
    write("Rendering ", i, " ");
    stdout.flush();
    foreach (y; parallel(iota(frame.height)))
    {
      foreach (x; parallel(iota(frame.width)))
      {
        frame[x, y] = Color.fromVec3(rm.computeColor(x, y));
      }
    }

    version (none)
    {
      import std.math;

      float c = cos(i / 30.0);
      float s = sin(i / 30.0);
      user.update(Vec3(10 * c, 1, 10 * s), Vec3(-c, 0.0, -s));
    }

    write("writing...");
    stdout.flush();
    import std.format;

    frame.dumpBufferToPPM(format("output/output%03d.ppm", i));
    writeln(" done");
    fire.updateParticles(0.01f);
  }
  return 0;
}
