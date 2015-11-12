module Util.Assets (opener) where

import Graphics.Rendering.OpenGL.Raw

drawRect x y w h = mapM_ (\(x,y) -> glVertex3f x y 0) [(x,y),(x+w,y),(x+w,y+h),(x,y+h)]

opener x y s = do
  glBegin gl_POLYGON
  glColor3f 1.0 0.5 0.5
  mapM_ (\(xx,yy) -> glVertex3f (s*(x+xx)) (s*(y+yy)) 0) [(0.4,0),(0.6,0),(1,0.4),(1,0.6),
                                                      (0.6,1),(0.4,1),(0,0.6),(0,0.4)]
  glEnd
  glBegin gl_QUADS
  glColor3f 1 1 1
  drawRect (s*(x+0.2)) (s*(y+0.45)) (s*0.6) (s*0.1)
  drawRect (s*(x+0.45)) (s*(y+0.2)) (s*0.1) (s*0.6)
  glEnd
