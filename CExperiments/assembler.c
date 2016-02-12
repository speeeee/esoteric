/* bytecode
   op-codes: 00 - pushb (1 byte, chars)
             01 - pushw (4 bytes, ints, pointers)
             02 - pushd (8 bytes, doubles, long ints)
             03 - malloc (pushes address to stack) (4 bytes)
             04 - realloc (4 bytes, 4 bytes)
             05 - free   (frees address at top of stack) (4 bytes)
             06 - mov (4 bytes)
             07 - mov_s [stack-only]
             08 - call (4 bytes)
             09 - out (4 bytes)
             0A - in (returns char)
             0B - label
             0C - ref (references stack by displacement) (4 bytes)
             0D - jns (jump if null stack) (LABEL or 4 bytes)
             0E - jmp (LABEL or 4 bytes)
             0F - terminate
             10 - pop
             11 - out_s
             12 - in_s

   constants: TSTK - always points to the top of the stack. Note that referencing
                     this does not pop.

   sample:
   label end
   terminate
   label main        ; labels are unnecessary, but good for gotos. 
   pushw 32
   pushw 33
   pushw 34
   label loop
   jns end
   out_s
   pop
   jmp loop 
  
   or: 0B 00000000 0F 00000000 0B 00000001 01 00000020 01 00000021 01 00000022
       0B 00000002 0D 00000000 09 00000000 10 00000000 0E 00000002
*/
   
