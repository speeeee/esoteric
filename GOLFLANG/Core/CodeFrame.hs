module Core.CodeFrame (Mode(..),CF(..),Code(..),code) where

import Graphics.Rendering.OpenGL.Raw
import Util.Font

data Mode = WordSelect | Neutral Bool | Transit Bool
          | VelSel Int Bool | TZSel GLfloat deriving (Show,Eq)
data CF = CF { mode :: Mode,
               pos  :: Int,
               code :: Code }

data Code = Sin Code | Cos Code | Square Code | Doub Code | Halve Code
          | Sqrt Code | X deriving (Show,Eq)

code (Code x c) = (case x of Sin -> sin
                             Cos -> cos
                             Doub -> (* 2)
                             Halve -> (/ 2)
                             Square -> (** 2)
                             Cube -> (** 3)
                             Sqrt -> sqrt
                             _ -> id) . c

--codeStr (Code x c) =
