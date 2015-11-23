module Util.Shapes (rect) where

import Graphics.Rendering.OpenGL.Raw

rect x y w h = do
  glBegin gl_QUADS
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w,0),(w,h),(0,h)]
  glEnd

cover (x,y,w,h) (r,g,b) wid = do
  glBegin gl_QUADS
  glColor3f r g b
  rect x y w h
  glColor3f (r-0.1) (g-0.1) (b-0.1)
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w*wid,h*wid),(w-w*wid,h*wid),(w,0),
                                                  (w,0),(w-w*wid,h*wid),(w-w*wid,h-h*wid),(w,h)]
  glColor3f (r-0.2) (g-0.2) (b-0.2)
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w*wid,h*wid),(w*wid,h-h*wid),(0,h),
                                                  (0,h),(w*wid,h-h*wid),(w-w*wid,h-h*wid),(w,h)]
  glEnd
