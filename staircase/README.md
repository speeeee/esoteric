staircase
====

staircase is an esoteric visual programming language.  The language is represented by a model of the sequence of instructions to be performed by the interpreter.  The interpreter itself is written in the language, Factor.

The building program itself works in three dimensions.  The purpose of each dimension is explained later.

# UI reference

This is documentation of the controls of the program itself.

## Basic controls

### Cursor movement

**↑**: move cursor in a positive direction on the y-axis; move up.
**→**: move cursor in a positive direction on the x-axis; move right.
**↓**: move cursor in a negative direction on the y-axis; move down.
**←**: move cursor in a negative direction on the x-axis; move left.
**w**: move cursor in a positive direction on the z-axis.
**s**: move cursor in a negative direction on the z-axis.

### Program modification controls

**i**: place block at current position.
**t**: remove block at current position.
**u**: switch selected block left.
**o**: switch selected block right.
**r**: run current program.

## Managing errors

The interpreter itself is not written to catch any syntactic errors yet, so when an error does appear, the program itself will crash.  Factor will return a message containing the type of error it ran into.

Currently, the only error that should ever appear is when the interpreter attempts to continue on its path (explained in language reference) and finds a non-existant block.  When it does, it returns an error saying that computation cannot be performed on the value, `f`.

# Language reference

This is the language reference (and partially tutorial) for staircase.  It contains definitions for all of the blocks as well as the "syntax" of the language itself.

## Syntax of staircase

The parsing of staircase's syntax is based off of whatever paths are made by blocks in the building program.  The interpreter will follow this path, and when certain blocks are reached, certain instructions will be supplied, and the interpreter will follow these special instructions.  It can be thought of as a slightly different finite state machine.

### The entry-point

Every staircase program defines a single point to be used as the entry-point to the program; it is at the origin, (0,0,0).

![at origin]()

(*The blue outline over the entry-point is the cursor*)

This is where the program begins when it is run (remember, *r*).  However, this program obviously does nothing if it is only an entry-point.

### The axes

Before creating paths is introduced, it should be noted what the axes themselves mean.  As mentioned before, staircase works on a three dimensional grid.  The x- and y-axis together represent position, while the z-axis represents the depth.  There is a reason why this distinction is made, and this is explained when the program state is introduced.

This is a graphical representation of the axes

![axes]()

### Creating paths and the end-point

Paths act as the most basic building block of staircase.  They technically do nothing on their own and only act as a transition between more important blocks (i.e. IO blocks and program state modifiers).

Path blocks look like this:

![path-block]()

**WARNING:** There is another block that looks *very* similar to this one.  However, it has a gradient on the surface, while the path block is a single solid color.

Another block will be introduced here, and that is the end-point block.  This block is a marker of the end of a program, and when the interpreter reaches this block, the program terminates.  Because of this, every program written in staircase *must* have an end-point.

End-point blocks look like this:

![end-point]()

With these blocks, a valid program can be written (really, only the end-point block is needed, but for this, both are used).  Before beginning, it should be noted the direction the program will first start in.  The entry-point of a program will *always* open to the positive *x* direction.  Because of this, the direction that any program begins in is the positive *x* direction.  With this in mind, the following is a valid staircase program:

![valid-prgm]()

Of course, all this program does is begin and end, and there aren't very many useful cases where only the x-axis is available.  Luckily, the next section introduces the z-axis, and later sections explain blocks that change the direction of the path, allowing interaction with the y-axis.

### Program state

Before the z-axis is introduced, there is an important concept to discuss first.  This is the program state.  Essentially, every program has a pair of integers representing its state.  This will be represented as `{ a b }`, where `a` is the *active* integer, and `b` is the *passive* integer.  For now, only the active integer is needed.  Essentially, this state is carried throughout the program, and is used by a variety of blocks.  First, the IO blocks use the current active integer to output text (to `target.txt`) based off of the integer.  The second are blocks that actually modify the state itself.  There are specialized blocks that modify the state, and interactions with the z-axis will also change the program state.

### The z-axis

Unlike the x- and y-axis, the z-axis has a slightly different meaning.  Really, only the x- and y-axis matter to the program as far as positioning goes.  The z-axis actually modifies the program state.  Unless a few certain blocks are used, the depth of a block is also equal to the program state's active integer.  The z-axis essentially acts as an incrementer, where a step up acts as +1 and a step down acts as -1.  The program, when searching for the next block in the path, ignores the z-axis, meaning that as long as the point is next in the path in terms of the x- and y-axis, it is selected.  As a side-effect, the program state is also changed according to this new depth.

Here is an example of using the z-axis:

![z-axis]()

Here, each block in the path is 1 higher than the last in the z-axis.  The final program state in this case is `{ 3 0 }`.  While not shown here, the steps can also be downward, and into the negatives.  Finally, the difference between two depths in a path can be anything, not just 1 or -1.

### The passive integer

So far, the active integer has been referenced, but the passive has been ignored.  The passive integer is not explained here though.  It is rather explained in the "store" and "call" sections in the language reference.  This is because the passive integer is only used by them.  However, the passive integer is very important.

# Docs will be continued later...