module drawing;

import std.file;
import std.stdio : File;

import geom;

struct Color
{
  ubyte[3] values;
  alias values this;

  static Color fromVec3(Vec3 color)
  {
    color = color.clamp();
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

  ref Color opIndex(size_t x, size_t y)
  {
    return data[y * width + x];
  }

  void dumpBufferToPPM(string filename)
  {
    auto f = File(filename, "wb");

    f.write("P6\n", width, " ", height, " 255\n");
    f.rawWrite(data);
    f.close();
  }
}
