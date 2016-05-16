// begin linguistic game
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include <OpenGL/GL.h>
#include <GLFW/glfw3.h>

//typedef enum { Attract, Repel, Follow, Drift } Action;
//typedef struct { int32_t v; int32_t type; /*Action act;*/ } Cell;
//typedef struct { int32_t x; int32_t y; Cell *cls; } Tile;

void error_callback(int error, const char* description) {
    fputs(description, stderr); }
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE); }
void rsz(GLFWwindow *win, int w, int h) {
  glViewport(0,0,w,h); float ratio = w/ (float) h;
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0, 2*ratio, 0, 2.f, 2.f, 0);
  glMatrixMode(GL_MODELVIEW); }

void setup(GLFWwindow *win) {
  float ratio;
  int width, height;
  glfwGetFramebufferSize(win, &width, &height);
  ratio = width / (float) height;
  glViewport(0, 0, width, height);
  glClear(GL_COLOR_BUFFER_BIT);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0, 2*ratio, 0, 2.f, 2.f, 0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity(); }

void rect(GLfloat x,GLfloat y,GLfloat w, GLfloat h) {
  glVertex3f(x,y,0); glVertex3f(x+w,y,0); glVertex3f(x+w,y+h,0); glVertex3f(x,y+h,0); }
void tri(GLfloat x, GLfloat y, GLfloat lx, GLfloat ly) {
  glVertex3f(x,y,0); glVertex3f(x+lx,y,0); glVertex3f(x,y+ly,0); }
void island(GLfloat x,GLfloat y,GLfloat w,GLfloat h) { glColor4f(0.8,0.95,0.8,1.0);
  glBegin(GL_QUADS); rect(x+0.1,y+0.1,w-0.2,h-0.2); glColor4f(0.6,0.75,0.6,1.0);
  rect(x,y+0.1,0.1,h-0.2); rect(x+0.1,y,w-0.2,0.1); glColor4f(0.55,0.7,0.55,1.0);
  rect(x+0.1,y+h-0.1,w-0.2,0.1); rect(x+w-0.1,y+0.1,0.1,h-0.2); glEnd();
  glBegin(GL_TRIANGLES); tri(x+0.1,y+0.1,-0.1,-0.1); glColor4f(0.45,0.6,0.45,1.0); 
  tri(x+w-0.1,y+0.1,0.1,-0.1); tri(x+0.1,y+h-0.1,-0.1,0.1);
  tri(x+w-0.1,y+h-0.1,0.1,0.1); glEnd(); }

void paint(GLFWwindow *win) { 
  glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); glLoadIdentity();
  glClearColor(0.4,0.4,0.55,1.0);
  //glTranslatef(-c.x/10,-c.y/10,0); //printf("%f, %f, %f\n",c.z,c.x,c.y); 
  /*glBegin(GL_TRIANGLES); glVertex3f(0,0,0); glVertex3f(1,0,0);
  glVertex3f(1,1,0); glVertex3f(0,1,0); glEnd();*/
  island(0,0,1,1); }

int pressed(GLFWwindow *win,int x) { return glfwGetKey(win,x)!=GLFW_RELEASE; }

/*cam getInput(GLFWwindow *win) { 
  int l = -pressed(win,GLFW_KEY_LEFT); int r = pressed(win,GLFW_KEY_RIGHT);
  int u = pressed(win,GLFW_KEY_UP); int d = -pressed(win,GLFW_KEY_DOWN);
  int i = pressed(win,GLFW_KEY_I); int o = -pressed(win,GLFW_KEY_O);
  return (cam) { l+r,u+d,i+o }; }*/


/*cam parse_input(GLFWwindow *win, cam c) {
  cam e = getInput(win); c = (cam){ c.x+e.x, c.y+e.y, e.z==0?c.z:1 };
  if(e.z<0) { c = (cam){ 0, 0, 0 }; }
  return c; }*/

int main(void) { //cam c = { 0, 0, 0 };
  GLFWwindow* window; int seed = time(NULL); srand(seed); 
  glfwSetErrorCallback(error_callback);
  if (!glfwInit()) exit(EXIT_FAILURE);
  window = glfwCreateWindow(800, 800, "Fizlang", NULL, NULL);
  if (!window) {
      glfwTerminate();
      exit(EXIT_FAILURE); }
  glfwMakeContextCurrent(window);
  glfwSwapInterval(1);
  glfwSetKeyCallback(window, key_callback); setup(window);
  glfwSetFramebufferSizeCallback(window, rsz);
  while (!glfwWindowShouldClose(window)) { paint(window);
    /*c = parse_input(window,c);*/ glfwSwapBuffers(window); glfwPollEvents(); }
  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS); }
