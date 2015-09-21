USING: kernel math math.rectangles sequences accessors ui ui.gadgets ui.render
       ui.gadgets.worlds opengl.gl opengl.glu game.input.scancodes game.input
       timers calendar ui.pixel-formats combinators staircase.map locals ;
IN: staircase

TUPLE: stairs-gadget < gadget { cursor initial: T{ tile f 0 0 0 "cursor" } }
  { map initial: { T{ tile f 0 0 0 "cons-cube" } } } timer ;

: resize ( w h -- )
   [ 0 0 ] 2dip glViewport GL_PROJECTION glMatrixMode 
   GL_PROJECTION glMatrixMode
   glLoadIdentity
   -30.0 30.0 -30.0 30.0 -30.0 30.0 glOrtho
   GL_MODELVIEW glMatrixMode ;

! +
! ++
! Only the two outer ones have sides blocked.

: draw ( m -- )
  bgc glClearColor
  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
  glLoadIdentity
  5 0 3 coords->iso cons-cube
  0 1 0 coords->iso cons-cube
  ! first { [ x>> ] [ y>> ] [ z>> ] [ t>> ] } cleave draw-type 
  dup map>> first draw-type
  0 0 1 coords->iso cons-cube
  cursor>> draw-type glFlush ;
  ! 1.0 0.0 0.0 glColor3f GL_QUADS glBegin
  ! -50.0 -50.0 0.0 glVertex3f 50.0 0.0 0.0 glVertex3f
  ! 50.0 50.0 0.0 glVertex3f -50.0 50.0 0.0 glVertex3f glEnd glFlush ;

:: assess ( g -- )
   read-keyboard keys>> :> k
   key-up-arrow k nth [ g cursor>> dup fetch 2drop nip 1 + >>y drop ] when
   key-down-arrow k nth [ g cursor>> dup fetch 2drop nip 1 - >>y drop ] when
   key-left-arrow k nth [ g cursor>> dup fetch 3drop 1 - >>x drop ] when
   key-right-arrow k nth [ g cursor>> dup fetch 3drop 1 + >>x drop ] when ;

: tick ( g -- ) relayout-1 ;

M: stairs-gadget pref-dim* drop { 1280 800 } ;
M: stairs-gadget draw-gadget*
   dup dup rect-bounds nip first2 resize assess draw ;
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
