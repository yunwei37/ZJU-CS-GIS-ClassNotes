#define _CRT_SECURE_NO_WARNINGS

#include "graphics.h"  
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <time.h>

FILE* fphzk = NULL; //hzk16字库文件指针

int startX = 0, startY = 0; //文字显示开始位置

const unsigned char* testString = (const unsigned char*)"这是用来测试的一句话。";

//在特定坐标显示单个字符；
// 其中style = 0 为正体，style = 1为斜体， style = 2为倒立;
void ShowCh(int x, int y, unsigned char* zm, int color, int size, int style);

// 加载hzk16字库文件
int loadhzk16(); 

 //从字库中获取一个字的点阵显示模式
void getWord(unsigned char* buffer, unsigned const char* word);

// 输出一个句子，其中style = 0 为正体，style = 1为斜体;
// size为大小；
void showString(int x, int y, const unsigned char* str, int wordCout, int color, int style , int size);  
// 重载版本
void showString(int x, int y, const unsigned char* str, int wordCout, int color);

//从文件中加载并显示字符
void showFileText(int x, int y, const char* filename, int color); 


int main()
{
    if (!loadhzk16()) {
        printf("Can't load the hzk16!\n");
        return 1;
    }
    initgraph(640, 480);

    //默认大小正体显示
    showString(startX, startY, testString, strlen((const char*)testString)/2, WHITE);

    //默认大小正体显示
    const unsigned char* hint = (const unsigned char*)"这是从文件中加载的一段话";
    showString(startX, startY+20, hint, strlen((const char*)hint) / 2, DARKGRAY);

    //从文件中加载显示文本
    showFileText(startX, startY + 40, "test.txt", GREEN);

    //放大2倍显示，黄色，斜体
    showString(startX, startY + 100, testString, strlen((const char*)testString) / 2, YELLOW, 1, 2);

    //放大3倍显示，蓝色，倒立
    showString(startX, startY + 140, testString, strlen((const char*)testString) / 2, BLUE, 2, 3);

    //正常大小显示，白色，斜体倒立
    showString(startX, startY + 200, testString, strlen((const char*)testString) / 2, WHITE, 3, 1);

    //动态显示demo
    int count = 0;
    while (TRUE) {
        showString(startX + count * 3, startY + 220, testString, strlen((const char*)testString) / 2, LIGHTRED);
        Sleep(100);
        showString(startX + count * 3, startY + 220, testString, strlen((const char*)testString) / 2, BLACK);
        count++;
        if (count == 100)
            count = 0;
    }

    _getch();
    closegraph();
    fclose(fphzk);
    return 0;
}

void showFileText(int x, int y, const char* filename, int color) {
    unsigned char buffer[1024];
    int len;
    FILE* f;
    if ((f = fopen(filename, "r")) == NULL) {
        perror("fail to read");
        exit(1);
    }
    while (fgets((char*)buffer, 1024, f) != NULL) {
        len = strlen((const char*)buffer);
        buffer[len - 1] = '\0';
        showString(x, y, buffer, len / 2, color);
        y += 20;
    }
    fclose(f);
}

void showString(int x, int y, const unsigned char* str, int wordCout, int color) {
    showString(x, y, str, wordCout, color, 0, 1);
}

void showString(int x, int y, const unsigned char* str, int wordCout, int color, int style, int size) {
    int i;
    unsigned char buffer[32];
    for (i = 0; i < wordCout; ++i) {
        getWord(buffer, str + 2 * i);
        ShowCh(x, y, buffer, color, size ,style);
        x += 18*size; //默认字间距宽为2
    }
}

void ShowCh(int x, int y,unsigned char* zm, int color, int size, int style)
{
    unsigned char i, j, m, n ,k, h;
    for (i = 0; i < 16; ++i) {  // 16行
        // 逐位测试字模，如果为1，则画点
        for (j = 0; j < 8; j++) { // 每行两字节，每字节8位
            k = ((style & 1) == 0) ? j : j + i / 4;  // 判断斜体
            h = ((style & 2) == 0) ? i : 15 - i;  //判断倒立

            if ((*zm) & (0x80 >> j)) {
                for(m=0;m<size;m++)
                    for(n=0;n<size;n++)
                        putpixel(x + k*size + m , y + h*size + n, color); //第一字节    
            }
            if ((*(zm + 1)) & (0x80 >> j)) {
                for (m = 0; m < size; m++)
                    for (n = 0; n < size; n++)
                        putpixel(x + (8 + k)*size + m, y + h*size + n, color);   //第二字节             
            }
        }
        zm += 2;
    }
}


void getWord(unsigned char* buffer, unsigned const char* word) {
    int offset = (94 * (unsigned int)(word[0] - 0xa0 - 1) + (word[1] - 0xa0 - 1)) * 32;
    fseek(fphzk, offset, SEEK_SET);
    fread(buffer, 1, 32, fphzk);
}

int loadhzk16()
{
    fphzk = fopen("HZK16", "rb");
    if (fphzk == NULL) {
        fprintf(stderr, "error hzk16\n");
        return 0;
    }
    return 1;
}
