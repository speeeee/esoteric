USING: kernel opengl.gl sequences locals combinators accessors math ;
IN: staircase.map

TUPLE: tile x y z ;

: coords->iso ( x y z -- ix iy iz ) [ 2dup + 0.5 * ] dip + [ - ] dip 0 ;

! ix = x-y
! iy = z+0.5(x+y)
! iz = 0
