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


 bool isDrawLine = FALSE;
 bool isChangeLine = FALSE;
 int lineWidth = 1;
 double omx, omy;

void MouseEventProcess(int x, int y, int button, int event);/*鼠标消息回调函数*/


void Main() /*仅初始化执行一次*/
{
    InitGraphics();        	
	//InitConsole();
	
	registerMouseEvent(MouseEventProcess);/*注册鼠标消息回调函数*/

	//printf("hello");

	SetPenColor("Red"); 
    SetPenSize(lineWidth);
	omx = GetWindowWidth() / 2;
	omy = GetWindowHeight() / 2;
}

void MouseEventProcess(int x, int y, int button, int event)
{
		
     double mx, my;

 	 mx = ScaleXInches(x);/*pixels --> inches*/
 	 my = ScaleYInches(y);/*pixels --> inches*/

     switch (event) {
         case BUTTON_DOWN:
   		 	  if (button == LEFT_BUTTON) {
				  isDrawLine = TRUE;
					MovePen(mx, my);
			  } else if (button == RIGHT_BUTTON) {
				  isChangeLine = TRUE;
			  }
			  omx = mx; omy = my;
              break;
    	 case BUTTON_DOUBLECLICK:
			  break;
         case BUTTON_UP:
  		 	  if (button == LEFT_BUTTON) {
				  isDrawLine = FALSE;
  		 	  }else if (button == RIGHT_BUTTON) {
				  isChangeLine = FALSE;
  		 	  } 
			  omx = mx; omy = my;
              break;
         case MOUSEMOVE:
			 if (isDrawLine) {
				 DrawLine(mx - omx, my - omy);
				 omx = mx;
				 omy = my;
			 }
			 else if (isChangeLine) {
				 lineWidth += omx + omy - mx - my;
				 SetPenSize(lineWidth);
			 }
             break;
     }	
}
