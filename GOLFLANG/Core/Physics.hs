module Core.Physics (Ball(..),Course(..)) where

import Graphics.Rendering.OpenGL.Raw

-- Ball (x,y) velocity theta height
data Ball = Ball (GLfloat,GLfloat) GLfloat GLfloat GLfloat
-- Course Ball Stroke Par Map
data Course = Course Ball Int Int [Int]

