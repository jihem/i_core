This is the core engine of a language ('I') and its virtual machine (all of this in PICO-8).
You can extend this engine (see how _SHW or _CLS are implemented).
You can create synonyms for a simplier use (see _ADD and _+).

The programs must be writen in a line. Terms are separated by space.

The engine is stack based (like forth): '5 4 + .' => shows 9

The operators + - * / and flr function are available.
The '#' duplicates the last value (of the stack).

You can evaluate (5 + 4) * (3 + 2) with '5 4 + 3 2 + * .' => 45

Create a sub function

:NAME <sequence of instructions> ;

':A 5 4 + ; :B 3 2 + ; A B * .' => 45

You can call the sub function NAME with its NAME (see A and B in the sample).

Create SQUARE and evaluate 3^2:

':SQUARE # * ; 3 SQUARE .' => 9

Conditional call

?NAME

If the last value in the stack isn't zero it calls NAME else it goes to the next instruction.

This is usefull to create tests and loops:

':SA # . 1 - ; :LP SA # ?LP ; 5 LP 0 .'

Count down from 5 to 0 (then stop).

You can use variables:
>NAME (load value from stack)
<NAME (push value in the stack)

'1 >A <A <A + .' =>2

You can use many :EVAL call to enter your program (one line per call).
You can use as many i_core engines as you want at the same time (object).
You can execute the whole program (:EXEC) or run it :STEP by step.

:STATE returns 3 when done. You can restart with :STATE(0).

If you have read the description so far, you may have a question.
This sounds crazy... So, why?

I'm working on two games. In the first you have to build a program by stacking graphic items to draw on screen to replicate a drawing with the minimal amonth of items. In the second, some robots fight together using genetic algorithms to evolve (by sharing part of their own code to create new ones).

I think I can share this library and my interest in doing this.

Sample of use :
- https://github.com/jihem/i_core/blob/master/i_editor/pico8/i_editor.pdf

jihem

I_C( °)RE is now available in pico8, tic-80, monkey2, cpp and go (last implementation with some extensions and a CLI REPL).
