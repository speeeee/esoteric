Documentation
====

This documentation will contain a very short tutorial on the use of Elem (being a LISP-style language).  What follows is a language reference, categorized by module.

# Syntax of Elem

## LISP-style syntax

Fortunately, the base of Elem's syntax is based off of LISP.  More specifically, it is based off of the concept of s-expressions.  Usually, s-expressions in LISP have two parts to them: the *head*, and the *tail*.  Take this list for example:

```
(+ 1 2)
```

The head of the list is `+` while the tail is another list, `(1 2)`, the entire expression rewritten as `(+ . (1 2))` where `.` denotes the pairing of a head with a tail.  However, the simplest form of this expression would be `(+ . (1 . (2 . ())))`.  This entire concept will be revisited in more detail when list traversal is explained.  For now, however, another use of s-expressions will be explained.

The above expression has more meaning than just being a list in most LISP-style languages.  In Elem, if the head of a list is also the name of a *function*, then that function will be called where the tail of the list are the arguments of the function.

### Functions

In the last paragraph of the previous section, it was mentioned that the head of a list was the name of a function and the tail of a list were its arguments.  Here is the same example from before:

```
(+ 1 2)
```

For this, it will be assumed that there exists a function named `+` that takes two arguments and returns the sum of the two arguments.  The head of this list is `+`, and the tail of the list is `(1 2)`.  Therefore, the result of this expression would be `3`.  This is, in its most basic form, the idea of the syntax.

The rules of the syntax are also recursive:

```
(+ (+ 1 2) (+ 3 4))
```

The head of the outer-most (or top-most) expression is `+`, and the tail is `((+ 1 2) (+ 3 4))`.  Before evaluating the sum, the expressions `(+ 1 2)` and `(+ 3 4)` are first evaluated, creating the simplified tail, `(3 7)`.  The sum of these two numbers is `10`, which is the final result of the expression.

A way to interpret this syntax is the idea of the syntax as a tree structure.

These concepts form the base syntax of Elem, and are also, for the most part, the end of the similarities between Elem and LISP.