module geom.vec;

import std.math : sqrt;

@nogc @safe
struct Vec(size_t N) if (N > 1)
{
  float[N] coords;

  alias coords this;
  alias VecCur = Vec!N;
  // TODO: cache vector components, and make it all immutable

  enum zero = VecCur(0);
  enum one = VecCur(1);
  enum min_square_length = 1.0e-4;

  this(float value)
  {
    coords[] = value;
  }

  this(float[N] values...)
  {
    coords[] = values;
  }

  float dot()(auto ref const(VecCur) b) const pure
  {
    auto res = 0.0f;

    static foreach (i; 0 .. N)
    {
      res += coords[i] * b.coords[i];
    }
    return res;
  }

  VecCur opBinary(string op)(auto ref const(VecCur) rhs) const pure
  {
    VecCur res = void;
    mixin("res.coords[] = coords[]" ~ op ~ "rhs[];");
    return res;
  }

  VecCur opBinary(string op, R)(R rhs) const pure
  if (is(R : float) || is(R : double) || is(R : real))
  {
    VecCur res = void;
    mixin("res.coords[] = coords[]" ~ op ~ "rhs;");
    return res;
  }

  ref VecCur opOpAssign(string op, T)(T value)
      if (is(T : float) || is(T : double) || is(T : real))
  {
    mixin("this.coords[]" ~ op ~ "= value;");
    return this;
  }

  ref VecCur opOpAssign(string op)(auto ref const(VecCur) value)
  {
    mixin("this.coords[]" ~ op ~ "= value[];");
    return this;
  }

  VecCur opBinaryRight(string op, L)(L lhs) const pure
  if (is(L : float) || is(L : double) || is(L : real))
  {
    VecCur res = void;
    mixin("res.coords[] = coords[]" ~ op ~ "lhs;");
    return res;
  }

  static if (N == 2)
  {
    float skew()(auto ref const(VecCur) b) const
    {
      return a.coords[0] * b.coords[1] - a.coords[1] * b.coords[0];
    }
  }

  static if (N == 3)
  {
    VecCur cross()(auto ref const(VecCur) b) const
    {
      return VecCur([
        coords[1] * b.coords[2] - coords[2] * b.coords[1],
        -coords[0] * b.coords[2] + coords[2] * b.coords[0],
        coords[0] * b.coords[1] - coords[1] * b.coords[0]
      ]);
    }
  }

  float len2() const => dot(this);
  float len() const => sqrt(len2);

  VecCur norm() const
  {
    VecCur res = this;
    res.normMe();
    return res;
  }

  ref VecCur normMe()
  {
    float l2 = len2();

    if (l2 < min_square_length)
    {
      this = zero;
    }

    return this /= sqrt(l2);
  }

  VecCur clamp(VecCur mn = zero, VecCur mx = one) const
  {
    VecCur res = void;

    static foreach (i; 0 .. N)
    {
      import std.algorithm.comparison : clamp;

      res.coords[i] = clamp(coords[i], mn[i], mx[i]);
    }
    return res;
  }

  /// Returns any vector, perpendicular to this.
  /// If vector has almost zero length, when there is no guarantee.
  VecCur anyPerp() const
  {
    static if (N == 2)
    {
      return VecCur(coords[1], -coords[0]);
    }
    else static if (N == 3)
    {
      // It is impossible to just compute it using formula:
      // https://en.wikipedia.org/wiki/Hairy_ball_theorem
      // Also it means, that you can not just write function f(v),
      // where for each v: f(v) not parallel to v.
      // Overwise, it would mean, that cross(f(v), v) always _|_ v

      VecCur res = cross(VecCur(1, 0, 0));
      if (res.len2() < min_square_length)
      {
        return VecCur(0, 1, 0);
      }
      return res;
    }
    else
    {
      static assert(false, "Not implemented");
    }
  }
}

alias Vec2 = Vec!2;
alias Vec3 = Vec!3;

unittest
{

}
