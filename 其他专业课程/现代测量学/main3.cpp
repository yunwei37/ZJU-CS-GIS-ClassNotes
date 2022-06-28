#include <iostream>
#include <math.h>
#include <cstring>
#include <fstream>
#include <string>
#include <sstream>
#include <memory>
#include <stdio.h>
using namespace std;

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
	int count_num;
	double g_point[4][3];
	double gp_tp[4][3];
	double gp_rotate[4][3];
	double fai, w, k;
	double lamda;
	double delta_xyz[3];
	double l[12];
	double A[12][7];
	double R[3][3];
	bool end;
	double *ATA;
	double *ATA_R;
	double *ATA_RAT;
	double delta[7];

	bool load_data();
	bool rotate_r();
	void solve();
	bool reverse_matrix(double *Mat_U1, double *Mat_U2, int nVar);
	~solution()
	{
		delete[] ATA;
		delete[] ATA_R;
		delete[] ATA_RAT;
	}
};

auto main() -> int
{
	solution s = {};

	s.load_data();
	s.solve();

	printf("%.3f %.3f %.3f %.6f %.6f %.6f %.6f\n", s.delta_xyz[0], s.delta_xyz[1], s.delta_xyz[2], s.lamda, s.fai, s.w, s.k);
}

void solution::solve(void)
{
	do
	{

		rotate_r();

		for (int i = 0; i < count_num; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				gp_rotate[i][j] = 0;
			}
		}
		for (int i = 0; i < count_num; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				for (int k = 0; k < 3; k++)
				{
					gp_rotate[i][j] += R[j][k] * g_point[i][k];
				}
			}
		}

		memset(l, 0, sizeof(double) * 12);
		for (int i = 0; i < count_num; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				l[i * 3 + j] = gp_tp[i][j] - lamda * gp_rotate[i][j] - delta_xyz[j];
			}
		}

		for (int i = 0; i < 12; i++)
		{
			for (int j = 0; j < 7; j++)
			{
				A[i][j] = 0;
			}
		}
		for (int i = 0; i < count_num; i++)
		{
			for (int j = 0; j < 3; j++)
			{
				A[i * 3 + j][j] = 1;
				A[i * 3 + j][3] = gp_rotate[i][j];
			}
			A[i * 3][4] = -gp_rotate[i][2];
			A[i * 3][6] = -gp_rotate[i][1];
			A[i * 3 + 1][5] = -gp_rotate[i][2];
			A[i * 3 + 1][6] = gp_rotate[i][0];
			A[i * 3 + 2][4] = gp_rotate[i][0];
			A[i * 3 + 2][5] = gp_rotate[i][1];
		}

		memset(ATA, 0, sizeof(double) * 49);
		memset(ATA_R, 0, sizeof(double) * 49);
		memset(ATA_RAT, 0, sizeof(double) * 84);
		for (int i = 0; i < 7; i++)
		{
			for (int j = 0; j < 7; j++)
			{
				for (int k = 0; k < 12; k++)
				{
					ATA[i * 7 + j] += A[k][i] * A[k][j];
				}
			}
		}

		reverse_matrix(ATA, ATA_R, 7);

		for (int i = 0; i < 7; i++)
		{
			for (int j = 0; j < 12; j++)
			{
				for (int k = 0; k < 7; k++)
				{
					ATA_RAT[i * 12 + j] += ATA_R[i * 7 + k] * A[j][k];
				}
			}
		}

		memset(delta, 0, sizeof(double) * 7);
		for (int i = 0; i < 7; i++)
		{
			for (int k = 0; k < 12; k++)
			{
				delta[i] += ATA_RAT[i * 12 + k] * l[k];
			}
		}
		end = true;

		delta_xyz[0] += delta[0];
		delta_xyz[1] += delta[1];
		delta_xyz[2] += delta[2];
		lamda = lamda * (1 + delta[3]);
		fai += delta[4];
		w += delta[5];
		k += delta[6];
		for (int i = 4; i < 7; i++)
		{
			if (abs(delta[i]) > 1e-5)
			{
				end = false;
				break;
			}
		}
	} while (!end);
	return;
}

bool solution::load_data()
{

	ifstream myfile("data3.txt");
	string input;
	if (!myfile.is_open())
	{
		cout << "can not open this file" << endl;
		return 0;
	}
	string s;
	int line_num = 0;
	while (getline(myfile, s))
	{
		line_num++;
		stringstream temp(s);
		if (line_num == 1)
		{
			temp >> count_num;
		}
		else if (line_num > 1)
		{
			for (int i = 0; i < 3; i++)
			{
				temp >> g_point[line_num - 2][i];
			}
			for (int i = 0; i < 3; i++)
			{
				temp >> gp_tp[line_num - 2][i];
			}
		}
	}

	fai = w = k = 0;
	lamda = 1;
	ATA = new double[49];
	ATA_R = new double[49];
	ATA_RAT = new double[12 * 7];
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

	for (jj = 0; jj < nVar; jj++)
		for (ii = 0; ii < nVar; ii++)
		{
			if (*(Mat_U1 + ii * nVar + jj) < 0.5)
				continue;
			if (ii == jj)
				continue;
			for (kk = 0; kk < nVar; kk++)
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
