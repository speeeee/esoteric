module Core.CodeFrame (Mode(..),CF(..),Code(..),mkfn) where

import Graphics.Rendering.OpenGL.Raw
import Util.Font

data Mode = WordSelect | Neutral Bool | Transit Bool
          | VelSel Int Bool | TZSel GLfloat deriving (Show,Eq)
data CF = CF { mode :: Mode,
               pos  :: Int,
               code :: Code }

data Code = Sin Code | Cos Code | Square Code | Doub Code | Halve Code
          | Sqrt Code | X deriving (Show,Eq)

