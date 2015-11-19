module Core.CodeFrame (Mode(..),CF(..)) where

import Graphics.Rendering.OpenGL.Raw

data Mode = WordSelect | Neutral deriving (Show,Eq)
data CF = CF { mode :: Mode,
               code :: Code }

data Code = FunCall String Code | Lit GLfloat deriving (Show,Eq)
