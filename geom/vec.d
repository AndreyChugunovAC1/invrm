module geom.vec;

import std.math : sqrt, abs;
import geom.base;

@nogc @safe
struct Vec(size_t N) if (N > 1)
{
  float[N] coords;

  alias coords this;
  alias VecCur = Vec!N;
  // TODO: cache vector components, and make it all immutable

  enum zero = VecCur(0);
  enum one = VecCur(1);

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

  float len2() const => this.dot(this);
  float len() const => sqrt(this.len2());

  VecCur norm() const
  {
    VecCur res = this;
    res.normMe();
    return res;
  }

  ref VecCur normMe()
  {
    float l2 = len2();

    if (l2 < N * EPSILON_SQUARED)
    {
      return this;
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

  bool isZero() const
  {
    auto res = true;

    static foreach (i; 0 .. N)
    {
      res &= abs(coords[i]) < EPSILON;
    }
    return res;
  }

  /// def for perpendicularity:
  ///   |v| < EPSILON or |u| < EPSILON or |vu| < EPSILON
  /// - not EPSILON_SQUARE, just because
  bool isPerpWith(VecCur v) const =>
    this.isZero ||
    v.isZero ||
    abs(this.dot(v)) < EPSILON;

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
      // Also it means, that you can not write function f(v) without if's,
      // ternary operators, or magic with signs, or bool/int conversions,
      // where for each v: f(v) not parallel to v.
      // Overwise, it would mean, that cross(f(v), v) _|_ v,
      // that is impossible.

      int isZeroXY = abs(coords[0]) < EPSILON && abs(coords[1]) < EPSILON;
      int isNotZeroXY = 1 - isZeroXY;

      return VecCur(isNotZeroXY * (-coords[1]), isNotZeroXY * coords[0] + isZeroXY, 0);
    }
    else
    {
      static assert(false, "Not implemented yet");
    }
  }
}

alias Vec2 = Vec!2;
alias Vec3 = Vec!3;

@safe @nogc
unittest  // any perp test
{
  bool checkPerp(Vec3 v) =>
    v.isPerpWith(v.anyPerp());

  bool checkCorrectPerp(Vec3 v)
  {
    auto u = v.anyPerp();

    // v!=0 => u!=0 and v _|_ u
    return v.isPerpWith(u) && (v.isZero || !u.isZero);
  }

  assert(checkCorrectPerp(Vec3(1, 1, 1)));
  assert(checkCorrectPerp(Vec3(0, 0, 1)));
  assert(checkCorrectPerp(Vec3(0, 1, 1)));
  assert(checkCorrectPerp(Vec3(EPSILON, EPSILON, 1)));
  assert(checkCorrectPerp(Vec3(EPSILON, -EPSILON, 1)));
  assert(checkPerp(Vec3(EPSILON, EPSILON, EPSILON)));
  assert(checkPerp(Vec3(-EPSILON, -0, EPSILON)));
}
