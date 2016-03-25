#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <time.h>
#include <math.h>
#include <GLFW/glfw3.h>
#include <OpenGL/GL.h>

#define BASE_HEIGHT 255
#define SEA_LEVEL 127

#define SZ 16

#define ASZX (2.13/SZ)
#define ASZY (2.0/SZ)

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

tile map[2000][2000];
nation nat[1000000];

dcds m_apx[1000] = { { 0,0 }, { 2.13,0 }, { 1,2 } }; int sz = 3;

int amap[SZ][SZ];

//tile smap[20][20];
//nation snat[100];

//int safe_rand(void) { srand(time(NULL)); return rand(); }

void dr(double x, double y, double w, double h) { glBegin(GL_QUADS);
  glVertex3f(x,y,0); glVertex3f(x+w,y,0); glVertex3f(x+w,y+h,0);
  glVertex3f(x,y+h,0); glEnd(); }
void draw_map_appx(void) { for(int i=0;i<pow(SZ,2);i++) {
  if(amap[i%SZ][i/SZ]>=SEA_LEVEL) {
    dr((double)(i%SZ)*ASZX,(double)(i/SZ)*ASZY,ASZX,ASZY); } } }
//void mapp(void) { for(int i=0;i<
void ds_map(int bh, int l, int r, int t, int b) {
  int x_cnt = (r+l)/2; int y_cnt = (t+b)/2;
  int cv = amap[x_cnt][y_cnt] = (amap[l][t]+amap[r][t]+amap[l][b]+amap[r][b])/4
    - (rand()%bh-bh/2)/2; //floor((double)rand()/RAND_MAX*bh);
  amap[x_cnt][t] = ((amap[l][t]+amap[r][t])-(rand()%bh-bh/2))/2;
  amap[x_cnt][b] = ((amap[l][b]+amap[r][b])-(rand()%bh-bh/2))/2;
  amap[l][y_cnt] = ((amap[l][t]+amap[l][b])-(rand()%bh-bh/2))/2;
  amap[r][y_cnt] = ((amap[r][t]+amap[r][b])-(rand()%bh-bh/2))/2;
  if(r-l>2) { int nbh = floor((double)bh*(double)pow(2.0,-0.75));
    ds_map(nbh,l,x_cnt,t,y_cnt); ds_map(nbh,x_cnt,r,t,y_cnt);
    ds_map(nbh,l,x_cnt,y_cnt,b); ds_map(nbh,x_cnt,r,y_cnt,b); } }
void init_map(void) { // not final algorithm!
  for(int i=0;i<4E6;i++) { map[i%2000][i/2000].mval = 0; 
    map[i%2000][i/2000].unit = NONE; int cram = rand()%2; //printf("%i",cram);
    map[i%2000][i/2000].typ = cram+1; } }
void draw_map(void) { glBegin(GL_POINTS);
  for(int i=0;i<4000;i++) { if(map[i%2000][i/2000].typ==LAND) {
    glVertex3f((i%2000)/2000,2-(i/2000)/2000,0); } } glEnd(); }
void tree_(double l,int lim,double tht,double x,double y) { //printf("%g",tht);
  glVertex3f(x+1,y,0); glVertex3f((x+1)+l*cos(tht),y+l*sin(tht),0);
  if(lim) { tree_(l*1/1.818,lim-1,tht-M_PI/4,x+l*cos(tht),y+l*sin(tht));
            tree_(l*1/1.818,lim-1,tht+M_PI/4,x+l*cos(tht),y+l*sin(tht)); } }
void tree(double l,int lim) { tree_(l,lim,M_PI/2,0,0); }
void dsm(int lim,int mag, crds a, crds b, crds c, crds d) {
  crds md = { ((a.x+b.x)/2+(c.x+d.x)/2)/2, ((a.y+c.y)/2+(b.y+d.y)/2)/2 };
  //md.x = md.x + (rand()%100-50); md.y = md.y + (rand()%100-50);
  map[md.x][md.y].typ = SEA; 
  crds ab = { md.x-abs(b.x-a.x)/2,md.y }; crds bb = { md.x,md.y-abs(c.y-a.y)/2 };
  crds cb = { md.x*2-1,md.y }; crds db = { md.x,md.y*2-1 };
  if(lim) { dsm(lim-1,mag/4,ab,bb,cb,db); } }
/*void init_map2(void) { srand(time(NULL));
  crds a = { 0,0 }; crds b = { 1999, 0 }; crds c = { 0, 1999 }; 
  crds d = { 1999, 1999 }; dsm(10,100,a,b,c,d); }*/

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

void paint(GLFWwindow *win) {
  //glRotatef((float) glfwGetTime() * 50.f, 0.f, 0.f, 1.f);
  //glTranslatef(1,0,0);
  /*glBegin(GL_TRIANGLES);
  glColor3f(1.f, 0.f, 0.f);
  glVertex3f(0.f, 0.f, 0.f);
  glColor3f(0.f, 1.f, 0.f);
  glVertex3f(1.2f, 0.f, 0.f);
  glColor3f(0.f, 0.f, 1.f);
  glVertex3f(0.f, 1.f, 0.f); 
  glEnd();*/
  draw_map_appx();
  glBegin(GL_LINES); tree(1,10); glEnd(); }

int main(void) {
  GLFWwindow* window; seed = time(NULL); srand(seed); 
  amap[0][0] = SEA_LEVEL; amap[SZ-1][0] = SEA_LEVEL;
  amap[SZ-1][SZ-1] = SEA_LEVEL; amap[0][SZ-1] = SEA_LEVEL;
  ds_map(BASE_HEIGHT,0,SZ-1,SZ-1,0);
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
  while (!glfwWindowShouldClose(window)) { paint(window);
    glfwSwapBuffers(window); glfwPollEvents(); }
  glfwDestroyWindow(window);
  glfwTerminate();
  exit(EXIT_SUCCESS); }
