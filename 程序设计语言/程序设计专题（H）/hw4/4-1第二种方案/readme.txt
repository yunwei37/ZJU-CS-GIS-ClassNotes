版本1：一个非常简单的实现
windows 10 使用vs2017

在igp1的MouseEventProcess中做了如下修改：

在case button_down中
				  if (inBox(mx, my, textx, textx+TextStringWidth(text), 
				                           texty, texty+GetFontHeight())){
				  	  isMoveText = TRUE;
				  }else
				  isMoveCircle = TRUE;
将 isMoveCircle默认设为true；

  在       case MOUSEMOVE中
			  if (isMoveCircle) {
                  //SetEraseMode(TRUE);/*擦除前一个*/
                  //DrawCenteredCircle(ccx, ccy, radius);
				  ccx = mx;
				  ccy = my;
				  omx = mx;
				  omy = my;
				  SetEraseMode(FALSE);/*画新的*/
                  DrawCenteredCircle(ccx, ccy, radius);

直接画新的圆
每个圆点连起来就成了一条线