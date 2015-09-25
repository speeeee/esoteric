USING: kernel math math.rectangles sequences accessors ui ui.gadgets ui.render
       ui.gadgets.worlds opengl.gl opengl.glu game.input.scancodes game.input
       timers calendar ui.pixel-formats combinators staircase.map locals ui.gestures 
       arrays sequences.generalizations io io.files io.encodings.utf8 math.vectors
       lists math.parser ;
IN: staircase

CONSTANT: repl-path "/Users/ssallay/Desktop/factor/work/staircase/target.txt"

TUPLE: stairs-gadget < gadget { cursor initial: T{ tile f 0 0 0 "cursor" } }
  { map initial: { T{ tile f 0 0 0 "entry" } } } { iter initial: 0 } 
  { cbs initial: { "cons-cube" } } { curr initial: { 0 } } timer ;

! Parsing data
! Invoke the interpreter by pressing 'r'.

! : find-pt ( m gp -- p ) [ 2coords = [ = [ = ] dip ] dip and and ] curry find nip ;

: find-pt ( m gp -- p ) [ 2coords 2drop = [ = ] dip and ] curry find nip ;

: eval ( g -- ) ! t>> 
  curr>> [ first number>string print ] curry [ repl-path utf8 ] dip
  with-file-appender ; 

: find-next ( m l t -- n ) swap [ dup ] dip swap 
  [ t->v ] bi@ v- -1 v*n swap t->v v+ v->t find-pt ;

:: parse ( l t g -- ) ! g map>> d find-pt :> q
   ! g map>> l t [ t->v ] bi@ v- -1 v*n t t->v v+ v->t find-pt eval ;
   ! g map>> l t find-next dup t [ z>> ] bi@ - g curr<< eval ;
   g eval ;

! Graphical representation of data

: resize ( w h -- )
   [ 0 0 ] 2dip glViewport GL_PROJECTION glMatrixMode 
   GL_PROJECTION glMatrixMode
   glLoadIdentity
   -30.0 30.0 -30.0 30.0 -30.0 30.0 glOrtho
   GL_MODELVIEW glMatrixMode ;

! +
! ++
! Only the two outer ones have sides blocked.

stairs-gadget H{
  { T{ key-down f f "UP" } [ cursor>> dup fetch 2drop nip 1 + >>y drop ] }
  { T{ key-down f f "DOWN" } [ cursor>> dup fetch 2drop nip 1 - >>y drop ] } 
  { T{ key-down f f "LEFT" } [ cursor>> dup fetch 3drop 1 - >>x drop ] } 
  { T{ key-down f f "RIGHT" } [ cursor>> dup fetch 3drop 1 + >>x drop ] }
  { T{ key-down f f "w" } [ cursor>> dup fetch drop [ 2drop ] dip 1 + >>z drop ] }
  { T{ key-down f f "s" } [ cursor>> dup fetch drop [ 2drop ] dip 1 - >>z drop ] }
  { T{ key-down f f "i" } 
       [ dup dup [ map>> ] dip cursor>> coords "cons-cube" <cube> 
         ! 1array append >>map drop 
         ins-map >>map drop ] }
    ! [ dup map>> { T{ tile f 2 2 2 "cons-cube" } } append >>map drop ] }
  { T{ key-down f f "r" } 
    [ [ T{ tile f -1 0 0 "filler" } T{ tile f 0 0 0 "filler" } ] dip parse ] } }
  set-gestures

: draw ( m -- )
  bgc glClearColor
  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
  glLoadIdentity
  ! 5 0 3 coords->iso cons-cube
  ! 0 1 0 coords->iso cons-cube
  ! first { [ x>> ] [ y>> ] [ z>> ] [ t>> ] } cleave draw-type 
  dup map>> [ draw-type ] each
  ! 0 0 1 coords->iso cons-cube
  cursor>> draw-type glFlush ;
  ! 1.0 0.0 0.0 glColor3f GL_QUADS glBegin
  ! -50.0 -50.0 0.0 glVertex3f 50.0 0.0 0.0 glVertex3f
  ! 50.0 50.0 0.0 glVertex3f -50.0 50.0 0.0 glVertex3f glEnd glFlush ;

! : ak ( ka kb k -- ? ) [ dup [ = not ] dip ] dip nth and ;

! :: assess ( g -- )
!   read-keyboard keys>> :> k g kdwn>>
!   { [ key-up-arrow k ak  
!       [ g cursor>> dup fetch 2drop nip 1 + >>y g key-up-arrow >>kdwn 2drop ] when ]
!     [ key-down-arrow k ak
!       [ g cursor>> dup fetch 2drop nip 1 - >>y g key-down-arrow >>kdwn 2drop ] when ]
!     [ key-left-arrow k ak
!       [ g cursor>> dup fetch 3drop 1 - >>x g key-left-arrow >>kdwn 2drop ] when ]
!     [ key-right-arrow k ak
!       [ g cursor>> dup fetch 3drop 1 + >>x g key-right-arrow >>kdwn 2drop ] when ]
!     [ drop k [ g kdwn>> = not ] all? [ g f kdwn<< ] ] }
!   cleave 2drop ;

: tick ( g -- ) relayout-1 ;

M: stairs-gadget pref-dim* drop { 1280 800 } ;
M: stairs-gadget draw-gadget*
   dup rect-bounds nip first2 resize draw ;
M: stairs-gadget graft* open-game-input [ [ tick ] curry 10 milliseconds every ] keep timer<< ;
M: stairs-gadget ungraft* [ stop-timer f ] change-timer drop ;

: stairs-window ( -- ) [ stairs-gadget new "staircase" open-window ] with-ui ;

! MAIN-WINDOW: staircase { { title "staircase" }
!                          { pixel-format-attributes {
!                              windowed
!                              double-buffered
!                             T{ depth-bits { value 16 } } } } } 
 !            stairs-gadget new >>gadgets ;

MAIN: stairs-window
