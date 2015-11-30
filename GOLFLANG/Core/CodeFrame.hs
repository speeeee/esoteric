module Core.CodeFrame (Mode(..),CF(..),Code(..),drawCode) where

import Graphics.Rendering.OpenGL.Raw
import Util.Font

data Mode = WordSelect | Neutral Bool | Transit Bool | VelSel Int Bool deriving (Show,Eq)
data CF = CF { mode :: Mode,
               pos  :: Int,
               code :: Code }

data Code = FunCall String Code | List [Code] | Lit GLfloat | Useless deriving (Show,Eq)

drawCode :: Code -> IO ()
drawCode Useless = do
  drawString (-28.75,27.75) "useless." 0.25
