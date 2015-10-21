Documentation
====

This is the documentation of ulang.  This documentation will cover the basics of stack-based programming as well as explaining quotes.  Then, there is a reference of all of the words currently implemented in ulang.

# Documentation

## Basics of a stack-based language

Compared to other types of languages, stack-based languages have a very simplistic syntax.  The syntax of the language is based off of pushing and popping items from a stack.  Pushing to a stack places an item on the top of the stack, while popping removes that top item from the stack.

In a stack-based language, pushing items to a stack is done by simply chaining items in text:

```
1 2 3
```

This represents a stack where the top element is `3` and the following two elements are `2` and `1`.  Any symbol can be pushed to the stack given it is not a defined word, where 'word' is a common name for 'function' in stack-based and other concatenative languages.

When a symbol **is** a defined word, pushing it to the stack instead calls the word.  This process of calling is elaborated on in more detail in the next section, but for now, consider the word, `+`.  In most languages, `+` takes two arguments and then returns the sum of the two.  The way this is represented in most stack-based languages is that when called, `+` will **pop** two elements, and **push** the sum of the two back onto the stack.  The following is a representation of this:

```
1 2 +
~ the result, 3, is pushed to the stack. ~
```

Here, `+` is pushed, popping `1` and `2` to be used as arguments.  The resulting stack is just `3`.  This is the basic idea of stack-based programming languages, including ulang.

## Concatenative languages

Many stack-based languages fall under a category of languages called concatenative languages.  Concatenative languages differ from applicative languages in that the focus of concatenative languages is chaining functions, representing function composition.  

For example, something like `f(g(x))` in an applicative language can be represented as `x g f` in a concatenative language.  This syntax makes it easier to compose functions, since function composition is natural in the language.

Concatenative languages also often point-free languages.  Point-free languages are essentially languages where variables are never explicitly referred to in function definitions.  Instead, functions are composed to construct a new function that is to be applied once called.  This is explained in more detail in the next section.

## Functions and quotes

Functions (or words) are defined in a way that makes no explicit reference to any variables, as mentioned previously.  A function can be defined with the built-in function, `:word`.  `:word` takes two arguments, a name and a **quote**.  

Quotes are essentially ulang's equivalent of lambda expressions in other languages (Joy was the original pioneer of quotes).  In ulang, quotes are represented by any expression enclosed in brackets.  The following is an example of a quote that when called, adds two numbers and then divides a third number by that sum:

```
[+ /]
```

When called, the body of the quote is essentially appended to the stack:

```
1 2 3 [+ /] call
```

However, until then, the quote acts as a literal, much like lambda expressions act as literals in applicative languages.

Functions are defined very simply, in that it is just associating a name with a quote:

```
+/ [+ /] :word
```

After this definition is processed, any occurence of `+/` will call `[+ /]` on the stack.  The following is equivalent to the expression mentioned before:

```
1 2 3 +/
```

This is the basic idea of quotes in ulang.

## Languages reference

Below is a reference of all the words currently implemeted in ulang, sorted by module.

### prelude

All of the standard functions available to the language.  This library should always be imported.

##### dup

`(x -- x x)`

`dup` takes one argument and returns two of that argument back to the stack.

##### over

`(x y -- x y x)`

Takes two arguments and pushes the second argument to the stack.

##### swap

`(x y -- y x)`

Takes two arguments and places them in reverse order onto the stack.

##### call

`(... quot -- ...)`

Same as `0 call@`.

##### if

`(x qa qb -- qa|qb)`

Same as `?`, the result of the conditions are quotes which are called.

### logic

Contains words for manipulating booleans.

##### and

`(x y -- t|f)`

Logical AND for two arguments.

##### or

`(x y -- t|f)`

Logical OR for two arguments.

##### not

`(x -- ~x)`

Logical negation for one argument.

##### positive?

`(x -- t|f)`

Checks if a number is positive.

##### negative?

`(x -- t|f)`

Checks if a number is negative.

### types

The `types` module is usually necessary.  This module is where the static typing of ulang is emulated.  Types are represented in literals as `(Type type literal)`.

##### typed?

`(x -- x|f)`

Tests whether or not the popped element is typed.  If so, the element is just pushed back onto the stack; if not, `False` is returned.

### list

Contains functions for creating and manipulating lists.  Also introduces the `List` type.  In general, the `List` type **must** be used as ulang does not allow untyped lists.

##### cons

`(x lst -- x:lst)`

Creates a new list with `x` as the head and `lst` as the tail.  Also, if `lst` is not a list, it will simply create a pair of the two items.

##### )

`(... -- lst)`

Constructs a list by popping all elements up to the first occurence of `(`, and then creating a list based off of that:

```
(List 1 2 3)
```

##### List?

`(lst -- t|f)`

Checks if the popped argument is of type `List`.

##### length

`(lst -- len)`

Gets the length of a `List`.

##### L@

`(lst n -- x)`

A more `List`-specific version of `@`.

### [BUILT-IN]

These are functions that are built-in to every ulang program.

##### add, sub, div, mul

`(x y -- res)`

Performs each of the four operations, +, -, /, and * based off of their name.
*Use of this function is not recommended*.

##### call@

`(quot n -- ...)`

Calls the quote, `quot`, at index, `n`.
*Use of this function is not recommended*.

##### dr

`(x -- )`

Drops the top-most element of the stack.

##### list?

`(x -- t|f)`

Pops top-most element to check if it is a list (does not necessarily need to be of type `List`).

##### in>

`( -- x)`

Returns a string that is a line from stdin.

##### out

`(x -- )`

Pops an element from the stack and prints it to stdout.

##### @

`(lst n -- x)`

Pushes to the stack the element at the index in the given list.
*Use of this function is not recommended*.

##### <@

`(n -- ...)`

Pushes the value at index `n` in the stack to the front; the original element is not removed.

##### }

`(x y -- lst)`

Constructs a list from the two arguments.

##### :

`(x y -- lst)`
Constructs a list where `x` is the head and `y` is the tail.

##### ?

`(x y z -- y|z)`

If `x`, then `y`, else `z`.

##### =

`(x y -- t|f)`

Tests if the two arguments popped are equal.

##### >codes

`(x -- List)`

Takes any symbol as an argument and returns a list (of type `List`) of the character codes of the symbol.

```
ABC >codes
~ returns (List 65 66 67) ~
```

##### >chars

`(List -- x)`

This is the inverse of `>codes` in that it takes a list (of type `List`) of character codes and transforms them into a symbol.

```
(List 65 66 67) >codes
~ returns ABC ~
```

##### :word

`(name def -- )`

As mentioned before, creates a new function, `name`, with body, `def`.

##### :import

`(name -- )`

Imports the module name popped, so all of the functions defined under that name are accessible.

```
prelude :import
1 2 swap dr dr
```

*Documentation still in progress*