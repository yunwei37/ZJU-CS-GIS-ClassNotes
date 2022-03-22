#ifndef _INTERSECT_H
#define _INTERSECT_H

#include <cmath>
#include <iostream>

struct Point {
  double x;
  double y;
  Point(double x, double y) : x(x), y(y){};

  Point operator+(const Point &p) const { return Point(x + p.x, y + p.y); }
  Point operator-(const Point &p) const { return Point(x - p.x, y - p.y); }
  Point operator*(const double a) const { return Point(a * x, a * y); }
  Point operator/(const double a) const { return Point(x / a, y / a); }

  double abs() { return sqrt(norm()); }
  double norm() { return x * x + y * y; }
  double cross(const Point &b) const { return x*b.y - b.x*y; }

  friend std::ostream &operator<<(std::ostream &os, const Point &p) {
    os << "(" << p.x << ", " << p.y << ")";
    return os;
  }
};

struct Segment {
  Point p1, p2;
};

using Vector = Point;

bool intersect(const Point x1, const Point y1, const Point x2, const Point y2);

bool intersect(Segment x, Segment y);

#endif