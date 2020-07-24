#include "graphics.h"
#include "extgraph.h"
#include "genlib.h"
#include "simpio.h"
#include "conio.h"
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

#include <windows.h>
#include <olectl.h>
#include <stdio.h>
#include <mmsystem.h>
#include <wingdi.h>
#include <ole2.h>
#include <ocidl.h>
#include <winuser.h>
#include <math.h>

int maxdeepth = 4;

void koch(int deepth, double r, double theta) {
	if (deepth >= maxdeepth) {
		double radians = theta / 180 * 3.1415926535;
		DrawLine(r*cos(radians), r*sin(radians));
		return;
	}
	koch(deepth + 1, r / 3, theta);
	koch(deepth + 1, r / 3, theta + 60);
	koch(deepth + 1, r / 3, theta - 60);
	koch(deepth + 1, r / 3, theta);
}

void KeyboardEventProcess(int key, int event);/*键盘消息回调函数*/

double ccx, ccy;

void Main() /*仅初始化执行一次*/
{
	InitGraphics();

	registerKeyboardEvent(KeyboardEventProcess);/*注册键盘消息回调函数*/

	SetPenColor("Black");
	SetPenSize(1);

	ccx = GetWindowWidth() / 2;
	ccy = GetWindowHeight() / 2;
	MovePen(ccx - 2, ccy - 1.732/2);
	koch(0, 4, 60);
	koch(0, 4, -60);
	koch(0, 4, 180);
	SetWindowTitle("按任意键可输入递归深度：");
}

void Clean()
{
	SetPenColor("White");
	StartFilledRegion(1);
	MovePen(0, 0);
	DrawLine(GetWindowWidth(), 0);
	DrawLine(0, GetWindowHeight());
	DrawLine(-GetWindowWidth(), 0);
	DrawLine(0, -GetWindowHeight());
	EndFilledRegion();
	SetPenColor("Black");
}

void KeyboardEventProcess(int key, int event)/*每当产生键盘消息，都要执行*/
{
	switch (event) {
	case KEY_DOWN:
		InitConsole();
		printf("Input radius: ");
		maxdeepth = GetReal();
		FreeConsole();
		Clean();
		MovePen(ccx - 1.5, ccy - 1.5);
		koch(0, 4, 60);
		koch(0, 4, -60);
		koch(0, 4, 180);
		break;
	case KEY_UP:
		break;
	}
}
