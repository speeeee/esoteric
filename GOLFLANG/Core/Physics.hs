module Core.Physics (Ball(..),Course(..)) where

import Graphics.Rendering.OpenGL.Raw
import Util.Course

-- Ball (x0,y0) (x,y) velocity theta theta-on-z-axis height time function
data Ball = Ball (GLfloat,GLfloat) (GLfloat,GLfloat) GLfloat GLfloat GLfloat GLfloat GLfloat (GLfloat -> GLfloat)
-- Course Ball Stroke Par Board
data Course = Course Ball Int Int [CseArea]

