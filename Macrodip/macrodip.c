#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <time.h>
#include <math.h>
#include <GLFW/glfw3.h>
#include <OpenGL/GL.h>

#define BASE_HEIGHT_A 255
#define SEA_LEVEL_A 127

#define SZ 2048

#define ASZX (2.13/SZ)
#define ASZY (2.0/SZ)

// map approximation every fourth tile.
#define BSZ (SZ/4)
#define BSZX (2.13/BSZ)
#define BSZY (2.0/BSZ)

#define NONE 0
#define ARMY 1
#define NAVY 2

#define DST 0
#define SEA 1
#define LAND 2

int debug = 0;
int seed;

// radial generation

typedef struct { int mval; int unit; int typ; } tile;
typedef struct { int x; int y; int type; } unit;
typedef struct { char *name; int treas; int *provs; unit *u; } nation;
typedef struct { int x; int y; } crds;
typedef struct { double x; double y; } dcds;
typedef struct { double x; double y; double z; } cam;

int amap[SZ][SZ];
int aamap[BSZ][BSZ];

void dr(double x, double y, double w, double h) { glBegin(GL_QUADS);
  glVertex3f(x,y,0); glVertex3f(x+w,y,0); glVertex3f(x+w,y+h,0);
  glVertex3f(x,y+h,0); glEnd(); }
void draw_map_appx(int sz, int bmap[sz][sz], double ix, double iy, int sl
                  ,int l, int r, int t, int b) { 
  for(int i=0;i<(r-l)*(t-b);i++) { int x = l+i%(r-l); int y = b+i/(t-b);
    if(x>=0&&y>=0&&x<sz&&y<sz&&bmap[x][y]>=sl) {
      dr((double)x*ix,2-(double)y*iy,ix,-iy); } } }
void fill_map(int sz, int csz, int bmap[sz][sz], int cmap[csz][csz]) { 
  int inc = sz/csz; for(int i=0;i<pow(csz,2);i++) { int ii = i*inc;
    cmap[i%csz][i/csz] = bmap[ii%sz][ii/csz]; } }
//void mapp(void) { for(int i=0;i<
void ds_map(int sz,int bmap[sz][sz], int bh, int l, int r, int t, int b) {
  int x_cnt = (r+l)/2; int y_cnt = (t+b)/2;
  int cv = amap[x_cnt][y_cnt] = (amap[l][t]+amap[r][t]+amap[l][b]+amap[r][b])/4
    - (rand()%bh-bh/2)/2; //floor((double)rand()/RAND_MAX*bh);
  bmap[x_cnt][t] = ((bmap[l][t]+bmap[r][t])-(rand()%bh-bh/2))/2;
  bmap[x_cnt][b] = ((bmap[l][b]+bmap[r][b])-(rand()%bh-bh/2))/2;
  bmap[l][y_cnt] = ((bmap[l][t]+bmap[l][b])-(rand()%bh-bh/2))/2;
  bmap[r][y_cnt] = ((bmap[r][t]+bmap[r][b])-(rand()%bh-bh/2))/2;
  if(r-l>2) { int nbh = ceil((double)bh*(double)pow(2.0,-0.75));
    ds_map(sz,bmap,nbh,l,x_cnt,t,y_cnt); ds_map(sz,bmap,nbh,x_cnt,r,t,y_cnt);
    ds_map(sz,bmap,nbh,l,x_cnt,y_cnt,b); ds_map(sz,bmap,nbh,x_cnt,r,y_cnt,b); } }
void tree_(double l,int lim,double tht,double x,double y) { //printf("%g",tht);
  glVertex3f(x+1,y,0); glVertex3f((x+1)+l*cos(tht),y+l*sin(tht),0);
  if(lim) { tree_(l*1/1.818,lim-1,tht-M_PI/4,x+l*cos(tht),y+l*sin(tht));
            tree_(l*1/1.818,lim-1,tht+M_PI/4,x+l*cos(tht),y+l*sin(tht)); } }
void tree(double l,int lim) { tree_(l,lim,M_PI/2,0,0); }

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

void paint(GLFWwindow *win, cam c) { 
  glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); glLoadIdentity();
  glTranslatef(-c.x/10,-c.y/10,0); printf("%f, %f, %f\n",c.z,c.x,c.y); 
  if(c.z>3) { draw_map_appx(SZ,amap,ASZX+2.13/3*c.z/SZ,ASZY+2.0/3*c.z/SZ
                           ,SEA_LEVEL_A,c.x*18,c.x*18+SZ/4
                           ,SZ/4,0); }
  else { draw_map_appx(BSZ,aamap,BSZX+2.13/3*c.z/BSZ,BSZY+2.0/3*c.z/BSZ,SEA_LEVEL_A
                      ,0,BSZ,BSZ,0); }
  glBegin(GL_LINES); tree(1,10); glEnd(); }

int pressed(GLFWwindow *win,int x) { return glfwGetKey(win,x)!=GLFW_RELEASE; }

cam getInput(GLFWwindow *win) { 
  int l = -pressed(win,GLFW_KEY_LEFT); int r = pressed(win,GLFW_KEY_RIGHT);
  int u = pressed(win,GLFW_KEY_UP); int d = -pressed(win,GLFW_KEY_DOWN);
  int i = pressed(win,GLFW_KEY_I); int o = -pressed(win,GLFW_KEY_O);
  return (cam) { l+r,u+d,i+o }; }

cam parse_input(GLFWwindow *win, cam c) {
  cam e = getInput(win); c = (cam){ c.x+e.x, c.y+e.y, c.z+e.z }; return c; }

int main(void) { cam c = { 0, 0, 0 };
  GLFWwindow* window; seed = time(NULL); srand(seed); 
  amap[0][0] = BASE_HEIGHT_A/2; amap[SZ-1][0] = BASE_HEIGHT_A/2;
  amap[SZ-1][SZ-1] = BASE_HEIGHT_A/2; amap[0][SZ-1] = BASE_HEIGHT_A/2;
  ds_map(SZ,amap,BASE_HEIGHT_A,0,SZ-1,SZ-1,0);
  /*aamap[0][0] = BASE_HEIGHT_A/2; aamap[BSZ-1][0] = BASE_HEIGHT_A/2;
  aamap[BSZ-1][BSZ-1] = BASE_HEIGHT_A/2; aamap[0][BSZ-1] = BASE_HEIGHT_A/2;
  ds_map(BSZ,aamap,BASE_HEIGHT_A,0,BSZ-1,BSZ-1,0);*/
  fill_map(2048,512,amap,aamap);
  glfwSetErrorCallback(error_callback);
  if (!glfwInit()) exit(EXIT_FAILURE);
  window = glfwCreateWindow(800, 800, "Macrodip", NULL, NULL);
  if (!window) {
      glfwTerminate();
      exit(EXIT_FAILURE); }
  glfwMakeContextCurrent(window);
  glfwSwapInterval(1);
  glfwSetKeyCallback(window, key_callback); setup(window);
  glfwSetFramebufferSizeCallback(window, rsz);
  while (!glfwWindowShouldClose(window)) { paint(window,c);
    c = parse_input(window,c); glfwSwapBuffers(window); glfwPollEvents(); }
  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS); }
