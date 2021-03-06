#include <iostream>
#include <string>
#include <stack>
#include <list>

using namespace std;

typedef struct Lit { std::string val; list<struct Lit> *lst;
                                      /*struct Lit **lst;*/ } Lit;

void push_int(int); void push_str(string); void swap(void); void drop(void);
Lit pop();
void RSTK_ADD(void); void RSTK_SUB(void); void RSTK_MUL(void); void RSTK_DIV(void);
void RSTK_LIST_CONS(void); void RSTK_GET_ELEM(void); list<Lit> take(int);

//#define RSTK_LIST_CONS() list<Lit> a = take(stoi(pop().val)); \
//  stk.push((Lit) { "", &a });

#define RSTK_LAMBDA_1 swap(); drop();

std::stack<Lit> stk;

// for calling lambdas, RSTK_CALL/2 is used.  This matches any strings that match
// their respective lambda names.
void RSTK_CALL(string lambda) {
  if(!lambda.compare("RSTK_LAMBDA_1")) { RSTK_LAMBDA_1; } }

Lit pop() { Lit a = stk.top(); stk.pop(); return a; }
list<Lit> take(int x) { list<Lit> lst;
  for(int i=0; i<x; i++) { lst.push_front(pop()); } return lst; }
void drop() { stk.pop(); }
void swap() { Lit a = pop(); Lit b = pop();
              stk.push(a); stk.push(b); }
void push_int(int x) { //char *xstr = itoa(x);
                       string xs = to_string(x);
                       Lit a = (Lit) { xs, NULL }; stk.push(a); }
void push_str(string x) { Lit a = (Lit) { x, NULL }; stk.push(a); }
void RSTK_ADD(void) {
  string a = stk.top().val; stk.pop(); string b = stk.top().val; stk.pop();
  push_int(stoi(a)+stoi(b)); }
void RSTK_SUB(void) {
  string a = stk.top().val; stk.pop(); string b = stk.top().val; stk.pop();
  push_int(stoi(a)-stoi(b)); }
void RSTK_MUL(void) {
  string a = stk.top().val; stk.pop(); string b = stk.top().val; stk.pop();
  push_int(stoi(a)*stoi(b)); }
void RSTK_DIV(void) {
  string a = stk.top().val; stk.pop(); string b = stk.top().val; stk.pop();
  push_int(stoi(a)/stoi(b)); }

void RSTK_LIST_CONS(void) { list<Lit> a = take(stoi(pop().val));
  stk.push((Lit) { "\n", new list<Lit> });
  for(list<Lit>::iterator i=a.begin(); i!=a.end(); ++i) {
    stk.top().lst->push_back(*i); } }
void RSTK_GET_ELEM(void) { int pos = stoi(pop().val);
  Lit l = pop(); list<Lit>::iterator i=l.lst->begin();
  for(int q=0; q<pos; q++, ++i);
  stk.push(*i); }

int main(int argc, char **argv) {
  //Lit a = (Lit) { "1", NULL };
  //stk.push(a);
  push_int(1); push_int(2); RSTK_ADD();
  cout << stk.top().val << endl;
  push_str("hallo"); push_str("hello"); RSTK_CALL("RSTK_LAMBDA_1");
  cout << stk.top().val << endl; pop();
  push_int(1); push_int(2); push_int(2); RSTK_LIST_CONS();
  push_int(0); RSTK_GET_ELEM();
  cout << stk.top().val << endl; }

