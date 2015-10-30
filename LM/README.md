LM
====

**LM** is a rule-based programming language based off of pattern matching (**L**ist **M**atching).  It has a somewhat LISP-like syntax.  Rather than a specific syntax for functions, rules can be defined to test the program.  Here is an example:

```
p (rule: (lambda x (if (std-eq (car x) Hello) (std-add 1 (car (cdr x))) False)))
  (Hello 1) 
~ The output is 2. ~
```
(*This can be tested by pasting this statement into the REPL.  It requires the result to be output though.*)

The interpreter was built in Racket.  For documentation on the language, see DOCS.md.