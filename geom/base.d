module geom.base;

/// almost zero
enum EPSILON = 1.0e-4;

/// almost infinity
enum BIG_VALUE = 1.0e+9f;

/// almost zero for measure_unit^2 measures:
enum EPSILON_SQUARED = EPSILON ^^ 2;

/// for approximate calculations:
enum SMALL_VALUE = 1.0e-2;