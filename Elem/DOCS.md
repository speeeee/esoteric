Documentation
====

This documentation will contain a very short tutorial on the use of Elem (being a LISP-style language).  What follows is a reference of the functions that make up the base of Elem.  In the source code of each module there are definitions for every function defined.

# Language

## LISP-style syntax

Fortunately, the base of Elem's syntax is based off of LISP.  More specifically, it is based off of the concept of s-expressions.  Usually, s-expressions in LISP have two parts to them: the *head*, and the *tail*.  Take this list for example:

```
(+ 1 2)
```
**NOTE:** `+` does not exist yet; use `std-add` instead.

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

## Syntax of Elem

Before covering any major differences, it should be noted that in Elem, the top-most part of an expression does not have surrounding parentheses:

```
+ (+ 1 2) (+ 3 4)
```

### Lambda expressions

One of the major components of Elem (and most LISP-style languages) is the lambda expression.  Lambda expressions serve a similar function to functions, but lack a name and are also literals.  Consider the expression at the end of the last section, but now, the arguments for the function are not actually known yet.  That is, the expression would be rewritten like this:

```
+ x y
~ where x and y are unknown values ~
```

Here, neither `x` nor `y` have a defined value, rather they are simply variables.  This could possibly resemble a function, where the inputs are `x` and `y`.  With this in mind, the lambda expression for this can be written as such:

```
\ (x y) (+ x y)
```

(*Note that defining a lambda expression is itself a function: `\`.*)

Essentially, the lambda expression defines two inputs: `x` and `y`, which are the first argument.  The second argument is an expression that involves the variables previously defined.  However, the above expression is technically incomplete.  The lambda expression needs to be applied for it to actually trigger:

```
\ (x y) (+ x y) (1 2)
```

This third argument, `(1 2)`, are the arguments for the lambda expression.  Therefore, the expression is simplified to `(+ 1 2)`, further simplified to `3` (*Note that if the user were to input this expression into the REPL, what would be returned is not the expression in simplest form, as in `3` would not actually be returned.  This is discussed in further detail in the next section*).

At first, this doesn't seem very useful, since the lambda expression simplifies to `(+ 1 2)` anyway.  However, consider the previous lambda expression that lacked the third argument.  If this expression were input into the REPL, it would return an error, since it lacked the third argument it needed.  This is explained in further detail in the next section.  Essentially, the most major idea is that lambda expressions are also literals, meaning that they can be arguments to a function, etc.  However, what can be explained now is the concept of function definition.

Another thing to note is that there is something odd about the arguments for the `\`.  The second argument, `(+ x y)` is *not* evaluated, since if it were, it would try to add the two symbols, `x` and `y`.  This is a lead in to another concept in Elem, which is the control on when Elem evaluates expressions.

### Functions definition

Before beginning, it should be noted that there is another syntax for a simpler type of lambda expression.  Take this lambda expression for example:

```
lambda x (+ x 1) 1
```

This evaluates to `2`.  This is the exact same as `\`, but the first and third arguments are not lists.  `lambda` is just a single-argument version of lambda expressions.  In fact, the definition of `\` uses `lambda`.  Here is the equivalent for `\ (x y) (+ x y) (1 2)`:

```
lambda x (lambda y (+ x y) 1) 2
```

The reasoning for this syntax will be explained in more detail later on; the reason `lambda` is even mentioned is because the syntax for function definition (currently) uses it.

Consider the lambda expression from before, but without the third argument:

```
lambda x (+ x 1)
```

Something to note is that if `lambda` does not have enough arguments, it instead returns itself.  This has some relation to the definition of functions.

Function definition in Elem has a very simple syntax.  In fact, much like other LISP-style languages, function definition is itself a function: `::`.  Here is an example:

```
:: inc (lambda x (+ (car x) 1))
```
**NOTE:** This simple form of function definition is not very safe yet, as it does not account for argument length at all.

`::` takes two arguments: the name of the function, which here it is `inc`, and the body of the function.  The body of a function is a lambda expression; more specifically, the body is a single-argument lambda expression where the single argument is the list of arguments the function is to be called with.  Consider the simple function call from before:

```
+ 1 2
```

Here, `+`, which is the name of the function, is called.  The single argument for the body of the function would be `(1 2)`, meaning that is what the lambda expression's variable.  This is similar to the previous `inc` definition.  The only reference to `x` made in `inc` is the expression, `car x`.  `car`, the name having been borrowed from other LISP-variants, returns the head of a list.  For a list like `(1 2)`, it would return `1`.  From this, it can be determined that the body of `inc` adds `1` to the first argument of the function.  Therefore, `inc 2` would return `3`, where the single argument for the lambda expression is `(2)`.

This is the basic idea of functions in Elem.

### Controlling evaluation

One of the major concepts of Elem is the forced prolonging or evaluation of expressions.  The user is given the option to control evaluation of expressions.  Consider a function that adds `1` to two numbers:

```
:: 2inc (lambda x ((+ (car x) 1) (+ (cadr x) 1)))
~ 'cadr' just returns the second element of a list; the head of the tail. ~
```

When something like `2inc 2 3` is given, what is returned is `((+ (car 2) 1) (+ (cadr 2) 1))`.  This is because by default, lists are not actually evaluated; the user must force evaluation to return the desired result.  This can be done with `p`, which takes an indefinite amount of arguments and evaluates all of them.

```
:: 2inc (lambda x (p (+ (car x) 1) (+ (cadr x) 1)))
```

This will return `(3 4)` when given `2inc 2 3`, as it is expected to.  At first, it may seem odd that the lists are not evaluated by default, but there are times when it is more desirable to stall evaluation.  One of these times would be when an argument is appended to an argument list of an unfinished function call:

```
><: (+ 1) (2)
```
(*`><:` means "append"*)

If the first argument, `(+ 1)`, were to be evaluated, it would return an error.  However, instead, `2` is appended to `(+ 1)`, creating `(+ 1 2)`.  Of course, this is not fully evaluated yet.  This requires another function called `!!:`.  `!!:` forces its first argument to be evaluated.  Here is the completed expression:

```
!!: (><: (+ 1) (2))
```

This returns `3`, as expected.

**NOTE:** Currently (7 November 2015), the actual concept of controlled evaluation is not fully explored yet, as the user is still forced to make a lot of calls to evaluate things.