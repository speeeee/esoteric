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

import UIKit

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
func call(nzx : [String], stk : [String], lnz : [[String]]) -> Stk {
  return parseExpr(nzx,ep:stk,lnz:lnz); }

// goes through list of tokens and parses them accordingly.

// 17 Feb 2016
// error: cannot convert return expression of type '(Stk, [[String]])' (aka '(Stk,
//   Array<Array<String>>)') to return type '(Stk, [[String]])' (aka '(Stk, 
//   Array<Array<String>>)')
// not-so-helpful error message that occurs in the all-operators case.
// error fixed.
func parseExpr(e : [String],ep : [String],lnz : [[String]]) -> Stk { return (e.reduce((Stk(mode:0,stk:ep),lnz),combine:{ 
  (nz:(Stk,[[String]]),s:String) -> (Stk,[[String]]) in let n = nz.0; switch(n.mode,s) {
  case (0,"["): return (Stk(mode:1,stk:n.stk+[s]),nz.1);
  case (1,"}"): let q = popb(n.stk);
                return (Stk(mode:0,stk:q.0+[String(nz.1.count)]),nz.1+[q.1]);
  case (0,"~"): return (Stk(mode:n.mode,stk:Array(n.stk[0..<n.stk.count-1])),nz.1);
  case (0,"!"): return 
    (parseExpr(nz.1[Int(n.stk.last!)!],ep:Array(n.stk[0..<n.stk.count-1]),lnz:[]),nz.1);
  case (0,"+"), (0,"-"), (0,"*"), (0,"/"): 
    let x : String = String((funize(s))(Double(pop(1,q:n.stk))!,Double(n.stk.last!)!));
    return (Stk(mode:0,stk:rp(2,q:n.stk)+[x]),nz.1);
  case (0,"="): let q = Double(n.stk.last!); let e = Double(pop(1,q:n.stk));
                return (Stk(mode:0,stk:rp(2,q:n.stk)+(q==e ? [n.stk.last!] : ["f"])),nz.1);
  case (0,"."): print(n.stk.last!,terminator:""); return (Stk(mode:0,stk:rp(1,q:n.stk)),nz.1);
  case (0,":"): return (Stk(mode:2,stk:n.stk+["["]),nz.1);
  case (2,"}"): let q = popb(n.stk); funs += [Fun(name:q.1[0],
                                                  expr:Array(q.1[1..<q.1.count]))];
                return (Stk(mode:0,stk:[]),nz.1);
  case (0,")"): let q = Int(pop(0,q:n.stk))!; 
                let e = Array(n.stk[n.stk.count-q-1..<n.stk.count-1]);
                return (Stk(mode:0,stk:rp(1,q:n.stk)+e),nz.1);
  case (0,"?"): let q = nz.1[Int(n.stk.last!)!]; let e = nz.1[Int(pop(1,q:n.stk))!];
                let z = pop(2,q:n.stk); 
                if z == "f" { 
                  return (call(q,stk:Array(n.stk[0..<n.stk.count-3]),lnz:[]),nz.1); }
                else { return (call(e,stk:Array(n.stk[0..<n.stk.count-3]),lnz:[]),nz.1); }
  case (0,"\\"): let q = nz.1[Int(n.stk.last!)!];
                 let e : Stk = call(q,stk:rp(1,q:n.stk),lnz:nz.1);
                 if rp(2,q:n.stk).isEmpty { return (Stk(mode:0,stk:rp(2,q:n.stk)),nz.1); }
                 else { return (parseExpr(["\\"],ep:e.stk+[n.stk.last!],lnz:nz.1),nz.1); }
  case (0,_): if funs.filter({s == $0.name}).isEmpty {
      return (Stk(mode:n.mode,stk:n.stk+[s]),nz.1); }
    else { let f : Fun = funs[funs.indexOf({$0.name == s})!];
           return (parseExpr(f.expr,ep:n.stk,lnz:[]),nz.1); }
  default: return (Stk(mode:n.mode,stk:n.stk+[s]),nz.1); } })).0 }

func parse(s : String) -> Stk { 
  let a = s.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: "\n ")).map({String($0)});
  return parseExpr(a,ep:[],lnz:[]); }

func ncmd(n : Int, name : Name, c : [String]) -> Cmd {
    return Cmd(name:name,args:Array(c[c.count-n...c.count-1]).map{(x:String) -> Float in Float(x)!}.map{(x:Float) in CGFloat(x)})
}

let prims : [String] = [",","r","l","c","p"]
func mkCmds(a : [String]) -> [Cmd] { return (a.reduce(([],[]),combine:{
    (c:([Cmd],[String]),s:String) -> ([Cmd],[String]) in
        if prims.filter({s==$0}).isEmpty { return (c.0,c.1+[s]) }
        else { switch(prims[prims.indexOf({$0==s})!]) {
        case ",": return (c.0+[ncmd(2,name:.Pt,c:c.1)],rp(2,q:c.1))
        case "r": return (c.0+[ncmd(4,name:.Rect,c:c.1)],rp(3,q:c.1))
        case "l": return (c.0+[ncmd(4,name:.Line,c:c.1)],rp(3,q:c.1))
        case "c": return (c.0+[ncmd(4,name:.RGBA,c:c.1)],rp(3,q:c.1))
        case "p": return (c.0+[ncmd(c.1.count,name:.Prn,c:c.1)],rp(3,q:c.1))
        default: return c } } }).0) }

//print("> ",terminator:"");
//parse(readLine()!).stk.map({ print($0); });