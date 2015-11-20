module Core.MouseInput (Hitbox(..),Click(..),inHB,minput) where

import Graphics.Rendering.OpenGL.Raw
import qualified Graphics.UI.GLFW as K

data Hitbox = Hitbox GLfloat GLfloat GLfloat GLfloat deriving (Show,Eq)
data Click = None | LeftC | RightC deriving (Show,Eq)

inHB :: (GLfloat,GLfloat) -> Hitbox -> Bool
inHB (x,y) (Hitbox hx hy w h) = x>=hx&&x<=(hx+w)&&y>=hy&&y<=(hy+h)

--toGLfloat :: Double -> GLfloat
toGLfloat x = realToFrac x::GLfloat
minput :: K.Window -> IO (GLfloat,GLfloat)
minput win = do
  (x,y) <- K.getCursorPos win
  (fx,fy) <- K.getFramebufferSize win
  let (x',y',fx',fy') = (toGLfloat x,toGLfloat y,toGLfloat fx,toGLfloat fy)
  return (x'/fx',y'/fy')

{-minput :: K.Window -> IO (GLfloat,GLfloat)
minput win = do
  (x,y) <- K.getCursorPos win
  return (realToFrac x::GLfloat,realToFrac y::GLfloat)-}
