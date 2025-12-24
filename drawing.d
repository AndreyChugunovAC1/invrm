module drawing;

import std.file;
import std.stdio;

import geom;

struct Color
{
  ubyte[3] values;
  alias values this;

  static Color fromVec3(Vec3 color)
  {
    foreach (ref coord; color)
    {
      import std.algorithm;
      coord = clamp(coord, 0, 1);
    }
    Vec3 scaledColor = color * 255;
    return Color([
      cast(ubyte) scaledColor[0],
      cast(ubyte) scaledColor[1],
      cast(ubyte) scaledColor[2]
    ]);
  }
}

struct Buffer
{
  size_t width;
  size_t height;
  Color[] data;

  this(size_t width, size_t height)
  {
    this.width = width;
    this.height = height;
    this.data = new Color[width * height];
  }

  auto opIndexAssign(Color color, size_t x, size_t y)
  {
    data[y * width + x] = color;
    return color;
  }

  ref auto opIndex(size_t x, size_t y)
  {
    return data[y * width + x];
  }
}

void dumpBuffer(string filename, const(Buffer) buffer)
{
  auto f = File(filename, "wb");

  f.write("P6\n", buffer.width, " ", buffer.height, " 255\n");
  foreach (pixel; buffer.data)
    f.rawWrite(pixel);
  f.close();
}
