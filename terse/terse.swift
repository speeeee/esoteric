// the interpreter so far; just has a simple setup of what is to be done.
// NOTE: the actual GUI compatibility will be done after the interpreter is
//       finished. – 17 February 2016

// MODE: 0 = eval
//       1 = no-eval
//       2 = fun-def

// WARNING: this language will almost certainly run very slowly compared to most others.

// TIP: try "1 2 3 + + ." to test.
//    : try "1 2 [ + } ! ."
//    : try ": pm + - } 1 2 3 pm ."

struct Fun { var name : String; var expr : [String]; }
struct Stk { var mode : Int; var stk : [String]; }

var funs : [Fun] = []

// crashes if "[" does not show.
func popb(q : [String]) -> ([String],[String]) { var i = 0; 
  for i=q.count-1;!(q[i]=="[");i-- { continue; }
  return (Array(q[0..<i]),Array(q[i+1..<q.count])); }
// pops from stack; essentially backwards indexing.
func pop(i : Int, q : [String]) -> String { return q[q.count-1-i]; }
// removes elements from stack.
func rp(i : Int, q : [String]) -> [String] { return Array(q[0..<q.count-i]); }
// unnecessary function, but for some reason Swift deems the contained expression as
//   too "complex" when expressed using the conditional ternary operator.
func funize(s : String) -> ((Double,Double) -> Double) { switch(s) { case "+": return (+); 
  case "-": return (-); case "*": return (*); case "/": return (/); default: return (+); } }

// goes through list of tokens and parses them accordingly.

// 17 Feb 2016
// error: cannot convert return expression of type '(Stk, [[String]])' (aka '(Stk,
//   Array<Array<String>>)') to return type '(Stk, [[String]])' (aka '(Stk, 
//   Array<Array<String>>)')
// not-so-helpful error message that occurs in the all-operators case.
// error fixed.
func parseExpr(e : [String],ep : [String]) -> Stk { return (e.reduce((Stk(mode:0,stk:ep),[] as [[String]]),combine:{ 
  (nz:(Stk,[[String]]),s:String) -> (Stk,[[String]]) in let n = nz.0; switch(n.mode,s) {
  case (0,"["): return (Stk(mode:1,stk:n.stk+[s]),nz.1);
  case (1,"}"): let q = popb(n.stk);
                return (Stk(mode:0,stk:q.0+[String(nz.1.count)]),nz.1+[q.1]);
  case (0,"~"): return (Stk(mode:n.mode,stk:Array(n.stk[0..<n.stk.count-1])),nz.1);
  case (0,"!"): return 
    (parseExpr(nz.1[Int(n.stk.last!)!],ep:Array(n.stk[0..<n.stk.count-1])),nz.1);
  case (0,"+"), (0,"-"), (0,"*"), (0,"/"): 
    let x : String = String((funize(s))(Double(pop(1,q:n.stk))!,Double(n.stk.last!)!));
    return (Stk(mode:0,stk:rp(2,q:n.stk)+[x]),nz.1);
  case (0,"."): print(n.stk.last!,terminator:""); return (Stk(mode:0,stk:rp(1,q:n.stk)),nz.1);
  case (0,":"): return (Stk(mode:2,stk:n.stk+["["]),nz.1);
  case (2,"}"): let q = popb(n.stk); funs += [Fun(name:q.1[0],
                                                  expr:Array(q.1[1..<q.1.count]))];
                return (Stk(mode:0,stk:q.1),nz.1);
  case (0,")"): let q = Int(pop(0,q:n.stk))!; 
                let e = Array(n.stk[n.stk.count-q-1..<n.stk.count-1]);
                return (Stk(mode:0,stk:rp(1,q:n.stk)+e),nz.1);
  case (0,"\\"): let q = nz.1[Int(n.stk.last!)!]; 
  case (0,_): if funs.filter({s == $0.name}).isEmpty {
      return (Stk(mode:n.mode,stk:n.stk+[s]),nz.1); }
    else { let f : Fun = funs[funs.indexOf({$0.name == s})!];
           return (parseExpr(f.expr,ep:n.stk),nz.1); }
  default: return (Stk(mode:n.mode,stk:n.stk+[s]),nz.1); } })).0 }

func parse(s : String) -> Stk { 
  let a = s.characters.split(" ").map({String($0)});
  return parseExpr(a,ep:[]); }

print("> ",terminator:"");
parse(readLine()!).stk.map({ print($0); });