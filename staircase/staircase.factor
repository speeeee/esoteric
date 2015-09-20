USING: kernel math math.rectangles sequences accessors ui ui.gadgets ui.render
       ui.gadgets.worlds opengl.gl opengl.glu game.input.scancodes game.input
       timers calendar ui.pixel-formats combinators ;
IN: staircase

TUPLE: tile x y z ;
TUPLE: stairs-gadget < gadget { map initial: { T{ tile f 0 0 0 } } } timer ;

: resize ( w h -- )
   [ 0 0 ] 2dip glViewport GL_PROJECTION glMatrixMode 
   GL_PROJECTION glMatrixMode
   glLoadIdentity
   -30.0 30.0 -30.0 30.0 -30.0 30.0 glOrtho
   GL_MODELVIEW glMatrixMode ;

! This is a temporary function
: cons-cube ( x y z -- )
  GL_QUADS glBegin
  { [ glVertex3f ] [ 1 0.7098 0.7333 glColor3f drop 0.5 + [ 1 - ] dip 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ]
    [ 1 0.8196 0.9294 glColor3f drop 1.5 + [ 1 - ] dip 0 glVertex3f ] 
    [ drop 1 + 0 glVertex3f ] [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] 
    [ drop 2 + 0 glVertex3f ]
    [ 1 0.7098 0.7333 glColor3f drop 1 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 0.5 + [ 1 + ] dip 0 glVertex3f ]
    [ glVertex3f ] } 3cleave glEnd ;

: draw ( m -- )
  0.9725 0.9216 1.0 0 glClearColor
  GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
  glLoadIdentity
  first { [ x>> ] [ y>> ] [ z>> ] } cleave cons-cube glFlush ;
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
