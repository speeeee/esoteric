USING: kernel math math.rectangles sequences accessors ui ui.gadgets ui.render
       ui.gadgets.worlds opengl.gl opengl.glu game.input.scancodes game.input
       timers calendar ui.pixel-formats combinators staircase.map locals ui.gestures 
       arrays sequences.generalizations io io.files io.encodings.utf8 math.vectors
       lists math.parser ui.text fonts io.encodings.string byte-arrays io.pathnames
       unicode.normalize images.loader images grouping namespaces ui.images math.ranges
       A98C14.map ;
IN: A98C14

TUPLE: a98-gadget < gadget map timer { pos initial: { 0 0 } } ;

: resize ( w h -- )
   [ 0 0 ] 2dip glViewport GL_PROJECTION glMatrixMode 
   GL_PROJECTION glMatrixMode
   glLoadIdentity
   -30.0 30.0 -30.0 30.0 -30.0 30.0 glOrtho
   GL_MODELVIEW glMatrixMode ;

: draw ( g -- )
   0.3 0.0 0.4 0 glClearColor
   GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
   30 30 0 glTranslatef
   ! pos>> -1 v*n first2 0 glTranslatef
   glLoadIdentity
   pos>> first2 15 render-node
   0 1 0 glColor3f glFlush ;
   ! GL_QUADS glBegin
   ! 0 0 { [ 0 glVertex3f ] [ [ 1 + ] dip 0 glVertex3f ]
   !      [ [ 1 + ] dip 1 + 0 glVertex3f ] [ 1 + 0 glVertex3f ] } 2cleave
   ! glEnd glFlush ;

:: assess ( g -- )
    read-keyboard keys>> :> k
    key-up-arrow k nth [ g dup pos>> { 0 0.5 } v+ >>pos drop ] when
    key-down-arrow k nth [ g dup pos>> { 0 -0.5 } v+ >>pos drop ] when
    key-left-arrow k nth [ g dup pos>> { -0.5 0 } v+ >>pos drop ] when
    key-right-arrow k nth [ g dup pos>> { 0.5 0 } v+ >>pos drop ] when ;

: tick ( g -- ) relayout-1 ;

M: a98-gadget pref-dim* drop { 800 800 } ;
M: a98-gadget draw-gadget*
   dup rect-bounds nip first2 resize [ assess ] [ draw ] bi ;
M: a98-gadget graft* open-game-input [ [ tick ] curry 16 milliseconds every ] keep timer<< ;
M: a98-gadget ungraft* [ stop-timer f ] change-timer drop ;

: a98-window ( -- ) [ a98-gadget new "Ä98Ç14" open-window ] with-ui ;

! kraken

MAIN: a98-window
