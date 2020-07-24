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

#define deltax 0.03
#define deltay 0.03

#define TIMER_BLINK500  1     /*500ms定时器事件标志号*/
#define TIMER_BLINK1000 2     /*1000ms定时器时间标志号*/

const int mseconds500 = 500;   
const int mseconds1000 = 1000; 

static double ccx = 1.0, ccy = 1.0;/*圆心坐标*/
static double radius = 0.05; /*圆半径*/

static char text[100]; /*输入的字符串缓冲区*/
static int textlen = 0;/*输入的字符串长度*/
static double textx, texty; /*字符串的起始位置*/

static bool isBlink = FALSE;   /*是否闪烁标志*/
static bool isDisplayText = FALSE; /*字符串显示标志*/
static bool isDisplayCircle = TRUE; /*圆显示标志*/

void DrawCenteredCircle(double x, double y, double r);/*画中心圆*/
/*判断点(x0,y0)是否在矩形包围盒(x1, y1) --> (x2, y2)范围内*/
bool inBox(double x0, double y0, double x1, double x2, double y1, double y2);

void KeyboardEventProcess(int key,int event);/*键盘消息回调函数*/
void CharEventProcess(char c);/*字符消息回调函数*/
void MouseEventProcess(int x, int y, int button, int event);/*鼠标消息回调函数*/
void TimerEventProcess(int timerID);/*定时器消息回调函数*/

void Main() /*仅初始化执行一次*/
{
    InitGraphics();        	
	//InitConsole();
	
	registerKeyboardEvent(KeyboardEventProcess);/*注册键盘消息回调函数*/
	registerCharEvent(CharEventProcess);/*注册字符消息回调函数*/
	registerMouseEvent(MouseEventProcess);/*注册鼠标消息回调函数*/
	registerTimerEvent(TimerEventProcess);/*注册定时器消息回调函数*/

	//printf("hello");

	SetPenColor("Red"); 
    SetPenSize(1);
    
    ccx = GetWindowWidth()/2;
    ccy = GetWindowHeight()/2;

    startTimer(TIMER_BLINK500, mseconds500);/*500ms定时器触发*/
    startTimer(TIMER_BLINK1000, mseconds1000);/*1000ms定时器触发*/
}

void DrawCenteredCircle(double x, double y, double r)
{	
	StartFilledRegion(1);
    MovePen(x + r, y);
	//DrawLine(r, r);
    DrawArc(r, 0.0, 360.0);
	EndFilledRegion();
}

void KeyboardEventProcess(int key,int event)/*每当产生键盘消息，都要执行*/
{
 	 double oldradius;
 	 
     switch (event) {
	 	case KEY_DOWN:
			 switch (key) {
			     case VK_UP:/*UP*/
			         SetEraseMode(TRUE);/*擦除前一个*/
                     DrawCenteredCircle(ccx, ccy, radius);
					 ccy += deltay;
					 SetEraseMode(FALSE);/*画新的*/
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_DOWN:
			         SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
					 ccy -= deltay;
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_LEFT:
			         SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
					 ccx -= deltax;
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_RIGHT:
			         SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
					 ccx += deltax;
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_F1:
  					 SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
		 	         SetPenSize(GetPenSize()+1);
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
					 break;
			     case VK_F2:
  					 SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
		 	         SetPenSize(GetPenSize()-1);
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_F3:
			     case VK_PRIOR:
	 	     		 SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     radius += 0.1;
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_F4:
			     case VK_NEXT:
		 	         SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     radius -= 0.1;
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_F5:
                     break;
			     case VK_F6:
                     break;
			     case VK_F9:
			         InitConsole();
			         oldradius = radius;
			         printf("Input radius: ");
			         radius = GetReal();
			         FreeConsole();
  					 SetEraseMode(TRUE);
                     DrawCenteredCircle(ccx, ccy, oldradius);
					 SetEraseMode(FALSE);
                     DrawCenteredCircle(ccx, ccy, radius);
                     break;
			     case VK_ESCAPE:/*设置光标闪烁标志*/
                     isBlink = !isBlink;
                     if (isBlink ) {
						startTimer(TIMER_BLINK500, mseconds500);
						startTimer(TIMER_BLINK1000, mseconds1000);
                     } else {
						cancelTimer(TIMER_BLINK500);
    					cancelTimer(TIMER_BLINK1000);
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
 	 static char str[2] = {0, 0};

     switch (c) {
       case '\r':  /* 注意：回车在这里返回的字符是'\r'，不是'\n'*/
		   isDisplayText = TRUE;/*设置字符串显示标志*/
           textx = GetCurrentX()-TextStringWidth(text);/*设置字符串的起始坐标*/
		   texty = GetCurrentY();
   	 	   break;
 	   case 27: /*ESC*/
 	       break;
      default:
	  	   str[0] = c;/*形成当前字符的字符串*/
	 	   text[textlen++] = c;/*将当前字符加入到整个字符缓冲区中*/
	 	   text[textlen] = '\0';
	 	   DrawTextString(str);/*输出当前字符，且输出位置相应后移*/
	 	   break;
    }
}

bool inBox(double x0, double y0, double x1, double x2, double y1, double y2)
{
	return (x0 >= x1 && x0 <= x2 && y0 >= y1 && y0 <= y2);
}

void MouseEventProcess(int x, int y, int button, int event)
{
 	 static bool isMoveCircle = FALSE;/*移动圆标志*/
 	 static bool isMoveText = FALSE; /*移动文本标志*/ 
	 static bool isChangeRadius = FALSE;/*改变圆半径标志*/
     static double r = 0.2;
 	 static double omx = 0.0, omy = 0.0;
     double mx, my;

 	 mx = ScaleXInches(x);/*pixels --> inches*/
 	 my = ScaleYInches(y);/*pixels --> inches*/

     switch (event) {
         case BUTTON_DOWN:
   		 	  if (button == LEFT_BUTTON) {
				 if (inBox(mx, my, textx, textx+TextStringWidth(text), 
				                           texty, texty+GetFontHeight())){
				  	  isMoveText = TRUE;
				  }else
					 isMoveCircle = TRUE;
			  } else if (button == RIGHT_BUTTON) {
					  isChangeRadius = TRUE;
			  }
		      omx = mx; omy = my;
              break;
    	 case BUTTON_DOUBLECLICK:
			  break;
         case BUTTON_UP:
  		 	  if (button == LEFT_BUTTON) {
  		 	  	isMoveCircle = FALSE;
  		 	  	isMoveText = FALSE;
  		 	  }else if (button == RIGHT_BUTTON) {
  		 	  	isChangeRadius = FALSE;
  		 	  } 
              break;
         case MOUSEMOVE:
			  if (isMoveCircle) {
                  //SetEraseMode(TRUE);/*擦除前一个*/
                  //DrawCenteredCircle(ccx, ccy, radius);
				  ccx = mx;
				  ccy = my;
				  omx = mx;
				  omy = my;
				  //SetEraseMode(FALSE);/*画新的*/
                  DrawCenteredCircle(ccx, ccy, radius);
			  } else if (isChangeRadius) {
                  SetEraseMode(TRUE);/*擦除前一个*/
                  DrawCenteredCircle(ccx, ccy, radius);
				  radius += mx - omx;
				  omx = mx;
				  omy = my;
				  SetEraseMode(FALSE);/*画新的*/
                  DrawCenteredCircle(ccx, ccy, radius);
			  } else if (isMoveText) {
					SetEraseMode(TRUE);
	          		MovePen(textx, texty);/*起始位置*/
					DrawTextString(text);
	 				textx += mx - omx;
					texty += my - omy;
					omx = mx;
					omy = my;				
					SetEraseMode(FALSE);
					MovePen(textx, texty);/*起始位置*/
					DrawTextString(text);
					break;
			  }
              break;
     }	
}

void TimerEventProcess(int timerID)
{
      bool erasemode;

	  switch (timerID) {
	    case TIMER_BLINK500: /*500ms光标闪烁定时器*/
		  if (!isBlink) return;
	      erasemode = GetEraseMode();
          MovePen(textx, texty);/*起始位置*/
		  SetEraseMode(isDisplayText);/*根据当前显示标志来决定是显示还是隐藏字符串*/
		  DrawTextString(text);/*当前位置会随字符串后移*/
	      SetEraseMode(erasemode);
		  isDisplayText = !isDisplayText;/*交替显示/隐藏字符串符号*/
		  break;
	    case TIMER_BLINK1000: /*1000ms光标闪烁定时器*/
		  if (!isBlink) return;
	      erasemode = GetEraseMode();
		  SetEraseMode(isDisplayCircle);
          DrawCenteredCircle(ccx, ccy, radius);
	      SetEraseMode(erasemode);
		  isDisplayCircle = !isDisplayCircle;
		  break;
	    default:
		  break;
	  }
}
