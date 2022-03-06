#include "Geometry.h"
#include <cmath>

#define NOT_IMPLEMENT -1.0

namespace lab3 {

/*
 * Envelope functions
 */
bool Envelope::contain(double x, double y) const
{
	return x >= minX && x <= maxX && y >= minY && y <= maxY;
}

bool Envelope::contain(const Envelope& envelope) const
{
	return contain(envelope.getMaxX(), envelope.getMaxY())
		&& contain(envelope.getMinX(), envelope.getMaxY())
		&& contain(envelope.getMaxX(), envelope.getMinY())
		&& contain(envelope.getMinX(), envelope.getMinY());
}

bool Envelope::intersect(const Envelope& envelope) const
{
	// Task 3.2 ����Envelope�Ƿ��ཻ
	// Write your code here
	bool flag = (envelope.getMaxX() < minX) || (envelope.getMinX() > maxX)
		|| (envelope.getMaxY() < minY) || (envelope.getMinY() > maxY);
		return !flag;
}

Envelope Envelope::unionEnvelope(const Envelope& envelope) const
{
	// Task 3.3 �ϲ�����Envelope����һ���µ�Envelope
	// Write your code here
	Envelope e(min<double>(minX, envelope.getMinX()), max<double>(maxX, envelope.getMaxX())
		, min<double>(minY, envelope.getMinY()), max<double>(maxY, envelope.getMaxY()));
	return e;
}
/*
void Envelope::draw() const
{
	glBegin(GL_LINE_STRIP);

	glVertex2d(minX, minY);
	glVertex2d(minX, maxY);
	glVertex2d(maxX, maxY);
	glVertex2d(maxX, minY);
	glVertex2d(minX, minY);

	glEnd();
}
*/

/*
 * Points functions
 */
double Point::distanceOnSphere(const Point* point) const
{
	// Task 8 ��������֮����������(km)
	double R  = 6367;
	double PI = 3.14159265358979323846;
	double f = PI / 180;
	// Write your code here
	return R * acos(cos(y*f) * cos(point->getY()*f) * cos((point->getX() - x)*f) + sin(y*f) * sin(point->getY()*f));
}

double Point::distance(const Point* point) const
{
	return sqrt((x - point->x) * (x - point->x) + (y - point->y) * (y - point->y));
}

double Point::distance(const LineString* line) const
{
	double mindist = line->getPointN(0).distance(this);
	for (size_t i = 0; i < line->numPoints() - 1; ++i) {
		double dist = 0;
		double x1 = line->getPointN(i).getX();
		double y1 = line->getPointN(i).getY();
		double x2 = line->getPointN(i + 1).getX();
		double y2 = line->getPointN(i + 1).getY();
		// Task 4.1 calculate the distance between Point P(x, y) and Line [P1(x1, y1), P2(x2, y2)] (less than 10 lines)
		// Write your code here
		double dotACAB = (x - x1)*(x2 - x1) + (y - y1)*(y2 - y1);
		double dotBCAB = (x - x2)*(x2 - x1) + (y - y2)*(y2 - y1);
		if ((dotACAB > 0 && dotBCAB > 0) ||(dotACAB < 0 && dotBCAB < 0)) {
			dist = min<double>(sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1)), sqrt((x - x2) * (x - x2) + (y - y2) * (y - y2)));
		}
		else {
			dist = sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1) - pow(dotACAB / sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)), 2));
		}

		if (dist < mindist)
			mindist = dist;
	}
	return mindist;
}

double Point::distance(const Polygon* polygon) const
{
	LineString line = polygon->getExteriorRing();
	size_t n = line.numPoints();

	bool inPolygon = false;
	// Task 4.2 whether Point P(x, y) is within Polygon (less than 15 lines)
	// write your code here
	for (size_t i = 0; i < n - 1; ++i) {
		double x1 = line.getPointN(i).getX();
		double y1 = line.getPointN(i).getY();
		double x2 = line.getPointN((i + 1)/n).getX();
		double y2 = line.getPointN((i + 1) / n).getY();
		double slope = (y2 - y1) / (x2 - x1);
		bool cond = ((x1 <= x) && (x < x2))|| ((x2 <= x) && (x < x1));
		bool above = y <= slope * (x - x1) + y1;
		if (cond && above) inPolygon = !inPolygon;
	}

	double mindist = 0;
	if (!inPolygon)
		mindist = this->distance(&line);
	return mindist;
}

bool Point::intersects(const Envelope& rect)  const
{
	return (x >= rect.getMinX()) && (x <= rect.getMaxX()) && (y >= rect.getMinY()) && (y <= rect.getMaxY());
}
/*
void Point::draw()  const
{
	glBegin(GL_POINTS);
	glVertex2d(x, y);
	glEnd();
}

*/
/*
 * LineString functions
 */
void LineString::constructEnvelope()
{
	double minX, minY, maxX, maxY;
	maxX = minX = points[0].getX();
	maxY = minY = points[0].getY();
	for (size_t i = 1; i < points.size(); ++i) {
		maxX = max(maxX, points[i].getX());
		maxY = max(maxY, points[i].getY());
		minX = min(minX, points[i].getX());
		minY = min(minY, points[i].getY());
	}
	envelope = Envelope(minX, maxX, minY, maxY);
}

double LineString::distance(const LineString* line) const
{
	cout << "to be implemented: LineString::distance(const LineString* line)\n";
	return NOT_IMPLEMENT;
}

double LineString::distance(const Polygon* polygon) const
{
	cout << "to be implemented: LineString::distance(const Polygon* polygon)\n";
	return NOT_IMPLEMENT;
}

typedef int OutCode;

const int INSIDE = 0; // 0000
const int LEFT = 1;   // 0001
const int RIGHT = 2;  // 0010
const int BOTTOM = 4; // 0100
const int TOP = 8;    // 1000

// Compute the bit code for a point (x, y) using the clip rectangle
// bounded diagonally by (xmin, ymin), and (xmax, ymax)
// ASSUME THAT xmax, xmin, ymax and ymin are global constants.
OutCode ComputeOutCode(double x, double y, double xmin, double xmax, double ymin, double ymax)
{
	OutCode code;

	code = INSIDE;          // initialised as being inside of [[clip window]]

	if (x < xmin)           // to the left of clip window
		code |= LEFT;
	else if (x > xmax)      // to the right of clip window
		code |= RIGHT;
	if (y < ymin)           // below the clip window
		code |= BOTTOM;
	else if (y > ymax)      // above the clip window
		code |= TOP;
	
	return code;
}

// Cohen�CSutherland clipping algorithm clips a line from
// P0 = (x0, y0) to P1 = (x1, y1) against a rectangle with 
// diagonal from (xmin, ymin) to (xmax, ymax).
bool intersectTest(double x0, double y0, double x1, double y1, double xmin, double xmax, double ymin, double ymax)
{
	// compute outcodes for P0, P1, and whatever point lies outside the clip rectangle
	OutCode outcode0 = ComputeOutCode(x0, y0, xmin, xmax, ymin, ymax);
	OutCode outcode1 = ComputeOutCode(x1, y1, xmin, xmax, ymin, ymax);
	bool accept = false;

	while (true) {
		if (!(outcode0 | outcode1)) {
			// bitwise OR is 0: both points inside window; trivially accept and exit loop
			accept = true;
			break;
		}
		else if (outcode0 & outcode1) {
			// bitwise AND is not 0: both points share an outside zone (LEFT, RIGHT, TOP,
			// or BOTTOM), so both must be outside window; exit loop (accept is false)
			break;
		}
		else {
			// failed both tests, so calculate the line segment to clip
			// from an outside point to an intersection with clip edge
			double x, y;

			// At least one endpoint is outside the clip rectangle; pick it.
			OutCode outcodeOut = outcode0 ? outcode0 : outcode1;

			// Now find the intersection point;
			// use formulas:
			//   slope = (y1 - y0) / (x1 - x0)
			//   x = x0 + (1 / slope) * (ym - y0), where ym is ymin or ymax
			//   y = y0 + slope * (xm - x0), where xm is xmin or xmax
			// No need to worry about divide-by-zero because, in each case, the
			// outcode bit being tested guarantees the denominator is non-zero
			if (outcodeOut & TOP) {           // point is above the clip window
				x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
				y = ymax;
			}
			else if (outcodeOut & BOTTOM) { // point is below the clip window
				x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
				y = ymin;
			}
			else if (outcodeOut & RIGHT) {  // point is to the right of clip window
				y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
				x = xmax;
			}
			else if (outcodeOut & LEFT) {   // point is to the left of clip window
				y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
				x = xmin;
			}
			
			// Now we move outside point to intersection point to clip
			// and get ready for next pass.
			if (outcodeOut == outcode0) {
				x0 = x;
				y0 = y;
				outcode0 = ComputeOutCode(x0, y0, xmin, xmax, ymin, ymax);
			}
			else {
				x1 = x;
				y1 = y;
				outcode1 = ComputeOutCode(x1, y1, xmin, xmax, ymin, ymax);
			}
		}
	}
	return accept;
}

bool LineString::intersects(const Envelope& rect)  const
{
	double xmin = rect.getMinX();
	double xmax = rect.getMaxX();
	double ymin = rect.getMinY();
	double ymax = rect.getMaxY();

	for (size_t i = 1; i < points.size(); ++i)
		if (intersectTest(points[i - 1].getX(), points[i - 1].getY(), points[i].getX(), points[i].getY(), xmin, xmax, ymin, ymax))
			return true;
	return false;
}
/*
void LineString::draw()  const
{
	glBegin(GL_LINE_STRIP);
	for (size_t i = 0; i < points.size(); ++i)
		glVertex2d(points[i].getX(), points[i].getY());
	glEnd();
}
*/
void LineString::print() const
{
	cout << "LineString(";
	for (size_t i = 0; i < points.size(); ++i) {
		if (i != 0)
			cout << ", ";
		cout << points[i].getX() << " " << points[i].getY();
	}
	cout << ")";
}

/*
 * Polygon
 */
double Polygon::distance(const Polygon* polygon) const
{
	return min(exteriorRing.distance(polygon), polygon->getExteriorRing().distance(this));
}

bool Polygon::intersects(const Envelope& rect)  const
{
	cout << "to be implemented: Polygon::intersects(const Envelope& box)\n";
	return true;
}
/*
void Polygon::draw() const
{
	exteriorRing.draw();
}
*/
void Polygon::print() const
{
	cout << "Polygon(";
	for (size_t i = 0; i < exteriorRing.numPoints(); ++i) {
		if (i != 0)
			cout << ", ";
		Point p = exteriorRing.getPointN(i);
		cout << p.getX() << " " << p.getY();
	}
	cout << ")";
}
	
/*
 * MultiPoint
 */

void MultiPoint::constructEnvelope()
{
	double minX, minY, maxX, maxY;
	maxX = minX = points[0].getX();
	maxY = minY = points[0].getY();
	for (size_t i = 1; i < points.size(); ++i) {
		maxX = max(maxX, points[i].getX());
		maxY = max(maxY, points[i].getY());
		minX = min(minX, points[i].getX());
		minY = min(minY, points[i].getY());
	}
	envelope = Envelope(minX, maxX, minY, maxY);
}

double MultiPoint::distance(const Point* point) const
{	
	double mindist = DBL_MAX;
	for (auto p : points) {
		mindist = min(mindist, point->distance(&p));
	}
	return mindist;
}

double MultiPoint::distance(const LineString* line) const
{	
	double mindist = DBL_MAX;
	for (auto p : points) {
		mindist = min(mindist, line->distance(&p));
	}
	return mindist;
}

double MultiPoint::distance(const Polygon* polygon) const
{	
	double mindist = DBL_MAX;
	for (auto p : points) {
		mindist = min(mindist, polygon->distance(&p));
	}
	return mindist;
}

bool MultiPoint::intersects(const Envelope& rect) const
{	
	bool flag = false;
	for (auto p : points) {
		flag = flag | p.intersects(rect);
	}
	return flag;
}
/*
void MultiPoint::draw() const
{	
	for (auto p : points) {
		glBegin(GL_POINTS);
		glVertex2d(p.getX(), p.getY());
		glEnd();
	}
}
*/
void MultiPoint::print() const
{	
	for (auto p : points) {
		cout << "Point(" << p.getX() << " " << p.getY() << ")"<<endl;
	}
}

}
