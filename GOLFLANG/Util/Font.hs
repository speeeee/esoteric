module Util.Font (tinySquare, switchPath, Dir(..)) where

import Graphics.Rendering.OpenGL.Raw

data Dir = DownLeft | DownRight | UpRight | UpLeft

-- "building blocks" for the characters.

-- tinySquare: it is as its name suggests. (0.2×0.2)
tinySquare :: (GLfloat,GLfloat) -> IO ()
tinySquare (x,y) = do
  glColor3f 1 1 1
  glBegin gl_QUADS
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(0.2,0),(0.2,0.2),(0,0.2)]
  glEnd

-- switchPath: curves the suggested path of a line elsewhere.
switchPath :: (GLfloat,GLfloat) -> Dir -> GLfloat -> IO ()
switchPath (x,y) dest s = do
  let lst = map ((*) (pi/2)) [0.05,0.1..0.95]
  glColor3f 1 1 1
  glBegin gl_POLYGON
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0)
    (case dest of DownLeft -> [(0,s),(s,s)] ++ (map (\k -> ((s*cos k),(-s*sin k+s))) lst) ++ [(0,0)]
                  DownRight -> [(0,s),(0,s)] ++ (map (\k -> ((-s*cos k+s),(-s*sin k+s))) lst) ++ [(s,0)]
                  UpLeft -> [(0,0),(s,0)] ++ (map (\k -> ((s*cos k),(s*sin k))) lst) ++ [(0,s)]
                  UpRight -> [(s,0),(0,0)] ++ (map (\k -> ((-s*cos k+s),(s*sin k))) lst) ++ [(s,s)])
  glEnd
