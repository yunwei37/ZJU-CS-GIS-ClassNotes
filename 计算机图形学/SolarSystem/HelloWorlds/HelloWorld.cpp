// This assignment may cost you some efferts, so I give you some important HINTS, hope that may help you.
// Enjoy the coding and thinking, do pay more attention to the library functions used in OPENGL, such as how they are used? what are the parameters used? and why?

// 实验报告里面多写点感想，即对函数的理解，以及调用的顺序，步骤等。思考为什么是这样子调用的，为什么参数是这样子设置的？。。。等等你觉得值得研究的问题。
#include <stdlib.h>
#include<cmath>
#include<stdlib.h>
#include "glut.h"
#include <windows.h>

using namespace std;
bool bPersp = false;
int year = 0, day = 0, marsYear = 0;
int speed = 12;
float light_angle = 0;
bool bWire = false;
float light_radius = 8.0;
float eye[] = { 5.5, 1.7, 1.7 };
float center[] = { 0, 0, 0 };
int wHeight = 0;
int wWidth = 0;
int state = 1;
GLUquadricObj *g_text;

void lPosition()
{
	float y, z;
	y = light_radius * cos(light_angle);
	z = light_radius * sin(light_angle);
	float light_position[] = { 3.0, y, z, 0.0 };
	glLightfv(GL_LIGHT0, GL_POSITION, light_position);
}

void init(void)
{
	glClearColor(0.0, 0.0, 0.0, 0.0);
	lPosition();
	glShadeModel(GL_SMOOTH);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_COLOR_MATERIAL);
	g_text = gluNewQuadric();
}

void sun()
{
	glPushMatrix();
	glColor3f(1.0f, 0.0f, 0.0f);
	gluSphere(g_text, 0.7, 32, 32);
	glPopMatrix();
}

void earth()
{
	glPushMatrix();
	glColor3f(0.0f, 0.0f, 1.0f);
	glRotatef((float)year / 10, 0.0, 0.0, 1.0);
	glTranslatef(2.1, 0.0, 0.0);
	glRotatef((float)day / 10, 0.0, 0.0, 1.0);
	gluSphere(g_text, 0.25, 20, 16);

	glColor3f(1.0f, 1.0f, 0.0f);
	glRotatef((float)year / 10, 0.0f, 0.0f, 1.0f);
	glRotatef(day / 30.0 * 360.0, 0.0f, 0.0f, 1.0f);
	glTranslatef(0.3f, 0.0f, 0.0f);
	gluSphere(g_text, 0.06, 20, 16);
	glPopMatrix();
}


void redraw(void)
{
	lPosition();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	if (bWire) {
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	}
	else {
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}
	glColor3f(1.0, 1.0, 1.0);
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
	glEnable(GL_TEXTURE_2D);
	sun();
	earth();
	glDisable(GL_TEXTURE_2D);
	glutSwapBuffers();
}

void cPosition()
{
	glLoadIdentity();
	gluLookAt(eye[0], eye[1], eye[2],
		center[0], center[1], center[2],
		0.0, 0.0, 1.0);

}

void updateView(int width, int height)
{

	glViewport(0, 0, (GLsizei)width, (GLsizei)height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	if (!bPersp) {
		gluPerspective(65.0f, (GLfloat)width / (GLfloat)height, 1.0f, 100.0f);
	}
	else {
		glOrtho(-3, 3, -3, 3, -100, 100);
	}
	glMatrixMode(GL_MODELVIEW);
	cPosition();
}

void reshape(int width, int height)
{
	wHeight = height;
	wWidth = width;
	updateView(wWidth, wHeight);

}

void move()
{
	year = (year + 8) % 3600;
	marsYear = (marsYear + 6) % 3600;
	day = (day + 30) % 3600;
}

void keyboard(unsigned char key, int x, int y)
{
	switch (key)
	{
	case 27:
	case 'q': {exit(0); break; }
	case 'p': {bPersp = !bPersp; updateView(wHeight, wWidth); break; }
	case 'o': {bWire = !bWire; break; }
	case 'w': {
		eye[0] += 1;
		center[0] += 1;
		cPosition();
		break;
	}
	case 'a': {
		eye[1] += 1;
		center[1] += 1;
		cPosition();
		break;
	}
	case 's': {
		eye[0] -= 1;
		center[0] -= 1;
		cPosition();
		break;
	}
	case 'd': {
		eye[1] -= 1;
		center[1] -= 1;
		cPosition();
		break;
	}
	case 'z': {
		eye[2] -= 1;
		center[2] -= 1;
		cPosition();
		break;
	}
	case 'c': {
		eye[2] += 1;
		center[2] += 1;
		cPosition();
		break;
	}
	case 'r':
		eye[0] = 5.5;
		eye[1] = 1.7;
		eye[2] = 1.7;
		center[0] = 0;
		center[1] = 0;
		center[2] = 0;
		cPosition();
		break;
	default:
		break;
	}
}

void myIdle(void)
{
	Sleep(speed);
	move();
	glutPostRedisplay();
}

int main(int argc, char **argv)
{

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE);
	glutInitWindowSize(480, 480);
	int windowHandle = glutCreateWindow("Simple GLUT App");
	init();

	glutDisplayFunc(redraw);
	glutReshapeFunc(reshape);
	glutKeyboardFunc(keyboard);
	glutIdleFunc(&myIdle);
	glutMainLoop();
	return 0;
}

