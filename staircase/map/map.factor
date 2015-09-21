USING: kernel opengl.gl sequences locals combinators accessors math ;
IN: staircase.map

TUPLE: tile x y z t ;

: fetch ( tile -- x y z tile ) { [ x>> ] [ y>> ] [ z>> ] [ t>> ] } cleave ;

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

: cursor ( x y z -- ) GL_LINE_STRIP glBegin 0 0 1 glColor3f
  { [ glVertex3f ] [ drop 0.5 + [ 1 - ] dip 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 2 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 0.5 + [ 1 + ] dip 0 glVertex3f ]
    [ glVertex3f ] [ drop 1 + 0 glVertex3f ] [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ]
    [ drop 1 + 0 glVertex3f ] [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] } 3cleave glEnd 
  side-c glColor3f ;

: coords->iso ( x y z -- ix iy iz ) [ 2dup + 0.5 * ] dip + [ - ] dip 0 ;

! ix = x-y
! iy = z+0.5(x+y)
! iz = 0

: draw-type ( tile -- )
  fetch [ coords->iso ] dip
  { { "cons-cube" [ cons-cube ] } { "cursor" [ cursor ] } [ 4drop ] } case ;
