module Core.CodeFrame (Mode(..),CF(..),Code(..)) where

import Graphics.Rendering.OpenGL.Raw

data Mode = WordSelect | Neutral deriving (Show,Eq)
data CF = CF { mode :: Mode,
               pos  :: Int,
               code :: Code }

data Code = FunCall String Code | List [Code] | Lit GLfloat | Useless deriving (Show,Eq)
