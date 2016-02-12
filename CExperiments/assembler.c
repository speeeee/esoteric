/* bytecode
   op-codes: 00 - push_byte (1 byte, chars)
             01 - push_word (4 bytes, ints, pointers)
             02 - push_dword (8 bytes, doubles, long ints)
             03 - malloc (pushes address to stack) (4 bytes)
             04 - realloc (4 bytes, 4 bytes)
             05 - free   (frees address at top of stack) (4 bytes)
             06 - mov (4 bytes)
             07 - mov_s [stack-only]
             08 - call (4 bytes)
             09 - out (4 bytes)
             0A - in (returns char)
             0B - label

   sample:
   label main        ; labels are unnecessary, but good for gotos. */
   
