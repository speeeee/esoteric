USING: kernel math math.rectangles sequences accessors ui ui.gadgets ui.render
       ui.gadgets.worlds opengl.gl opengl.glu game.input.scancodes game.input
       timers calendar ui.pixel-formats combinators staircase.map ;
IN: staircase

TUPLE: stairs-gadget < gadget { map initial: { T{ tile f 0 0 0 } } } timer ;

: resize ( w h -- )
   [ 0 0 ] 2dip glViewport GL_PROJECTION glMatrixMode 
   GL_PROJECTION glMatrixMode
   glLoadIdentity
   -30.0 30.0 -30.0 30.0 -30.0 30.0 glOrtho
   GL_MODELVIEW glMatrixMode ;

: bgc ( -- a b c d ) 0.9725 0.9216 1.0 0 ;
: side-c ( -- a b c ) 1 0.7098 0.7333 ;
: top-c ( -- a b c ) 1 0.8196 0.9294 ;

! This is a temporary function
: cons-cube ( x y z -- )
  GL_QUADS glBegin
  { [ glVertex3f ] [ side-c glColor3f drop 0.5 + [ 1 - ] dip 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ]
    [ top-c glColor3f drop 1.5 + [ 1 - ] dip 0 glVertex3f ] 
    [ drop 1 + 0 glVertex3f ] [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] 
    [ drop 2 + 0 glVertex3f ]
    [ side-c glColor3f drop 1 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 0.5 + [ 1 + ] dip 0 glVertex3f ]
    [ glVertex3f ] } 3cleave glEnd ;

! +
! ++
! Only the two outer ones have sides blocked.

: draw ( m -- )
  bgc glClearColor
  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
  glLoadIdentity
  5 0 3 coords->iso cons-cube
  0 1 0 coords->iso cons-cube
  first { [ x>> ] [ y>> ] [ z>> ] } cleave coords->iso cons-cube 
  0 0 1 coords->iso cons-cube glFlush ;
  ! 1.0 0.0 0.0 glColor3f GL_QUADS glBegin
  ! -50.0 -50.0 0.0 glVertex3f 50.0 0.0 0.0 glVertex3f
  ! 50.0 50.0 0.0 glVertex3f -50.0 50.0 0.0 glVertex3f glEnd glFlush ;

: tick ( g -- ) relayout-1 ;

M: stairs-gadget pref-dim* drop { 1280 800 } ;
M: stairs-gadget draw-gadget*
   dup rect-bounds nip first2 resize map>> draw ;
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
