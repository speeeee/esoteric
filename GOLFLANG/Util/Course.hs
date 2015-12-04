module Util.Course (CseElt(..),CseArea(..),baseboard,drawBoard) where

import Graphics.Rendering.OpenGL.Raw
import Foreign.C.Types
import System.Random

data CseElt = Fairway | Rough | UnRough | Bunker | SUPERFairway | Green  | Water | OB
            | Hole | DL | DR | UL | UR deriving (Show,Eq)
data CseArea = Block (GLfloat,GLfloat) GLfloat GLfloat CseElt
             | Func (GLfloat,GLfloat) (GLfloat -> GLfloat) (GLfloat -> GLfloat) GLfloat CseElt
             | SFun (GLfloat,GLfloat) (GLfloat -> GLfloat) GLfloat CseElt

baseboard :: IO [CseArea]
baseboard = do
  x <- randomIO :: IO CFloat
  y <- randomIO :: IO CFloat
  return [Block (-x*250,-y*250) 400 400 Fairway]

drawBoard :: CseArea -> IO ()
drawBoard (Block (x,y) w h Fairway) = do
  glBegin gl_LINES
  mapM_ (\k -> do glColor3f (sin (k*0.25)*0.5) 0 (cos (k*0.25)*0.5)
                  glVertex3f (x+k) y 0
                  glVertex3f (x+k) (y+h) 0) [0,0.1..w]
  glEnd
