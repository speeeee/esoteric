#include <GLFW/glfw3.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

GLfloat Ax_1[5] = { 0.0, 0.5, 1.0, 0.75, 0.25 };
GLfloat Ay_1[5] = { 0.0, 1.0, 0.0, 0.5, 0.5 };

GLfloat Bx_1[14] = { 0, 0, -4.37114e-08, 0.587785, 0.951057, 0.951057,
                     0.587785, -4.37114e-08, 0.587785, 0.9, 0.951057, 
                     0.951057, 0.587785, -4.37114e-08 };
GLfloat By_1[14] = { 0, 1, 1, 0.952254, 0.827254, 0.672746, 0.547746, 0.5, 
                     0.5, 0.452254, 0.327254, 0.172746, 0.047746, 0.0 };

void drawLetter(int c, GLfloat posx, GLfloat posy, GLfloat skew) {
  if(c=='A') { glBegin(GL_LINE_STRIP);
    for(int i=0; i<(sizeof(Ax_1)/sizeof(GLfloat)); i++) { 
      glVertex2f((Ax_1[i]+posx)/skew,Ay_1[i]+posy); } }
  if(c=='B') { glBegin(GL_LINE_STRIP);
    for(int i=0; i<(sizeof(Bx_1)/sizeof(GLfloat)); i++) {
      glVertex2f((Bx_1[i]+posx)/skew,By_1[i]+posy); } } glEnd(); }

void paint(GLFWwindow *win) {
  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
  glLoadIdentity();
  glTranslatef(-30.0, -30.0, 0.0);
  glBegin(GL_TRIANGLES);
  glColor3f(1.0, 0.0, 0.0);
  glVertex2f(0.0, 0.0);
  glColor3f(0.0, 1.0, 0.0);
  glVertex2f(30.0, 0.0);
  glColor3f(0.0, 0.0, 1.0);
  glVertex2f(0.0, 30.0);
  glEnd();
 
  glColor3f(1.0, 1.0, 1.0);
  drawLetter('A', 10, 10, 1.6);
  drawLetter('B', 11.1, 10, 1.6);
  glFlush();
}
 
void reshape(GLFWwindow *win, int width, int height) {
  glViewport(0, 0, width, height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-30.0, 30.0, -30.0, 30.0, -30.0, 30.0);
  glMatrixMode(GL_MODELVIEW);
}

void initGL(GLFWwindow *win) {
  glShadeModel(GL_SMOOTH); glClearColor(0,0,0,0);
  int w, h; glfwGetFramebufferSize(win, &w, &h);
  reshape(win, w, h); }

int main(void) {
  GLFWwindow* win;
  if (!glfwInit()) { return -1; }

  win = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
  if (!win) {
    glfwTerminate();
    return -1; }

  glfwMakeContextCurrent(win);
  glfwSetWindowRefreshCallback(win,paint);
  glfwSetFramebufferSizeCallback(win,reshape);
  initGL(win);
  while (!glfwWindowShouldClose(win)) {
    glfwSwapBuffers(win);
    paint(win); glfwPollEvents(); }
  glfwTerminate();
  return 0; }