module Util.Shapes (rect,ball,button) where

import Graphics.Rendering.OpenGL.Raw
import Util.Font

rect x y w h = do
  glBegin gl_QUADS
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w,0),(w,h),(0,h)]
  glEnd

ball x y r = do
  glBegin gl_POLYGON
  mapM_ (\(t) -> glVertex3f (x+r*cos t) (y+r*sin t) 0) $ map ((*) (2*pi)) [0,0.05..1]
  glEnd

button x y w h t s (r,g,b) = do
  glBegin gl_QUADS
  glColor3f r g b
  rect x y w h
  glEnd
  glColor3f (r-0.2) (g-0.2) (b-0.2)
  drawString (x+(w-(5.2*(fromIntegral $ length t)*s))/2,y+(h+5*s)/2) t s

{-cover (x,y,w,h) (r,g,b) wid = do
  glBegin gl_QUADS
  glColor3f r g b
  rect x y w h
  glColor3f (r-0.1) (g-0.1) (b-0.1)
  --rect (x+5) (y+5) w h
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w*wid,h*wid),(w-w*wid,h*wid),(w,0),
                                                  (w,0),(w-w*wid,h*wid),(w-w*wid,h-h*wid),(w,h)]
  glColor3f (r-0.2) (g-0.2) (b-0.2)
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w*wid,h*wid),(w*wid,h-h*wid),(0,h),
                                                  (0,h),(w*wid,h-h*wid),(w-w*wid,h-h*wid),(w,h)]
  glEnd-}
