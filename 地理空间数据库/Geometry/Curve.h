#ifndef CURVE_H_INCLUDED
#define CURVE_H_INCLUDED

namespace lab3 {

// Z-Curve
void zorder(int order, int& value, int coor[2]);
void izorder(int order, int value, int coor[2]);
int  zdist(int order);
//void zrender(int order, int width, int height);

// Hilbert Curve
void horder(int order, int& value, int coor[2]);
void ihorder(int order, int value, int coor[2]);
int  hdist(int order);
//void hrender(int order, int width, int height);

}
#endif
