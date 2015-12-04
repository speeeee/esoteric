module Util.Course (CseElt(..),CseArea(..),baseboard,drawBoard,mkCourse) where

import Graphics.Rendering.OpenGL.Raw
import Foreign.C.Types
import System.Random

data CseElt = Fairway | Rough | UnRough | SUPERFairway | Green  | Water
            | Hole | DL | DR | UL | UR deriving (Show,Eq)
data CseArea = Block (GLfloat,GLfloat) GLfloat GLfloat CseElt deriving (Show,Eq)
             -- | Func (GLfloat,GLfloat) (GLfloat -> GLfloat) (GLfloat -> GLfloat) GLfloat CseElt
             -- | SFun (GLfloat,GLfloat) (GLfloat -> GLfloat) GLfloat CseElt

baseboard :: IO [CseArea]
baseboard = do
  x <- randomIO :: IO CFloat
  y <- randomIO :: IO CFloat
  return [Block (-x*250,-y*250) 400 400 Fairway]

getElt x | x==0 = Rough
         | x==1 = UnRough
         | x==2 = Water
getElt _ = Hole

genObjs :: CseArea -> Int -> Int -> [CseArea]
genObjs' :: [CseArea] -> CseArea -> Int -> Int -> [CseArea]
genObjs = genObjs' []
genObjs' n _ _ 0 = n
genObjs' n (Block (x,y) _ _ _) q amt =
  let q'  = fromIntegral $ q `div` (amt^2) `mod` 320
      q2' = fromIntegral $ (q `div` 20+amt) `mod` 80
      q3' = fromIntegral $ q `div` amt `mod` 80
      q4' = fromIntegral $ q `div` (amt^3) `mod` 320 in
  genObjs' ((Block (x+q',y+q4')
                   q3' q2' (getElt $ q `div` amt `mod` 3)):n)
           (Block (x,y) 0 0 Fairway) q (amt-1)

mkCourse :: IO [CseArea]
mkCourse = do
  b <- baseboard
  q <- randomIO :: IO Int
  return (b ++ (genObjs (b!!0) (abs q) (abs $ q `mod` 5+10)))

drawBoard :: CseArea -> IO ()
drawBoard (Block (x,y) w h Fairway) = do
  glBegin gl_QUADS
  mapM_ (\k -> do glColor3f (sin (k*0.125)*0.1725+0.35) 0 (sin (k*0.125)*0.1725+0.5) -- possible: (0.5,0.25) (0.5,0.5)
                  glVertex3f (x+k-0.2) y 0
                  glVertex3f (x+k-0.2) (y+h) 0
                  glVertex3f (x+k+0.2) (y+h) 0
                  glVertex3f (x+k+0.2) y 0) [0,0.4..w]
  glEnd
drawBoard (Block (x,y) w h elt) = do
  glBegin gl_QUADS
  (\(x,y,z) -> glColor3f x y z) $ getCol elt
  mapM_ (\(x',y') -> glVertex3f (x+x') (y+y') 0) [(0,0),(w,0),(w,h),(0,h)]
  glEnd

getCol :: CseElt -> (GLfloat,GLfloat,GLfloat)
getCol x | x==Rough = (0.5,0.3,0.3)
         | x==UnRough = (0.3,0.5,0.5)
         | x==Green = (0.1,0.3,0.1)
         | x==Water = (0.0,0.0,0.3)
         | x==Hole = (0.7,0.7,1)
getCol _ = (0,0,0)
