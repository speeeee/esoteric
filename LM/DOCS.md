Documentation
====

This documentation contains a small tutorial on the syntax of LM followed by a complete reference of the rules in the standard library.

# Syntax of LM

Fortunately, LM has a *very* simple base syntax that is easily recognizable.  In fact, at its core, the only data structure in LM is the list.  Here is an example of an LM program:

```
1 (2 3) 4
```

All this is is the list, `(1 (2 3) 4)`, where the element, `(2 3)`, is another list.  Something to note is that the outer-most list's parentheses are omitted.  This is because all LM programs are technically composed of a single list.  However, the lists alone don't have any meaning until a *rule* is applied to them.

## Rules

Rules are used to manipulate lists.  If a given list matches the conditions of a certain rule, the manipulation for the list from the rule is performed.  In the actual language, the definition of a rule requires a lambda expression (*see "lambda expressions" in the language reference).  The lambda expression takes one argument which is the list to-be-tested and returns either a newly manipulated item or `False` if the conditions of the rule are not met.

Here is an example of the condition of a rule being satisfied:

```
car (1 2 3)
~ This will return "1" ~
```

(*Recall that the REPL can be used to evaluate these expressions.  Though for it to print, `std-out` is required: `std-out (car (1 2 3))`*)

Above is the list, `(car (1 2 3))`.  This list would remain the same, but there is actually a rule in the language this list satisfies.  This rule requires a list of size 2 where the first argument is `car`.  The result of this rule is defined to be the first element of the second element of the list, which is `1`.

Rules are similar, in a way, to functions.  However, the main difference is that while functions in most languages have explicit names, LM has patterns that lists would match.

Defining rules is very simple in LM.  Here is an example:

```
rule: (lambda x (if (std-eq (car x) Hello) (std-add 1 (car (cdr x))) False))
```

**NOTE:** This is a very early build of the language being documented, so the syntax may seem awkward.

First, it should be noted that this expression is a rule itself, a rule that requires a list of length 2 with the first element being `rule:`.  As mentioned before, all rules consist of a lambda expression.  Something to note is that all rules' lambda expressions *must* only take a single argument, because this single argument is the list that would be tested.  In the lambda expression body, there is a conditional statement.  The condition of the statement is the test of the given list.  Here, it tests if the first element is `Hello`.  If it is, then the manipulation occurs, where the manipulation in this case simply adds 1 to the second element in the list.  If the condition fails, `False` is returned.

Here is an example of the rule in usage:

```
Hello 3
~ returns 4 ~
```

The list, `Hello 3`, passes the rule of needing `Hello` as the first element, and as a result, `4` is returned.

**NOTE:** This rule is actually slightly unsafe because there is no bounds test to make sure the list is large enough to have a second element.  `Hello` would work, but the program would crash trying to get the non-existant second element.

## Lambda expressions

As mentioned in the last section, the single argument that `rule:` requires is a *lambda expression*.  A lambda expression is essentially a nameless function in that it takes an amount of arguments and then returns something, like functions.

Here is an example of a lambda expression in LM:

```
lambda x (std-add x 1) 1
```
**NOTE:** LM has only implemented lambdas that take only a single argument.  More arguments, however, can be simulated through closures.

The rule starts with `lambda`, which must appear at the beginning.  The next argument, `x`, is the parameter of the lambda.  The body of the lambda is `std-add x 1`, where it can be seen that `x` is used.  This essentially creates a nameless function where its parameters are `x` and the body is `std-add x 1`.  The last argument, `1`, is the value of the parameter.  When put into the REPL, this expression will return `2`.  This is because `x` had equaled `1`, meaning that the final expression was `std-add 1 1` or `2`.

Something important to note is that the expression `std-add x 1` was never evaluated.  This is an important part of LM, that LM does not evaluate expressions until it is required to.  Take this expression for example:

```
((std-add 1 1) (std-sub 1 1) (std-mul 1 1))
```

The result of this should be `(2 0 1)`, but the result when entered into the REPL is simply the same.  None of the three expressions are evaluated since it is not necessary yet to do so.  This is the same case with `lambda`.  Before `std-add x 1` is finally called, all instances of `x` are replaced with `1`, creating and calling `std-add 1 1`.

Here is a possible problem, however.  Consider that there is a lambda the same as the one above, but the value (`1` in the original lambda) was unknown.

```
lambda x (std-add x 1)
```

The first thing to consider is that the new expression does not satisfy the conditions for the `lambda` rule, as it needs three parameters.  Since it is not satisfied, and the list is a builtin rule, the program returns an error.  The rule could be satisfied if a final value were appended to the end of the list.  Later in the next section covers this, as it is possible to better control the evaluation of LM to suit problems.

## Evaluation control



# Language Reference

This is a reference of all of the rules in LM.

## Notation

There is a certain notation to the rules in the reference.  In its simplest form, the notation of each rule is as follows:

```
Input -> Output
```

More specifically, they are the input parameters of each rule and the output of the rule.  Here is a list of the different "terms" in the definitions:

**[TYPE]**– This represents the type of a variable that is part of the rule definition.  However, s of now, LM is typeless.
**_**– This represents a typeless variable.
**()**– Represents a list.
**{}**– Rules that have the same syntax but with slight difference can have these braces.  The braces means "one of these".
**!**– This is used to show rules that should *not* be used unless under specific circumstances.
**?**– A boolean value; `True` or `False`.
**#DONE**– The value returned after any call to a rule returning void.

## Builtin

This is a list of the rules that are built in to every LM program by default.  All of the builtin rules are written in prefix notation.

##### ({std-add std-sub std-mul std-div} _ _) -> _ !

Takes the second and third element of the list and adds/subtracts/multiplies/divides the two.

##### (car _) -> _

`car` takes a list and gets the first element, or the *head*, of the list.  For example, `car (1 2 3)` would return `1`.

##### (cdr _) -> _

`cdr` takes a list and gets all of the elements except for the first, or the *tail*.  For example, `cdr (1 2 3)` would return `(2 3)`.

##### (std-eq _ _) -> ?

Takes two values and tests if they are equal to each other.

```
std-eq 3 (std-add 1 2)
~ returns True ~
```

##### (>codes _) -> _

Takes any symbol and returns a list of the corresponding character codes.

```
>codes ABC
~ returns (65 66 67) ~
```

##### (>chars _) -> _

Inverse of `>codes`

```
>chars (65 66 67)
~ returns ABC ~
```

##### (if _ _ _) -> _

A standard if-else statement constructed of the next three elements of the list.  First element is a condition and if it is satisfied, the second element is executed; if false, the third element is executed.

##### (>in) -> _

Reads a line from stdin and returns it.

##### (std-out _) -> #DONE

Prints the first argument to the standard output stream.

##### (p ...) -> _

A list of expressions to be evaluated.

```
p (std-add 1 2) 2 3
~ returns (3 2 3) ~
```

##### (! ...) -> _

Same as `p`, though after creating the newly evaluated list, the entire list is rule-checked.

```
! (>in) 1 2
~ given the contents of stdin are "std-add", the result would be 3. ~
```

##### (import _) -> #DONE

Imports all of the rules of the filename that is argument one into the current file.

##### (rule: _) -> #DONE

See *Rules* for an explanation.

##### (lambda _ _ _) -> _

See *Lambda expressions* for more detail.

