module Core.Physics (Ball(..),Course(..),Board(..)) where

import Graphics.Rendering.OpenGL.Raw

-- Ball (x,y) velocity theta theta-on-y-axis height time function
data Ball = Ball (GLfloat,GLfloat) GLfloat GLfloat GLfloat GLfloat GLfloat (GLfloat -> GLfloat)
-- Board Width Height Map
data Board = Board Int Int [Int]
-- Course Ball Stroke Par Board
data Course = Course Ball Int Int Board

