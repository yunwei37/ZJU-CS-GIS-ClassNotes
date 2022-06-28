#include <iostream>
#include <math.h>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <stdio.h>
using namespace std;

/*
4
-86.15 -68.99 36589.41 25273.32 2195.17
-53.40 82.21 37631.08 31324.51 728.69
-14.78 -76.63 39100.97 24934.98 2386.50
10.46 64.43 40426.54 30319.81 757.31
*/

struct GPoint
{
	double x;
	double y;
	double z;
};

struct PPoint
{
	long double x;
	long double y;
};

struct solution
{
	double m;
	int count_num;
	double x0, y0, f;
	double fai, w, k;
	GPoint g_point[4];
	PPoint p_point[4];
	double R[3][3];
	double delta_xyz[4][3];
	double approx_xy[4][2];
	double xyz_ba[4][3];
	double A[8][6];
	double *ATA;
	double *ATA_R;
	double *ATA_RAT;
	double L[8];
	double delta_x[6];

	double Xs, Ys, Zs;
	bool load_data();
	bool rotate_r();
	bool appro_coordinate();
	auto error_coordinate() -> bool;
	bool reverse_matrix(double *Mat_U1, double *Mat_U2, int nVar);
	bool multi_matrix(double *Ma1, double *Ma2, int Row1, int Col1, int Col2, double *result);
	~solution()
	{
		delete[] ATA;
		delete[] ATA_R;
		delete[] ATA_RAT;
	}
};

auto main() -> int
{
	solution s;

	s.load_data();

	bool end_of_iter = true;
	do
	{
		s.rotate_r();

		s.appro_coordinate();

		end_of_iter = s.error_coordinate();
	} while (!end_of_iter);
	printf("%.2lf %.2lf %.2lf %.6lf %.6lf %.6lf\n", s.Xs, s.Ys, s.Zs, s.fai, s.w, s.k);
}

bool solution::load_data()
{

	ifstream myfile("data1.txt");
	string input;
	if (!myfile.is_open())
	{
		cout << "fail to load data" << endl;
		return 0;
	}
	string s;
	int l = 0;
	while (getline(myfile, s))
	{
		stringstream temp(s);
		x0 = 0;
		y0 = 0;
		f = 153.24;
		m = 40000;

		if (l == 0)
		{
			temp >> count_num;
		}
		else if (l > 0)
		{
			temp >> p_point[l - 1].x;
			temp >> p_point[l - 1].y;
			temp >> g_point[l - 1].x;
			temp >> g_point[l - 1].y;
			temp >> g_point[l - 1].z;
		}
		l++;
	}

	f = f / 1000.0;
	for (int i = 0; i < count_num; i++)
	{
		p_point[i].x /= 1000.0;
		p_point[i].y /= 1000.0;
	}
	fai = 0;
	w = 0;
	k = 0;
	Zs = m * f;
	Xs = 0, Ys = 0;
	for (int i = 0; i < count_num; i++)
	{
		Xs += g_point[i].x;
		Ys += g_point[i].y;
	}
	Xs = 1.0 * Xs / count_num;
	Ys = 1.0 * Ys / count_num;
	ATA = new double[36];
	ATA_R = new double[36];
	ATA_RAT = new double[48];
	return true;
}

bool solution::rotate_r()
{
	R[0][0] = cos(fai) * cos(k) - sin(fai) * sin(w) * sin(k);
	R[0][1] = -cos(fai) * sin(k) - sin(fai) * sin(w) * cos(k);
	R[0][2] = -sin(fai) * cos(w);
	R[1][0] = cos(w) * sin(k);
	R[1][1] = cos(w) * cos(k);
	R[1][2] = -sin(w);
	R[2][0] = sin(fai) * cos(k) + cos(fai) * sin(w) * sin(k);
	R[2][1] = -sin(fai) * sin(k) + cos(fai) * sin(w) * cos(k);
	R[2][2] = cos(fai) * cos(w);
	return true;
}

bool solution::appro_coordinate()
{
	for (int i = 0; i < count_num; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			delta_xyz[i][j] = 0;
			xyz_ba[i][j] = 0;
		}
		for (int j = 0; j < 2; j++)
		{
			approx_xy[i][j] = 0;
		}
	}
	for (int i = 0; i < 8; i++)
	{
		for (int j = 0; j < 6; j++)
		{
			A[i][j] = 0;
		}
	}

	for (int i = 0; i < count_num; i++)
	{
		delta_xyz[i][0] = g_point[i].x - Xs;
		delta_xyz[i][1] = g_point[i].y - Ys;
		delta_xyz[i][2] = g_point[i].z - Zs;
	}
	for (int i = 0; i < count_num; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			for (int k = 0; k < 3; k++)
			{
				xyz_ba[i][j] += R[k][j] * delta_xyz[i][k];
			}
		}
		approx_xy[i][0] = -f * xyz_ba[i][0] / xyz_ba[i][2];
		approx_xy[i][1] = -f * xyz_ba[i][1] / xyz_ba[i][2];
	}
	return true;
}

auto solution::error_coordinate() -> bool
{

	for (int i = 0; i < count_num; i++)
	{
		for (int j = 0; j < 3; j++)
		{

			A[2 * i][j] = 1 / xyz_ba[i][2] * (R[j][0] * f + R[j][2] * approx_xy[i][0]);
			A[2 * i + 1][j] = 1 / xyz_ba[i][2] * (R[j][1] * f + R[j][2] * approx_xy[i][1]);
		}
	}
	for (int i = 0; i < count_num; i++)
	{
		A[2 * i][3] = approx_xy[i][1] * sin(w) - (approx_xy[i][0] / f * (approx_xy[i][0] * cos(k) - approx_xy[i][1] * sin(k)) + f * cos(k)) * cos(w);
		A[2 * i][4] = -f * sin(k) - approx_xy[i][0] / f * (approx_xy[i][0] * sin(k) + approx_xy[i][1] * cos(k));
		A[2 * i][5] = approx_xy[i][1];
		A[2 * i + 1][3] = -approx_xy[i][0] * sin(w) - (approx_xy[i][1] / f * (approx_xy[i][0] * cos(k) - approx_xy[i][1] * sin(k)) - f * sin(k)) * cos(w);
		A[2 * i + 1][4] = -f * cos(k) - approx_xy[i][1] / f * (approx_xy[i][0] * sin(k) + approx_xy[i][1] * cos(k));
		A[2 * i + 1][5] = -approx_xy[i][0];
	}

	memset(ATA, 0, sizeof(double) * 36);
	memset(ATA_R, 0, sizeof(double) * 36);
	memset(ATA_RAT, 0, sizeof(double) * 48);
	for (int i = 0; i < 6; i++)
	{
		for (int j = 0; j < 6; j++)
		{
			for (int k = 0; k < 8; k++)
			{
				ATA[i * 6 + j] += A[k][i] * A[k][j];
			}
		}
	}

	for (int i = 0; i < count_num; i++)
	{
		L[2 * i] = p_point[i].x - approx_xy[i][0];
		L[2 * i + 1] = p_point[i].y - approx_xy[i][1];
	}

	memset(delta_x, 0, sizeof(double) * 6);
	reverse_matrix(ATA, ATA_R, 6);

	for (int i = 0; i < 6; i++)
	{
		for (int j = 0; j < 8; j++)
		{
			for (int k = 0; k < 6; k++)
			{
				ATA_RAT[i * 8 + j] += ATA_R[i * 6 + k] * A[j][k];
			}
		}
	}

	for (int i = 0; i < 6; i++)
	{
		for (int k = 0; k < 8; k++)
		{
			delta_x[i] += ATA_RAT[i * 8 + k] * L[k];
		}
	}
	bool end = true;

	Xs += delta_x[0];
	Ys += delta_x[1];
	Zs += delta_x[2];
	fai += delta_x[3];
	w += delta_x[4];
	k += delta_x[5];
	for (int i = 3; i < 6; i++)
	{
		if (abs(delta_x[i]) > 1e-5)
		{
			end = false;
			break;
		}
	}
	return end;
}

bool solution::reverse_matrix(double *Mat_U1, double *Mat_U2, int nVar)
{
	int ii, jj, kk, i9, j9;
	double tt, Smax;

	for (ii = 0; ii < nVar; ii++)
	{
		for (jj = 0; jj < nVar; jj++)
			*(Mat_U2 + ii * nVar + jj) = 0.;
		*(Mat_U2 + ii * nVar + ii) = 1.;
	}

	for (kk = 0; kk < nVar; kk++)
	{

		Smax = 0.;
		for (ii = kk; ii < nVar; ii++)
			for (jj = 0; jj < nVar; jj++)
			{
				tt = *(Mat_U1 + ii * nVar + jj);
				if (tt < 0.)
					tt = -tt;
				if (tt <= Smax)
					continue;
				Smax = tt;
				i9 = ii;
				j9 = jj;
			}
		if (Smax < 1.0e-15)
			return false;

		if (i9 != kk)
		{
			for (jj = 0; jj < nVar; jj++)
			{
				tt = *(Mat_U1 + i9 * nVar + jj);
				*(Mat_U1 + i9 * nVar + jj) = *(Mat_U1 + kk * nVar + jj);
				*(Mat_U1 + kk * nVar + jj) = tt;
				tt = *(Mat_U2 + i9 * nVar + jj);
				*(Mat_U2 + i9 * nVar + jj) = *(Mat_U2 + kk * nVar + jj);
				*(Mat_U2 + kk * nVar + jj) = tt;
			}
		}

		tt = *(Mat_U1 + kk * nVar + j9);
		tt = 1. / tt;
		for (jj = 0; jj < nVar; jj++)
		{
			*(Mat_U1 + kk * nVar + jj) = *(Mat_U1 + kk * nVar + jj) * tt;
			*(Mat_U2 + kk * nVar + jj) = *(Mat_U2 + kk * nVar + jj) * tt;
		}
		for (ii = 0; ii < nVar; ii++)
		{
			if (ii == kk)
				continue;
			tt = -*(Mat_U1 + ii * nVar + j9);
			for (jj = 0; jj < nVar; jj++)
			{
				*(Mat_U1 + ii * nVar + jj) += *(Mat_U1 + kk * nVar + jj) * tt;
				*(Mat_U2 + ii * nVar + jj) += *(Mat_U2 + kk * nVar + jj) * tt;
			}
		}
	}

	for (jj = 0; jj < nVar; ++jj)
		for (ii = 0; ii < nVar; ++ii)
		{
			if (*(Mat_U1 + ii * nVar + jj) < 0.5)
				continue;
			if (ii == jj)
				continue;
			for (kk = 0; kk < nVar; ++kk)
			{
				tt = *(Mat_U1 + ii * nVar + kk);
				*(Mat_U1 + ii * nVar + kk) = *(Mat_U1 + jj * nVar + kk);
				*(Mat_U1 + jj * nVar + kk) = tt;
				tt = *(Mat_U2 + ii * nVar + kk);
				*(Mat_U2 + ii * nVar + kk) = *(Mat_U2 + jj * nVar + kk);
				*(Mat_U2 + jj * nVar + kk) = tt;
			}
		}
	return true;
}

bool solution::multi_matrix(double *Ma1, double *Ma2, int Row1, int Col1, int Col2, double *result)
{
	for (int i = 0; i < Row1; ++i)
	{
		for (int j = 0; j < Col2; ++j)
		{
			for (int k = 0; k < Col1; ++k)
			{
				if (k == 0)
					result[i * Row1 + j] = 0;
				result[i * Row1 + j] += Ma1[i * Col1 + k] * Ma2[k * Col2 + j];
			}
		}
	}
	return true;
}
