module Util.Shapes (rect) where

import Graphics.Rendering.OpenGL.Raw

rect x y w h = do
  glBegin gl_QUADS
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w,0),(w,h),(0,h)]
  glEnd
