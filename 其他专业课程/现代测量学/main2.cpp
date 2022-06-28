#include <cstring>
#include <iostream>
#include <math.h>
#include <fstream>
#include <string>
#include <sstream>
#include <stdio.h>
using namespace std;

struct PPoint
{
	long double x;
	long double y;
};

struct solution
{
	double f;
	int count_num;
	double Bx, By, Bz;
	double N1[6], N2[6], Q[6];
	double R[3][3];
	PPoint pLeft[6];
	PPoint pRight[6];
	double M1[6][3];
	double M2[6][3];
	double A[6][5];
	double *ATA;
	double *ATA_R;
	double *ATA_RAT;
	double delta_x[5];

	double fai, w, k;
	double u, v;
	bool load_data();
	bool rotate_r();
	bool solve();
	bool solve_bz_n_q();
	bool solve_error_coo();
	bool reverse_matrix(double *Mat_U1, double *Mat_U2, int nVar);
	~solution() {
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

		s.solve();

		s.solve_bz_n_q();

		end_of_iter = s.solve_error_coo();
	} while (!end_of_iter);
	printf("%.6lf %.6lf %.6lf %.6lf %.6lf\n", s.fai, s.w, s.k, s.u, s.v);
}

bool solution ::load_data()
{

	ifstream myfile("data2.txt");
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
		f = 24;
		if (line_num == 1)
		{
			temp >> count_num;
		}
		else if (line_num > 1)
		{
			temp >> pLeft[line_num - 2].x;
			temp >> pLeft[line_num - 2].y;
			temp >> pRight[line_num - 2].x;
			temp >> pRight[line_num - 2].y;
		}
	}

	f = f / 1000.0;
	for (int i = 0; i < count_num; i++)
	{
		pRight[i].x /= 1000.0;
		pRight[i].y /= 1000.0;
		pLeft[i].x /= 1000.0;
		pLeft[i].y /= 1000.0;
	}
	Bx = 0.005185;
	fai = 0;
	w = 0;
	k = 0;
	u = 0;
	v = 0;
	ATA = new double[25];
	ATA_R = new double[25];
	ATA_RAT = new double[30];
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

bool solution::solve()
{
	for (int i = 0; i < 6; i++)
	{
		M1[i][2] = -f;
		M1[i][1] = pLeft[i].y;
		M1[i][0] = pLeft[i].x;
		M2[i][0] = R[0][0] * pRight[i].x + R[0][1] * pRight[i].y - R[0][2] * f;
		M2[i][1] = R[1][0] * pRight[i].x + R[1][1] * pRight[i].y - R[1][2] * f;
		M2[i][2] = R[2][0] * pRight[i].x + R[2][1] * pRight[i].y - R[2][2] * f;
	}
	return true;
}

bool solution::solve_bz_n_q()
{
	By = u * Bx;
	Bz = v * Bx;
	for (int i = 0; i < 6; i++)
	{
		N2[i] = (Bx * M1[i][2] - Bz * M1[i][0]) / (M1[i][0] * M2[i][2] - M1[i][2] * M2[i][0]);
		N1[i] = (Bx * M2[i][2] - Bz * M2[i][0]) / (M1[i][0] * M2[i][2] - M1[i][2] * M2[i][0]);
		Q[i] = N1[i] * M1[i][1] - N2[i] * M2[i][1] - By;
	}
	return true;
}
bool solution::solve_error_coo()
{

	for (int i = 0; i < 6; i++)
	{
		A[i][0] = -N2[i] * M2[i][0] * M2[i][1] / M2[i][2];
		A[i][1] = -N2[i] * (M2[i][2] + M2[i][1] * M2[i][1] / M2[i][2]);
		A[i][2] = M2[i][0] * N2[i];
		A[i][3] = Bx;
		A[i][4] = -Bx * M2[i][1] / M2[i][2];
	}

	memset(ATA_RAT, 0, sizeof(double) * 30);
	memset(ATA_R, 0, sizeof(double) * 25);
	memset(ATA, 0, sizeof(double) * 25);
	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < 5; j++)
		{
			for (int k = 0; k < 6; k++)
			{
				ATA[i * 5 + j] += A[k][i] * A[k][j];
			}
		}
	}

	reverse_matrix(ATA, ATA_R, 5);
	memset(delta_x, 0, sizeof(double) * 5);
	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < 6; j++)
		{
			for (int k = 0; k < 5; k++)
			{
				ATA_RAT[i * 6 + j] += ATA_R[i * 5 + k] * A[j][k];
			}
		}
	}

	for (int i = 0; i < 5; i++)
	{
		for (int k = 0; k < 6; k++)
		{
			delta_x[i] += ATA_RAT[i * 6 + k] * Q[k];
		}
	}
	bool end = true;

	fai += delta_x[0];
	w += delta_x[1];
	k += delta_x[2];
	u += delta_x[3];
	v += delta_x[4];
	for (int i = 0; i < 5; i++)
	{
		if (abs(delta_x[i]) > 0.3e-5)
		{
			end = false;
			break;
		}
	}
	return end;
}
bool solution ::reverse_matrix(double *Mat_U1, double *Mat_U2, int nVar)
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
