module Util.Course (CseElt(..),CseArea(..),baseboard,drawBoard) where

import Graphics.Rendering.OpenGL.Raw
import Foreign.C.Types
import System.Random

data CseElt = Fairway | Rough | UnRough | SUPERFairway | Green  | Water | OB
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
  glBegin gl_QUADS
  mapM_ (\k -> do glColor3f (sin (k*0.125)*0.1725+0.35) 0 (sin (k*0.125)*0.1725+0.5) -- possible: (0.5,0.25) (0.5,0.5)
                  glVertex3f (x+k-0.2) y 0
                  glVertex3f (x+k-0.2) (y+h) 0
                  glVertex3f (x+k+0.2) (y+h) 0
                  glVertex3f (x+k+0.2) y 0) [0,0.4..w]
  glEnd
