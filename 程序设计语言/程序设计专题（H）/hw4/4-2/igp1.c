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

#define TIMER_BLINK500  1     /*500ms定时器事件标志号*/
#define TIMER_BLINK1000 2     /*1000ms定时器时间标志号*/

const int mseconds500 = 500;
const int mseconds1000 = 1000;

//共有30行，每行最大1000个字母
static char text[50][1000]; /*输入的字符串缓冲区*/
static int textlen[50];/*输入的字符串长度*/
static double textx, texty; /*当前字符串的起始位置*/
int block_px = 0, block_py = 0;//当前光标所在位置

static bool isBlink = TRUE;   /*是否闪烁标志*/
static bool isDisplayText = FALSE; /*字符串显示标志*/
static bool isBlock = FALSE; /*是否画了光标*/

void KeyboardEventProcess(int key, int event);/*键盘消息回调函数*/
void CharEventProcess(char c);/*字符消息回调函数*/
void TimerEventProcess(int timerID);/*定时器消息回调函数*/

void drawBlock(bool state) {
	bool erasemode = GetEraseMode();
	SetEraseMode(!state);
	StartFilledRegion(1);
	DrawLine(0, GetFontHeight());
	DrawLine(0.05, 0);
	DrawLine(0, -GetFontHeight());
	DrawLine(-0.05, 0);
	EndFilledRegion();
	isBlock = state;
	SetEraseMode(erasemode);
}

void eraseText() {
	double ox = GetCurrentX(), oy = GetCurrentY();
	MovePen(textx, texty);
	SetEraseMode(TRUE);
	DrawTextString(text[block_py]);
	SetEraseMode(FALSE);
	MovePen(ox, oy);
}

void drawText() {
	double ox = GetCurrentX(), oy = GetCurrentY();
	MovePen(textx, texty);
	DrawTextString(text[block_py]);
	MovePen(ox, oy);
}

void moveBlock() {
	char t = text[block_py][block_px];
	text[block_py][block_px] = 0;
	MovePen(textx + TextStringWidth(text[block_py]), texty);
	text[block_py][block_px] = t;
}

void Main() /*仅初始化执行一次*/
{
	InitGraphics();

	registerKeyboardEvent(KeyboardEventProcess);/*注册键盘消息回调函数*/
	registerCharEvent(CharEventProcess);/*注册字符消息回调函数*/
	registerTimerEvent(TimerEventProcess);/*注册定时器消息回调函数*/

	SetPenColor("Black");
	MovePen(0.2, GetWindowHeight()*0.95);
	textx = 0.2;
	texty = GetWindowHeight()*0.95;
	startTimer(TIMER_BLINK500, mseconds500);/*500ms定时器触发*/
	startTimer(TIMER_BLINK1000, mseconds1000);/*1000ms定时器触发*/
}

void KeyboardEventProcess(int key, int event)/*每当产生键盘消息，都要执行*/
{
	double oldradius;

	switch (event) {
	case KEY_DOWN:
		switch (key) {
		case VK_UP:/*UP*/
			if (block_py > 0) {
				if (isBlock) {
					drawBlock(FALSE);
				}
				drawText();
				block_py--;
				if (textlen[block_py] < block_px) {
					block_px = textlen[block_py];
				}
				texty += GetFontHeight();
				if (block_px == 0) {
					MovePen(textx, texty);
				}else
					moveBlock();
			}
			break;
		case VK_DOWN:
			if (block_py < 50) {
				if (isBlock) {
					drawBlock(FALSE);
				}
				drawText();
				block_py++;
				if (textlen[block_py] < block_px) {
					block_px = textlen[block_py];
				}
				texty -= GetFontHeight();
				if (block_px == 0) {
					MovePen(textx, texty);
				}
				else
					moveBlock();
			}
			break;
		case VK_LEFT:
			if (block_px > 0) {
				if (isBlock) {
					drawBlock(FALSE);
				}
				drawText();
				--block_px;
				moveBlock();
			}
			break;
		case VK_RIGHT:
			if (block_px < textlen[block_py]) {
				if (isBlock) {
					drawBlock(FALSE);
				}
				drawText();	
				++block_px;
				moveBlock();
			}
			break;
		}
		break;
	case KEY_UP:
		break;
	}
}

void CharEventProcess(char c)
{
	static char str[2] = { 0, 0 };
	switch (c) {
	case '\r':  /* 注意：回车在这里返回的字符是'\r'，不是'\n'*/
		if (isBlock) {
			drawBlock(FALSE);
		}
		drawText();
		textx = 0.2;/*设置字符串的起始坐标*/
		texty = GetCurrentY() - GetFontHeight();
		MovePen(textx, texty);
		block_py++;
		block_px = 0;
		//int ret = MessageBox(NULL, TEXT(text[block_py]), TEXT("终端窗口"), MB_OK);
		break;
	case 27: /*ESC*/
		break;
	case '\b':
	case 127:
		if (block_px > 0) {
			if (isBlock) {
				drawBlock(FALSE);
			}
			eraseText();
			for (int p1 = block_px; p1 <= textlen[block_py]; p1++)
				text[block_py][p1 - 1] = text[block_py][p1];
			drawText();
			block_px--;
			moveBlock();
			textlen[block_py]--;
		}
		break;
	default:
		str[0] = c;/*形成当前字符的字符串*/
		/*光标在行尾，将当前字符加入到整个字符缓冲区中*/
		if (block_px == textlen[block_py]) {
			text[block_py][textlen[block_py]++] = c;
			text[block_py][textlen[block_py]] = '\0';
			if (isBlock) {
				drawBlock(FALSE);
			}
			DrawTextString(str);/*输出当前字符，且输出位置相应后移*/
		}
		//光标在行中
		else {
			//擦除重写
			if (isBlock) {
				drawBlock(FALSE);
			}
			eraseText();
			//后移
			for (int p1 = textlen[block_py]; p1 >= block_px; --p1)
				text[block_py][p1 + 1] = text[block_py][p1];
			text[block_py][block_px] = c;
			textlen[block_py]++;
			drawText();
		}
		block_px++;
		moveBlock();
		break;
	}
}

void TimerEventProcess(int timerID)
{
	bool erasemode;
	switch (timerID) {
	case TIMER_BLINK500: /*500ms光标闪烁定时器*/
		if (!isBlink) return;
		drawBlock(!isBlock);
		break;
	case TIMER_BLINK1000: /*1000ms光标闪烁定时器*/
		if (!isBlink) return;
		//drawBlock(TRUE);
		break;
	default:
		break;
	}
}
