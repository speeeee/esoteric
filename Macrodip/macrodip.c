#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <GLFW/glfw3.h>
#include <OpenGL/GL.h>

#define NONE 0
#define ARMY 1
#define NAVY 2

#define LAND 0
#define SEA 1
#define DST 2

// radial generation

typedef struct { int mval; int unit; int typ; } tile;
typedef struct { int x; int y; int type; } unit;
typedef struct { char *name; int treas; int *provs; unit *u; } nation;

tile map[2000][2000];
nation nat[1000000];

tile smap[20][20];
nation snat[100];

void init_map(void) { srand(time(NULL)); // not final algorithm!
  for(int i=0;i<4E6;i++) { map[i%2000][i/2000].mval = 0; 
    map[i%2000][i/2000].unit = NONE; map[i%2000][i/2000].typ = rand()%2; } }
void draw_map(void) { glBegin(GL_POINTS);
  for(int i=0;i<4E6;i++) { if(map[i%2000][i/2000].typ==LAND) {
    glVertex3f(1.5*(i%2000)/2000,1.5*(i/2000)/2000,0); } } glEnd(); }

void error_callback(int error, const char* description) {
    fputs(description, stderr); }
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE); }
void setup(GLFWwindow *win) {
  float ratio;
  int width, height;
  glfwGetFramebufferSize(win, &width, &height);
  ratio = width / (float) height;
  glViewport(0, 0, width, height);
  glClear(GL_COLOR_BUFFER_BIT);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-ratio, ratio, -1.f, 1.f, 1.f, -1.f);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity(); }

void paint(GLFWwindow *win) {
  //glRotatef((float) glfwGetTime() * 50.f, 0.f, 0.f, 1.f);
  /*glBegin(GL_TRIANGLES);
  glColor3f(1.f, 0.f, 0.f);
  glVertex3f(-0.6f, -0.4f, 0.f);
  glColor3f(0.f, 1.f, 0.f);
  glVertex3f(0.6f, -0.4f, 0.f);
  glColor3f(0.f, 0.f, 1.f);
  glVertex3f(0.f, 0.6f, 0.f); 
  glEnd();*/
  glTranslatef(-1,-1,0);
  draw_map(); }

int main(void) {
  GLFWwindow* window; init_map();
  glfwSetErrorCallback(error_callback);
  if (!glfwInit()) exit(EXIT_FAILURE);
  window = glfwCreateWindow(800, 800, "Simple example", NULL, NULL);
  if (!window) {
      glfwTerminate();
      exit(EXIT_FAILURE); }
  glfwMakeContextCurrent(window);
  glfwSwapInterval(1);
  glfwSetKeyCallback(window, key_callback); setup(window);
  while (!glfwWindowShouldClose(window)) { paint(window);
    glfwSwapBuffers(window); glfwPollEvents(); }
  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS); }
