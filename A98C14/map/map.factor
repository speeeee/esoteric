USING: kernel math sequences opengl.gl math.ranges math.constants math.functions 
       locals ;
IN: A98C14.map

TUPLE: node power culture def disc? rest ;
TUPLE: region name tiles ;

:: render-node ( x y -- ) GL_POLYGON glBegin
    1 141/255 74/255 glColor3f
    20 [0,b) [ 2 pi * swap / ] map 
    [ [ cos ] [ sin ] bi [ x + ] dip y + 0 glVertex3f ] each
    glEnd ;
