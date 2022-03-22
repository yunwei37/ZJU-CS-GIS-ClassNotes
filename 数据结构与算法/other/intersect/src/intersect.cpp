#include "intersect.h"
#include <algorithm>
#include <assert.h>

bool intersect(const Point x1, const Point y1, const Point x2, const Point y2) {
  // check in box
  if (!(std::min(x1.x, y1.x) <= std::max(x2.x, y2.x) &&
        std::min(x2.x, y2.x) <= std::max(x1.x, y1.x) &&
        std::min(x1.y, y1.y) <= std::max(x2.y, y2.y) &&
        std::min(x2.y, y2.y) <= std::max(x1.y, y1.y)))
    return false;

  double u, v, w, z;

  u = (x2 - x1).cross((y1 - x1)); // AC×AB
  v = (y2 - x1).cross((y1 - x1)); // AD×AB
  w = (x1 - x2).cross((y2 - x2)); // CA×CD
  z = (y1 - x2).cross((y2 - x2)); // CB×CD

  if (u * v <= 1e-9 && w * z <= 1e-9)
    return true;
  return false;
}
