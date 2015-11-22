L__I_
====

L__I_ is a language that is too early into development to really be calssified as much else than a clone of LISP.  The aim of the language is to create a system where predicates are the norm, much like in a logic language.

Documentation will be added soon, though there exists very brieg documentation of each function in the actual files themselves.  It should be possible, given decent knowledge of LISP's syntax, to be able to apply the functions given.  The only thing to note is that L__I_ uses eager evaluation, which is not usually a problem.  However, when creating lambda expressions, the expression body must not be evaluated on sight.  To stall evaluation, place an element at the beginning of the list (if L__I_ finds an expression where the head doesn't match the name of any function name, it returns itself). 