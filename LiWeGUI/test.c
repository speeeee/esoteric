#include <GLFW/glfw3.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

GLfloat ax_1[5] = { 0.0, 0.5, 1.0, 0.75, 0.25 };
GLfloat ay_1[5] = { 0.0, 1.0, 0.0, 0.5, 0.5 };

void drawLetter(int c, GLfloat posx, GLfloat posy, GLfloat skew) {
  if(c=='a') { glBegin(GL_LINE_STRIP);
    for(int i=0; i<(sizeof(ax_1)/sizeof(GLfloat)); i++) { 
      glVertex2f((ax_1[i]+posx)/skew,ay_1[i]+posy); } } glEnd(); }

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
  drawLetter('a', 10, 10, 1.6);
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

  /* Initialize the library */
  if (!glfwInit()) { return -1; }

  /* Create a windowed mode window and its OpenGL context */
  win = glfwCreateWindow(640, 480, "Hello World", NULL, NULL);
  if (!win) {
    glfwTerminate();
    return -1; }

  glfwMakeContextCurrent(win);
  glfwSetWindowRefreshCallback(win,paint);
  glfwSetFramebufferSizeCallback(win,reshape);

  initGL(win);

  /* Loop until the user closes the window */
  while (!glfwWindowShouldClose(win)) {
    glfwSwapBuffers(win);
    paint(win); glfwPollEvents(); }

    glfwTerminate();
    return 0; }