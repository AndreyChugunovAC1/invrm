module geom.vec;

import std.math : sqrt;

struct Vec(size_t N) if (N > 1)
{
  float[N] coords;
  alias coords this;
  alias VecCur = Vec!N;
  // TODO: cache vector components, and make it all immutable

  static immutable VecCur zero = VecCur(0);
  static immutable VecCur one = VecCur(1);

  this(float value)
  {
    coords[] = value;
  }

  this(float[N] values...)
  {
    coords[] = values;
  }

  float dot()(auto ref const(VecCur) b) const
  {
    auto res = 0.0f;

    static foreach (i; 0 .. N)
    {
      res += coords[i] * b.coords[i];
    }
    return res;
  }

  VecCur opBinary(string op)(auto ref const(VecCur) rhs) const
  {
    VecCur res = void;
    mixin("res.coords[] = coords[]" ~ op ~ "rhs[];");
    return res;
  }

  VecCur opBinary(string op, R)(R rhs) const
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

  VecCur opBinaryRight(string op, L)(L lhs) const
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

    if (l2 < float.epsilon)
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
}

alias Vec2 = Vec!2;
alias Vec3 = Vec!3;
