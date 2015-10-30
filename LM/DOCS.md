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

# Language Reference

This is a reference of all of the rules in LM.

## Builtin

This is a list of the rules that are built in to every LM program by default.

##### ({std-add std-sub std-mul std-div} _ _) -> _


