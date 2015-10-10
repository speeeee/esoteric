Documentation
====

The syntax of wavlang is very simple.  As mentioned before, wavlang is a stack-based language, meaning that all actions done are done with respect to a "stack" of items.

## The stack

The grammar of the language can be essentially be imagined as a stack of items.  With a stack, the only item that can be accessed is the topmost item, and other items are accessed by first removing all items above the desired item.  Imagine the following stack:

```
TOP: 1
     2
     3
```

There are a few base operations that can be made on a stack.  The first of which is `pop`. Here is the resulting stack after calling `pop`:

```
TOP: 2
     3
```

This new stack is the same as the old one, only that the `1` at the top was removed, shifting all other items closer to the top.  This is what `pop` is: removing the top item from the stack.  Later it will be covered what happens to the `pop`ped item.

The opposite of `pop` is `push`, which pushing an item to the top of the stack.  Here is the result of pushing `4` to the stack:

```
TOP: 4
     2
     3
```

With this in mind, it can be determined that stacks are *LIFO queues*.  LIFO stands for Last In, First Out, meaning that the last item to get added to the stack is also the first to come out when called.  

`push` and `pop` are the basic operations that can be performed on a stack.  However, in a stack-based language, these operations are implied.  Here is an example of the above stack written in a stack-based language:

```
3 2 4
```

A stack-based language like wavlang reads from left-to-right, pushing any items it comes across onto the stack.  However, wavlang, and other stack-based languages, have a special use for `pop`.

### Words/Functions

In most stack-based languages, functions (or words) are what `pop`s items from the stack as well as generally manipulate the stack at a higher level than just `push`ing.

Take the function, `+`.  `+` takes two arguments and returns one, which is the sum.  Consider this stack:

```
1 2
```

If `+` were pushed to the stack, it would immediately call `+`.  As mentioned before, `+` first takes two arguments.  It pops two arguments from the stack for use on the function.  Then, it returns the sum, which in a stack-based language, is pushed to the stack:

```
3
```

Essentially, functions pop a certain amount of items from the stack and return a certain amount by pushing them.

In some stack-based languages, including wavlang, a certain notation is used to describe the *stack-effect* of a function.  It simply shows the amount of inputs and the amount of outputs that a certain function has.  For example, `+`'s stack-effect would be written as this: `( x y -- z )`.  Essentially, the notation is `( IN -- OUT )`.

## Reference

This is a reference of the functions available in wavlang.

### Shuffle words

Shuffle words are functions that only modify the stack itself.  The items themselves in the stack do not matter.

#### drop

`( x -- )`

`drop` is a very simple function that takes one argument and discards it.

#### swap

`( x y -- y x )`

Swaps the two top-most items on the stack.

#### dup

`( x -- x x )`

Duplicates the top-most item.

#### $get-at-index

`( n -- x )`

`$get-at-index` takes one argument which is a number representing the index of the item in the stack to be pushed.  This should *never* be used unless it is in the creation of new shuffle words!

### Arithmetic and logical operations

#### +, -, *, /

`( x y -- z )`

Like `+`, all four of these operations do what they would in mathematics.

#### <, >, =

`( x y -- t/f )`

Operations that take two arguments and return a boolean value.

#### and, or

`( t/f t/f -- t/f )`

Logical AND and logical OR.

### Quotation based words

The following two words perform on quotations, which are basically a list of words that are pushed to the stack as literals.  Here is an example:

```
(+ -)
```

This is a quotation that essentially adds two numbers together and subtracts that sum with a third number.  Until actually called, this is just a literal.

#### :word

`( name quot -- )`

This word defines a new word witht the name `name` and the definition defined by `quot`.  Here is an example:

```
inc (1 +) :word
```

This defines a new word, `inc`, which adds `1` to a number.  Stack-effect of `( x -- x+1 )`.  Example usage would be `3 inc` which returns `4`.

#### ?

`( t/f quot quot -- ... )`

This word acts as `if`.  If `t/f` were to be true, the first quotation (from the left) would be called.  If `t/f` were false, then the second quotation is called.

### WAV manipulation

#### wav

`( string -- wav )`

This word takes a string and opens a WAV file of the same name and pushes this to the stack.

#### sample

`( wav a b -- wav )`

This word takes two integers and a WAV file.  It returns a section of the WAV file where the boundaries are the two integers [a,b).

#### shift

`( wav i -- wav )`

Takes an integer and a WAV file and returns a new WAV file pitch shifted by `i`  that is also `1/i` of its size.

#### concur

`( wav wav -- wav )`

Takes two WAV files and returns a new WAV file that is the size of the first two combined containing both of the WAV files playing concurrently.
