// begin linguistic game
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include <OpenGL/GL.h>
#include <GLFW/glfw3.h>

#define SZ 1024

#define BASE_HEIGHT 255
#define SEA_LEVEL 127

#define MTITLE 0
#define MSETUP 1

//int seed; int map[SZ][SZ];

//typedef enum { Attract, Repel, Follow, Drift } Action;
//typedef struct { int32_t v; int32_t type; /*Action act;*/ } Cell;
//typedef struct { int32_t x; int32_t y; Cell *cls; } Tile;

typedef struct { GLfloat x; GLfloat y; GLfloat w; GLfloat h; } Rect;
typedef struct { Rect dim; Rect *but; } Window;

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
/*void island(GLfloat x,GLfloat y,GLfloat w,GLfloat h) { glColor4f(0.8,0.95,0.8,1.0);
  glBegin(GL_QUADS); rect(x+0.1,y+0.1,w-0.2,h-0.2); glColor4f(0.6,0.75,0.6,1.0);
  rect(x,y+0.1,0.1,h-0.2); rect(x+0.1,y,w-0.2,0.1); glColor4f(0.55,0.7,0.55,1.0);
  rect(x+0.1,y+h-0.1,w-0.2,0.1); rect(x+w-0.1,y+0.1,0.1,h-0.2); glEnd();
  glBegin(GL_TRIANGLES); tri(x+0.1,y+0.1,-0.1,-0.1); glColor4f(0.45,0.6,0.45,1.0); 
  tri(x+w-0.1,y+0.1,0.1,-0.1); tri(x+0.1,y+h-0.1,-0.1,0.1);
  tri(x+w-0.1,y+h-0.1,0.1,0.1); glEnd(); }*/
void ds_map(int sz,int bmap[sz][sz], int bh, int l, int r, int t, int b) {
  int x_cnt = (r+l)/2; int y_cnt = (t+b)/2;
  int cv = bmap[x_cnt][y_cnt] = (bmap[l][t]+bmap[r][t]+bmap[l][b]+bmap[r][b])/4
    - (rand()%bh-bh/2)/2; //floor((double)rand()/RAND_MAX*bh);
  bmap[x_cnt][t] = ((bmap[l][t]+bmap[r][t])-(rand()%bh-bh/2))/2;
  bmap[x_cnt][b] = ((bmap[l][b]+bmap[r][b])-(rand()%bh-bh/2))/2;
  bmap[l][y_cnt] = ((bmap[l][t]+bmap[l][b])-(rand()%bh-bh/2))/2;
  bmap[r][y_cnt] = ((bmap[r][t]+bmap[r][b])-(rand()%bh-bh/2))/2;
  if(r-l>2) { int nbh = ceil((double)bh*(double)pow(2.0,-0.75));
    ds_map(sz,bmap,nbh,l,x_cnt,t,y_cnt); ds_map(sz,bmap,nbh,x_cnt,r,t,y_cnt);
    ds_map(sz,bmap,nbh,l,x_cnt,y_cnt,b); ds_map(sz,bmap,nbh,x_cnt,r,y_cnt,b); } }

void paint(GLFWwindow *win) { 
  glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); glLoadIdentity();
  glClearColor(0.4,0.4,0.55,1.0);
  //glTranslatef(-c.x/10,-c.y/10,0); //printf("%f, %f, %f\n",c.z,c.x,c.y); 
  /*glBegin(GL_TRIANGLES); glVertex3f(0,0,0); glVertex3f(1,0,0);
  glVertex3f(1,1,0); glVertex3f(0,1,0); glEnd();*/ }

int pressed(GLFWwindow *win,int x) { return glfwGetKey(win,x)!=GLFW_RELEASE; }
int mpressed(GLFWwindow *win, int x) { return glfwGetMouseButton(win,x); }
// making drawing tool
int bhover(GLFWwindow *win, Rect b) { Glfloat x, y;
  glfwGetCursorPos(win,&x,&y); return x>b.x&&x<b.x+b.w&&y>b.y&&y<b.y+b.h; }
int bclick(GLFWwindow *win, Rect b) { 
  return mpressed(win,GLFW_MOUSE_BUTTON_LEFT)&&bhover(win,b); }

int parse_input(GLFWwindow *win, int mode) { Rect ng = { 30, 30, 100, 30 };
  if(mpressed(win,ng)) { return MSETUP; } returm mode; }
  
int main(void) { //cam c = { 0, 0, 0 };
  GLFWwindow* window; int seed = time(NULL); srand(seed); int mode = MTITLE;
  /*map[0][0] = BASE_HEIGHT/2; map[SZ-1][0] = BASE_HEIGHT/2;
  map[SZ-1][SZ-1] = BASE_HEIGHT/2; map[0][SZ-1] = BASE_HEIGHT/2;
  ds_map(SZ,map,BASE_HEIGHT_A,0,SZ-1,SZ-1,0);*/
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
    mode = parse_input(window,mode); glfwSwapBuffers(window); glfwPollEvents(); }
  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS); }
