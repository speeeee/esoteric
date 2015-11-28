module Core.Physics (Ball(..)) where

import Graphics.Rendering.OpenGL.Raw

-- Ball (x,y) velocity theta
data Ball = Ball (GLfloat,GLfloat) GLfloat GLfloat
