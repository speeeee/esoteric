USING: kernel opengl.gl sequences locals combinators accessors math math.order
       arrays ;
IN: staircase.map

TUPLE: tile x y z t ;

: fetch ( tile -- x y z tile ) { [ x>> ] [ y>> ] [ z>> ] [ t>> ] } cleave ;

: bgc ( -- a b c d ) 0.9725 0.9216 1.0 0 ;
: side-c ( -- a b c ) 1 0.7098 0.7333 ;
: top-c ( -- a b c ) 1 0.8196 0.9294 ;
: ob-c ( -- a b c ) 1 0.7647 0.83135 ;

! This is a temporary function
: cons-cube ( x y z -- )
  GL_QUADS glBegin side-c glColor3f
  { [ glVertex3f ] [ drop 0.5 + [ 1 - ] dip 0 glVertex3f ]
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

: entry ( x y z -- ) side-c glColor3f GL_TRIANGLES glBegin
  { [ glVertex3f ] [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ]
    [ glVertex3f ] [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f 
      glEnd ] [ top-c glColor3f GL_QUADS glBegin drop 1 + 0 glVertex3f ] 
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 2 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ]
    [ side-c glColor3f drop 1.2 + 0 glVertex3f ]
    [ drop 1.5 + [ 0.3 - ] dip 0 glVertex3f ] [ drop 1.8 + 0 glVertex3f ]
    [ drop 1.5 + [ 0.3 + ] dip 0 glVertex3f ] } 3cleave glEnd ;

: end ( x y z -- ) side-c glColor3f 
  { [ cons-cube ] [ GL_QUADS glBegin side-c glColor3f drop 1.2 + 0 glVertex3f ]
    [ drop 1.5 + [ 0.8 - ] dip 0 glVertex3f ] [ drop 1.8 + 0 glVertex3f ]
    [ drop 1.5 + [ 0.8 + ] dip 0 glVertex3f ] } 3cleave glEnd ;

: out ( x y z -- ) 
  { [ cons-cube ] [ GL_QUADS glBegin ob-c glColor3f drop 1 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 2.5 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] } 3cleave glEnd ;

: support ( x y z -- ) GL_QUADS glBegin side-c glColor3f
  { [ glVertex3f ] [ drop 0.5 + [ 1 - ] dip 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ]
    [ glVertex3f ] [ drop 0.5 + [ 1 + ] dip 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ] } 3cleave glEnd ;

: x+ ( x y z -- ) 
  { [ cons-cube ] [ GL_TRIANGLES glBegin side-c glColor3f drop 1.2 + 0 glVertex3f ] 
    [ drop 1.5 + [ 0.7 - ] dip 0 glVertex3f ] [ drop 1.75 + [ 0.3 + ] dip 0 glVertex3f ]
  } 3cleave glEnd ;
: x- ( x y z -- ) 
  { [ cons-cube ] [ GL_TRIANGLES glBegin side-c glColor3f 
                    drop 1.5 + [ 0.6 + ] dip 0 glVertex3f ] 
    [ drop 1.8 + 0 glVertex3f ] [ drop 1.25 + [ 0.3 - ] dip 0 glVertex3f ]
  } 3cleave glEnd ;
: y+ ( x y z -- ) 
  { [ cons-cube ] [ GL_TRIANGLES glBegin side-c glColor3f drop 1.2 + 0 glVertex3f ] 
    [ drop 1.5 + [ 0.8 + ] dip 0 glVertex3f ] [ drop 1.65 + [ 0.4 - ] dip 0 glVertex3f ]
  } 3cleave glEnd ;
: y- ( x y z -- ) 
  { [ cons-cube ] [ GL_TRIANGLES glBegin side-c glColor3f drop 1.8 + 0 glVertex3f ] 
    [ drop 1.5 + [ 0.7 - ] dip 0 glVertex3f ] [ drop 1.35 + [ 0.4 + ] dip 0 glVertex3f ]
  } 3cleave glEnd ;

: eq ( x y z -- )
  { [ cons-cube ] [ side-c glColor3f GL_QUADS glBegin
                    drop 1.25 + [ 0.5 - ] dip 0 glVertex3f ]
    [ drop 1.75 + [ 0.5 - ] dip 0 glVertex3f ] [ drop 1.75 + [ 0.5 + ] dip 0 glVertex3f ]
    [ drop 1.25 + [ 0.5 + ] dip 0 glVertex3f ] } 3cleave glEnd ;
: ne ( x y z -- )
  { [ cons-cube ] [ side-c glColor3f GL_QUADS glBegin
                    drop 1.73 + [ 0.7 - ] dip 0 glVertex3f ]
    [ drop 1.77 + [ 0.3 - ] dip 0 glVertex3f ] [ drop 1.27 + [ 0.7 + ] dip 0 glVertex3f ]
    [ drop 1.23 + [ 0.3 + ] dip 0 glVertex3f ] } 3cleave glEnd ;
: pos ( x y z -- )
  { [ cons-cube ] [ side-c glColor3f GL_QUADS glBegin
                    drop 1.27 + [ 0.7 - ] dip 0 glVertex3f ]
    [ drop 1.23 + [ 0.3 - ] dip 0 glVertex3f ] [ drop 1.73 + [ 0.7 + ] dip 0 glVertex3f ]
    [ drop 1.77 + [ 0.3 + ] dip 0 glVertex3f ] } 3cleave glEnd ;

: outc ( x y z -- ) 
  { [ cons-cube ] [ GL_QUADS glBegin top-c glColor3f drop 1 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] [ drop 2.5 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] } 3cleave glEnd ;
: sto ( x y z -- )
  { [ cons-cube ] [ GL_QUADS glBegin 1 1 1 glColor3f 
                    drop 1.5 + [ 1 - ] dip 0 glVertex3f ] 
    [ drop 1 + 0 glVertex3f ] [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] 
    [ drop 2 + 0 glVertex3f ] } 3cleave glEnd ;
: cal ( x y z -- )
  { [ cons-cube ] [ GL_QUADS glBegin 1 1 1 glColor3f 
                    drop 1.5 + [ 1 - ] dip 0 glVertex3f ] 
    [ drop 1 + 0 glVertex3f ] [ drop 1.5 + [ 1 + ] dip 0 glVertex3f ] 
    [ drop 2.5 + 0 glVertex3f ] } 3cleave glEnd ;
: sub1 ( x y z -- )
  { [ cons-cube ] [ GL_QUADS glBegin side-c glColor3f 
                    drop 2 + 0 glVertex3f ] 
    [ top-c glColor3f drop 1.5 + [ 1 + ] dip 0 glVertex3f ] [ drop 1 + 0 glVertex3f ]
    [ drop 1.5 + [ 1 - ] dip 0 glVertex3f ] } 3cleave glEnd ;


: <cube> ( x y z t -- cc ) tile boa ;

: coords->iso ( x y z -- ix iy iz ) [ 2dup + 0.5 * ] dip + [ - ] dip 0 ;
: coords ( t -- x y z ) { [ x>> ] [ y>> ] [ z>> ] } cleave ;
: 2coords ( t t2 -- x a y b z c ) 
  { [ [ x>> ] dip x>> ] [ [ y>> ] dip y>> ] [ [ z>> ] dip z>> ] } 2cleave ;

: t->v ( t -- v ) coords 3array ;
: v->t ( v -- t ) { [ first ] [ second ] [ third ] } cleave "filler" <cube> ;

! ix = x-y
! iy = z+0.5(x+y)
! iz = 0

: draw-type ( tile -- )
  fetch [ coords->iso ] dip
  { { "cons-cube" [ cons-cube ] } { "cursor" [ cursor ] }
    { "entry" [ entry ] } { "out" [ out ] } 
    { "end" [ end ] } { "support" [ support ] } 
    { "x+" [ x+ ] } { "x-" [ x- ] } { "y+" [ y+ ] } { "y-" [ y- ] }
    { "pos" [ pos ] } { "ne" [ ne ] } { "eq" [ eq ] }
    { "outc" [ outc ] } { "sto" [ sto ] } { "cal" [ cal ] }
    { "sub1" [ sub1 ] } [ 4drop ] } case ;

! greatest x first
! then greatest y
! least z

! highest priority
! z > y = x

! :: interlope ( x y z a b c -- x a y b z c ) x a y b z c ;

! triggers
! tz > mz
! ty > my
! tx > mx

: cmp ( e ti -- ? )
  { [ [ x>> ] dip x>> ] [ [ y>> ] dip y>> ] [ [ z>> ] dip z>> ] } 2cleave
  <=> [ <=> [ <=> ] dip ] dip dup +gt+ = 
  [ [ 2array [ +lt+ = ] any? ] dip +eq+ = and ] dip or ;

:: ins-map ( mp til -- mp' )
   mp [ til cmp ] find drop dup [ til swap mp insert-nth ] curry
   [ mp til suffix ] if ;
